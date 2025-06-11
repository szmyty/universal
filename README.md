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
