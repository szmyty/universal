import path from "path";
import process from "node:process";
import { fileURLToPath } from "url";
import { defineConfig } from "vitest/config";
import react from "@vitejs/plugin-react";
import svgr from "vite-plugin-svgr";
import envCompatible from "vite-plugin-env-compatible";
import eslint from "vite-plugin-eslint";
import tsconfigPaths from "vite-tsconfig-paths";
import checker from "vite-plugin-checker";
import tailwindcss from "@tailwindcss/vite";
import { VitePWA } from "vite-plugin-pwa";
import pkg from "./package.json";
import fixReactVirtualized from "esbuild-plugin-react-virtualized";

// Resolve __dirname since we're in ES module context
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Define constants
const ESLINT_CONFIG_PATH = path.resolve(__dirname, ".eslint.config.mjs");

export default defineConfig({
    plugins: [
        react({
            jsxRuntime: "automatic",
        }),
        svgr(),
        envCompatible(),
        eslint({
            overrideConfigFile: ESLINT_CONFIG_PATH,
            include: ["src/**/*.ts", "src/**/*.tsx"],
            cacheLocation: "node_modules/.cache/eslint",
            cache: true,
            exclude: ["/virtual:/**", "node_modules/**"],
        }),
        tsconfigPaths(),
        checker({
            typescript: true,
        }),
        VitePWA(),
        tailwindcss(),
    ],
    server: {
        port: Number(process.env.UI_PORT) || 5173,
        proxy: {
            "/api": {
                target: `http://localhost:${process.env.API_PORT || 8000}`,
                changeOrigin: true,
            },
        },
        host: true,
        strictPort: true,
        cors: true,
        headers: {
            "Access-Control-Allow-Origin": "*",
        },
    },
    optimizeDeps: {
        esbuildOptions: {
            plugins: [fixReactVirtualized],
        },
    },
});
