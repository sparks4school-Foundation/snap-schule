#!/bin/sh
# Installs the Calliope mini library into a Snap! checkout.
#
#   snap-libraries/install.sh [path/to/Snap]
#
# Default path is ./snap (the symlink to the Snap! checkout, see install/install.md).
# Copies the files into Snap/libraries and registers the library in
# Snap/libraries/LIBRARIES.json (idempotent, can be run after every Snap! update).

set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
SNAP="${1:-$HERE/../snap}"
LIB="$SNAP/libraries"

if [ ! -f "$LIB/LIBRARIES.json" ]; then
    echo "Snap! libraries folder not found: $LIB" >&2
    exit 1
fi

mkdir -p "$LIB/calliope"
cp "$HERE/calliope/calliope.js" "$LIB/calliope/calliope.js"
cp "$HERE/calliope_module.xml" "$LIB/calliope_module.xml"
# Snap!Schule editor template (look: flat & bright, German) incl. Calliope blocks,
# opened by calliope.html
cp "$HERE/../static/template-calliope.xml" "$LIB/calliope_template.xml"
cp "$HERE/calliope.html" "$SNAP/calliope.html"

python3 - "$LIB/LIBRARIES.json" <<'EOF'
import json, sys
path = sys.argv[1]
with open(path, encoding='utf-8') as f:
    libs = json.load(f)
entry = {
    "fileName": "calliope_module.xml",
    "name": "Calliope mini",
    "description": "Control a Calliope mini (v3) via Bluetooth or USB. "
                   "Needs the \"Scratch more\" firmware on the Calliope mini "
                   "and Chrome, Edge or a Chromebook.",
    "categories": ["Calliope mini"],
    "translations": {
        "de": {
            "name": "Calliope mini",
            "description": "Steuere einen Calliope mini (v3) über Bluetooth "
                           "oder USB. Auf dem Calliope mini muss das "
                           "\"Scratch more\"-Programm laufen; benötigt "
                           "Chrome, Edge oder ein Chromebook."
        }
    }
}
libs = [l for l in libs if l.get("fileName") != entry["fileName"]]
libs.append(entry)
with open(path, "w", encoding="utf-8") as f:
    json.dump(libs, f, indent=2, ensure_ascii=False)
    f.write("\n")
EOF

echo "Calliope mini library installed into $LIB"
