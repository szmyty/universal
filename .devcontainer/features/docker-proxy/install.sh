#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Dev Container Feature: Docker Proxy Setup
# -----------------------------------------------------------------------------

# Constants
FEATURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="post_create.py"
PYTHON_SCRIPT="${FEATURE_DIR}/${SCRIPT_NAME}"
CONFIG_ENV_FILE="/etc/devcontainer/docker-proxy.env"

# Resolve feature options passed as containerEnv or default values
resolve_env_vars() {
    HTTP_PROXY="${HTTPPROXY:-""}"
    HTTPS_PROXY="${HTTPSPROXY:-""}"
    NO_PROXY="${NOPROXY:-""}"
    DOCKER_DNS="${DOCKERDNS:-"8.8.8.8"}"
    INSECURE_REGISTRIES="${INSECUREREGISTRIES:-""}"
    LOG_FILE="${LOGFILE:-"/var/log/.devtools/docker-proxy-setup.log"}"
}

log_config() {
    echo "🚀 Starting Docker proxy feature install..."
    echo "🔧 HTTP_PROXY=${HTTP_PROXY}"
    echo "🔧 HTTPS_PROXY=${HTTPS_PROXY}"
    echo "🔧 NO_PROXY=${NO_PROXY}"
    echo "🔧 DOCKER_DNS=${DOCKER_DNS}"
    echo "🔧 INSECURE_REGISTRIES=${INSECURE_REGISTRIES}"
    echo "📝 LOG_FILE=${LOG_FILE}"
}

write_env_file() {
    mkdir -p "$(dirname "${CONFIG_ENV_FILE}")"
    cat <<EOF | sudo tee "${CONFIG_ENV_FILE}" >/dev/null
HTTP_PROXY="${HTTP_PROXY:-}"
HTTPS_PROXY="${HTTPS_PROXY:-}"
NO_PROXY="${NO_PROXY:-}"
DOCKER_DNS="${DOCKER_DNS:-8.8.8.8}"
INSECURE_REGISTRIES="${INSECURE_REGISTRIES:-}"
LOG_FILE="${LOG_FILE:-/home/vscode/.devtools/docker-proxy.log}"
EOF
    chmod 0644 "${CONFIG_ENV_FILE}"
}

copy_python_script() {
    cp "${PYTHON_SCRIPT}" /usr/local/share/docker-proxy-setup.py
}

main() {
    resolve_env_vars
    log_config
    write_env_file
    copy_python_script
    echo "✅ Docker proxy setup complete!"
}

main "$@"
