#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# scripts/generate-pwa-icons.sh
# Generates PWA PNG icons + favicon.ico from a single source image
# ------------------------------------------------------------------------------

set -euo pipefail

SOURCE="icon.png"
OUT_DIR="icons"
FAVICON_SIZES=(16 32 48 64 128 256)
ALL_SIZES=(16 32 48 64 128 192 256 384 512)

mkdir -p "$OUT_DIR"

log() {
  echo "🔹 $1"
}

abort() {
  echo "❌ $1" >&2
  exit 1
}

check_imagemagick_installed() {
  if ! command -v convert &> /dev/null; then
    abort "ImageMagick 'convert' command not found. Please install ImageMagick."
  fi
}

check_source_exists() {
  if [[ ! -f "$SOURCE" ]]; then
    abort "Source image not found: $SOURCE"
  fi
}

generate_png_icons() {
  log "Generating PNG icons (32-bit RGBA)..."
  for size in "${ALL_SIZES[@]}"; do
    convert "$SOURCE" \
      -resize "${size}x${size}" \
      -define png:color-type=6 -depth 8 \
      "$OUT_DIR/icon-${size}x${size}.png"
  done
}

generate_favicon() {
  log "Generating favicon.ico..."
  local favicon_sources=()
  for size in "${FAVICON_SIZES[@]}"; do
    favicon_sources+=("$OUT_DIR/icon-${size}x${size}.png")
  done

  convert "${favicon_sources[@]}" "$OUT_DIR/favicon.ico"
}

main() {
  log "Starting icon generation..."
  check_imagemagick_installed
  check_source_exists
  generate_png_icons
  generate_favicon
  log "✅ All icons and favicon.ico generated in: $OUT_DIR"
}

main "$@"
