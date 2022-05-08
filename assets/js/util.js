window.util = {
	toggleSidebar: () => {
		document.getElementById("sidebar").classList.toggle("sidebar-toggled");
	},
	
	/**
	 *  The parent of this element requires a non-direct child with the js-local-dropdown class.
	 */
	toggleLocalDropdown: (sender) => {
		let d = sender.parentElement.getElementsByClassName("js-local-dropdown");
		
		if (d.length > 0) {
			d[0].classList.toggle("hidden");
		} else {
			console.log("Error: no local dropdown element found! Sender:");
			console.log(sender);
		}
	}
};
