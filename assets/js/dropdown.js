/**
 *  Requires this HTML structure (any level of nesting):
 *  .js-dropdown
 *  	.js-dropdown-button
 *  	.js-dropdown-content
 */

[...document.getElementsByClassName("js-dropdown")].forEach((wrapper) => {
	const button = wrapper.getElementsByClassName("js-dropdown-button")[0]
	button.dropdownContent = wrapper.getElementsByClassName("js-dropdown-content")[0];
	
	if (button.dropdownContent) {
		button.addEventListener("click", (sender) => {
			sender.currentTarget.dropdownContent.classList.toggle("hidden");
		})
	}
});
