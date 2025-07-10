## 🧠 General Task

### 🧭 Objective

Resolve reverse proxy configuration for Vite's HMR WebSocket when running locally through Apache. This is needed to enable full hot reload support behind a reverse proxy.

### 🗺️ Plan

- [ ] Identify the HMR WebSocket path (default: `/socket` or `/@vite/client`)
- [ ] Ensure Apache `mod_proxy_wstunnel` is enabled
- [ ] Configure Apache `ProxyPass` and `ProxyPassReverse` for WebSocket (e.g., `ws://localhost:5173`)
- [ ] Validate CORS and origin headers if failing silently
- [ ] Try setting `server.hmr.host`, `server.hmr.protocol`, `server.hmr.clientPort` in `vite.config.ts`
- [ ] Add rewrite rules for non-WebSocket paths (e.g., `/@vite/client`)
- [ ] Confirm fallback behavior for 404s is correctly passed to Vite dev server
- [ ] Test with Vite dev server launched via `--host 0.0.0.0`

### 🔗 References / Resources

- [Vite HMR docs](https://vitejs.dev/config/server-options.html#server-hmr)
- [Apache WebSocket reverse proxy guide](https://httpd.apache.org/docs/current/mod/mod_proxy_wstunnel.html)
- Related Vite HMR issue: https://github.com/vitejs/vite/issues/2111
- Sample config:
  ```apache
  ProxyPass "/@vite" "http://localhost:5173/@vite"
  ProxyPass "/@react-refresh" "http://localhost:5173/@react-refresh"
  ProxyPass "/socket" "ws://localhost:5173/socket"
  ```
