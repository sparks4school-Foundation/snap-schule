/**
 * Popups
 */

function popup() {
	window.alert = (body, properties, onSuccess) => {
		setModalMessage(body, onSuccess);
		toggleModalMessage();
	}
};

export { popup };
