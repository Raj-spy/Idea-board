/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter', 'ui-sans-serif', 'system-ui', 'sans-serif'],
      },
      colors: {
        ink: '#17233d',
        muted: '#66718a',
        canvas: '#f6f7fb',
        violet: '#6558d3',
      },
      boxShadow: {
        card: '0 12px 36px rgba(27, 39, 72, 0.07)',
      },
    },
  },
  plugins: [],
}
