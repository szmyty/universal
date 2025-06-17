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
import { visualizer } from "rollup-plugin-visualizer";
import wasm from "vite-plugin-wasm";

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
        visualizer({
            filename: "stats.html",
            open: false,
            gzipSize: true,
            brotliSize: true,
            emitFile: true,
        }),
        wasm(),
    ],
    server: {
        port: Number(process.env.UI_PORT) || 5173,
        // proxy: {
        //     "/api": {
        //         target: `http://localhost:${process.env.API_PORT || 8000}`,
        //         changeOrigin: true,
        //     },
        // },
        host: true,
        strictPort: true,
        cors: true,
        headers: {
            "Access-Control-Allow-Origin": "*",
        },
    },
    define: {
        global: "globalThis",
        "process.env": {
            NODE_ENV: JSON.stringify(process.env.NODE_ENV || "production"),
            NODE_DEBUG: JSON.stringify(process.env.NODE_DEBUG || false),
            VERSION: JSON.stringify(pkg.version),
            BUILD_TIME: JSON.stringify(new Date().toISOString()),
            MapboxAccessToken: JSON.stringify(
                process.env.MapboxAccessToken || "",
            ),
            MapboxExportToken: JSON.stringify(
                process.env.MapboxExportToken || "",
            ),
            DropboxClientId: JSON.stringify(process.env.DropboxClientId || ""),
            CartoClientId: JSON.stringify(process.env.CartoClientId || ""),
            FoursquareClientId: JSON.stringify(
                process.env.FoursquareClientId || "",
            ),
            FoursquareDomain: JSON.stringify(
                process.env.FoursquareDomain || "",
            ),
            FoursquareAPIURL: JSON.stringify(
                process.env.FoursquareAPIURL || "https://api.foursquare.com/v2",
            ),
            FoursquareUserMapsURL: JSON.stringify(
                process.env.FoursquareUserMapsURL || "",
            ),
            OpenAIToken: JSON.stringify(process.env.OpenAIToken || ""),
        },
    },
    optimizeDeps: {
        esbuildOptions: {
            plugins: [fixReactVirtualized],
            define: {
                global: "globalThis",
            },
        },
        include: [
            "react",
            "react-dom",
            "react-router-dom",
            "react-query",
            "zustand",
            "@tanstack/react-query",
            "@tanstack/react-router",
        ],
        exclude: ["@vitejs/plugin-react-refresh"],
    },
    resolve: {
        dedupe: ["react", "react-dom", "styled-components"],
        alias: {
            "@": path.resolve(__dirname, "src"),
        },
    },
    build: {
        outDir: "dist",
        sourcemap: true,
        minify: true,
        rollupOptions: {
            input: {
                main: path.resolve(__dirname, "index.html"),
            },
            output: {
                manualChunks: {
                    vendor: ["react", "react-dom"], // Separate React into its own chunk
                },
            },
        },
        target: "esnext",
        commonjsOptions: {
            include: [/node_modules/],
            transformMixedEsModules: true, // Allow mixing ESM and CommonJS
        },
    },
});
