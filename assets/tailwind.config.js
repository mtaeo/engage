// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration
const plugin = require('tailwindcss/plugin');
const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
	content: [
		'./js/**/*.js',
		'../lib/*_web.ex',
		'../lib/*_web/**/*.*ex'
	],
	theme: {
		screens: {
			'xxs': '400px',
			'xs': '480px',
			...defaultTheme.screens
		},
		extend: {
			animation: {
				'alert-enter-down': 'alert-enter-down 0.3s ease-out',
				'alert-leave-up': 'alert-leave-up 5s ease-out'
			},
			keyframes: {
				'alert-enter-down': {
					'from': {
						transform: 'translate(-50%, calc(-100% - 8rem))'
					},
					'to': {
						transform: 'translate(-50%, 0)'
					}
				},
				'alert-leave-up': {
					'0%, 90%': {
						transform: 'translate(-50%, 0)'
					},
					'100%': {
						transform: 'translate(-50%, calc(-100% - 8rem))'
					}
				}
			},
			backgroundImage: {
				'pattern-dark': "url('/images/background-dark.svg')",
				'pattern-light': "url('/images/background-light.svg')"
			},
			boxShadow: {
				'equal': '0 0 12px -3px hsl(0 0% 0% / 0.5)',
				'equal-lg': '0 0 12px 0px hsl(0 0% 0% / 0.5)'
			},
			colors: {
				accent: {
					100: '#f9e5ff',
					200: '#edc3fe',
					300: '#d88efb',
					400: '#ba5df4',
					500: '#9727e7',
					600: '#6b18af',
					700: '#471278',
					800: '#2d0d4f',
					900: '#1a0830',
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
				theme: {
					1: 'var(--theme-1)',
					2: 'var(--theme-2)',
					3: 'var(--theme-3)',
					4: 'var(--theme-4)',
					5: 'var(--theme-5)',
					6: 'var(--theme-6)',
					7: 'var(--theme-7)',
					8: 'var(--theme-8)',
					9: 'var(--theme-9)',
					10: 'var(--theme-10)'
				}
			},
			fontFamily: {
				'sans': ['"Open Sans"', 'sans-serif'],
				'display': ['"Poppins"', 'sans-serif']
			},
			gridTemplateColumns: {
				'presentation': '3fr 2fr',
				'presentation-reverse': '2fr 3fr'
			},
			spacing: {
				'120': '30rem',
				'144': '36rem'
			},
			translate: {
				'alert-hide': 'calc(-100% - 8rem)'
			}
		}
	},
	plugins: [
		require('@tailwindcss/forms'),
		plugin(({addVariant}) => {
			addVariant('sidebar-toggled', '&.sidebar-toggled');
		})
	]
}
