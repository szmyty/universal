## 🧠 General Task

### 🧭 Objective

Standardize and finalize environment variable naming and usage across the deployment pipeline, and ensure the Jenkinsfile references them consistently.

### 🗺️ Plan

- [ ] Audit current env variables used across `.env`, `vite.config.ts`, and Docker-related scripts
- [ ] Rename or adjust variables for clarity and consistency (e.g., `MAPBOX_ACCESS_TOKEN`, `API_PREFIX`)
- [ ] Update `Jenkinsfile` to consume the correct env variables at build/runtime
- [ ] Validate that deployment works with minimal overrides

### 🔗 References / Resources

- Current `Jenkinsfile`
- `.env`, `.env.production`, and build config patterns
- Related task: moving away from `define`-injected env vars in Vite
