import { menu } from "./menu.js";
import { editor } from "./editor.js";
import { touchDevice } from "./touch-device.js";
import { verticalHeight } from "./vertical-height.js";
import { popup } from "./popup.js";

function autorun() {

    // Utilities
    verticalHeight();
    touchDevice();

    // Components
    editor();
    menu();
    popup();
};

document.addEventListener("DOMContentLoaded", autorun);
