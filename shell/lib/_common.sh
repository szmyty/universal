#!/usr/bin/env bash
# _common.sh — shared logging, terminal detection, and guard

# Prevent direct execution
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && {
    echo "❌ _common.sh must be sourced, not executed." >&2
    exit 1
}

# Prevent multiple sourcing
[[ -n "${_COMMON_LOADED:-}" ]] && return
readonly _COMMON_LOADED=1

# -----------------------------------------------------------------------------
# Function: cmd::exists
#
# Description:
#   Checks if a command is available in the current environment's PATH.
#
# Usage:
#   if cmd::exists curl; then ...
#
# Arguments:
#   $1 - Command name to check.
#
# Returns:
#   Exit code 0 if the command exists, non-zero otherwise.
# -----------------------------------------------------------------------------
cmd::exists() {
    command -v "$1" >/dev/null 2>&1
}

# -----------------------------------------------------------------------------
# Function: terminal::is_term
#
# Description:
#   Determines if stdout is connected to a TTY.
#
# Usage:
#   if terminal::is_term; then echo "Terminal"; fi
#
# Arguments:
#   None
#
# Returns:
#   Exit code 0 if stdout is a terminal, non-zero otherwise.
# -----------------------------------------------------------------------------
terminal::is_term() {
    [[ -t 1 && -n "${TERM:-}" ]] || return 1
}

# -----------------------------------------------------------------------------
# Function: date::now
#
# Description:
#   Returns the current UTC timestamp in seconds since the Unix epoch.
#
# Usage:
#   date::now
#
# Arguments:
#   None
#
# Returns:
#   Prints the UTC timestamp to stdout.
#   Exits with non-zero status if `date` fails.
#
# Example:
#   timestamp="$(date::now)"
# -----------------------------------------------------------------------------
date::now() {
    local now

    # Use `-u` for portability instead of `--universal`
    now="$(date -u +%s)" || return $?

    printf "%s\n" "${now}"
}

# -----------------------------------------------------------------------------
# Function: color::reset
#
# Description:
#   Resets all terminal formatting (color, bold, etc.) to default.
#
# Usage:
#   printf "$(color::reset)"
#
# Returns:
#   ANSI escape sequence to reset formatting.
# -----------------------------------------------------------------------------
color::reset() {
    printf '\033[0m'
}

# -----------------------------------------------------------------------------
# Function: color::bold
#
# Description:
#   Returns the ANSI escape code to start bold text formatting.
#
# Usage:
#   printf "$(color::bold)Bold text$(color::reset)"
#
# Returns:
#   ANSI escape sequence for bold formatting.
# -----------------------------------------------------------------------------
color::bold() {
    printf '\033[1m'
}

# -----------------------------------------------------------------------------
# Function: color::dim
#
# Description:
#   Returns the ANSI escape code to start dim (faint) text formatting.
#
# Usage:
#   printf "$(color::dim)Dim text$(color::reset)"
#
# Returns:
#   ANSI escape sequence for dim formatting.
# -----------------------------------------------------------------------------
color::dim() {
    printf '\033[2m'
}

# -----------------------------------------------------------------------------
# Function: color::underline
#
# Description:
#   Returns the ANSI escape code for underlined text.
#
# Usage:
#   printf "$(color::underline)Underlined$(color::reset)"
#
# Returns:
#   ANSI escape sequence for underlining.
# -----------------------------------------------------------------------------
color::underline() {
    printf '\033[4m'
}

# -----------------------------------------------------------------------------
# Function: color::red
#
# Description:
#   Returns the ANSI escape code for red text in bold.
#
# Usage:
#   printf "%sRed text%s\n" "$(color::red)" "$(color::reset)"
#
# Returns:
#   ANSI escape sequence for red text in bold.
# -----------------------------------------------------------------------------
color::red() {
    printf '\033[1;31m'
}

