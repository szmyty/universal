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
