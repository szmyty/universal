Configuration for local development. `httpd.conf` proxies to the Vite dev
server on port 5173 while `httpd-ssl.conf` adds TLS and routes `/api` and
`/auth` to the API and Keycloak services.
