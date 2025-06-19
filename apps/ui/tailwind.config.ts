/**
 * Tailwind CSS configuration for the Universal React template.
 * Includes typography, form styling, and responsive aspect ratio utilities.
 * https://tailwindcss.com/docs/configuration
 */

import type { Config } from "tailwindcss";
import forms from "@tailwindcss/forms";
import typography from "@tailwindcss/typography";
import aspectRatio from "@tailwindcss/aspect-ratio";

const config: Config = {
    content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx,css,scss}"],
    theme: {
        extend: {
            fontFamily: {
                sans: ["Inter", "system-ui", "sans-serif"],
                mono: ["Fira Code", "monospace"],
            },
        },
    },
    plugins: [forms(), typography(), aspectRatio()],
};

export default config;