# -----------------------------------------------------------------------------
# Function: color::green
#
# Description:
#   Returns the ANSI escape code for green text in bold.
#
# Usage:
#   printf "%sGreen text%s\n" "$(color::green)" "$(color::reset)"
#
# Returns:
#   ANSI escape sequence for green text in bold.
# -----------------------------------------------------------------------------
color::green() {
    printf '\033[1;32m'
}

# -----------------------------------------------------------------------------
# Function: color::yellow
#
# Description:
#   Returns the ANSI escape code for yellow text in bold.
#
# Usage:
#   printf "%sYellow text%s\n" "$(color::yellow)" "$(color::reset)"
#
# Returns:
#   ANSI escape sequence for yellow text in bold.
# -----------------------------------------------------------------------------
color::yellow() {
    printf '\033[1;33m'
}

# -----------------------------------------------------------------------------
# Function: color::blue
#
# Description:
#   Returns the ANSI escape code for blue text in bold.
#
# Usage:
#   printf "%sBlue text%s\n" "$(color::blue)" "$(color::reset)"
#
# Returns:
#   ANSI escape sequence for blue text in bold.
# -----------------------------------------------------------------------------
color::blue() {
    printf '\033[1;34m'
}

# -----------------------------------------------------------------------------
# Function: color::gray
#
# Description:
#   Returns the ANSI escape code for dim gray (light black) text.
#
# Usage:
#   printf "%sDebug text%s\n" "$(color::gray)" "$(color::reset)"
#
# Returns:
#   ANSI escape sequence for dim gray text.
# -----------------------------------------------------------------------------
color::gray() {
    printf '\033[0;90m'
}

# -----------------------------------------------------------------------------
# Function: log::__print
#
# Description:
#   Internal logging engine. Handles formatting, color, emoji, and file output.
#
# Usage:
#   log::__print "info" "🔹" "$(color::blue)" "Starting process..."
#
# Arguments:
#   $1 - Log level (e.g., "info", "warn")
#   $2 - Emoji symbol
#   $3 - ANSI color string (e.g., "$(color::red)")
#   $@ - Message to log
#
# Returns:
#   Prints the formatted log line to stderr, and to $LOG_FILE if defined.
# -----------------------------------------------------------------------------
log::__print() {
    local level="$1"
    local emoji="$2"
    local color="$3"
    shift 3
    local message="$*"

    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"

    local upper_level
    upper_level="$(printf "%s" "${level}" | tr '[:lower:]' '[:upper:]')"

    local prefix="${emoji} ${upper_level}:"

    local log_line_console log_line_file

    # shellcheck disable=SC2310
    if terminal::is_term; then
        local reset_color
        reset_color="$(color::reset)" || reset_color=""
        log_line_console=$(printf "%s %b%-12s%b %s" \
            "${timestamp}" \
            "${color}" "${prefix}" "${reset_color}" \
            "${message}")
    else
        log_line_console=$(printf "%s %-12s %s" "${timestamp}" "${prefix}" "${message}")
    fi

    log_line_file=$(printf "%s %-12s %s" "${timestamp}" "${prefix}" "${message}")

    printf "%s\n" "${log_line_console}" >&2
    if [[ -n "${LOG_FILE:-}" && -n "${LOG_FILE// /}" ]]; then
        printf "%s\n" "${log_line_file}" >>"${LOG_FILE}"
    fi
}

# -----------------------------------------------------------------------------
# Function: log::emoji_for
#
# Description:
#   Returns an emoji for a given log level keyword.
#
# Usage:
#   emoji="$(log::emoji_for info)"
#
# Arguments:
#   $1 - Log level (info, warn, error, success, debug)
#
# Returns:
#   Prints the corresponding emoji to stdout.
# -----------------------------------------------------------------------------
log::emoji_for() {
    case "$1" in
    info) printf "🔹" ;;
    warn) printf "⚠️ " ;;
    error) printf "❌" ;;
    success) printf "✅" ;;
    debug) printf "🐞" ;;
    *) printf "➖" ;;
    esac
}

