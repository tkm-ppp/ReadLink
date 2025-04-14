// tailwind.config.js
module.exports = {
  content: [
    "./app/**/*.{html.erb, html, js}",
    './app/helpers/**/*.rb',
    './app/javascript/**/*.{js,jsx,ts,tsx}'
  ],
  theme: {
    extend: {},
  },
  plugins: [require('daisyui')],
}