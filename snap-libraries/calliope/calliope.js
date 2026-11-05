/*
    calliope.js

    Snap! extension for the Calliope mini 3.
    Talks to the Calliope mini Blocks firmware (https://calliope.cc/programmieren/editoren/calliope-mini-blocks-scratch-programmieren) via
      - Web Bluetooth (GATT service 0b50f3e4-...)
      - Web Serial (USB, framed protocol of the same firmware)

    Protocol and logic follow the Calliope mini extension of
    https://github.com/calliope-edu/Scratch-more-v3 (scratch-vm/src/extensions/calliopeMini).

    Requires a Chromium based browser (Chrome, Edge, Chromebook).

    All primitives are registered in SnapExtensions with the prefix "cal_".
    The custom blocks in calliope_module.xml call them.
*/

/*global SnapExtensions, List, Color, Process*/

(function () {
    'use strict';

    if (SnapExtensions.primitives.has('cal_status()')) {
        return; // already loaded
    }

    // ---------------------------------------------------------------------
    // constants (see MbitMoreCommon.h / scratch-vm calliopeMini/index.js)

    var SERVICE = '0b50f3e4-607f-4151-9091-7d008d6ffc5c',
        CH = {
            COMMAND: 0x0100,
            STATE: 0x0101,
            MOTION: 0x0102,
            PIN_EVENT: 0x0110,
            ACTION_EVENT: 0x0111,
            ANALOG_IN: [0x0120, 0x0121, 0x0122],
            MESSAGE: 0x0130
        },
        CMD = {
            CONFIG: 0x00,
            PIN: 0x01,
            DISPLAY: 0x02,
            AUDIO: 0x03,
            DATA: 0x04,
            RGB: 0x05,
            MOTOR: 0x06
        },
        PIN_CMD = {
            SET_OUTPUT: 0x01,
            SET_PWM: 0x02,
            SET_SERVO: 0x03,
            SET_PULL: 0x04,
            SET_EVENT: 0x05
        },
        DISPLAY_CMD = {
            CLEAR: 0x00,
            TEXT: 0x01,
            PIXELS_0: 0x02,
            PIXELS_1: 0x03
        },
        CONFIG_CMD = {MIC: 0x01, TOUCH: 0x02},
        AUDIO_CMD = {STOP_TONE: 0x00, PLAY_TONE: 0x01},
        MOTOR_CMD = {M0: 0x01, M1: 0x02, M0_M1: 0x03},
        DATA_FORMAT = {PIN_EVENT: 0x11, ACTION_EVENT: 0x12,
            DATA_NUMBER: 0x13, DATA_TEXT: 0x14},
        ACTION_EVENT = {BUTTON: 0x01, GESTURE: 0x02},
        PULL = {NONE: 0, DOWN: 1, UP: 2},
        PIN_EVENT_TYPE = {NONE: 0, ON_EDGE: 1, ON_PULSE: 2, ON_TOUCH: 3},
        PIN_EVENT = {RISE: 2, FALL: 3, PULSE_HIGH: 4, PULSE_LOW: 5},
        HW_V1 = 1,
        ROUTE_SERIAL = 1,
        BUTTON_ID = {1: 'A', 2: 'B', 100: 'P0', 101: 'P1', 102: 'P2',
            103: 'P3', 121: 'LOGO'},
        BUTTON_STATE_INDEX = {P0: 0, P1: 1, P2: 2, P3: 3, A: 4, B: 5, LOGO: 6},
        BUTTON_PIN_INDEX = {P0: 0, P1: 1, P2: 2, P3: 3},
        BUTTON_EVENT_ID = {1: 'DOWN', 2: 'UP', 3: 'CLICK', 4: 'LONG_CLICK',
            5: 'HOLD', 6: 'DOUBLE_CLICK'},
        GESTURE_ID = {1: 'TILT_UP', 2: 'TILT_DOWN', 3: 'TILT_LEFT',
            4: 'TILT_RIGHT', 5: 'FACE_UP', 6: 'FACE_DOWN', 7: 'FREEFALL',
            8: 'G3', 9: 'G6', 10: 'G8', 11: 'SHAKE'},
        GPIO = [0, 1, 2, 3, 8, 9, 12, 13, 14, 15, 16, 17],
        G = 1024,
        DATA_TIMEOUT = 4500, // ms without data => connection lost
        USB_FILTER = {usbVendorId: 0x0d28, usbProductId: 0x0204},
        SERIAL_SFD = 0xFF,
        SERIAL_REQ = {READ: 0x01, WRITE: 0x10, WRITE_RESPONSE: 0x11},
        SERIAL_RES = {READ: 0x01, WRITE_RESPONSE: 0x11, NOTIFY: 0x21};

    function uuid(ch) {
        return '0b50' + ch.toString(16).padStart(4, '0') +
            '-607f-4151-9091-7d008d6ffc5c';
    }

    var lastStamp = 0;

    function stamp() {
        // strictly increasing timestamps, so equal events never collide
        lastStamp = Math.max(Date.now(), lastStamp + 1);
        return lastStamp;
    }

    function sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    function clamp(n, min, max) {
        return Math.max(min, Math.min(max, n));
    }

    function num(x, fallback) {
        var n = Number(x);
        return isNaN(n) ? (fallback || 0) : n;
    }

    // ---------------------------------------------------------------------
    // BLE transport (Web Bluetooth)

    function BleTransport() {
        this.device = null;
        this.server = null;
        this.chars = {};
        this.queue = Promise.resolve();
        this.onDisconnect = null;
        this.streamsState = false; // state/motion have to be polled
    }

    BleTransport.prototype.connect = async function () {
        if (!navigator.bluetooth) {
            throw new Error('Web Bluetooth wird von diesem Browser ' +
                'nicht unterstützt. Bitte Chrome oder Edge verwenden.');
        }
        this.device = await navigator.bluetooth.requestDevice({
            filters: [
                {namePrefix: 'Calliope mini'},
                {namePrefix: 'BBC micro:bit'},
                {services: [SERVICE]}
            ],
            optionalServices: [SERVICE]
        });
        this.device.addEventListener(
            'gattserverdisconnected',
            () => this.handleDisconnect()
        );
        this.server = await this.device.gatt.connect();
        var service = await this.server.getPrimaryService(SERVICE),
            list = await service.getCharacteristics();
        list.forEach(c => {
            this.chars[parseInt(c.uuid.slice(4, 8), 16)] = c;
        });
    };

    BleTransport.prototype.enqueue = function (job) {
        // GATT operations must not overlap
        var result = this.queue.then(job);
        this.queue = result.catch(() => null);
        return result;
    };

    BleTransport.prototype.read = function (ch) {
        return this.enqueue(async () => {
            var c = this.chars[ch];
            if (!c) {throw new Error('characteristic ' + uuid(ch)); }
            var dv = await c.readValue();
            return new Uint8Array(dv.buffer.slice(
                dv.byteOffset,
                dv.byteOffset + dv.byteLength
            ));
        });
    };

    BleTransport.prototype.write = function (ch, bytes, gap) {
        return this.enqueue(async () => {
            var c = this.chars[ch];
            if (!c) {throw new Error('characteristic ' + uuid(ch)); }
            if (c.writeValueWithoutResponse &&
                    c.properties.writeWithoutResponse) {
                await c.writeValueWithoutResponse(bytes);
            } else if (c.writeValueWithResponse) {
                await c.writeValueWithResponse(bytes);
            } else {
                await c.writeValue(bytes);
            }
            await sleep(gap);
        });
    };

    BleTransport.prototype.notify = function (ch, callback) {
        var c = this.chars[ch];
        if (!c) {return Promise.resolve(); }
        c.addEventListener('characteristicvaluechanged', event => {
            var dv = event.target.value;
            callback(new Uint8Array(dv.buffer.slice(
                dv.byteOffset,
                dv.byteOffset + dv.byteLength
            )));
        });
        return this.enqueue(() => c.startNotifications());
    };

    BleTransport.prototype.pending = function () {
        return 0;
    };

    BleTransport.prototype.disconnect = async function () {
        var dev = this.device;
        this.device = null;
        if (dev && dev.gatt.connected) {
            dev.gatt.disconnect();
        }
    };

    BleTransport.prototype.handleDisconnect = function () {
        if (this.onDisconnect) {this.onDisconnect(); }
    };

    // ---------------------------------------------------------------------
    // Serial transport (Web Serial, USB)

    function SerialTransport() {
        this.port = null;
        this.reader = null;
        this.writer = null;
        this.buffer = [];
        this.responses = {}; // ch -> {type -> Uint8Array}
        this.listeners = {}; // ch -> function (notify + streamed reads)
        this.queue = Promise.resolve();
        this.onDisconnect = null;
        this.open = false;
        this.streamsState = true; // firmware pushes state & motion
    }

    SerialTransport.prototype.connect = async function () {
        if (!navigator.serial) {
            throw new Error('Web Serial wird von diesem Browser ' +
                'nicht unterstützt. Bitte Chrome oder Edge verwenden.');
        }
        this.port = await navigator.serial.requestPort({filters: [USB_FILTER]});
        await this.port.open({baudRate: 115200});
        this.open = true;
        this.writer = this.port.writable.getWriter();
        this.reader = this.port.readable.getReader();
        this.onPortDisconnect = (event) => {
            if (event.target === this.port) {this.handleDisconnect(); }
        };
        navigator.serial.addEventListener('disconnect', this.onPortDisconnect);
        this.readLoop();
    };

    SerialTransport.prototype.readLoop = async function () {
        try {
            while (this.open) {
                var result = await this.reader.read();
                if (result.done) {break; }
                if (result.value) {this.receive(result.value); }
            }
        } catch (err) {
            // port vanished
        }
        if (this.open) {this.handleDisconnect(); }
    };

    SerialTransport.prototype.receive = function (chunk) {
        var buf = this.buffer, start, type, ch, len, end, sum, i, value;
        for (i = 0; i < chunk.length; i += 1) {buf.push(chunk[i]); }
        while (true) {
            start = buf.indexOf(SERIAL_SFD);
            if (start === -1) {buf.length = 0; return; }
            if (start > 0) {buf.splice(0, start); }
            if (buf.length < 5) {return; }
            type = buf[1];
            if (type > SERIAL_RES.NOTIFY) {buf.shift(); continue; }
            ch = (buf[2] << 8) | buf[3];
            len = buf[4];
            end = 5 + len;
            if (buf.length < end + 1) {return; }
            sum = 0;
            for (i = 0; i < end; i += 1) {sum += buf[i]; }
            if (sum % 0xFF !== buf[end]) {buf.shift(); continue; }
            value = new Uint8Array(buf.slice(5, end));
            buf.splice(0, end + 1);
            if (!this.responses[ch]) {this.responses[ch] = {}; }
            this.responses[ch][type] = value;
            if ((type === SERIAL_RES.NOTIFY || type === SERIAL_RES.READ) &&
                    this.listeners[ch]) {
                this.listeners[ch](value);
            }
        }
    };

    SerialTransport.prototype.send = async function (bytes) {
        await this.writer.ready;
        await this.writer.write(bytes);
    };

    SerialTransport.prototype.enqueue = BleTransport.prototype.enqueue;

    SerialTransport.prototype.read = function (ch) {
        return this.enqueue(async () => {
            var attempt, wait;
            for (attempt = 0; attempt < 3; attempt += 1) {
                if (this.responses[ch]) {
                    this.responses[ch][SERIAL_RES.READ] = null;
                }
                await this.send(new Uint8Array(
                    [SERIAL_SFD, SERIAL_REQ.READ, ch >> 8, ch & 0xFF]
                ));
                for (wait = 0; wait < 50; wait += 1) {
                    await sleep(10);
                    if (this.responses[ch] &&
                            this.responses[ch][SERIAL_RES.READ]) {
                        return this.responses[ch][SERIAL_RES.READ];
                    }
                }
            }
            throw new Error('Calliope mini antwortet nicht (USB)');
        });
    };

    SerialTransport.prototype.write = function (ch, bytes, gap) {
        return this.enqueue(async () => {
            var frame = new Uint8Array(6 + bytes.length), sum = 0, i;
            frame[0] = SERIAL_SFD;
            frame[1] = SERIAL_REQ.WRITE;
            frame[2] = ch >> 8;
            frame[3] = ch & 0xFF;
            frame[4] = bytes.length;
            frame.set(bytes, 5);
            for (i = 0; i < frame.length - 1; i += 1) {sum += frame[i]; }
            frame[frame.length - 1] = sum % 0xFF;
            await this.send(frame);
            await sleep(gap);
        });
    };

    SerialTransport.prototype.notify = function (ch, callback) {
        // the firmware starts notifications automatically on serial
        this.listeners[ch] = callback;
        return Promise.resolve();
    };

    SerialTransport.prototype.disconnect = async function () {
        if (!this.open) {return; }
        this.open = false;
        navigator.serial.removeEventListener(
            'disconnect',
            this.onPortDisconnect
        );
        try {await this.reader.cancel(); } catch (e) {/* ignore */}
        try {this.reader.releaseLock(); } catch (e) {/* ignore */}
        try {await this.writer.close(); } catch (e) {/* ignore */}
        try {this.writer.releaseLock(); } catch (e) {/* ignore */}
        try {await this.port.close(); } catch (e) {/* ignore */}
        this.port = null;
    };

    SerialTransport.prototype.handleDisconnect = function () {
        var cb = this.onDisconnect;
        this.disconnect();
        if (cb) {cb(); }
    };

    // ---------------------------------------------------------------------
    // Calliope mini device

    function Calliope() {
        this.transport = null;
        this.status = 'disconnected'; // 'connecting', 'connected', 'error'
        this.error = '';
        this.connectionEvents = {connected: 0, disconnected: 0};
        this.reset();
    }

    Calliope.prototype.reset = function () {
        this.hardware = 0;
        this.route = 0;
        this.commandGap = 30;
        this.updateInterval = 50;
        this.digitalLevel = {};
        this.buttonState = {};
        this.lightLevel = 0;
        this.temperature = 0;
        this.soundLevel = 0;
        this.pitch = 0;
        this.roll = 0;
        this.acceleration = {x: 0, y: 0, z: 0};
        this.compassHeading = 0;
        this.magneticForce = {x: 0, y: 0, z: 0};
        this.analogValue = {};
        this.analogUpdated = {};
        this.analogPending = {};
        this.buttonEvents = {}; // name -> event -> timestamp
        this.gestureEvents = {}; // name -> timestamp
        this.pinEvents = {}; // pin -> event -> {value, timestamp}
        this.receivedData = {};
        this.config = {mic: false, pinMode: {}, touchRequested: {}};
        this.lastData = Date.now();
    };

    Calliope.prototype.isConnected = function () {
        return this.status === 'connected';
    };

    Calliope.prototype.connect = function (route) {
        if (this.status === 'connecting') {return; }
        var useSerial = /usb|serial|kabel/i.test(String(route));
        this.disconnect(true);
        this.status = 'connecting';
        this.error = '';
        this.transport = useSerial ? new SerialTransport() : new BleTransport();
        this.transport.onDisconnect = () => this.lost();
        this.transport.connect()
            .then(() => this.handshake())
            .catch(err => {
                var t = this.transport;
                this.transport = null;
                if (t) {t.disconnect(); }
                this.status = 'error';
                this.error = err && err.name === 'NotFoundError' ?
                    'Kein Calliope mini ausgewählt.'
                    : String(err && err.message ? err.message : err);
            });
    };

    Calliope.prototype.handshake = async function () {
        var t = this.transport, data;
        this.reset();
        data = await t.read(CH.COMMAND);
        this.hardware = data[0];
        this.route = data[2];
        this.commandGap = this.route === ROUTE_SERIAL ? 100 : 30;
        this.updateInterval = this.hardware === HW_V1 ? 100 : 50;
        if (t.streamsState) {
            t.notify(CH.STATE, value => this.parseState(value));
            t.notify(CH.MOTION, value => this.parseMotion(value));
        }
        await t.notify(CH.ACTION_EVENT, value => this.parseNotify(value));
        await t.notify(CH.PIN_EVENT, value => this.parseNotify(value));
        if (this.hardware !== HW_V1) {
            await t.notify(CH.MESSAGE, value => this.parseNotify(value));
        }
        if (t !== this.transport) {return; } // disconnected meanwhile
        this.status = 'connected';
        this.connectionEvents.connected = stamp();
        this.lastData = Date.now();
        this.startUpdater();
    };

    Calliope.prototype.startUpdater = function () {
        var t = this.transport,
            loop = async () => {
                while (this.transport === t && this.isConnected()) {
                    try {
                        if (!t.streamsState) {
                            this.parseState(await t.read(CH.STATE));
                            this.parseMotion(await t.read(CH.MOTION));
                        }
                    } catch (err) {
                        // ignore single failures, watchdog handles the rest
                    }
                    if (Date.now() - this.lastData > DATA_TIMEOUT) {
                        this.lost();
                        return;
                    }
                    await sleep(this.updateInterval);
                }
            };
        loop();
    };

    Calliope.prototype.lost = function () {
        if (this.status !== 'connected' && this.status !== 'connecting') {
            return;
        }
        this.disconnect();
        this.status = 'error';
        this.error = 'Verbindung zum Calliope mini verloren.';
    };

    Calliope.prototype.disconnect = function (silent) {
        var t = this.transport,
            wasConnected = this.isConnected();
        this.transport = null;
        if (t) {
            t.onDisconnect = null;
            t.disconnect();
        }
        if (!silent || wasConnected) {
            this.status = 'disconnected';
        }
        if (wasConnected) {
            this.connectionEvents.disconnected = stamp();
        }
    };

    // parsing -------------------------------------------------------------

    Calliope.prototype.parseState = function (data) {
        if (!data || data.length < 7) {return; }
        var dv = new DataView(data.buffer, data.byteOffset, data.byteLength),
            gpio = dv.getUint32(0, true);
        GPIO.forEach(pin => {
            this.digitalLevel[pin] = (gpio >> pin) & 1;
        });
        Object.keys(BUTTON_STATE_INDEX).forEach(name => {
            this.buttonState[name] =
                (gpio >> (24 + BUTTON_STATE_INDEX[name])) & 1;
        });
        this.lightLevel = dv.getUint8(4);
        this.temperature = dv.getUint8(5) - 128;
        this.soundLevel = dv.getUint8(6);
        this.lastData = Date.now();
    };

    Calliope.prototype.parseMotion = function (data) {
        if (!data || data.length < 18) {return; }
        var dv = new DataView(data.buffer, data.byteOffset, data.byteLength);
        this.pitch = Math.round(dv.getInt16(0, true) * 180 / Math.PI / 1000);
        this.roll = Math.round(dv.getInt16(2, true) * 180 / Math.PI / 1000);
        this.acceleration.x = 1000 * dv.getInt16(4, true) / G;
        this.acceleration.y = 1000 * dv.getInt16(6, true) / G;
        this.acceleration.z = 1000 * dv.getInt16(8, true) / G;
        this.compassHeading = dv.getUint16(10, true);
        this.magneticForce.x = dv.getInt16(12, true);
        this.magneticForce.y = dv.getInt16(14, true);
        this.magneticForce.z = dv.getInt16(16, true);
        this.lastData = Date.now();
    };

    Calliope.prototype.parseNotify = function (data) {
        if (!data || data.length < 20) {return; }
        var dv = new DataView(data.buffer, data.byteOffset, data.byteLength),
            format = dv.getUint8(19),
            decoder = new TextDecoder(),
            name, event, pin, label;
        this.lastData = Date.now();
        if (format === DATA_FORMAT.ACTION_EVENT) {
            if (dv.getUint8(0) === ACTION_EVENT.BUTTON) {
                name = BUTTON_ID[dv.getUint16(1, true)];
                event = BUTTON_EVENT_ID[dv.getUint8(3)];
                if (name && event) {
                    if (!this.buttonEvents[name]) {
                        this.buttonEvents[name] = {};
                    }
                    this.buttonEvents[name][event] = stamp();
                }
            } else if (dv.getUint8(0) === ACTION_EVENT.GESTURE) {
                name = GESTURE_ID[dv.getUint8(1)];
                if (name) {this.gestureEvents[name] = stamp(); }
            }
        } else if (format === DATA_FORMAT.PIN_EVENT) {
            pin = dv.getUint8(0);
            if (!this.pinEvents[pin]) {this.pinEvents[pin] = {}; }
            this.pinEvents[pin][dv.getUint8(1)] = {
                value: dv.getUint32(2, true),
                timestamp: stamp()
            };
        } else if (format === DATA_FORMAT.DATA_NUMBER) {
            label = decoder.decode(data.slice(0, 8).filter(c => c !== 0));
            this.receivedData[label] = {
                content: dv.getFloat32(8, true),
                timestamp: Date.now()
            };
        } else if (format === DATA_FORMAT.DATA_TEXT) {
            label = decoder.decode(data.slice(0, 8).filter(c => c !== 0));
            this.receivedData[label] = {
                content: decoder.decode(data.slice(8, 20).filter(c => c !== 0)),
                timestamp: Date.now()
            };
        }
    };

    // commands ------------------------------------------------------------

    Calliope.prototype.command = function (cmd, sub, bytes) {
        if (!this.isConnected()) {return Promise.resolve(); }
        var t = this.transport,
            data = new Uint8Array(1 + bytes.length);
        data[0] = (cmd << 5) | sub;
        data.set(bytes, 1);
        return t.write(CH.COMMAND, data, this.commandGap)
            .catch(() => null);
    };

    Calliope.prototype.displayText = function (text, delay) {
        var chars = [], i, code;
        text = String(text);
        for (i = 0; i < Math.min(18, text.length); i += 1) {
            code = text.charCodeAt(i);
            chars.push(code < 128 ? code : 63); // non ascii => '?'
        }
        chars.push(0);
        this.command(
            CMD.DISPLAY,
            DISPLAY_CMD.TEXT,
            [clamp(Math.round(delay / 10), 0, 255)].concat(chars)
        );
        return delay * (6 * Math.min(18, text.length) + 6);
    };

    Calliope.prototype.displayPixels = function (levels) {
        // levels: 25 brightness values 0..255
        this.command(CMD.DISPLAY, DISPLAY_CMD.PIXELS_0, levels.slice(0, 15));
        this.command(CMD.DISPLAY, DISPLAY_CMD.PIXELS_1, levels.slice(15, 25));
    };

    Calliope.prototype.setRGB = function (colors) {
        var bytes = [];
        colors.forEach(rgb => bytes.push(rgb[0], rgb[1], rgb[2]));
        this.command(CMD.RGB, 0, bytes);
    };

    Calliope.prototype.setMotor = function (motor, speed) {
        var sub = motor === 'm0' ? MOTOR_CMD.M0
                : (motor === 'm1' ? MOTOR_CMD.M1 : MOTOR_CMD.M0_M1);
        speed = clamp(Math.round(speed), -100, 100);
        this.command(CMD.MOTOR, sub, [speed < 0 ? 1 : 0, Math.abs(speed)]);
    };

    Calliope.prototype.setPull = function (pin, mode) {
        this.config.pinMode[pin] = 'INPUT';
        this.command(CMD.PIN, PIN_CMD.SET_PULL, [pin, mode]);
    };

    Calliope.prototype.setOutput = function (pin, level) {
        this.config.pinMode[pin] = 'OUTPUT';
        this.command(CMD.PIN, PIN_CMD.SET_OUTPUT, [pin, level ? 1 : 0]);
    };

    Calliope.prototype.setPWM = function (pin, level) {
        this.config.pinMode[pin] = 'PWM';
        this.command(
            CMD.PIN,
            PIN_CMD.SET_PWM,
            [pin, level & 0xFF, (level >> 8) & 0xFF]
        );
    };

    Calliope.prototype.setServo = function (pin, angle) {
        this.config.pinMode[pin] = 'SERVO';
        this.command(
            CMD.PIN,
            PIN_CMD.SET_SERVO,
            [pin, angle & 0xFF, (angle >> 8) & 0xFF, 0, 0, 0, 0]
        );
    };

    Calliope.prototype.listenPinEvent = function (pin, type) {
        this.command(CMD.PIN, PIN_CMD.SET_EVENT, [pin, type]);
    };

    Calliope.prototype.playTone = function (freq, volume) {
        var period = Math.round(1000000 / Math.max(1, freq));
        this.command(CMD.AUDIO, AUDIO_CMD.PLAY_TONE, [
            period & 0xFF,
            (period >> 8) & 0xFF,
            (period >> 16) & 0xFF,
            (period >> 24) & 0xFF,
            Math.round(clamp(volume, 0, 100) * 0xFF / 100)
        ]);
    };

    Calliope.prototype.stopTone = function () {
        this.command(CMD.AUDIO, AUDIO_CMD.STOP_TONE, []);
    };

    Calliope.prototype.ensureMic = function () {
        if (this.isConnected() && !this.config.mic) {
            this.config.mic = true;
            this.command(CMD.CONFIG, CONFIG_CMD.MIC, [1]);
        }
    };

    Calliope.prototype.ensureTouch = function (name) {
        var pin = BUTTON_PIN_INDEX[name];
        if (pin === undefined || !this.isConnected()) {return; }
        if (this.config.pinMode[pin] === 'TOUCH') {return; }
        if (Date.now() - (this.config.touchRequested[pin] || 0) < 1000) {
            return;
        }
        this.config.touchRequested[pin] = Date.now();
        this.command(CMD.CONFIG, CONFIG_CMD.TOUCH, [pin, 1]).then(() => {
            this.config.pinMode[pin] = 'TOUCH';
        });
    };

    Calliope.prototype.analog = function (pin) {
        // answers the value 0..1023 or -1 while a request is pending
        var ch = CH.ANALOG_IN[pin], t = this.transport;
        if (!this.isConnected() || ch === undefined) {return 0; }
        if (Date.now() - (this.analogUpdated[pin] || 0) < 100) {
            return this.analogValue[pin];
        }
        if (this.analogPending[pin]) {return -1; }
        if (this.config.pinMode[pin] !== 'INPUT') {
            this.setPull(pin, PULL.NONE);
        }
        this.analogPending[pin] = true;
        t.read(ch).then(data => {
            var dv = new DataView(data.buffer, data.byteOffset, data.byteLength);
            this.analogValue[pin] = dv.getUint16(0, true);
        }).catch(() => {
            this.analogValue[pin] = this.analogValue[pin] || 0;
        }).finally(() => {
            this.analogUpdated[pin] = Date.now();
            this.analogPending[pin] = false;
        });
        return -1;
    };

    // ---------------------------------------------------------------------
    // edge detection for event hat blocks
    // Each hat block (the top block of the evaluating process) remembers
    // the last event it has seen, so several hats can react to the same
    // event independently. A hat only reacts to events which arrive after
    // it started watching.

    var globalSeen = {};

    function isNewEvent(proc, key, timestamp) {
        var owner = proc && proc.topBlock ? proc.topBlock : null,
            seen = globalSeen;
        if (owner) {
            if (!owner.calliopeSeen) {owner.calliopeSeen = {}; }
            seen = owner.calliopeSeen;
        }
        timestamp = timestamp || 0;
        if (seen[key] === undefined) {
            seen[key] = timestamp;
            return false;
        }
        if (seen[key] === timestamp) {return false; }
        seen[key] = timestamp;
        return true;
    }

    // ---------------------------------------------------------------------
    // input helpers

    function listToArray(x) {
        if (x instanceof List) {
            return x.itemsArray().map(listToArray);
        }
        return x;
    }

    function parseColor(c) {
        var hex, m;
        if (c instanceof Color) {
            return [Math.round(c.r), Math.round(c.g), Math.round(c.b)];
        }
        if (c instanceof List) {
            m = c.itemsArray().map(v => clamp(Math.round(num(v)), 0, 255));
            return [m[0] || 0, m[1] || 0, m[2] || 0];
        }
        hex = String(c).trim().replace(/^#/, '');
        if (/^[0-9a-f]{3}$/i.test(hex)) {
            hex = hex.split('').map(d => d + d).join('');
        }
        if (/^[0-9a-f]{6}$/i.test(hex)) {
            return [
                parseInt(hex.slice(0, 2), 16),
                parseInt(hex.slice(2, 4), 16),
                parseInt(hex.slice(4, 6), 16)
            ];
        }
        return [0, 0, 0];
    }

    function parseMatrix(input) {
        // accepts "01010 11111 ...", "0,50,100,...", a list of 25 values
        // (0..100 %) or a 5x5 list
        var values, str;
        if (input instanceof List) {
            values = [].concat.apply([], listToArray(input).map(
                row => Array.isArray(row) ? row : [row]
            ));
            values = values.map(v => clamp(num(v), 0, 100));
        } else {
            str = String(input);
            if (str.includes(',')) {
                values = str.split(/[,\n]/).map(v => clamp(num(v), 0, 100));
            } else {
                values = str.replace(/\s/g, '').split('').map(
                    ch => ch === '0' || ch === '.' ? 0 : 100
                );
            }
        }
        while (values.length < 25) {values.push(0); }
        return values.slice(0, 25).map(v => Math.round(v * 255 / 100));
    }

    // menu entries of the Snap! blocks (German, as in Scratch more)
    // mapped to protocol names; English protocol names work as well
    var MENU = {
        // button events
        'unten': 'DOWN', 'gedrückt': 'DOWN', 'oben': 'UP',
        'geklickt': 'CLICK', 'lange geklickt': 'LONG_CLICK',
        'gehalten': 'HOLD', 'doppelt geklickt': 'DOUBLE_CLICK',
        // touch events
        'berührt': 'DOWN', 'losgelassen': 'UP', 'getippt': 'CLICK',
        'lange getippt': 'LONG_CLICK', 'doppelt getippt': 'DOUBLE_CLICK',
        // gestures
        'logo nach oben': 'TILT_UP', 'logo nach unten': 'TILT_DOWN',
        'nach links gedreht': 'TILT_LEFT', 'nach rechts gedreht': 'TILT_RIGHT',
        'display nach oben': 'FACE_UP', 'display nach unten': 'FACE_DOWN',
        'freier fall': 'FREEFALL', '3g beschleunigt': 'G3',
        '6g beschleunigt': 'G6', '8g beschleunigt': 'G8',
        'geschüttelt': 'SHAKE',
        // pull modes
        'nichts': 'NONE', 'pullup': 'UP', 'pulldown': 'DOWN',
        // pin event types
        'flanke': 'ON_EDGE', 'impuls': 'ON_PULSE', 'berührung': 'ON_TOUCH',
        // pin events
        'ansteigen': 'RISE', 'abfallen': 'FALL',
        'impuls hoch': 'PULSE_HIGH', 'impuls tief': 'PULSE_LOW',
        // sensors
        'lichtstärke': 'light', 'temperatur': 'temperature',
        'kompassrichtung': 'compass', 'neigung vor/zurück': 'pitch',
        'neigung links/rechts': 'roll', 'lautstärke': 'sound',
        'magnetkraft': 'magnetic', 'betrag': 'absolute'
    };

    function code(choice) {
        var key = String(choice).trim().toLowerCase();
        return MENU[key] || String(choice).trim();
    }

    function pinNumber(p) {
        return parseInt(String(p).replace(/^[PC]/i, ''), 10) || 0;
    }

    function buttonName(b) {
        b = String(b).toUpperCase();
        return b === 'LOGO' ? 'LOGO' : b;
    }

    // ---------------------------------------------------------------------
    // Snap! extension primitives

    var cal = new Calliope(),
        prims = SnapExtensions.primitives;

    window.SnapCalliope = cal; // for debugging

    // connection

    prims.set('cal_connect(route)', function (route) {
        cal.connect(route);
    });

    prims.set('cal_disconnect()', function () {
        cal.disconnect();
    });

    prims.set('cal_status()', function () {
        return cal.status;
    });

    prims.set('cal_error()', function () {
        return cal.error;
    });

    prims.set('cal_connected()', function () {
        return cal.isConnected();
    });

    prims.set('cal_connection_event(state)', function (state, proc) {
        var key = /dis|getrennt/i.test(String(state)) ? 'disconnected'
                : 'connected';
        return isNewEvent(proc, 'conn:' + key, cal.connectionEvents[key]);
    });

    // buttons, touch & gestures

    prims.set('cal_button_event(name, event)', function (name, event, proc) {
        name = buttonName(name);
        event = code(event).toUpperCase();
        if (BUTTON_PIN_INDEX[name] !== undefined) {cal.ensureTouch(name); }
        if (name === 'A+B') {
            return isNewEvent(proc, 'btn:AB:' + event,
                Math.min(
                    (cal.buttonEvents.A || {})[event] || 0,
                    (cal.buttonEvents.B || {})[event] || 0
                ) && Math.max(
                    (cal.buttonEvents.A || {})[event] || 0,
                    (cal.buttonEvents.B || {})[event] || 0
                ));
        }
        return isNewEvent(
            proc,
            'btn:' + name + ':' + event,
            (cal.buttonEvents[name] || {})[event]
        );
    });

    prims.set('cal_button_pressed(name)', function (name) {
        name = buttonName(name);
        if (!cal.isConnected()) {return false; }
        if (BUTTON_PIN_INDEX[name] !== undefined) {cal.ensureTouch(name); }
        if (name === 'A+B') {
            return cal.buttonState.A === 1 && cal.buttonState.B === 1;
        }
        return cal.buttonState[name] === 1;
    });

    prims.set('cal_gesture(name)', function (name, proc) {
        name = code(name).toUpperCase();
        return isNewEvent(proc, 'gst:' + name, cal.gestureEvents[name]);
    });

    // display & LEDs

    prims.set('cal_show_pattern(matrix)', function (matrix) {
        cal.displayPixels(parseMatrix(matrix));
    });

    prims.set('cal_show_text(text, delay)', function (text, delay) {
        // answers the scrolling duration in seconds
        if (!cal.isConnected()) {return 0; }
        delay = parseInt(delay, 10);
        if (isNaN(delay)) {delay = 120; }
        return cal.displayText(text, clamp(delay, 0, 2550)) / 1000;
    });

    prims.set('cal_clear_display()', function () {
        cal.displayPixels(new Array(25).fill(0));
    });

    prims.set('cal_rgb(c1, c2, c3)', function (c1, c2, c3) {
        cal.setRGB([parseColor(c1), parseColor(c2), parseColor(c3)]);
    });

    prims.set('cal_motor(motor, speed)', function (motor, speed) {
        cal.setMotor(String(motor).toLowerCase(), num(speed));
    });

    // sensors

    prims.set('cal_sensor(name)', function (name) {
        if (!cal.isConnected()) {return 0; }
        switch (code(name)) {
        case 'light':
            return cal.lightLevel;
        case 'temperature':
            return cal.temperature;
        case 'compass':
            return cal.compassHeading;
        case 'pitch':
            return cal.pitch;
        case 'roll':
            return cal.roll;
        case 'sound':
            cal.ensureMic();
            return Math.round(cal.soundLevel * 1000 / 255) / 10;
        case 'magnetic':
            return Math.round(Math.sqrt(
                cal.magneticForce.x ** 2 +
                cal.magneticForce.y ** 2 +
                cal.magneticForce.z ** 2
            ));
        }
        return 0;
    });

    prims.set('cal_acceleration(axis)', function (axis) {
        var a = cal.acceleration;
        if (!cal.isConnected()) {return 0; }
        axis = code(axis).toLowerCase();
        if (axis === 'x' || axis === 'y' || axis === 'z') {
            return Math.round(a[axis]);
        }
        return Math.round(Math.sqrt(a.x ** 2 + a.y ** 2 + a.z ** 2));
    });

    prims.set('cal_magnetic(axis)', function (axis) {
        var m = cal.magneticForce;
        if (!cal.isConnected()) {return 0; }
        axis = code(axis).toLowerCase();
        if (axis === 'x' || axis === 'y' || axis === 'z') {
            return m[axis];
        }
        return Math.round(Math.sqrt(m.x ** 2 + m.y ** 2 + m.z ** 2));
    });

    prims.set('cal_analog(pin)', function (pin) {
        // answers 0..100 (%) or -1 while waiting for the device
        var raw = cal.analog(pinNumber(pin));
        return raw < 0 ? -1 : Math.round(raw * 1000 / 1024) / 10;
    });

    // pins

    prims.set('cal_pull(pin, mode)', function (pin, mode) {
        mode = code(mode).toUpperCase();
        cal.setPull(pinNumber(pin), PULL[mode] === undefined ? 0 : PULL[mode]);
    });

    prims.set('cal_pin_high(pin)', function (pin) {
        pin = pinNumber(pin);
        if (!cal.isConnected()) {return false; }
        if (cal.config.pinMode[pin] !== 'INPUT') {
            cal.setPull(pin, PULL.DOWN);
        }
        return cal.digitalLevel[pin] === 1;
    });

    prims.set('cal_digital_out(pin, level)', function (pin, level) {
        var high = level === true || /^(true|high|hoch|an|1)$/i.test(
            String(level).trim()
        ) || num(level) > 0;
        cal.setOutput(pinNumber(pin), high);
    });

    prims.set('cal_analog_out(pin, percent)', function (pin, percent) {
        var level = Math.round(clamp(num(percent), 0, 100) * 1024 / 100);
        cal.setPWM(pinNumber(pin), level);
    });

    prims.set('cal_servo(pin, angle)', function (pin, angle) {
        cal.setServo(pinNumber(pin), Math.round(clamp(num(angle), 0, 180)));
    });

    prims.set('cal_listen_pin(pin, type)', function (pin, type) {
        type = code(type).toUpperCase();
        cal.listenPinEvent(
            pinNumber(pin),
            PIN_EVENT_TYPE[type] === undefined ? 0 : PIN_EVENT_TYPE[type]
        );
    });

    prims.set('cal_pin_event(pin, event)', function (pin, event, proc) {
        var p = pinNumber(pin),
            id = PIN_EVENT[code(event).toUpperCase()],
            e = (cal.pinEvents[p] || {})[id];
        return isNewEvent(proc, 'pin:' + p + ':' + id, e ? e.timestamp : 0);
    });

    prims.set('cal_pin_event_value(pin, event)', function (pin, event) {
        var p = pinNumber(pin),
            id = PIN_EVENT[code(event).toUpperCase()],
            e = (cal.pinEvents[p] || {})[id];
        return e ? e.value : 0;
    });

    // sound

    prims.set('cal_tone(freq, volume)', function (freq, volume) {
        cal.playTone(num(freq, 440), num(volume, 100));
    });

    prims.set('cal_stop_tone()', function () {
        cal.stopTone();
    });

    // stop sound and motors when the red stop sign is pressed
    if (Process && !Process.prototype.calliopeStopHooked) {
        Process.prototype.calliopeStopHooked = true;
        var oldStopAll = window.IDE_Morph ?
                window.IDE_Morph.prototype.stopAllScripts : null;
        if (oldStopAll) {
            window.IDE_Morph.prototype.stopAllScripts = function () {
                if (cal.isConnected()) {
                    cal.stopTone();
                    cal.setMotor('m0m1', 0);
                }
                return oldStopAll.apply(this, arguments);
            };
        }
    }
}());
