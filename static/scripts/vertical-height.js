/**
 * Vertical Height
 */


function setVh() {
  const vh = window.innerHeight * 0.01;
  document.documentElement.style.setProperty('--vh', `${vh}px`);
}

function verticalHeight() {
  setVh(); // initial call
  window.addEventListener('resize', setVh); // re-apply on resize
}

export { verticalHeight };
