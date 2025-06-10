#!/usr/bin/env bash
set -euo pipefail

# Copy post-create script into a standard location
install -Dm755 "$(dirname "$0")/post_create.py" /usr/local/share/docker-proxy-setup.py

# Nothing else to do at build time
