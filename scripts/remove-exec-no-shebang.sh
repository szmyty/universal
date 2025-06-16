#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Script: fix-exec-perms.sh
# Description: Removes exec permission from Git-visible files without shebangs.
# -----------------------------------------------------------------------------

SHEBANG_REGEX='^#!'

log() {
  printf "👉 %s\n" "$*" >&2
}

has_exec_bit() {
  [[ -x "$1" ]]
}

has_shebang() {
  head -n 1 "$1" | grep -qE "${SHEBANG_REGEX}"
}

error_trap() {
  local exit_code=$?
  local line_no=${1:-unknown}
  log "❌ Error on line ${line_no} (exit code ${exit_code})"
  exit "${exit_code}"
}

main() {
  trap 'error_trap $LINENO' ERR

  log "🔍 Checking Git-visible files for invalid exec bits..."

  local count=0

  readarray -d '' files < <(git ls-files --cached --others --exclude-standard -z)

  for file in "${files[@]}"; do
    [[ -f "${file}" ]] || continue
    log "🔍 Checking file: ${file}"

    if has_exec_bit "${file}"; then
        log "🔧 File has exec bit: ${file}"
    fi

    if ! has_shebang "$file"; then
        log "🚫 File has no shebang: $file"
    fi

    if has_exec_bit "$file" && ! has_shebang "$file"; then
      chmod -x "${file}"
      log "🛠️  Removed exec bit: ${file}"
      count=$((count + 1))
    fi
  done

  log "✅ Done. Stripped exec from ${count} file(s)."
}

main "$@"
