#!/usr/bin/env bash
# Install developer tools for a development container

set -euo pipefail

declare -A KNOWN_PLUGINS=(
    [nodejs]=node
    [python]=python3
    [poetry]=poetry
    [pnpm]=pnpm
    [ruby]=ruby
    [go]=go
    [java]=java
    [rust]=rustc
)

ASDF_PLUGIN_DATA=$(cat <<EOF
nodejs node https://github.com/asdf-vm/asdf-nodejs.git
python python3 https://github.com/danhper/asdf-python.git
poetry poetry https://github.com/asdf-community/asdf-poetry.git
pnpm pnpm https://github.com/jonathanmorley/asdf-pnpm.git
ruby ruby https://github.com/asdf-vm/asdf-ruby.git
go go https://github.com/asdf-vm/asdf-golang.git
java java https://github.com/halcyon/asdf-java.git
rust rustc https://github.com/code-lever/asdf-rust.git
EOF
)

mapfile -t ASDF_PLUGIN_TABLE <<< "${ASDF_PLUGIN_DATA}"

# -----------------------------------------------------------------------------
# Function: get_plugin_command
#
# Description:
#   Retrieves the command associated with a given asdf plugin.
#
# Usage:
#   command=$(get_plugin_command nodejs)
#
# Arguments:
#   $1 - Plugin name (e.g., "nodejs", "python").
#
# Returns:
#   Prints the command name associated with the plugin.
#   Exits with an error if the plugin is not found.
# -----------------------------------------------------------------------------
get_plugin_command() {
  local plugin="$1"
  for entry in "${ASDF_PLUGIN_TABLE[@]}"; do
    local plugin_name command_name url
    read -r plugin_name command_name url <<< "${entry}"
    if [[ "${plugin}" == "${plugin_name}" ]]; then
      echo "${command_name}"
      return
    fi
  done
}

# -----------------------------------------------------------------------------
# Function: get_plugin_url
#
# Description:
#   Returns the URL of the specified asdf plugin.
#
# Usage:
#   url=$(get_plugin_url nodejs)
#
# Arguments:
#   $1 - Plugin name (e.g., "nodejs", "python").
#
# Returns:
#   Prints the URL of the plugin repository.
#   Exits with an error if the plugin is not found.
# -----------------------------------------------------------------------------
get_plugin_url() {
  local plugin="$1"
  for entry in "${ASDF_PLUGIN_TABLE[@]}"; do
    local plugin_name command_name url
    read -r plugin_name command_name url <<< "${entry}"
    if [[ "${plugin}" == "${plugin_name}" ]]; then
      echo "${url}"
      return
    fi
  done
}

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
# Function: realpath
#
# Description:
#   Resolves an absolute path. Uses the system realpath if available,
#   otherwise falls back to a POSIX-compliant implementation.
#
# Usage:
#   resolved=$(realpath ./relative/file)
#
# Arguments:
#   $1 - Path to resolve.
#
# Returns:
#   Prints the absolute path or exits non-zero on error.
# -----------------------------------------------------------------------------
realpath() {
    local path="$1"

    # Call cmd::exists in its own statement to preserve 'set -e' behavior
    # shellcheck disable=SC2310
    if cmd::exists realpath; then
        command realpath "${path}"
        return
    fi

    # Fallback without masking subshell failure
    local dir
    dir=$(dirname "${path}") || return 1
    local base
    base=$(basename "${path}") || return 1

    local dirpath
    dirpath=$(cd "${dir}" && pwd -P) || return 1
    printf "%s/%s\n" "${dirpath}" "${base}"
}

# -----------------------------------------------------------------------------
# Function: trap::on_error
#
# Description:
#   Trap function triggered when a command fails under `set -e`.
#   Prints error details (line number and exit code) to stderr and exits.
#
# Usage:
#   trap 'trap::on_error $LINENO' ERR
#
# Arguments:
#   $1 - Line number where the error occurred.
#
# Returns:
#   Exits with the same exit code that caused the trap.
# -----------------------------------------------------------------------------
trap::on_error() {
  local exit_code=$?
  local line_no=$1
  printf "❌ Error on line %s. Exit code: %d\n" "${line_no}" "${exit_code}" >&2
  exit "${exit_code}"
}

