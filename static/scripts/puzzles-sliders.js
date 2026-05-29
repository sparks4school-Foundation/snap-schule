/**
 * Sliders
 */

function puzzlesSliders()
{
	const sliders = document.querySelectorAll('[data-puzzles-slider="wrapper"]');

	sliders.forEach( slider => {
		const btnPrev = slider.parentElement.querySelector('[data-puzzles-slider="button-prev"');
		const btnNext = slider.parentElement.querySelector('[data-puzzles-slider="button-next"');
		const pagination = slider.parentElement.querySelector('[data-puzzles-slider="pagination"]');

		const sliderInstance = new Swiper(slider, {

			// Optional parameters
			slidesPerView: 1.2,
			spaceBetween: 16,

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
				},
				768: {
					slidesPerView: 2.8,
				},
				1024: {
					slidesPerView: 3.2,
					spaceBetween: 24,
				},
				1280: {
					slidesPerView: 4,
					spaceBetween: 24,
				},
				1536: {
					slidesPerView: 4.4,
				},
				1792: {
					slidesPerView: 4.8,
					spaceBetween: 32,
				},
			}
		});
	});

};

export { puzzlesSliders };
