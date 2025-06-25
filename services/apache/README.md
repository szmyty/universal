# Apache Reverse Proxy

This folder contains the Apache HTTP server configuration for all runtime environments.
Each environment has its own `conf` directory that is mounted by Docker Compose
based on the value of `APP_ENV`.

- `development` – proxies the Vite dev server and exposes ports 8084/8085
- `demo` – serves the built UI and listens on the default ports 80/443
- `production` – same layout as `demo` but intended for production deployments

The configuration exposes the React application at `/` and forwards API requests
to `/api`. Keycloak is reachable under `/auth`.
