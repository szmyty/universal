## 🧠 General Task

### 🧭 Objective

Refactor the API Dockerfile into a multi-stage build to optimize for local development. The goal is to support hot reloading during development while keeping build artifacts clean and production-ready.

### 🗺️ Plan

- [ ] Split Dockerfile into `builder` and `runner` stages
- [ ] In `builder`, install deps, copy source, compile (if needed)
- [ ] In `runner`, run the API using a lightweight base with volume mounting and hot reload (e.g., using `watchgod`, `uvicorn --reload`, or `nodemon`)
- [ ] Use `.dockerignore` to minimize rebuild triggers
- [ ] Mount local source volume for instant code reloads
- [ ] Add development profile to `docker-compose` or `taskfile` if needed

### 🔗 References / Resources

- [Docker multi-stage builds](https://docs.docker.com/build/building/multi-stage/)
- [FastAPI + Uvicorn reload example](https://fastapi.tiangolo.com/tutorial/reload/)
- Check `Dockerfile.api` or `Dockerfile.dev` if it exists
