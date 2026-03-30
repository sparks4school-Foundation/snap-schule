/**
 * Menu
 */

function menu()
{
    const menu = document.querySelector('[data-menu="menu"]');
    const btnToggle = document.querySelector('[data-menu="toggle"]');
    // const btnHide = document.querySelector('[data-menu="hide"]');
    // const background = document.querySelector('[data-menu="background"]');
    const duration = 400; // Used in CSS


    // Listeners
    // ========================================

    btnToggle.addEventListener('click', () => {

        if (menu.classList.contains('--is-transitioning')) { return };

        if (menu.classList.contains('--is-visible')) {
            hideMenu();
        } else {
            showMenu();
        }
    });
    // btnShow.addEventListener('click', showMenu);
    // btnHide.addEventListener('click', hideMenu);
    // background.addEventListener('click', hideMenu);

    // Functions
    // ========================================

    function showMenu() {
        if (menu.classList.contains('--is-visible')) { return };

        menu.classList.add('--is-visible');
        menu.classList.add('--is-transitioning');
        btnToggle.setAttribute('aria-expanded', 'true');

        menu.addEventListener('transitionend', function onEnd(ev) {
            menu.setAttribute('aria-hidden', 'false');
            menu.classList.remove('--is-transitioning');
        }, { once: true });
    }

    function hideMenu() {
        if (!menu.classList.contains('--is-visible')) { return };

        menu.classList.remove('--is-visible');
        menu.classList.add('--is-transitioning');
        btnToggle.setAttribute('aria-expanded', 'false');

        menu.addEventListener('transitionend', function onEnd(ev) {
            menu.setAttribute('aria-hidden', 'true');
            menu.classList.remove('--is-transitioning');
        }, { once: true });
    }
};

export { menu };
