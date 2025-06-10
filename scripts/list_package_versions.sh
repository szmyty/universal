#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------------------------
# Script: list-installed-packages.sh
#
# Description:
#   Lists all installed packages on a Debian-based system with their versions,
#   sorted alphabetically in "package=version" format.
#
# Usage:
#   ./list-installed-packages.sh
#
# Dependencies:
#   - dpkg-query
# ------------------------------------------------------------------------------

list_installed_packages() {
    local packages

    echo "📦 Retrieving installed packages..."
    packages=$(dpkg-query --show --showformat='${Package}=${Version}\n')

    echo "📃 Installed packages (sorted):"
    echo "${packages}" | sort
}

main() {
    list_installed_packages
}

main "$@"
