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
			boxShadow: {
				'equal': '0 0 12px -3px hsl(0 0% 0% / 0.5)'
			},
			colors: {
				accent: {
					100: '#f9e6ff',
					200: '#edc3fe',
					300: '#d88efb',
					400: '#ba5df4',
					500: '#9728e6',
					600: '#6c0fb8',
					700: '#470684',
					800: '#2c025a',
					900: '#190038',
				},
				gray: {
					50:  '#fcfcfd',
					100: '#dee0e3',
					200: '#c4c6ca',
					300: '#a0a5ab',
					400: '#7c8188',
					500: '#5d6269',
					600: '#444850',
					700: '#33373d',
					800: '#25272d',
					900: '#17181c',
				},
			},
			fontFamily: {
				'sans': ['"Open Sans"', 'sans-serif'],
				'display': ['"Poppins"', 'sans-serif']
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
