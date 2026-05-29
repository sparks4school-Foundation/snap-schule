import { menu } from "./menu.js";
import { editor } from "./editor.js";
import { touchDevice } from "./touch-device.js";
import { verticalHeight } from "./vertical-height.js";
import { popup } from "./popup.js";
import { puzzlesSliders } from "./puzzles-sliders.js";

function autorun() {

    // Utilities
    verticalHeight();
    touchDevice();

    // Components
//    editor();
    menu();
    popup();
    puzzlesSliders();
};

document.addEventListener("DOMContentLoaded", autorun);
