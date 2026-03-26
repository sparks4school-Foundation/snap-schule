/**
 * Touch device
 */

function touchDevice() {
  const hasTouchSupport = 'ontouchstart' in window || navigator.maxTouchPoints > 0 || navigator.msMaxTouchPoints > 0;

  if (hasTouchSupport) {
    document.body.classList.add('--has-touch');
  } else {
    document.body.classList.add('--not-touch');
  }
}

export { touchDevice };
