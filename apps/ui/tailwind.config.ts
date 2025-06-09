import { type Config } from "tailwindcss";

const config: Config = {
    content: ["./index.html", "./src/**/*.{ts,tsx,css,scss,js,jsx}"],
    theme: {
        extend: {
            fontFamily: {
                sans: ["Inter", "system-ui", "sans-serif"],
                mono: ["Fira Code", "monospace"],
            },
        },
    },
    plugins: [],
};

export default config;
