#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Dev Container Feature: Docker Proxy Setup
# -----------------------------------------------------------------------------

FEATURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="post_create.py"
PYTHON_SCRIPT="${FEATURE_DIR}/${SCRIPT_NAME}"
CONFIG_ENV_FILE="/etc/devcontainer/docker-proxy.env"
LOG_FILE="/var/log/.devtools/docker-proxy-setup.log"

# Create log file directory early
mkdir -p "$(dirname "${LOG_FILE}")"

log_info() {
    local message="$1"
    printf "[INFO]  %s | %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "${message}" | tee -a "${LOG_FILE}"
}

log_error() {
    local message="$1"
    printf "[ERROR] %s | %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "${message}" | tee -a "${LOG_FILE}" >&2
}

log_debug() {
    local message="$1"
    if [[ "${DEBUG:-false}" == "true" ]]; then
        printf "[DEBUG] %s | %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "${message}" | tee -a "${LOG_FILE}"
    fi
}

trap 'log_error "Script failed at line $LINENO"; exit 1' ERR

resolve_env_vars() {
    HTTP_PROXY="${HTTP_PROXY:-""}"
    HTTPS_PROXY="${HTTPS_PROXY:-""}"
    NO_PROXY="${NO_PROXY:-""}"
    DOCKER_DNS="${DOCKER_DNS:-"8.8.8.8"}"
    INSECURE_REGISTRIES="${INSECURE_REGISTRIES:-""}"
    LOG_FILE="${LOG_FILE}"
}

log_config() {
    log_info "🚀 Starting Docker proxy feature install..."
    log_info "🔧 HTTP_PROXY=${HTTP_PROXY}"
    log_info "🔧 HTTPS_PROXY=${HTTPS_PROXY}"
    log_info "🔧 NO_PROXY=${NO_PROXY}"
    log_info "🔧 DOCKER_DNS=${DOCKER_DNS}"
    log_info "🔧 INSECURE_REGISTRIES=${INSECURE_REGISTRIES}"
    log_info "📝 LOG_FILE=${LOG_FILE}"
}

write_env_file() {
    log_info "📄 Writing environment configuration to ${CONFIG_ENV_FILE}"
    mkdir -p "$(dirname "${CONFIG_ENV_FILE}")"
    {
        printf 'HTTP_PROXY="%s"\n' "${HTTP_PROXY}"
        printf 'HTTPS_PROXY="%s"\n' "${HTTPS_PROXY}"
        printf 'NO_PROXY="%s"\n' "${NO_PROXY}"
        printf 'DOCKER_DNS="%s"\n' "${DOCKER_DNS}"
        printf 'INSECURE_REGISTRIES="%s"\n' "${INSECURE_REGISTRIES}"
        printf 'LOG_FILE="%s"\n' "${LOG_FILE}"
    } | sudo tee "${CONFIG_ENV_FILE}" >/dev/null
    chmod 0644 "${CONFIG_ENV_FILE}"
}

copy_python_script() {
    log_info "🐍 Installing supporting Python script to /usr/local/share/"
    cp "${PYTHON_SCRIPT}" /usr/local/share/docker-proxy-setup.py
}

main() {
    resolve_env_vars
    log_config
    write_env_file
    copy_python_script
    log_info "✅ Docker proxy setup complete!"
}

main "$@"
