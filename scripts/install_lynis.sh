#!/usr/bin/env bash
# install_lynis.sh - Download and install Lynis from GitHub
set -euo pipefail

VERSION="${1:-3.1.1}"
PREFIX="${2:-/usr/local}"

LYNIS_URL="https://github.com/CISOfy/lynis/archive/refs/tags/v${VERSION}.tar.gz"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

echo "📥 Downloading Lynis ${VERSION}"
curl --fail --location --output "$WORK_DIR/lynis.tar.gz" "$LYNIS_URL"

echo "📦 Extracting"
tar -xf "$WORK_DIR/lynis.tar.gz" -C "$WORK_DIR"
LYNIS_SRC="$(find "$WORK_DIR" -maxdepth 1 -type d -name "lynis-*" | head -n 1)"

install -d "${PREFIX}/lynis"
cp -r "$LYNIS_SRC"/* "${PREFIX}/lynis/"
ln -sf "${PREFIX}/lynis/lynis" /usr/local/bin/lynis

echo "✅ Lynis installed to ${PREFIX}/lynis"
