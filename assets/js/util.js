window.util = {
	clipboardInsert: (content) => {
		navigator.clipboard.writeText(content);
	}
};

window.addEventListener("phx:scroll-end", e => {
	let element = document.getElementById(e.detail.id);
	element.scrollTop = element.scrollHeight;
});

window.addEventListener("phx:clear-input", e => {
	document.getElementById(e.detail.id).value = "";
});
