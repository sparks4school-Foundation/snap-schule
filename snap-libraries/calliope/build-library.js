#!/usr/bin/env node
/*
    Generates ../calliope_module.xml (Snap! library "Calliope mini")
    from the block table below.

        node snap-libraries/calliope/build-library.js

    Every custom block first runs src_load(libraries/calliope/calliope.js)
    (a no-op after the first call) and then calls the cal_* primitives
    defined in calliope.js.
*/

'use strict';

const fs = require('fs');
const path = require('path');

const CATEGORY = 'Calliope mini';
const COLOR = '0,150,136,1';
const SRC = 'libraries/calliope/calliope.js';

// --- helpers --------------------------------------------------------------

const esc = s => String(s)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&apos;')
    .replace(/\n/g, '&#xD;');

const l = v => `<l>${esc(v)}</l>`;
const v = name => `<block var="${esc(name)}"/>`;
const list = items => `<list>${items.join('')}</list>`;
const load = () =>
    `<block s="doApplyExtension">${l('src_load(url)')}${list([l(SRC)])}</block>`;
const run = (prim, args = []) =>
    `<block s="doApplyExtension">${l(prim)}${list(args)}</block>`;
const call = (prim, args = []) =>
    `<block s="reportApplyExtension">${l(prim)}${list(args)}</block>`;
const report = expr => `<block s="doReport">${expr}</block>`;
const eq = (a, b) => `<block s="reportVariadicEquals">${list([a, b])}</block>`;
const not = a => `<block s="reportNot">${a}</block>`;
const lt = (a, b) => `<block s="reportVariadicLessThan">${list([a, b])}</block>`;
const ifThen = (cond, body) =>
    `<block s="doIf">${cond}<script>${body.join('')}</script><list></list></block>`;

// input slot declarations
const menu = (options, def = options[0], type = '%s') => ({
    type, def, options, readonly: true
});
const field = (def = '', type = '%s', options = null) => ({
    type, def, options, readonly: false
});

const PINS_GPIO = ['P0', 'P1', 'P2', 'P3', 'C8', 'C9', 'C12', 'C13',
    'C14', 'C15', 'C16', 'C17'];
const BUTTONS = ['A', 'B', 'A+B'];
const BUTTON_EVENTS = ['geklickt', 'unten', 'oben', 'lange geklickt',
    'gehalten', 'doppelt geklickt'];
const TOUCH = ['Logo', 'P0', 'P1', 'P2', 'P3'];
const TOUCH_EVENTS = ['berührt', 'losgelassen', 'getippt', 'lange getippt',
    'gehalten', 'doppelt getippt'];
const GESTURES = ['geschüttelt', 'Logo nach oben', 'Logo nach unten',
    'nach links gedreht', 'nach rechts gedreht', 'Display nach oben',
    'Display nach unten', 'freier Fall', '3g beschleunigt',
    '6g beschleunigt', '8g beschleunigt'];
const COLORS = ['#ff0000', '#00ff00', '#0000ff', '#ffff00', '#ff00ff',
    '#00ffff', '#ffffff', '#000000'];
const PIN_EVENTS = ['Ansteigen', 'Abfallen', 'Impuls hoch', 'Impuls tief'];

// --- blocks ---------------------------------------------------------------
// spec: English spec with %'param' names, de: German translation (_ = input)

