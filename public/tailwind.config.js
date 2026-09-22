/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: 'class',
  content: [
	'./src/**/*.{html,js}',
	'./*.html',
	'./partials/*.html',
	'./adx/*.html'
  ],
  theme: {
    extend: {
	fontFamily: {
		'sans': ['Inter', 'system-ui', 'sans-serif'],
	}
    },
  },
  plugins: [require('tailwindcss-motion')],
}
