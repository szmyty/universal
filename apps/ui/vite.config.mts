import path from "path";
import process from "node:process";
import { defineConfig } from "vitest/config";
import react from "@vitejs/plugin-react";
import svgr from "vite-plugin-svgr";
import envCompatible from "vite-plugin-env-compatible";
import eslint from "vite-plugin-eslint";
import tsconfigPaths from "vite-tsconfig-paths";
import checker from "vite-plugin-checker";
import { VitePWA } from "vite-plugin-pwa";
import { visualizer } from "rollup-plugin-visualizer";
import wasm from "vite-plugin-wasm";
import fixReactVirtualized from "esbuild-plugin-react-virtualized";
import pkg from "./package.json";
import postcss from "./postcss.config.mjs";

// Inject selected environment variables
const env = {
    NODE_ENV: process.env.NODE_ENV || "production",
    NODE_DEBUG: process.env.NODE_DEBUG || "false",
    VERSION: pkg.version,
    BUILD_TIME: new Date().toISOString(),
    MapboxAccessToken: process.env.MapboxAccessToken || "",
    MapboxExportToken: process.env.MapboxExportToken || "",
    DropboxClientId: process.env.DropboxClientId || "",
    CartoClientId: process.env.CartoClientId || "",
    FoursquareClientId: process.env.FoursquareClientId || "",
    FoursquareDomain: process.env.FoursquareDomain || "",
    FoursquareAPIURL:
        process.env.FoursquareAPIURL || "https://api.foursquare.com/v2",
    FoursquareUserMapsURL: process.env.FoursquareUserMapsURL || "",
    OpenAIToken: process.env.OpenAIToken || "",
};

export default defineConfig({
    css: {
        postcss,
    },
    plugins: [
        react({ jsxRuntime: "automatic" }),
        tsconfigPaths(),
        svgr(),
        envCompatible(),
        eslint({
            overrideConfigFile: path.resolve(__dirname, "eslint.config.mjs"),
            include: ["src/**/*.ts", "src/**/*.tsx"],
            cacheLocation: "node_modules/.cache/eslint",
            cache: true,
            exclude: ["node_modules/**", "/virtual:/**"],
        }),
        checker({ typescript: true }),
        VitePWA(),
        wasm(),
        visualizer({
            filename: "stats.html",
            open: false,
            gzipSize: true,
            brotliSize: true,
            emitFile: true,
        }),
    ],

    resolve: {
        alias: {
            "@": path.resolve(__dirname, "src"),
        },
        dedupe: ["react", "react-dom", "styled-components"],
    },

    server: {
        port: Number(process.env.UI_PORT) || 5173,
        host: true,
        strictPort: true,
        cors: true,
        headers: {
            "Access-Control-Allow-Origin": "*",
        },
        // proxy: {
        //     "/api": {
        //         target: `http://localhost:${process.env.API_PORT || 8000}`,
        //         changeOrigin: true,
        //     },
        // },
    },

    define: {
        global: "globalThis",
        "process.env": Object.fromEntries(
            Object.entries(env).map(([key, val]) => [key, JSON.stringify(val)])
        ),
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
            "zustand",
            "react-query",
            "@tanstack/react-query",
            "@tanstack/react-router",
        ],
        exclude: ["@vitejs/plugin-react-refresh"],
    },

    build: {
        outDir: "dist",
        target: "esnext",
        sourcemap: true,
        minify: true,
        commonjsOptions: {
            include: [/node_modules/],
            transformMixedEsModules: true,
        },
        rollupOptions: {
            input: {
                main: path.resolve(__dirname, "index.html"),
            },
            output: {
                manualChunks: {
                    vendor: ["react", "react-dom"],
                },
            },
        },
    },
});