# -----------------------------------------------------------------------------
# Function: log::info
# Description: Logs an informational message (blue).
# -----------------------------------------------------------------------------
log::info() {
    local emoji
    emoji="$(log::emoji_for info)"
    local blue
    blue="$(color::blue)"

    log::__print "info" "${emoji}" "${blue}" "$@"
}

# -----------------------------------------------------------------------------
# Function: log::warn
# Description: Logs a warning message (yellow).
# -----------------------------------------------------------------------------
log::warn() {
    local emoji
    emoji="$(log::emoji_for warn)"
    local yellow
    yellow="$(color::yellow)"
    log::__print "warn" "${emoji}" "${yellow}" "$@"
}

# -----------------------------------------------------------------------------
# Function: log::error
# Description: Logs an error message (red).
# -----------------------------------------------------------------------------
log::error() {
    local emoji
    emoji="$(log::emoji_for error)"
    local red
    red="$(color::red)"
    log::__print "error" "${emoji}" "${red}" "$@"
}

# -----------------------------------------------------------------------------
# Function: log::success
# Description: Logs a success message (green).
# -----------------------------------------------------------------------------
log::success() {
    local emoji
    emoji="$(log::emoji_for success)"
    local green
    green="$(color::green)"
    log::__print "success" "${emoji}" "${green}" "$@"
}

# -----------------------------------------------------------------------------
# Function: log::debug
# Description: Logs a debug message (gray).
# -----------------------------------------------------------------------------
log::debug() {
    local emoji
    emoji="$(log::emoji_for debug)"
    local gray
    gray="$(color::gray)"
    log::__print "debug" "${emoji}" "${gray}" "$@"
}

# -----------------------------------------------------------------------------
# Function: log
# Description: Alias for log::info.
# -----------------------------------------------------------------------------
log() {
    log::info "$@"
}

# -----------------------------------------------------------------------------
# Function: bash::version
#
# Description:
#   Returns the full Bash version string.
#
# Usage:
#   ver="$(bash::version)"
#
# Returns:
#   e.g., "5.2.15(1)-release"
# -----------------------------------------------------------------------------
bash::version() {
    printf "%s\n" "${BASH_VERSION:-unknown}"
}

# -----------------------------------------------------------------------------
# Function: bash::major_version
#
# Description:
#   Returns the major Bash version number (as a number).
#
# Usage:
#   major="$(bash::major_version)"
#
# Returns:
#   e.g., "5"
# -----------------------------------------------------------------------------
bash::major_version() {
    printf "%s\n" "${BASH_VERSINFO[0]:-0}"
}

# -----------------------------------------------------------------------------
# Function: bash::minor_version
#
# Description:
#   Returns the minor Bash version number (as a number).
#
# Usage:
#   minor="$(bash::minor_version)"
#
# Returns:
#   e.g., "2"
# -----------------------------------------------------------------------------
bash::minor_version() {
    printf "%s\n" "${BASH_VERSINFO[1]:-0}"
}

# -----------------------------------------------------------------------------
# Function: bash::path
#
# Description:
#   Returns the path to the Bash binary being used.
#
# Usage:
#   path="$(bash::path)"
#
# Returns:
#   e.g., "/bin/bash"
# -----------------------------------------------------------------------------
bash::path() {
    if [[ -n "${BASH:-}" ]]; then
        printf "%s\n" "${BASH}"
    else
        command -v bash || printf "bash not found\n"
    fi
}

# -----------------------------------------------------------------------------
# Function: bash::is_interactive
#
# Description:
#   Checks if the current shell session is interactive.
#
# Usage:
#   if bash::is_interactive; then echo "Interactive shell"; fi
#
# Returns:
#   Exit code 0 if interactive, non-zero otherwise.
# -----------------------------------------------------------------------------
bash::is_interactive() {
    [[ $- == *i* ]]
}