const blocks = [
    // connection
    {
        spec: "connect Calliope mini via %'route'",
        de: 'verbinde Calliope mini über _',
        type: 'command',
        inputs: [menu(['Bluetooth', 'USB'])],
        body: [
            run('cal_connect(route)', [v('route')]),
            `<block s="doWaitUntil">${not(eq(call('cal_status()'),
                l('connecting')))}</block>`,
            ifThen(
                eq(call('cal_status()'), l('error')),
                [run('err_error(msg)', [call('cal_error()')])]
            )
        ]
    },
    {
        spec: 'disconnect Calliope mini',
        de: 'trenne Calliope mini',
        type: 'command',
        body: [run('cal_disconnect()')]
    },
    {
        spec: 'Calliope mini connected?',
        de: 'Calliope mini verbunden?',
        type: 'predicate',
        body: [report(call('cal_connected()'))]
    },
    {
        spec: "when Calliope mini %'state'",
        de: 'Wenn Calliope mini _ ist',
        type: 'hat',
        inputs: [menu(['verbunden', 'getrennt'])],
        body: [report(call('cal_connection_event(state)', [v('state')]))],
        space: true
    },

    // buttons, touch, gestures
    {
        spec: "when button %'button' is %'event'",
        de: 'Wenn Taste _ _ ist',
        type: 'hat',
        inputs: [menu(BUTTONS), menu(BUTTON_EVENTS)],
        body: [report(call('cal_button_event(name, event)',
            [v('button'), v('event')]))],
        space: true
    },
    {
        spec: "button %'button' pressed?",
        de: 'Taste _ gedrückt?',
        type: 'predicate',
        inputs: [menu(BUTTONS)],
        body: [report(call('cal_button_pressed(name)', [v('button')]))]
    },
    {
        spec: "when pin %'pin' is %'event'",
        de: 'Wenn Pin _ _ wird',
        type: 'hat',
        inputs: [menu(TOUCH), menu(TOUCH_EVENTS)],
        body: [report(call('cal_button_event(name, event)',
            [v('pin'), v('event')]))]
    },
    {
        spec: "pin %'pin' touched?",
        de: 'Pin _ berührt?',
        type: 'predicate',
        inputs: [menu(TOUCH)],
        body: [report(call('cal_button_pressed(name)', [v('pin')]))]
    },
    {
        spec: "when gesture %'gesture'",
        de: 'Wenn Bewegung _',
        type: 'hat',
        inputs: [menu(GESTURES)],
        body: [report(call('cal_gesture(name)', [v('gesture')]))]
    },

    // display, LEDs, motors
    {
        spec: "show pattern %'pattern'",
        de: 'zeige Bild _',
        type: 'command',
        inputs: [field('01010 11111 11111 01110 00100', '%s', [
            '01010 11111 11111 01110 00100',
            '00000 01010 00000 10001 01110',
            '00100 01110 10101 00100 00100',
            '11111 11111 11111 11111 11111'
        ])],
        body: [run('cal_show_pattern(matrix)', [v('pattern')])],
        space: true
    },
    {
        spec: "show text %'text' delay %'delay' ms",
        de: 'zeige Text _ mit _ ms Verzögerung',
        type: 'command',
        inputs: [field('Hallo!'), field('120', '%n')],
        body: [`<block s="doWait">${call('cal_show_text(text, delay)',
            [v('text'), v('delay')])}</block>`]
    },
    {
        spec: 'clear display',
        de: 'lösche Display',
        type: 'command',
        body: [run('cal_clear_display()')]
    },
    {
        spec: "set RGB LEDs to %'color 1' %'color 2' %'color 3'",
        de: 'setze Farben auf _ _ _',
        type: 'command',
        inputs: [field('#ff0000', '%s', COLORS),
            field('#00ff00', '%s', COLORS), field('#0000ff', '%s', COLORS)],
        body: [run('cal_rgb(c1, c2, c3)',
            [v('color 1'), v('color 2'), v('color 3')])]
    },
    {
        spec: 'turn off RGB LEDs',
        de: 'eingebaute RGB-LEDs ausschalten',
        type: 'command',
        body: [run('cal_rgb(c1, c2, c3)',
            [l('#000000'), l('#000000'), l('#000000')])]
    },
    {
        spec: "set motor %'motor' to %'speed' %",
        de: 'Motor _ an mit _ %',
        type: 'command',
        inputs: [menu(['M0', 'M1', 'M0 & M1']), field('100', '%n')],
        body: [ifThen(eq(v('motor'), l('M0 & M1')),
            [`<block s="doSetVar">${l('motor')}${l('m0m1')}</block>`]),
            run('cal_motor(motor, speed)', [v('motor'), v('speed')])]
    },

    // sound
    {
        spec: "play tone %'frequency' Hz volume %'volume' %",
        de: 'spiele Ton _ Hz mit Lautstärke _ %',
        type: 'command',
        inputs: [field('440', '%n', ['262', '294', '330', '349', '392',
            '440', '494', '523']), field('100', '%n')],
        body: [run('cal_tone(freq, volume)', [v('frequency'), v('volume')])],
        space: true
    },
    {
        spec: 'stop tone',
        de: 'stoppe Ton',
        type: 'command',
        body: [run('cal_stop_tone()')]
    },

    // sensors
    {
        spec: "Calliope %'sensor'",
        de: 'Calliope _',
        type: 'reporter',
        inputs: [menu(['Lichtstärke', 'Temperatur', 'Kompassrichtung',
            'Neigung vor/zurück', 'Neigung links/rechts', 'Lautstärke',
            'Magnetkraft'])],
        body: [report(call('cal_sensor(name)', [v('sensor')]))],
        space: true
    },
    {
        spec: "acceleration %'axis' mg",
        de: 'Beschleunigung _ mg',
        type: 'reporter',
        inputs: [menu(['x', 'y', 'z', 'Betrag'])],
        body: [report(call('cal_acceleration(axis)', [v('axis')]))]
    },
    {
        spec: "magnetic force %'axis' µT",
        de: 'Magnetkraft _ µT',
        type: 'reporter',
        inputs: [menu(['Betrag', 'x', 'y', 'z'])],
        body: [report(call('cal_magnetic(axis)', [v('axis')]))]
    },
    {
        spec: "analog value of pin %'pin'",
        de: 'analoger Wert von Pin _',
        type: 'reporter',
        inputs: [menu(['P0', 'P1', 'P2'])],
        body: [
            `<block s="doDeclareVariables">${list([l('value')])}</block>`,
            `<block s="doSetVar">${l('value')}${call('cal_analog(pin)',
                [v('pin')])}</block>`,
            `<block s="doUntil">${not(lt(v('value'), l('0')))}<script>` +
                `<block s="doSetVar">${l('value')}${call('cal_analog(pin)',
                    [v('pin')])}</block></script></block>`,
            report(v('value'))
        ]
    },

    // pins
    {
        spec: "pin %'pin' is high?",
        de: 'ist Pin _ hoch?',
        type: 'predicate',
        inputs: [menu(PINS_GPIO)],
        body: [report(call('cal_pin_high(pin)', [v('pin')]))],
        space: true
    },
    {
        spec: "set pin %'pin' to input %'mode'",
        de: 'setze Eingang _ auf _',
        type: 'command',
        inputs: [menu(PINS_GPIO), menu(['nichts', 'Pullup', 'Pulldown'])],
        body: [run('cal_pull(pin, mode)', [v('pin'), v('mode')])]
    },
    {
        spec: "set digital pin %'pin' to %'level'",
        de: 'setze digitalen Ausgang _ auf _',
        type: 'command',
        inputs: [menu(PINS_GPIO), field('1', '%n', ['0', '1'])],
        body: [run('cal_digital_out(pin, level)', [v('pin'), v('level')])]
    },
    {
        spec: "set analog pin %'pin' to %'level' %",
        de: 'setze analogen Ausgang _ auf _ %',
        type: 'command',
        inputs: [menu(PINS_GPIO), field('50', '%n')],
        body: [run('cal_analog_out(pin, percent)', [v('pin'), v('level')])]
    },
    {
        spec: "set servo at %'pin' to %'angle' °",
        de: 'setze Servo an _ auf Winkel _ °',
        type: 'command',
        inputs: [menu(PINS_GPIO), field('90', '%n')],
        body: [run('cal_servo(pin, angle)', [v('pin'), v('angle')])]
    }
    // pin event blocks (listen / when / value) are hidden on purpose;
    // the primitives cal_listen_pin, cal_pin_event, cal_pin_event_value
    // still exist in calliope.js
];

