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
	  	}
	  }
  },
  plugins: [
    require('@tailwindcss/forms')
  ]
}
