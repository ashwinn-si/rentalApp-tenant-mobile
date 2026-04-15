/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./app/**/*.{js,jsx,ts,tsx}", "./components/**/*.{js,jsx,ts,tsx}"],
  presets: [require("nativewind/preset")],
  theme: {
    extend: {
      colors: {
        brand: {
          violet: "#7c3aed",
          fuchsia: "#a21caf",
          rose: "#e11d48"
        }
      }
    }
  },
  plugins: []
};
