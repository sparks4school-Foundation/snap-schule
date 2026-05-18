/**
 * Popups
 */

function popup()
{
	window.alert = (body, properties, onSuccess) => {
		onSuccess.call();
	}
};

export { popup };
