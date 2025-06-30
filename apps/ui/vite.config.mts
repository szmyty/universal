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
import ViteSitemapPlugin from "vite-plugin-sitemap";
import tailwindcss from "@tailwindcss/vite";

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
    WEB_HTTPS_PORT: process.env.WEB_HTTPS_PORT || 443,
    FQDN: process.env.FQDN || "localhost",
    API_PREFIX: process.env.API_PREFIX || "/api",
    MOCK_AUTH: process.env.MOCK_AUTH || "false",
};

export default defineConfig({
    base: "/", // Base path for the application
    publicDir: "public", // Directory for static assets
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
        tailwindcss(),
        wasm(),
        visualizer({
            filename: "stats.html",
            open: false,
            gzipSize: true,
            brotliSize: true,
            emitFile: true,
        }),
        // ViteSitemapPlugin({
        //     hostname: "https://yourdomain.com",
        // }),
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
    },
    define: {
        global: "globalThis",
        ...Object.fromEntries(
            Object.entries(env).map(([key, val]) => [
                `import.meta.env.${key}`,
                JSON.stringify(val),
            ]),
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
