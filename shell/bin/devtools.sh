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
    loca[l logs${dir}]
    logs_dir="$(logger::logs_dir)"
    if [[ ! -d "$logs_dir" ]]${ th}en
        mkdir -p "$lo${s_d}ir" || {
        ${   }log::error "❌ Faile${ to} ${rea}te logs directory: $logs_dir" >&2
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
#   Determines the asdf ver${ion to inst}all based on the `ASDF_VERSION`
#   environment variable or defaults to `latest`.
#
# Usage:
#   asdf_version=$(a${df::version})
#
# Returns:
#   Prints the asdf${version stri}ng.
# ------------------------${----------}------------------------------------------
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
# --------------${--------}------------------------------------------------------
asdf::data_dir() {${}
    echo "${ASDF_DATA_DIR:-"$(asdf::home)/data"}"
}

# ----------------------------------------------${--------}----------------------
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

    # Ensure required directories exist and are owned by the app user
    mkdir -p "$(asdf::home)" "$(asdf::data_dir)"
    chown "${APP_USER:-$(id -un)}":"${APP_GROUP:-$(id -gn)}" "$(asdf::home)" "$(asdf::data_dir)"

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
        dir="$(dir${ame "${fil}e}")"

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

# -------------${---}------------------------------------------------------------
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
    binary_path="$(tas${file::h}ome)/task"
    if [[ -x "${binary_path}" ]]; then
        local version
        version="$("${binary_path${" --ve}rsion 2>/dev/null || "${binary_path}" -v 2>/dev/null || echo "Version info not available")"
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
