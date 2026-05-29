/**
 * Editor
 */

function editor()
{
	const puzzleList = document.querySelector('[data-editor-puzzle-list="list"]');

	if (!puzzleList) return;

	const btnToggle = document.querySelector('[data-menu="class-puzzles"]');
	const slider = puzzleList.querySelector('[data-editor-puzzle-list="slider"]');
	const btnPrev = slider.parentElement.querySelector('[data-editor-puzzle-list="button-prev"]');
	const btnNext = slider.parentElement.querySelector('[data-editor-puzzle-list="button-next"]');
	const pagination = slider.parentElement.querySelector('[data-editor-puzzle-list="pagination"]');

	btnToggle.addEventListener('click', toggleList);

	function toggleList() {
		updateCheckbox();
		if (puzzleList.classList.contains('--is-transitioning')) { return };

		if (!puzzleList.classList.contains('--is-visible')) {
			puzzleList.classList.add('--is-visible');
			btnToggle.setAttribute('aria-expanded', 'true');
		} else {
			puzzleList.classList.remove('--is-visible');
			btnToggle.setAttribute('aria-expanded', 'false');
		}

		puzzleList.classList.add('--is-transitioning');

		puzzleList.addEventListener('transitionend', function onEnd(ev) {
			puzzleList.setAttribute('aria-hidden', 'false');
			puzzleList.classList.remove('--is-transitioning');
		}, { once: true });
	}


	const swiper = new Swiper(slider, {

		// Optional parameters
		slidesPerView: 1.2,
		spaceBetween: 16,
		slidesOffsetBefore: 16,
		slidesOffsetAfter: 24,

		// If we need pagination
		pagination: {
			el: pagination,
			clickable: true
		},

		// Navigation arrows
		navigation: {
			nextEl: btnNext,
			prevEl: btnPrev,
		},

		// Breakpoints
		breakpoints: {
			640: {
				slidesPerView: 2.4,
				spaceBetween: 24,
				slidesOffsetBefore: 24,
				slidesOffsetAfter: 24,
			},
			768: {
				slidesPerView: 2.8,
				// slidesOffsetBefore: 32,
				// slidesOffsetAfter: 32,
			},
			1024: {
				slidesPerView: 3.2,
				spaceBetween: 24,
				slidesOffsetBefore: 40,
				slidesOffsetAfter: 40,
			},
			1280: {
				slidesPerView: 3.6,
				spaceBetween: 24,
				slidesOffsetBefore: 56,
				slidesOffsetAfter: 56,
			},
			1536: {
				slidesPerView: 4.2,
				slidesOffsetBefore: 64,
				slidesOffsetAfter: 64,
			},
			1792: {
				slidesPerView: 4.6,
				spaceBetween: 32,
				slidesOffsetBefore: 80,
				slidesOffsetAfter: 80,
			},
		}
	});

};

export { editor };
