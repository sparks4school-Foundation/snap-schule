import { menu } from "./menu.js";
import { touchDevice } from "./touch-device.js";
import { verticalHeight } from "./vertical-height.js";

function autorun() {

    // Utilities
    verticalHeight();
    touchDevice();

    // Components
    menu();
};

document.addEventListener("DOMContentLoaded", autorun);
