/**
 * Vitest configuration for the Universal React template.
 * https://vitest.dev/config/
 */

import { defineConfig } from "vitest/config";
import react from "@vitejs/plugin-react";

export default defineConfig({
    plugins: [react()],
    test: {
        environment: "jsdom",
        globals: true,
        setupFiles: "./src/tests/setup.ts",
        // Uncomment if you want code coverage:
        // coverage: {
        //   reporter: ["text", "html"],
        //   reportsDirectory: "./coverage",
        // },
        include: ["src/**/*.{test,spec}.{js,ts,jsx,tsx}"],
        exclude: ["node_modules", "dist", "src/tests/mocks"],
    },
});
