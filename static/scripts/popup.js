/**
 * Popups
 */

function popup() {
	window.alert = (body, properties, onSuccess) => {
		setModalMessage(properties.title, body, onSuccess);
		toggleModalMessage();
	}
	window.confirm = (body, onSuccess) => {
		console.log(body);
		console.log(onSuccess);

		setModalMessage('Confirmation', body, onSuccess, toggleModalMessage);
		toggleModalMessage();
	}
};

export { popup };
