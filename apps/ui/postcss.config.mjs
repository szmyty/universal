// postcss.config.mjs
// PostCSS configuration for Vite + TailwindCSS v3.4+
import tailwindcss from "@tailwindcss/postcss";
import autoprefixer from "autoprefixer";

export default {
    plugins: [tailwindcss(), autoprefixer()],
};
