## 🧠 General Task

### 🧭 Objective

Restructure our Dockerfiles using multi-stage builds and layer separation to improve build-time caching and enable near hot-reload-level efficiency during development.

### 🗺️ Plan

- [ ] Move `apt-get` or system-level installs into an early dedicated stage
- [ ] Use intermediate `FROM deps` or `FROM base` stages to prevent redundant downloads
- [ ] Copy project files in a later step to avoid invalidating base layers
- [ ] Validate that rebuilding after source code changes skips system deps and rebuilds faster

### 🔗 References / Resources

- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- `docker build --progress=plain` for debugging cache usage
- Discussion about caching and rebuild speed improvements
