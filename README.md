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

📁 [View Project Tree](https://szmyty.github.io/universal//tree.md)
