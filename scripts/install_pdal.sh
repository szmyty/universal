#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Script: install-pdal.sh
# Description: Builds and installs PDAL from a specific commit with optional
#              SHA256 verification.
# -----------------------------------------------------------------------------

log()   { printf "👉 %s\n" "$*" >&2; }
error() { printf "❌ %s\n" "$*" >&2; exit 1; }

download_pdal() {
  log "📥 Downloading PDAL source from ${URL}"
  curl --fail --location --output "${ARCHIVE}" "${URL}"
}

verify_checksum() {
  echo "${CHECKSUM}  ${ARCHIVE}" | sha256sum -c -
  log "✅ SHA256 checksum verified"
}

extract_source() {
  log "📦 Extracting source"
  tar -xf "${ARCHIVE}" -C "${WORK_DIR}"
  SRC_DIR="$(find "${WORK_DIR}" -maxdepth 1 -type d -name 'PDAL-*' | head -n 1)"
}

build_pdal() {
  mkdir -p "${SRC_DIR}/build"
  cd "${SRC_DIR}/build"
  log "🔨 Configuring build"
  cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="${PREFIX}"
  log "🚀 Building PDAL"
  local jobs
  jobs=$(nproc || echo 1)  # Fallback to 1 if nproc fails
  make -j "${jobs}"
}

install_pdal() {
  log "📂 Installing to ${PREFIX}"
  make install
}

main() {
  SHA="${1:-}"
  CHECKSUM="${2:-}"
  PREFIX="${3:-/usr/local}"

  [[ -z "${SHA}" ]] && error "PDAL commit SHA required"

  WORK_DIR="$(mktemp -d)"
  trap 'rm -rf "$WORK_DIR"' EXIT

  ARCHIVE="${WORK_DIR}/pdal.tar.gz"
  URL="https://github.com/PDAL/PDAL/archive/${SHA}.tar.gz"

  download_pdal
  if [[ -n "${CHECKSUM}" ]]; then
    verify_checksum
  else
    log "⚠️ No SHA256 provided — skipping verification"
  fi

  extract_source
  build_pdal
  install_pdal

  log "🎉 PDAL installation complete"
}

main "$@"
