module.exports = {
  content: [
    "./layouts/**/*.html",
    "./content/**/*.md", 
    "./data/**/*.{yml,yaml,json}"
  ],
  theme: {
    extend: {
      colors: {
        brand: {
          DEFAULT: "#0ea5a7",
          dark: "#0f172a"
        }
      },
      borderRadius: {
        '2xl': '1rem'
      }
    }
  },
  plugins: [
    require('@tailwindcss/typography')
  ]
};
