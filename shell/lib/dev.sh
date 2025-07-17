#!/usr/bin/env bash
# dev.sh — main entrypoint for sourcing all modules

# Prevent direct execution
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && {
    echo "❌ dev.sh must be sourced, not executed." >&2
    exit 1
}

_libdir="${BASH_SOURCE%/*}"

# shellcheck source=/dev/null
source "${_libdir}/_os.sh"
