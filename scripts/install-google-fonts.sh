#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Script: install-google-fonts.sh
# Description: Installs all Google Fonts from a specific GitHub commit SHA
# -----------------------------------------------------------------------------

# ─────────────────────────────────────────────────────────────────────────────
# Config Defaults
# ─────────────────────────────────────────────────────────────────────────────
DEFAULT_SHA="main"
DEFAULT_INSTALL_DIR="$HOME/.local/share/fonts/google-fonts"

GOOGLE_FONTS_ARCHIVE_URL="https://github.com/google/fonts/archive"
GOOGLE_FONTS_SHA_URL="https://api.github.com/repos/google/fonts/commits/main"

# ─────────────────────────────────────────────────────────────────────────────
# Functions
# ─────────────────────────────────────────────────────────────────────────────

log() {
  printf "👉 %s\n" "$*" >&2
}

error() {
  printf "❌ %s\n" "$*" >&2
  exit 1
}

get_latest_sha() {
  curl --show-error "${GOOGLE_FONTS_SHA_URL}" | grep '"sha"' | head -n 1 | cut -d '"' -f 4
}

download_fonts_zip() {
  local sha="$1"
  local dest="$2"
  local url="${GOOGLE_FONTS_ARCHIVE_URL}/${sha}.zip"

  log "📥 Downloading Google Fonts release @ SHA: $sha"
  curl --show-error --location --output "$dest" "$url" || error "Failed to download ZIP from $url"
}

extract_fonts() {
  local zip_file="$1"
  local dest_dir="$2"

  log "📦 Extracting ZIP..."
  unzip -q "$zip_file" -d "$dest_dir" || error "Failed to extract ZIP"
}

install_fonts() {
  local extracted_dir="$1"
  local install_dir="$2"

  log "📁 Installing fonts to $install_dir"
  mkdir -p "$install_dir"

  find "$extracted_dir" -type f \( -iname '*.ttf' -o -iname '*.otf' \) \
    -exec cp {} "$install_dir" \;
}

refresh_font_cache() {
  local install_dir="$1"

  if command -v fc-cache &>/dev/null; then
    log "🔄 Refreshing font cache..."
    fc-cache -f "$install_dir"
    log "✅ Font cache updated"
  else
    log "⚠️ 'fc-cache' not found — please refresh font cache manually"
  fi
}

cleanup_temp() {
  [[ -d "${TEMP_DIR:-}" ]] && rm -rf "$TEMP_DIR"
}

# ─────────────────────────────────────────────────────────────────────────────
# Main Entrypoint
# ─────────────────────────────────────────────────────────────────────────────

main() {
  local sha="${1:-$DEFAULT_SHA}"
  local install_dir="${2:-$DEFAULT_INSTALL_DIR}"
  TEMP_DIR="$(mktemp -d)"
  trap cleanup_temp EXIT

  [[ "$sha" == "latest" || "$sha" == "main" ]] && sha="$(get_latest_sha)"

  local zip_file="$TEMP_DIR/fonts.zip"
  local extracted_dir="$TEMP_DIR/fonts-${sha}"

  download_fonts_zip "$sha" "$zip_file"
  extract_fonts "$zip_file" "$TEMP_DIR"
  install_fonts "$TEMP_DIR/fonts-${sha}" "$install_dir"
  refresh_font_cache "$install_dir"

  log "🎉 Fonts installed to: $install_dir"
}

main "$@"
