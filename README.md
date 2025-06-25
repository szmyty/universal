# universal

This repository is managed as a pnpm monorepo. The root `package.json` only provides development tooling.

Currently the workspace includes the [cspell](https://github.com/streetsidesoftware/cspell) spell checker.

## Usage

Install the Node.js dev tools:

```sh
pnpm install
```

Install the Python dev tools:

```sh
poetry install --with dev
```

Run the spell checker:

```sh
pnpm cspell
```

For a preconfigured development environment using Docker, see
[Dev Container Usage](docs/devcontainer.md).

📁 [View Project Tree](https://szmyty.github.io/universal//tree.md)

## Applications

- `apps/ui` – React front-end application

Start the UI in dev mode with:

```bash
pnpm --filter universal-ui dev
```

## Runtime Environments

Docker Compose files allow switching between `development`, `demo`, and `production` stacks. The development configuration automatically imports a Keycloak realm from `services/keycloak/development-realm.json` so local users and roles are available out of the box.
### Docker Compose

A multi environment Docker setup is provided. Start the development stack with:

```bash
docker compose -f universal.base.yml -f universal.development.yml \
  --env-file .env.universal --env-file .env.development up --build
```

For the demo or production stacks replace `universal.development.yml` with
`universal.demo.yml` or `universal.production.yml` and supply the matching
environment files.

Apache exposes the React UI at `/` and forwards API requests to `/api`. Keycloak
is available under `/auth`.

### Default Credentials

- **Keycloak Admin:** `admin` / `6UE7nLjzv3F86qkChHwXaZoftMgYlazl`
- **pgAdmin Login:** `admin@universal.localhost` / `6UE7nLjzv3F86qkChHwXaZoftMgYlazl`

### Access URLs (development)

- UI: http://localhost:8084 (or https://localhost:8085)
- Keycloak: https://localhost:8085/auth
- API: https://localhost:8085/api
- pgAdmin: http://localhost:5050