# -----------------------------------------------------------------------------
# Function: trap::on_exit
#
# Description:
#   Trap function triggered on script exit, successful or not.
#   Can be used for cleanup or logging.
#
# Usage:
#   trap trap::on_exit EXIT
#
# Arguments:
#   None
#
# Returns:
#   Nothing (exit proceeds).
# -----------------------------------------------------------------------------
trap::on_exit() {
  local exit_code=$?
  printf "📤 Script exited with code %d\n" "${exit_code}" >&2
}

# -----------------------------------------------------------------------------
# Function: trap::on_interrupt
#
# Description:
#   Trap function triggered by Ctrl+C (SIGINT).
#   Prints a message and exits with code 130 (SIGINT convention).
#
# Usage:
#   trap trap::on_interrupt INT
#
# Arguments:
#   None
#
# Returns:
#   Exits with status 130.
# -----------------------------------------------------------------------------
trap::on_interrupt() {
  printf "🚫 Interrupted by user (Ctrl+C)\n" >&2
  exit 130
}

# -----------------------------------------------------------------------------
# Function: trap::init
#
# Description:
#   Installs standard traps for error handling, interrupt signals, and clean exit.
#
# Usage:
#   trap::init
#
# Arguments:
#   None
#
# Returns:
#   Registers traps globally for ERR, EXIT, and INT.
# -----------------------------------------------------------------------------
trap::init() {
  trap 'trap::on_error $LINENO' ERR
  trap trap::on_exit EXIT
  trap trap::on_interrupt INT
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
  if [[ -n "${LOG_FILE:-}" && -n "${LOG_FILE// }" ]]; then
    printf "%s\n" "${log_line_file}" >> "${LOG_FILE}"
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
    info)    printf "🔹" ;;
    warn)    printf "⚠️ " ;;
    error)   printf "❌" ;;
    success) printf "✅" ;;
    debug)   printf "🐞" ;;
    *)       printf "➖" ;;
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
  uname -s 2>/dev/null | tr '[:upper:]' '[:lower:]'
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
    x86_64)   printf "amd64\n" ;;
    aarch64 | arm64) printf "arm64\n" ;;
    *)
      log "❌ Unsupported architecture: ${raw_arch}"
      return 1
      ;;
  esac
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
        grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"'
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
        grep '^VERSION_ID=' /etc/os-release | cut -d= -f2 | tr -d '"'
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
  printf '{"os":"%s","arch":"%s"}\n' "$(os::operating_system)" "$(os::architecture)"
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
  printf "%s\n" "${BASH:-$(command -v bash)}"
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
  set -o | grep -qE '^errexit +on' &&
  set -o | grep -qE '^nounset +on' &&
  set -o pipefail &>/dev/null && set -o | grep -qE '^pipefail +on'
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
        log::error "❌ Bash version $bash_major.$bash_minor detected. Bash $min_major.0+ is required."
        exit 1
    else
        log::success "✅ Bash version $bash_major.$bash_minor meets the minimum requirement of $min_major.0+."
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
  log "🔍 Bash Info:"
  log "   • Version         : $(bash::version)"
  log "   • Major Version   : $(bash::major_version)"
  log "   • Minor Version   : $(bash::minor_version)"
  log "   • Path            : $(bash::path)"

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

  log "   • Enabled Options :"
  while IFS= read -r line; do
    log "     - ${line}"
  done < <(bash::options)

  if terminal::is_term; then
      log "🖥️  Running in terminal"
  else
      log "🚫 Not running in terminal — some features may be limited"
  fi
}

