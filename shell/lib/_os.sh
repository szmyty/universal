#!/usr/bin/env bash
# _os.sh — OS and architecture utilities

# Prevent direct execution
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && {
    echo "❌ _os.sh must be sourced, not executed." >&2
    exit 1
}

# shellcheck source=_common.sh disable=SC1091
source "${BASH_SOURCE%/*}/_common.sh"

# -----------------------------------------------------------------------------
# Function: os::operating_system
#
# Description:
#   Detects the host operating system and returns it as a lowercase string.
#
# Usage:
#   os="$(os::operating_system)"
#
# Arguments:
#   None
#
# Returns:
#   Prints the OS name (e.g., "linux", "darwin", "cygwin") to stdout.
#
# Example:
#   if [[ "$(os::operating_system)" == "linux" ]]; then echo "Running on Linux"; fi
# -----------------------------------------------------------------------------
os::operating_system() {
    local os
    os=$(uname -s 2>/dev/null) || return 1
    echo "${os}" | tr '[:upper:]' '[:lower:]'
    return 0
}

# -----------------------------------------------------------------------------
# Function: os::architecture
#
# Description:
#   Detects the CPU architecture and normalizes it into a standard name.
#
# Usage:
#   arch="$(os::architecture)"
#
# Arguments:
#   None
#
# Returns:
#   Prints the normalized architecture (e.g., "amd64", "arm64").
#   Exits with error and logs a message if unsupported.
#
# Example:
#   if [[ "$(os::architecture)" == "arm64" ]]; then echo "ARM machine"; fi
# -----------------------------------------------------------------------------
os::architecture() {
    local raw_arch
    raw_arch="$(uname -m 2>/dev/null || true)"

    case "${raw_arch}" in
    x86_64) printf "amd64\n" ;;
    aarch64 | arm64) printf "arm64\n" ;;
    *)
        log "❌ Unsupported architecture: ${raw_arch}"
        return 1
        ;;
    esac
}

# -----------------------------------------------------------------------------
# Function: os::is_linux
#
# Description:
#   Checks if the current operating system is Linux.
#
# Usage:
#   if os::is_linux; then echo "Linux host"; fi
#
# Arguments:
#   None
#
# Returns:
#   Exit code 0 if Linux, non-zero otherwise.
# -----------------------------------------------------------------------------
os::is_linux() {
    local os
    os="$(os::operating_system)"
    [[ "${os}" == "linux" ]]
}

# -----------------------------------------------------------------------------
# Function: os::is_macos
#
# Description:
#   Checks if the current operating system is macOS (Darwin).
#
# Usage:
#   if os::is_macos; then echo "macOS host"; fi
#
# Arguments:
#   None
#
# Returns:
#   Exit code 0 if macOS, non-zero otherwise.
# -----------------------------------------------------------------------------
os::is_macos() {
    local os
    os="$(os::operating_system)"
    [[ "${os}" == "darwin" ]]
}

# -----------------------------------------------------------------------------
# Function: os::is_windows
#
# Description:
#   Checks if the current environment is Windows via Cygwin or MinGW.
#
# Usage:
#   if os::is_windows; then echo "Windows environment"; fi
#
# Arguments:
#   None
#
# Returns:
#   Exit code 0 if detected as Windows, non-zero otherwise.
# -----------------------------------------------------------------------------
os::is_windows() {
    local os
    os="$(os::operating_system)"
    [[ "${os}" == "cygwin" || "${os}" == mingw* ]]
}

# -----------------------------------------------------------------------------
# Function: os::is_wsl
#
# Description:
#   Checks if the system is running under Windows Subsystem for Linux (WSL).
#
# Usage:
#   if os::is_wsl; then echo "WSL environment"; fi
#
# Arguments:
#   None
#
# Returns:
#   Exit code 0 if WSL, non-zero otherwise.
# -----------------------------------------------------------------------------
os::is_wsl() {
    os::is_linux && grep -qi 'microsoft' /proc/version 2>/dev/null
}

# -----------------------------------------------------------------------------
# Function: os::is_debian
#
# Description:
#   Checks if the system is Debian-based by looking for /etc/debian_version.
#
# Usage:
#   if os::is_debian; then echo "Debian-like system"; fi
#
# Arguments:
#   None
#
# Returns:
#   Exit code 0 if Debian-like system, non-zero otherwise.
# -----------------------------------------------------------------------------
os::is_debian() {
    [[ -f /etc/debian_version ]]
}

# -----------------------------------------------------------------------------
# Function: os::is_ubuntu
#
# Description:
#   Checks if the system is specifically Ubuntu.
#
# Usage:
#   if os::is_ubuntu; then echo "Ubuntu detected"; fi
#
# Arguments:
#   None
#
# Returns:
#   Exit code 0 if Ubuntu, non-zero otherwise.
# -----------------------------------------------------------------------------
os::is_ubuntu() {
    [[ -f /etc/lsb-release ]] && grep -q "DISTRIB_ID=Ubuntu" /etc/lsb-release
}

