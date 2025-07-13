#!/usr/bin/env bash
# XDG Base Directory initialization script
# Author: Alan Szmyt
# Source: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html

set -euo pipefail

# Set default paths if not already defined
set_xdg_defaults() {
    export HOME="${HOME:-/root}"

    export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
    export XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
    export XDG_CACHE_HOME="${XDG_CACHE_HOME:-${HOME}/.cache}"
    export XDG_STATE_HOME="${XDG_STATE_HOME:-${HOME}/.local/state}"

    # Optional runtime dir handling (nonstandard but common in containers)
    if [[ -z "${XDG_RUNTIME_DIR:-}" ]]; then
        export XDG_RUNTIME_DIR="/tmp/xdg-runtime-${UID:-$(id -u)}"
    fi
}

# Create missing directories if needed
ensure_xdg_dirs_exist() {
    mkdir -p \
        "${XDG_CONFIG_HOME}" \
        "${XDG_DATA_HOME}" \
        "${XDG_CACHE_HOME}" \
        "${XDG_STATE_HOME}" \
        "${XDG_RUNTIME_DIR}"

    chmod 700 "${XDG_RUNTIME_DIR}"
}

# Optional log (comment out if quiet)
log_xdg_vars() {
    echo "📁 XDG paths:"
    env | grep '^XDG_'
}

main() {
    set_xdg_defaults
    ensure_xdg_dirs_exist
    log_xdg_vars
}

main "$@"
