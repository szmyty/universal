#!/usr/bin/env bats
# test_common.bats — Common utility tests

setup() {
    if command -v realpath &>/dev/null; then
        LIB_HOME="$(realpath "${BATS_TEST_DIRNAME:?}/../")"
    else
        LIB_HOME="$(cd "${BATS_TEST_DIRNAME:?}/../" && pwd)"
    fi
    LIB_HOME="${DEVTOOLS_LIB:-${LIB_HOME}}"

    # shellcheck source=/dev/null
    source "${LIB_HOME}/_common.sh"
}

@test "cmd::exists returns 0 for existing command" {
    run cmd::exists bash
    [[ "${status}" -eq 0 ]]
}

@test "terminal::is_term returns 0 when in a TTY" {
    if [[ -t 1 ]]; then
        run terminal::is_term
        [[ "${status}" -eq 0 ]]
    fi
}

@test "date::now returns a valid Unix timestamp" {
    run date::now
    [[ "${output}" =~ ^[0-9]+$ ]]
}

@test "bash::version returns a version string" {
    run bash::version
    [[ "${output}" =~ ^[0-9]+\.[0-9]+ ]]
}

@test "bash::major_version returns a numeric value" {
    run bash::major_version
    [[ "${output}" =~ ^[0-9]+$ ]]
}

@test "bash::minor_version returns a numeric value" {
    run bash::minor_version
    [[ "${output}" =~ ^[0-9]+$ ]]
}

@test "bash::path returns an executable path" {
    run bash::path
    [[ -x "${output}" ]]
}

@test "bash::is_interactive does not error" {
    run bash::is_interactive
    [[ "${status}" -eq 0 ]] || [[ "${status}" -eq 1 ]]
}

@test "bash::is_strict_mode_enabled returns 0 or 1" {
    run bash::is_strict_mode_enabled
    [[ "${status}" -eq 0 ]] || [[ "${status}" -eq 1 ]]
}

@test "bash::options returns output" {
    run bash::options
    [[ -n "${output}" ]]
}

@test "bash::require_version does not exit if satisfied" {
    run bash -c "source '${LIB_HOME}/_common.sh'; bash::require_version 3"
    [[ "${status}" -eq 0 ]]
}