# -----------------------------------------------------------------------------
# Function: os::kernel
#
# Description:
#   Returns the kernel release string (e.g., the output of `uname -r`).
# -----------------------------------------------------------------------------
os::kernel() {
    uname -r 2>/dev/null || true
}

# -----------------------------------------------------------------------------
# Function: os::distro
#
# Description:
#   Returns the distribution ID from /etc/os-release if available.
# -----------------------------------------------------------------------------
os::distro() {
    if [[ -f /etc/os-release ]]; then
        local line distro_id
        line="$(grep '^ID=' /etc/os-release 2>/dev/null)" || return 1
        distro_id="$(echo "${line}" | cut -d= -f2)"
        echo "${distro_id}" | tr -d '"'
    elif os::is_macos; then
        printf "macos"
    fi
}

# -----------------------------------------------------------------------------
# Function: os::version
#
# Description:
#   Returns the distribution version from /etc/os-release if available.
# -----------------------------------------------------------------------------
os::version() {
    if [[ -f /etc/os-release ]]; then
        local line version_id
        line="$(grep '^VERSION_ID=' /etc/os-release 2>/dev/null)" || return 1
        version_id="$(echo "${line}" | cut -d= -f2)"
        echo "${version_id}" | tr -d '"'
    elif os::is_macos; then
        sw_vers -productVersion 2>/dev/null
    fi
}

# -----------------------------------------------------------------------------
# Function: os::id_like
#
# Description:
#   Extracts the ID_LIKE value from /etc/os-release to determine OS family.
#
# Usage:
#   family="$(os::id_like)"
#
# Arguments:
#   None
#
# Returns:
#   Prints the ID_LIKE string (e.g., "debian", "rhel") or nothing if unavailable.
# -----------------------------------------------------------------------------
os::id_like() {
    if [[ -f /etc/os-release ]]; then
        grep '^ID_LIKE=' /etc/os-release | cut -d= -f2 | tr -d '"' || true
    elif os::is_macos; then
        printf "darwin"
    fi
}

# -----------------------------------------------------------------------------
# Function: os::is_supported
#
# Description:
#   Validates that both OS and ARCH are supported.
#
# Usage:
#   if os::is_supported; then proceed; else exit 1; fi
#
# Arguments:
#   None
#
# Returns:
#   Exit code 0 if both OS and ARCH are valid, non-zero otherwise.
# -----------------------------------------------------------------------------
os::is_supported() {
    os::operating_system &>/dev/null && os::architecture &>/dev/null
}

# -----------------------------------------------------------------------------
# Function: os::print_info
#
# Description:
#   Outputs OS and architecture information as a JSON-like string.
#
# Usage:
#   os::print_info
#
# Arguments:
#   None
#
# Returns:
#   Prints: {"os":"linux","arch":"amd64"}
# -----------------------------------------------------------------------------
os::print_info() {
    local os arch
    os="$(os::operating_system)"
    arch="$(os::architecture)"
    if [[ -z "${os}" || -z "${arch}" ]]; then
        log::error "❌ Unable to determine OS or architecture"
        return 1
    fi
    log "🖥️  Detected OS: ${os}, Architecture: ${arch}"
}

# -----------------------------------------------------------------------------
# Function: os::init
#
# Description:
#   Detects the host operating system and architecture, sets global OS and ARCH
#   variables, and logs the result.
#
# Usage:
#   os::init
#
# Arguments:
#   None
#
# Returns:
#   Sets global variables OS and ARCH.
#   Exits with error if the architecture is unsupported.
#
# Example:
#   os::init
#   echo "Detected: $OS / $ARCH"
# -----------------------------------------------------------------------------
os::init() {
    OS="$(os::operating_system)"
    log "🖥️  Detected OS: ${OS}"

    ARCH="$(os::architecture)"
    log "💻 Detected Architecture: ${ARCH}"

    OS_KERNEL="$(os::kernel)"
    log "🛠️  Kernel: ${OS_KERNEL}"

    OS_DISTRO="$(os::distro)"
    log "📦 Distribution: ${OS_DISTRO:-unknown}"

    OS_VERSION="$(os::version)"
    log "🔢 Version: ${OS_VERSION:-unknown}"

    OS_ID_LIKE="$(os::id_like)"
    log "🆔 ID_LIKE: ${OS_ID_LIKE:-unknown}"

    if ! os::is_supported; then
        log::error "❌ Unsupported OS or architecture: ${OS} / ${ARCH}"
        exit 1
    fi

    OPERATING_SYSTEM="${OS} ${OS_DISTRO}-${OS_VERSION} (${ARCH}), Kernel: ${OS_KERNEL}"
    log "🖥️  Operating System: ${OPERATING_SYSTEM}"
}
