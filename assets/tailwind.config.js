// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration
module.exports = {
	content: [
		'./js/**/*.js',
		'../lib/*_web.ex',
		'../lib/*_web/**/*.*ex'
	],
	theme: {
		extend: {
			backgroundImage: {
				'pattern-dark': "url('/images/background-dark.svg')",
				'pattern-light': "url('/images/background-light.svg')"
			},
			fontFamily: {
				'sans': ['"Open Sans"', 'sans-serif'],
				'title': ['"Poppins"', 'sans-serif']
			},
			gridTemplateColumns: {
				'presentation': '3fr 2fr',
				'presentation-reverse': '2fr 3fr'
			}
		}
	},
	plugins: [
		require('@tailwindcss/forms')
	]
}