# -----------------------------------------------------------------------------
# Function: script::path
#
# Description:
#   Resolves the absolute path of the currently executing script.
#   Works across Bash, Dash, POSIX, Zsh, and on systems without GNU readlink.
#
# Usage:
#   path="$(script::path)"
#
# Returns:
#   Prints the absolute path to the script (not the cwd).
# -----------------------------------------------------------------------------
script::path() {
  # shellcheck disable=SC2296
  local src="${BASH_SOURCE[0]:-${(%):-%x}}"  # Bash or Zsh-safe fallback
  while [ -h "$src" ]; do
    local dir
    dir="$(cd -P "$(dirname "$src")" >/dev/null 2>&1 && pwd)"
    src="$(readlink "$src")"
    [[ "$src" != /* ]] && src="$dir/$src"
  done
  cd -P "$(dirname "$src")" >/dev/null 2>&1 && pwd
}

# -----------------------------------------------------------------------------
# Function: script::init
#
# Description:
#   Detects information about the running script and stores it in globals.
# -----------------------------------------------------------------------------
script::init() {
  SCRIPT_SHELL="${SHELL:-$(command -v bash)}"
  SCRIPT_PID="$$"
  ORIGINAL_CWD="$(pwd)"
  SCRIPT_PARAMS="$*"
  SCRIPT_DIR="$(script::path)"
  SCRIPT_PATH="${SCRIPT_DIR}/$(basename "$0")"
  SCRIPT_NAME="$(basename "$SCRIPT_PATH")"

  log "Original CWD: $ORIGINAL_CWD"
  log "Script parameters: $SCRIPT_PARAMS"
  log "Script path: $SCRIPT_PATH"
  log "Script directory: $SCRIPT_DIR"
  log "Script name: $SCRIPT_NAME"
  log "Shell path: $SCRIPT_SHELL"
  log "Current shell PID: $SCRIPT_PID"
}

# -----------------------------------------------------------------------------
# Function: logger::logs_dir
#
# Description:
#   Returns the directory path where log files will be stored. Defaults to
#   `./logs` when the `DEVTOOLS_LOGS` environment variable is not set.
#
# Usage:
#   logs_dir=$(logger::logs_dir)
#
# Returns:
#   Prints the path to the logs directory.
# -----------------------------------------------------------------------------
logger::logs_dir() {
    echo "${DEVTOOLS_LOGS:-./logs}"
}

# -----------------------------------------------------------------------------
# Function: logger::init
#
# Description:
#   Initializes logging by creating the logs directory if needed and defining
#   the path to the log file used by the script.
#
# Usage:
#   logger::init
#
# Returns:
#   Sets the global variable `LOG_FILE`.
# -----------------------------------------------------------------------------
logger::init() {
    local logs_dir
    logs_dir="$(logger::logs_dir)"
    if [[ ! -d "$logs_dir" ]]; then
        mkdir -p "$logs_dir" || {
            log::error "❌ Failed to create logs directory: $logs_dir" >&2
            exit 1
        }
        log::success "✅ Logs directory created: $logs_dir"
    else
        log "ℹ️  Logs directory already exists: $logs_dir"
    fi

    local timestamp
    timestamp=$(date::now)
    LOG_FILE="$(cd "${logs_dir}" && pwd)/devtools-${timestamp}.log"
    log "📁 Logs will be written to ${LOG_FILE}"
}

# -----------------------------------------------------------------------------
# Function: asdf::version
#
# Description:
#   Determines the asdf version to install based on the `ASDF_VERSION`
#   environment variable or defaults to `latest`.
#
# Usage:
#   asdf_version=$(asdf::version)
#
# Returns:
#   Prints the asdf version string.
# -----------------------------------------------------------------------------
asdf::version() {
    local asdf_version
    asdf_version="${ASDF_VERSION:-"latest"}"
    echo "${asdf_version}"
}

# -----------------------------------------------------------------------------
# Function: asdf::home
#
# Description:
#   Echoes the directory where the asdf binary will be installed.
#   Defaults to `$HOME/.asdf` unless `ASDF_DIR` is specified.
#
# Usage:
#   binary_dir=$(asdf::home)
#
# Returns:
#   Prints the installation directory path.
# -----------------------------------------------------------------------------
asdf::home() {
    echo "${ASDF_DIR:-"${HOME}/.asdf"}"
}

# -----------------------------------------------------------------------------
# Function: asdf::data_dir
#
# Description:
#   Echoes the directory where asdf stores shims and other data files.
#   Defaults to "$(asdf::home)/data" unless `ASDF_DATA_DIR` is specified.
#
# Usage:
#   data_dir=$(asdf::data_dir)
#
# Returns:
#   Prints the data directory path.
# -----------------------------------------------------------------------------
asdf::data_dir() {
    echo "${ASDF_DATA_DIR:-"$(asdf::home)/data"}"
}

# -----------------------------------------------------------------------------
# Function: asdf::verify
#
# Description:
#   Validates the asdf installation by checking if the binary exists and
#   printing its version. Returns an error if the binary cannot be found.
#
# Usage:
#   asdf::verify
#
# Returns:
#   Exit status 0 if installed, non-zero otherwise.
# -----------------------------------------------------------------------------
asdf::verify() {
    local binary_path=""

    if command -v asdf >/dev/null 2>&1; then
        binary_path="$(command -v asdf)"
    elif [[ -x "$(asdf::home)/bin/asdf" ]]; then
        binary_path="$(asdf::home)/bin/asdf"
    fi

    if [[ -n "${binary_path}" && -x "${binary_path}" ]]; then
        local version
        version="$("${binary_path}" --version 2>/dev/null || echo "Version info not available")"
        log::success "✅ ASDF available at ${binary_path}: ${version}"
    else
        log::error "❌ ASDF not found"
        return 1
    fi
}

# -----------------------------------------------------------------------------
# Function: asdf::install
#
# Description:
#   Downloads and installs the asdf binary. If the current version is set to
#   "latest", the function will resolve the latest release from GitHub.
#
# Usage:
#   asdf::install
# -----------------------------------------------------------------------------
asdf::install() {
    local repo_url="https://github.com/asdf-vm/asdf"
    local binary_path
    binary_path="$(asdf::home)/bin/asdf"
    local version
    version="$(asdf::version)"

    # Ensure required directories exist and are owned by the vscode user
    mkdir -p "$(asdf::home)" "$(asdf::data_dir)"
    chown vscode:vscode "$(asdf::home)" "$(asdf::data_dir)"

    if [[ "${version}" == "latest" ]]; then
        log::info "🔍 Fetching latest ASDF version..."
        version="$(curl --fail --silent --show-error --location -o /dev/null -w '%{url_effective}' "${repo_url}/releases/latest" | sed 's#.*/tag/##')"
    fi

    if [[ -x "${binary_path}" ]]; then
        if "${binary_path}" --version &>/dev/null; then
            log::success "✅ ASDF already installed at ${binary_path}"
            return
        else
            log::warn "⚠️ Detected existing ASDF, but it failed to execute. Reinstalling..."
            rm -rf "$(asdf::home)"
        fi
    fi

    log::info "📥 Downloading asdf ${version}..."
    curl --fail --silent --show-error --location \
        "${repo_url}/releases/download/${version}/asdf-${version}-${OS}-${ARCH}.tar.gz" \
        --output asdf.tar.gz

    tar -xzf asdf.tar.gz
    mkdir -p "$(dirname "${binary_path}")"
    chmod +x asdf
    mv asdf "${binary_path}"
    rm -f asdf.tar.gz

    log::success "✅ ASDF installed to ${binary_path}"
    asdf::verify
}

has_asdf_plugin() {
    grep -q "^$1\$" < <(asdf plugin list 2>/dev/null)
}

install_asdf_plugin() {
    local plugin_name=$1

    if ! has_asdf_plugin "${plugin_name}"; then
        log "📥 Adding plugin: ${plugin_name}"

        local plugin_url
        plugin_url="$(get_plugin_url "${plugin_name}")"

        if [[ -n "$plugin_url" ]]; then
            asdf plugin add "${plugin_name}" "${plugin_url}"
        else
            asdf plugin add "${plugin_name}"
        fi

        if ! asdf plugin add "${plugin_name}"; then
            log "❌ Failed to add plugin: ${plugin_name}"
            return 1
        fi
        log "✅ Plugin added: ${plugin_name}"
    else
        log "🔁 Plugin already exists: ${plugin_name}"
    fi
}

sort_plugins_by_known_plugins() {
    local -n input_plugins=$1
    local -a sorted_plugins=()

    # First: install all plugins from KNOWN_PLUGINS in order of declaration
    for plugin in "${!KNOWN_PLUGINS[@]}"; do
        for i in "${!input_plugins[@]}"; do
            if [[ "${input_plugins[$i]}" == "${plugin}" ]]; then
                sorted_plugins+=("${input_plugins[$i]}")
                unset 'input_plugins[i]'
            fi
        done
    done

    # Then: install remaining unknown plugins (alphabetically)
    for plugin in "${input_plugins[@]}"; do
        sorted_plugins+=("${plugin}")
    done

    input_plugins=("${sorted_plugins[@]}")
}

install_asdf_plugins() {
    log "🔍 Gathering plugins from .tool-versions files..."

    local tool_files
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        mapfile -t tool_files < <(
            git ls-files --cached --others --exclude-standard '*.tool-versions' |
                while read -r f; do realpath "$f"; done
        )
    else
        mapfile -t tool_files < <(
            find . -type f -name ".tool-versions" -not -path "*/.*/*" |
                while read -r f; do realpath "$f"; done
        )
    fi

    if [[ ${#tool_files[@]} -eq 0 ]]; then
        log "⚠️ No .tool-versions files found."
        return
    fi
    log "📁 Found ${#tool_files[@]} .tool-versions files."

    for file in "${tool_files[@]}"; do
        log "📄 Processing .tool-versions file: ${file}"

        local dir
        dir="$(dirname "${file}")"

        pushd "$dir" >/dev/null
        log "📍 Moved into: $(pwd) to install dependencies from ${file}"

        local all_plugins=()
        local seen=()

        while IFS= read -r line || [[ -n "${line}" ]]; do
            [[ "${line}" =~ ^#.*$ || -z "${line}" ]] && continue

            local plugin
            plugin=$(awk '{print $1}' <<<"${line}")

            if [[ ! " ${seen[*]} " =~ " ${plugin} " ]]; then
                seen+=("${plugin}")
                all_plugins+=("${plugin}")
            fi
        done <"${file}"
        log "🔧 Found plugins: ${all_plugins[*]}"

        sort_plugins_by_known_plugins all_plugins
        log "🔧 Sorted plugins: ${all_plugins[*]}"

        for plugin in "${all_plugins[@]}"; do
            install_asdf_plugin "${plugin}"
        done

        log "✅ All plugins installed from ${file}"

        # Install dependencies now that plugins are installed
        for plugin in "${all_plugins[@]}"; do
            local version
            version=$(awk -v plugin="${plugin}" '$1 == plugin {print $2}' "${file}")
            if [[ -n "$version" ]]; then
                log "📦 Installing ${plugin} version: ${version}"
                asdf install "${plugin}" "${version}"
                log "✅ Installed $plugin version: ${version}"
            else
                log "⚠️ No version specified for ${plugin} in ${file}"
            fi
        done

        popd >/dev/null
    done
}

# -----------------------------------------------------------------------------
# Function: taskfile::version
#
# Description:
#   Determines the Taskfile version to install based on the
#   `TASKFILE_VERSION` environment variable or defaults to `latest`.
#
# Usage:
#   version=$(taskfile::version)
#
# Returns:
#   Prints the Taskfile version string.
# -----------------------------------------------------------------------------
taskfile::version() {
    local taskfile_version
    taskfile_version="${TASKFILE_VERSION:-"latest"}"
    echo "${taskfile_version}"
}

# -----------------------------------------------------------------------------
# Function: taskfile::home
#
# Description:
#   Echoes the directory where the Taskfile binary will be installed.
#   Defaults to `/usr/local/bin` unless `TASKFILE_HOME_DIR` is specified.
#
# Usage:
#   binary_dir=$(taskfile::home)
#
# Returns:
#   Prints the installation directory path.
# -----------------------------------------------------------------------------
taskfile::home() {
    echo "${TASKFILE_HOME_DIR:-"${HOME}/.taskfile"}"
}

# -----------------------------------------------------------------------------
# Function: taskfile::verify
#
# Description:
#   Validates the Taskfile installation by checking if the binary exists and
#   printing its version. Returns an error if the binary cannot be found.
#
# Usage:
#   taskfile::verify
#
# Returns:
#   Exit status 0 if installed, non-zero otherwise.
# -----------------------------------------------------------------------------
taskfile::verify() {
    local binary_path
    binary_path="$(taskfile::home)/task"
    if [[ -x "${binary_path}" ]]; then
        local version
        version="$("${binary_path}" --version 2>/dev/null || "${binary_path}" -v 2>/dev/null || echo "Version info not available")"
        log::success "✅ Taskfile installed at ${binary_path}: ${version}"
    elif command -v task >/dev/null 2>&1; then
        binary_path="$(command -v task)"
        local version
        version="$("${binary_path}" --version 2>/dev/null || "${binary_path}" -v 2>/dev/null || echo "Version info not available")"
        log::success "✅ Taskfile available at ${binary_path}: ${version}"
    else
        log::error "❌ Taskfile not found"
        return 1
    fi
}

# -----------------------------------------------------------------------------
# Function: install::asdf
#
# Description:
#   Installs the asdf version manager if it is not already installed.
#   Currently this is a placeholder that simply logs the action.
#
# Usage:
#   install::asdf
# -----------------------------------------------------------------------------
install::asdf() {
    log::info "📥 Installing ASDF version manager '$(asdf::version)'..."
    asdf::install
}

# -----------------------------------------------------------------------------
# Function: install::taskfile
#
# Description:
#   Downloads and installs the Taskfile binary in the directory returned by
#   `taskfile::home` if it is not already present.
#
# Usage:
#   install::taskfile
# -----------------------------------------------------------------------------
install::taskfile() {
    local home_dir
    home_dir="$(taskfile::home)"
    local binary_path="${home_dir}/task"

    if [[ -x "${binary_path}" ]]; then
        log::success "✅ Taskfile already installed at ${binary_path}"
        return
    fi

    local taskfile_version
    taskfile_version="$(taskfile::version)"
    log "📥 Installing Taskfile '${taskfile_version}' to ${home_dir}..."
    mkdir -p "${home_dir}"
    curl --fail --silent --show-error https://taskfile.dev/install.sh | sh -s -- -d -b "${home_dir}"

    taskfile::verify
}

# -----------------------------------------------------------------------------
# Function: install
#
# Description:
#   Installs all development tooling required for this container by calling the
#   individual install functions.
# -----------------------------------------------------------------------------
install() {
    log "🔧 Installing development tools..."
    install::asdf
    install_asdf_plugins
    install::taskfile
    # install::oxipng
    log::success "🔧 Development tools installation complete."
}

# -----------------------------------------------------------------------------
# Function: preflight::check
#
# Description:
#   Performs required system checks before proceeding.
#   Validates the presence of required CLI tools and compatible environment.
#
# Usage:
#   preflight::check
#
# Returns:
#   Exits if any checks fail. Otherwise returns 0.
# -----------------------------------------------------------------------------
preflight::check() {
    log "🔧 Performing preflight checks..."

    # Ensure we have the required Bash version
    bash::require_version 3

    local missing=()

    local required_tools=(
        git curl jq
        uname grep cut tr date mkdir pwd
        readlink dirname basename printf
        command
    )
    # shellcheck disable=SC2310
    for cmd in "${required_tools[@]}"; do
        if ! cmd::exists "${cmd}"; then
            missing+=("${cmd}")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        log::error "❌ Missing required commands: ${missing[*]}" >&2
        exit 1
    else
        log::success "✅ All required commands are available."
    fi

    log::success "✅ Preflight checks passed."
}

# -----------------------------------------------------------------------------
# Function: init
#
# Description:
#   Performs initialization routines before running installs: sets up traps,
#   logging, runs preflight checks and prints environment information.
#
# Usage:
#   init "$@"
# -----------------------------------------------------------------------------
init() {
    trap::init
    logger::init
    preflight::check
    os::init
    script::init "$@"
    bash::print_info
    log "🚀 Starting development environment setup..."
}

# -----------------------------------------------------------------------------
# Function: main
#
# Description:
#   Entry point for the script. Initializes the environment and performs the
#   installation of development tools.
#
# Usage:
#   main "$@"
# -----------------------------------------------------------------------------
main() {
    init "$@"
    install
    log::success "🎉 Development environment setup complete!"
}

main "$@"
