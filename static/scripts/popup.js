/**
 * Popups
 */

function popup() {
	window.alert = (body, properties, onSuccess) => {
		setModalMessage(properties.title, body, onSuccess);
		toggleModalMessage('alert');
	};
	window.confirm = (body, onSuccess) => {
		setModalMessage('Confirmation', body, onSuccess, toggleModalMessage);
		toggleModalMessage('confirm');
	};
	window.prompt = (body, onSuccess, onCancel) => {
		setModalMessage('Input', body, onSuccess, onCancel);
		toggleModalMessage('prompt');
	};
};

export { popup };
