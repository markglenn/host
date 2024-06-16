// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")
const fs = require("fs")
const path = require("path")
// const { addIconSelectors } = require('@iconify/tailwind');

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/host_web.ex",
    "../lib/host_web/**/*.*ex"
  ],
  darkMode: 'selector',
  theme: {
    extend: {
      animation: {
        'spin-slow': 'spin 3s linear infinite',
      },
      colors: {
        brand: "#FD4F00",
        'rich-black': { DEFAULT: '#04151f', 100: '#010406', 200: '#02090d', 300: '#020d13', 400: '#031119', 500: '#04151f', 600: '#0f4f74', 700: '#1a88c7', 800: '#57b4e9', 900: '#abd9f4' },
        'white-smoke': { DEFAULT: '#eff1ed', 100: '#30362a', 200: '#606b54', 300: '#909d82', 400: '#c0c7b8', 500: '#eff1ed', 600: '#f3f4f1', 700: '#f6f7f5', 800: '#f9faf8', 900: '#fcfcfc' },
        'pomp-and-power': { DEFAULT: '#706993', 100: '#16151d', 200: '#2c293a', 300: '#423e58', 400: '#595375', 500: '#706993', 600: '#8b85a9', 700: '#a8a4be', 800: '#c5c2d4', 900: '#e2e1e9' },
        'persian-green': { DEFAULT: '#549f93', 100: '#11201e', 200: '#22403b', 300: '#336059', 400: '#448076', 500: '#549f93', 600: '#74b6ab', 700: '#97c8c0', 800: '#badad5', 900: '#dcedea' },
        'blue-munsell': { DEFAULT: '#1b9aaa', 100: '#051f22', 200: '#0b3e45', 300: '#105d67', 400: '#157c8a', 500: '#1b9aaa', 600: '#28c8dd', 700: '#5ed6e6', 800: '#93e4ee', 900: '#c9f1f7' }
      }
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({ addVariant }) => addVariant("phx-no-feedback", [".phx-no-feedback&", ".phx-no-feedback &"])),
    plugin(({ addVariant }) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({ addVariant }) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({ addVariant }) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),

    // Embeds Heroicons (https://heroicons.com) into your app.css bundle
    // See your `CoreComponents.icon/1` for more information.
    //
    plugin(function ({ matchComponents, theme }) {
      let iconsDir = path.join(__dirname, "../deps/heroicons/optimized")
      let values = {}
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"],
        ["-micro", "/16/solid"]
      ]
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).forEach(file => {
          let name = path.basename(file, ".svg") + suffix
          values[name] = { name, fullPath: path.join(iconsDir, dir, file) }
        })
      })
      matchComponents({
        "hero": ({ name, fullPath }) => {
          let content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")
          let size = theme("spacing.6")
          if (name.endsWith("-mini")) {
            size = theme("spacing.5")
          } else if (name.endsWith("-micro")) {
            size = theme("spacing.4")
          }
          return {
            [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
            "-webkit-mask": `var(--hero-${name})`,
            "mask": `var(--hero-${name})`,
            "mask-repeat": "no-repeat",
            "background-color": "currentColor",
            "vertical-align": "middle",
            "display": "inline-block",
            "width": size,
            "height": size
          }
        }
      }, { values })
    })
  ]
}
