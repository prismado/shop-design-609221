/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: 'class',
  content: [
	'./src/**/*.{html,js}',
	'./*.html',
	'./partials/*.html',
	'./adx/*.html',
	'./parts/*.html',	// -- z. B. parts/main_order_detail.html
	'./*/parts/*.html'	// -- z. B. about/parts/main.html, order_detail/parts/main_order_detail.html
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
