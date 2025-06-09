// This file is used to configure PostCSS plugins for a React project using Vite.
import tailwindcss from "@tailwindcss/postcss";
import autoprefixer from "autoprefixer";

export default {
    plugins: [tailwindcss(), autoprefixer()],
};
