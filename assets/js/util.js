window.util = {
	clipboardInsert: (content) => {
		navigator.clipboard.writeText(content);
	},

	scrollXPage: (source, target, factor = 1) => {
		target = document.getElementById(target);

		const nextPos = target.scrollLeft + factor * target.offsetWidth;

		// reached end
		if (factor > 0 && nextPos >= target.scrollWidth - target.offsetWidth || factor < 0 && nextPos <= 0) {
			liveSocket.execJS(source, source.attributes["data-hide"].value);
		}

		// unhide opposite arrow
		if (factor > 0) {
			let opposite = target.getElementsByClassName("js-scrollx-left")[0];
			liveSocket.execJS(opposite, opposite.attributes["data-show"].value);
		} else {
			let opposite = target.getElementsByClassName("js-scrollx-right")[0];
			liveSocket.execJS(opposite, opposite.attributes["data-show"].value);
		}

		target.scrollBy(factor * target.offsetWidth, 0);
	}
};

window.addEventListener("phx:scroll-end", e => {
	let element = document.getElementById(e.detail.id);
	element.scrollTop = element.scrollHeight;
});

window.addEventListener("phx:clear-input", e => {
	document.getElementById(e.detail.id).value = "";
});

window.addEventListener("phx:init-scrollx", e => {
	[...document.getElementsByClassName(e.detail.class)].forEach(e => {
		if (e.offsetWidth < e.scrollWidth) {
			let button = e.getElementsByClassName("js-scrollx-right")[0];
			liveSocket.execJS(button, button.attributes["data-show"].value);
		}
	});
});