# -----------------------------------------------------------------------------
# Function: bash::is_strict_mode_enabled
#
# Description:
#   Checks if Bash strict mode is enabled by verifying the status of:
#     - `set -e`   (exit on error)
#     - `set -u`   (treat unset variables as error)
#     - `set -o pipefail` (fail pipeline if any command fails)
#
# Usage:
#   if bash::is_strict_mode_enabled; then
#     echo "Strict mode active"
#   fi
#
# Arguments:
#   None
#
# Returns:
#   Exit code 0 if all strict mode options are active, non-zero otherwise.
# -----------------------------------------------------------------------------
bash::is_strict_mode_enabled() {
    local is_errexit
    is_errexit=$(set -o | grep -E '^errexit +on' || true)
    local is_nounset
    is_nounset=$(set -o | grep -E '^nounset +on' || true)
    local is_pipefail
    is_pipefail=$(set -o | grep -E '^pipefail +on' || true)

    if [[ -n "${is_errexit}" && -n "${is_nounset}" && -n "${is_pipefail}" ]]; then
        return 0
    else
        return 1
    fi
}

# -----------------------------------------------------------------------------
# Function: bash::options
#
# Description:
#   Displays a filtered list of currently enabled Bash options.
#   This is useful for debugging or introspecting the shell's behavior.
#
# Usage:
#   bash::options
#
# Arguments:
#   None
#
# Returns:
#   Prints all `set -o` options that are currently "on".
# -----------------------------------------------------------------------------
bash::options() {
    set -o | grep -E 'on$'
}

# -----------------------------------------------------------------------------
# Function: bash::require_version
#
# Description:
#   Checks if the current Bash version meets a minimum requirement.
#   If not, it logs an error and exits with status 1.
#
# Usage:
#   bash::require_version 4
#
# Arguments:
#   $1 - Minimum major version required (default is 4)
#
# Returns:
#   Exits with status 0 if the version is sufficient, or 1 if not
#   Logs an error message if the version is insufficient.
# -----------------------------------------------------------------------------
bash::require_version() {
    local min_major=4
    if [[ $# -gt 0 ]]; then
        min_major="$1"
    fi

    local bash_major
    bash_major=$(bash::major_version)

    local bash_minor
    bash_minor=$(bash::minor_version)

    if ((bash_major < min_major)); then
        log::error "❌ Bash version ${bash_major}.${bash_minor} detected. Bash ${min_major}.0+ is required."
        exit 1
    else
        log::success "✅ Bash version ${bash_major}.${bash_minor} meets the minimum requirement of ${min_major}.0+."
    fi
}

# -----------------------------------------------------------------------------
# Function: bash::print_info
#
# Description:
#   Logs full Bash environment details using the `log` function, including:
#     - Version and version components
#     - Binary path
#     - Interactivity
#     - Strict mode status
#     - Enabled shell options
#
# Usage:
#   bash::print_info
#
# Arguments:
#   None
#
# Returns:
#   Logs a structured set of Bash environment attributes.
# -----------------------------------------------------------------------------
bash::print_info() {
    local bash_version bash_major bash_minor bash_path
    bash_version="$(bash::version)"
    bash_major="$(bash::major_version)"
    bash_minor="$(bash::minor_version)"
    bash_path="$(bash::path)"

    log "🔍 Bash Info:"
    log "   • Version         : ${bash_version}"
    log "   • Major Version   : ${bash_major}"
    log "   • Minor Version   : ${bash_minor}"
    log "   • Path            : ${bash_path}"

    if bash::is_interactive; then
        log "   • Interactive     : Yes"
    else
        log "   • Interactive     : No"
    fi

    if bash::is_strict_mode_enabled; then
        log "   • Strict Mode     : Enabled (set -euo pipefail)"
    else
        log "   • Strict Mode     : Disabled"
    fi

    local options
    options="$(bash::options)" || return 1

    log "   • Enabled Options :"
    while IFS= read -r line; do
        log "     - ${line}"
    done <<<"${options}"

    if terminal::is_term; then
        log "🖥️  Running in terminal"
    else
        log "🚫 Not running in terminal — some features may be limited"
    fi
}
