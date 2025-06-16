#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Script: install-google-fonts.sh
# Description: Installs Google Fonts from a Git commit with SHA256 verification.
#              Caches zip downloads and skips reinstall if unchanged.
# -----------------------------------------------------------------------------

DEFAULT_INSTALL_DIR="/usr/local/share/fonts/google"
GOOGLE_FONTS_SHA_COMMIT="${GOOGLE_FONTS_SHA_COMMIT:-main}"
GOOGLE_FONTS_SHA256="${GOOGLE_FONTS_SHA256:-}"
GOOGLE_FONTS_ARCHIVE_URL="https://github.com/google/fonts/archive"
ZIP_CACHE_DIR="/var/cache/fonts"

log()    { printf "👉 %s\n" "$*" >&2; }
error()  { printf "❌ %s\n" "$*" >&2; exit 1; }

verify_checksum() {
  local file="$1"
  local expected="$2"
  local actual
  actual=$(sha256sum "${file}" | cut -d ' ' -f 1)

  if [[ "${actual}" != "${expected}" ]]; then
    error "SHA256 mismatch! Expected: ${expected} | Got: ${actual}"
  fi
  log "✅ SHA256 checksum verified"
}

download_fonts_zip() {
  local sha="$1"
  local dest="$2"
  local url="${GOOGLE_FONTS_ARCHIVE_URL}/${sha}.zip"

  log "📥 Downloading fonts from ${url}"
  curl --fail --location --output "${dest}" "${url}" || error "Failed to download ZIP"
}

extract_fonts() {
  local zip_file="$1"
  local dest_dir="$2"
  log "📦 Extracting ZIP..."
  unzip -q "${zip_file}" -d "${dest_dir}" || error "Failed to extract ZIP"
}

install_fonts() {
  local src_dir="$1"
  local dest_dir="$2"
  log "📁 Installing fonts to ${dest_dir}"
  mkdir -p "${dest_dir}"
  find "${src_dir}" -type f \( -iname '*.ttf' -o -iname '*.otf' \) -exec cp {} "${dest_dir}" \;
}

refresh_font_cache() {
  local dir="$1"
  if command -v fc-cache &>/dev/null; then
    log "🔄 Refreshing font cache..."
    fc-cache -f "${dir}"
    log "✅ Font cache updated"
  else
    log "⚠️ fc-cache not found — skipping font cache refresh"
  fi
}

cleanup_temp() {
  [[ -d "${TEMP_DIR:-}" ]] && rm -rf "${TEMP_DIR}"
}

main() {
  local install_dir="${1:-$DEFAULT_INSTALL_DIR}"
  local lockfile="${install_dir}/.installed-sha256"
  local zip_file="${ZIP_CACHE_DIR}/fonts-${GOOGLE_FONTS_SHA_COMMIT}.zip"
  local extract_dir
  TEMP_DIR="$(mktemp -d)"
  extract_dir="${TEMP_DIR}/fonts-${GOOGLE_FONTS_SHA_COMMIT}"
  trap cleanup_temp EXIT

  # Skip if already installed with same hash
  if [[ -f "${lockfile}" && -n "${GOOGLE_FONTS_SHA256}" ]]; then
    if [[ "$(cat "${lockfile}")" == "${GOOGLE_FONTS_SHA256}" ]]; then
      log "✅ Fonts already installed (SHA256 match) — skipping"
      return 0
    fi
  fi

  mkdir -p "$ZIP_CACHE_DIR"
  if [[ ! -f "${zip_file}" ]]; then
    download_fonts_zip "${GOOGLE_FONTS_SHA_COMMIT}" "${zip_file}"
  else
    log "📦 Using cached ZIP: ${zip_file}"
  fi

  if [[ -n "${GOOGLE_FONTS_SHA256}" ]]; then
    verify_checksum "${zip_file}" "${GOOGLE_FONTS_SHA256}"
  else
    log "⚠️ No GOOGLE_FONTS_SHA256 provided — skipping hash check"
  fi

  extract_fonts "${zip_file}" "${TEMP_DIR}"
  install_fonts "${extract_dir}" "${install_dir}"
  refresh_font_cache "${install_dir}"

  echo "$GOOGLE_FONTS_SHA256" > "${lockfile}"
  log "🎉 Fonts installed to: ${install_dir}"
}

main "$@"
