#!/usr/bin/env bats
# test_os.bats — Tests for OS utilities in _os.sh
setup() {
    if command -v realpath &>/dev/null; then
        LIB_HOME="$(realpath "${BATS_TEST_DIRNAME:?}/../")"
    else
        LIB_HOME="$(cd "${BATS_TEST_DIRNAME:?}/../" && pwd)"
    fi
    LIB_HOME="${DEVTOOLS_LIB:-${LIB_HOME}}"

    # shellcheck source=/dev/null
    source "${LIB_HOME}/_os.sh"
}

@test "os::is_linux returns 0 on Linux systems" {
    local _os_name
    _os_name="$(uname -s)"
    if [[ "${_os_name}" == "Linux" ]]; then
        run os::is_linux
        [[ "${status}" -eq 0 ]]
    fi
}

@test "os::is_macos returns 0 on macOS systems" {
    local _os_name
    _os_name="$(uname -s)"
    if [[ "${_os_name}" == "Darwin" ]]; then
        run os::is_macos
        [[ "${status}" -eq 0 ]]
    fi
}

@test "os::is_windows returns 0 on Windows systems" {
    local _os_name
    _os_name="$(uname -s)"
    if [[ "${_os_name}" =~ ^(CYGWIN|MINGW|MSYS) ]]; then
        run os::is_windows
        [[ "${status}" -eq 0 ]]
    fi
}

@test "os::is_wsl returns 0 on WSL systems" {
    if grep -qi 'microsoft' /proc/version 2>/dev/null; then
        run os::is_wsl
        [[ "${status}" -eq 0 ]]
    fi
}

@test "os::is_debian returns 0 if /etc/debian_version exists" {
    if [[ -f /etc/debian_version ]]; then
        run os::is_debian
        [[ "${status}" -eq 0 ]]
    fi
}

@test "os::is_ubuntu returns 0 if /etc/lsb-release contains Ubuntu" {
    if [[ -f /etc/lsb-release ]] && grep -q "DISTRIB_ID=Ubuntu" /etc/lsb-release; then
        run os::is_ubuntu
        [[ "${status}" -eq 0 ]]
    fi
}

@test "os::kernel returns a non-empty string" {
    run os::kernel
    [[ "${status}" -eq 0 ]]
    [[ -n "${output}" ]]
}

@test "os::distro returns a string or macos fallback" {
    run os::distro
    [[ "${status}" -eq 0 ]]
    [[ -n "${output}" ]]
}

@test "os::version returns version string or macOS version" {
    run os::version
    [[ "${status}" -eq 0 ]]
    [[ "${output}" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]
}

@test "os::id_like returns lowercase OS family or fallback" {
    run os::id_like
    [[ "${status}" -eq 0 ]]
    [[ "${output}" =~ ^[a-zA-Z0-9_-]*$ ]]
}

@test "os::is_supported returns 0 on known OS/ARCH" {
    run os::is_supported
    [[ "${status}" -eq 0 ]]
}

@test "os::print_info prints expected log format" {
    run os::print_info
    [[ "${status}" -eq 0 ]]
    [[ "${output}" =~ Detected\ OS:.* ]]
}

@test "os::init sets OS and ARCH and prints log info" {
    run bash -c "source '${LIB_HOME}/_os.sh'; os::init"
    [[ "${status}" -eq 0 ]]
    [[ "${output}" =~ Detected\ OS:.* ]]
    [[ "${output}" =~ Detected\ Architecture:.* ]]
}
