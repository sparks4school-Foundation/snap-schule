# Calliope mini für Snap!

Snap!-Bibliothek, mit der man einen **Calliope mini 3** direkt aus
Snap! steuert – per **Bluetooth (Web Bluetooth)** oder **USB-Kabel (Web Serial)**.
Funktioniert in Chromium-Browsern (Chrome, Edge, Chromebook).

Protokoll und Blöcke entsprechen dem Umfang des Calliope mini Blocks Editors:
[blocks.calliope.cc](https://blocks.calliope.cc).
Auf dem Calliope mini muss deshalb dasselbe Programm laufen wie für Blocks:
[Blocks-Hex:] (https://calliope.cc/downloads/blocks.hex).

## Dateien

| Datei | Inhalt |
|---|---|
| `calliope/calliope.js` | JavaScript-Erweiterung: Bluetooth- und USB-Verbindung, Protokoll, Sensorwerte, Ereignisse. Registriert die Primitive `cal_*` in `SnapExtensions`. |
| `calliope_module.xml` | Die Snap!-Bibliothek (Kategorie „Calliope mini“, 29 Blöcke). **Generiert** – nicht von Hand bearbeiten. |
| `calliope/build-library.js` | Erzeugt `calliope_module.xml` aus einer Blocktabelle: `node snap-libraries/calliope/build-library.js` |
| `install.sh` | Kopiert beides in die Snap!-Installation und trägt die Bibliothek in `libraries/LIBRARIES.json` ein. |

## Installation auf dem Server

Snap! liegt als unverändertes `jmoenig/Snap` neben Snap!Schule und ist als `snap`
verlinkt (siehe `install/install.md`). Nach jedem Snap!-Update ausführen:

```bash
snap-libraries/install.sh snap
```

Die JS-Datei muss unter `snap/libraries/…` liegen: Snap! lädt Erweiterungen
von dort ohne die Einstellung „JavaScript-Erweiterungen erlauben“, weil
`libraries/` auf Snap!s Liste vertrauenswürdiger Adressen steht.

## Snap!Schule-Editor

`/editor?calliope` öffnet den Editor mit der Vorlage
`static/template-calliope.xml`: die normale Vorlage `static/template.xml`
plus Kategorie „Calliope mini“ mit allen Blöcken. Die Vorlage wird von
`build-library.js` erzeugt – nach Änderungen an `static/template.xml` oder an
den Blöcken neu bauen:

```bash
node snap-libraries/calliope/build-library.js
```

In reinem Snap! (ohne Snap!Schule) öffnet `calliope.html`, das `install.sh`
in den Snap!-Ordner kopiert, dieselbe Vorlage (`libraries/calliope_template.xml`)
mit dem angepassten Look von Snap!Schule und den Calliope-mini-Blöcken.
Die Blöcke ohne Vorlage:
`snap.html#open:libraries/calliope_module.xml`.

## Benutzung

1. Snap! → Datei-Menü → **Bibliotheken…** → **Calliope mini** importieren.
2. Den Block **„verbinde Calliope mini über Bluetooth/USB“** anklicken
   (oder in ein Skript mit grüner Flagge setzen). Der Browser zeigt die
   Geräteauswahl. Das Verbinden muss durch einen Mausklick ausgelöst werden!
3. Die übrigen Blöcke funktionieren wie schon in dem Blocks Editor

Wird ein Projekt mit Calliope-mini-Blöcken geöffnet, lädt jeder Block die
Erweiterung bei Bedarf selbst; man muss also nur neu verbinden.

## Blöcke

* Verbindung: verbinden, trennen, verbunden?, Wenn Calliope mini verbunden/getrennt ist
* Tasten & Berührung: Wenn Taste A/B/A+B … ist, Taste … gedrückt?,
  Wenn Pin Logo/P0–P3 … wird, Pin … berührt?
* Bewegung: Wenn Bewegung (geschüttelt, Logo nach oben, freier Fall, …)
* Anzeige: zeige Bild, zeige Text, lösche Display, RGB-LEDs setzen/ausschalten
* Motor M0/M1/beide, Ton spielen/stoppen
* Sensoren: Lichtstärke, Temperatur, Kompass, Neigung, Lautstärke, Magnetkraft,
  Beschleunigung x/y/z/Betrag, analoger Wert P0–P2
* Pins: digital/analog schreiben, Servo

`zeige Bild` nimmt 25 Zeichen `0`/`1` (Leerzeichen erlaubt), kommagetrennte
Helligkeiten in Prozent oder eine Snap!-Liste (25 Werte oder 5×5).
Farben für die RGB-LEDs als `#rrggbb` oder Liste `(r, g, b)`.

Ein Klick auf das rote Stoppschild stoppt Ton und Motoren.