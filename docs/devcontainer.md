# Dev Container Usage

This repository provides a fully configured [VS Code Dev Container](https://containers.dev/) environment.
It is designed to run on most systems that support Docker and the VS Code Dev Containers extension or the standalone `devcontainer` CLI.

## Quick Start

1. Install [Docker](https://docs.docker.com/get-docker/) for your platform.
2. Install the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) in VS Code
   or the [`devcontainer` CLI](https://github.com/devcontainers/cli).
3. Open this repository in VS Code and choose **"Reopen in Container"** when prompted.
   Alternatively run:

   ```bash
   devcontainer up
   ```

The container will build the development image. The `docker-proxy` feature
automatically runs a post-create script to finalize Docker proxy configuration.

## Features

- Docker-in-Docker support so you can run Docker commands inside the container.
- Optional proxy configuration via the custom `docker-proxy` feature.
- Development tools installed through `Taskfile.yml`.

## Troubleshooting

If Docker commands fail after the container starts, run the proxy setup
manually:

```bash
python3 /usr/local/share/docker-proxy-setup.py
```

Check the `docs` directory for additional project documentation.
