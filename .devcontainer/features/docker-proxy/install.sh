#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Dev Container Feature: Docker Proxy Setup
#
# This script is executed at build time. It prepares the environment by
# invoking the Python script that applies proxy, DNS, and insecure registry
# configuration for Docker and the dev container.
# -----------------------------------------------------------------------------

# Constants
FEATURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="post_create.py"
PYTHON_SCRIPT="${FEATURE_DIR}/${SCRIPT_NAME}"

# Resolve feature options passed as containerEnv or default values
HTTP_PROXY="${HTTP_PROXY:-""}"
HTTPS_PROXY="${HTTPS_PROXY:-""}"
NO_PROXY="${NO_PROXY:-""}"
DOCKER_DNS="${DOCKER_DNS:-"8.8.8.8"}"
INSECURE_REGISTRIES="${INSECURE_REGISTRIES:-""}"
LOG_FILE="${LOG_FILE:-"/var/log/.devtools/docker-proxy-setup.log"}"

# Logging
echo "🚀 Starting Docker proxy feature install..."
echo "🔧 HTTP_PROXY=${HTTP_PROXY}"
echo "🔧 HTTPS_PROXY=${HTTPS_PROXY}"
echo "🔧 NO_PROXY=${NO_PROXY}"
echo "🔧 DOCKER_DNS=${DOCKER_DNS}"
echo "🔧 INSECURE_REGISTRIES=${INSECURE_REGISTRIES}"
echo "📝 LOG_FILE=${LOG_FILE}"

# Execute Python logic directly during install
if [[ -f "${PYTHON_SCRIPT}" ]]; then
    echo "🐍 Running proxy setup via Python..."
    sudo /usr/bin/python3 "${PYTHON_SCRIPT}" \
        --http-proxy "${HTTP_PROXY}" \
        --https-proxy "${HTTPS_PROXY}" \
        --no-proxy "${NO_PROXY}" \
        --docker-dns "${DOCKER_DNS}" \
        --insecure-registries "${INSECURE_REGISTRIES}" \
        --log-file "${LOG_FILE}"
else
    echo "❌ Could not find script: ${PYTHON_SCRIPT}"
    exit 1
fi

echo "✅ Docker proxy setup complete!"
