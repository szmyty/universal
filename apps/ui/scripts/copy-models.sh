#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# scripts/copy-models.sh
# Copies config/models.json → node_modules/@kepler.gl/ai-assistant/dist/config/
# Skips if the destination file already exists
# ------------------------------------------------------------------------------

set -euo pipefail

SOURCE="config/models.json"
DEST_DIR="node_modules/@kepler.gl/ai-assistant/dist/config"
DEST_FILE="${DEST_DIR}/models.json"

log() {
  echo "🔹 $1"
}

abort() {
  echo "❌ $1" >&2
  exit 1
}

ensure_source_exists() {
  if [[ ! -f "${SOURCE}" ]]; then
    abort "Source file not found: ${SOURCE}"
  fi
}

skip_if_already_exists() {
  if [[ -f "${DEST_FILE}" ]]; then
    log "Skipping copy — destination already exists: ${DEST_FILE}"
    exit 0
  fi
}

ensure_dest_dir_exists() {
  mkdir -p "${DEST_DIR}"
}

copy_file() {
  cp "${SOURCE}" "${DEST_FILE}"
  log "Copied models.json → ${DEST_FILE}"
}

main() {
  log "Starting copy of models.json..."
  ensure_source_exists
  skip_if_already_exists
  ensure_dest_dir_exists
  copy_file
  log "✅ models.json copied successfully."
}

main "$@"
