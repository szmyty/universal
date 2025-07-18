## 🧠 General Task

### 🧭 Objective

Refactor the Vite build process to stop injecting environment variables at build time via `define`. Instead, move to a runtime configuration pattern so environment-specific values can change without rebuilding.

### 🗺️ Plan

- [ ] Remove `define: { import.meta.env.* }` from `vite.config.ts`
- [ ] Create a runtime `config.json` or `window.__CONFIG__` object to hold env values
- [ ] Populate that config from the server (e.g., via Docker entrypoint or volume)
- [ ] Update client code to load config dynamically (e.g., `fetch('/config.json')`)
- [ ] Verify that secrets and environment differences are no longer hardcoded into the build

### 🔗 References / Resources

- [Vite Env Docs](https://vitejs.dev/guide/env-and-mode.html)
- Discussion about `define` in `vite.config.ts`
- Runtime injection options: config.json or `window.__CONFIG__` pattern