// --- XML ------------------------------------------------------------------

function inputXML(inp) {
    const attrs = inp.readonly ? ' readonly="true"' : '';
    const opts = inp.options ?
            `<options>${esc(inp.options.join('\n'))}</options>` : '';
    return `<input type="${inp.type}"${attrs}>${esc(inp.def)}${opts}</input>`;
}

function definitionXML(b) {
    const inputs = (b.inputs || []).map(inputXML).join('');
    return `<block-definition s="${esc(b.spec)}" type="${b.type}" ` +
        `category="${esc(CATEGORY)}"${b.space ? ' space="true"' : ''}>` +
        '<header></header><code></code>' +
        `<translations>${esc('de:' + b.de + '\n')}</translations>` +
        `<inputs>${inputs}</inputs>` +
        `<script>${[load()].concat(b.body).join('')}</script>` +
        '</block-definition>';
}

const xml = '<blocks app="Snap! 12, https://snap.berkeley.edu" version="2">' +
    `<palette><category name="${esc(CATEGORY)}" color="${COLOR}"/></palette>` +
    blocks.map(definitionXML).join('') +
    '</blocks>';

const target = path.join(__dirname, '..', 'calliope_module.xml');
fs.writeFileSync(target, xml);
console.log(`wrote ${blocks.length} blocks to ${target}`);

// --- Snap!Schule editor template with the library preloaded --------------
// static/template.xml + palette category + global block definitions
// => static/template-calliope.xml

const base = path.join(__dirname, '..', '..', 'static', 'template.xml');
if (fs.existsSync(base)) {
    let project = fs.readFileSync(base, 'utf8');
    const palette =
        `<palette><category name="${esc(CATEGORY)}" color="${COLOR}"/></palette>`;
    const definitions = blocks.map(definitionXML).join('');
    // custom category: <palette> right after the scene's <notes>
    project = project.replace(
        /(<scene [^>]*>)(<notes>[^<]*<\/notes>)/,
        `$1$2${palette}`
    );
    // global custom blocks: the scene's <blocks> after <headers>/<code>
    project = project.replace(
        /(<headers><\/headers><code><\/code>)<blocks><\/blocks>/,
        `$1<blocks>${definitions}</blocks>`
    );
    if (!project.includes(palette) || !project.includes(definitions)) {
        throw new Error('static/template.xml has an unexpected structure');
    }
    const out = path.join(__dirname, '..', '..', 'static',
        'template-calliope.xml');
    fs.writeFileSync(out, project);
    console.log(`wrote Snap!Schule template ${out}`);
}
