#!/usr/bin/env bash
# backup-container.sh
# Backup a Docker container (or devcontainer) to a .tar file.

set -euo pipefail

DEFAULT_DEVCONTAINER_NAME="my-devcontainer"
CONTAINER_NAME=""
OUTPUT_DIR="./backups"
TAG="latest"
IS_DEVCONTAINER=false

print_usage() {
  echo "Usage: $0 [--container name] [--tag tagname] [--devcontainer] [--output ./dir]"
  echo ""
  echo "  --container       Name of the container to back up"
  echo "  --tag             Optional image tag to apply (default: latest)"
  echo "  --devcontainer    Use devcontainer name defined in devcontainer.json"
  echo "  --output          Directory to save the backup (default: ./backups)"
  exit 1
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --container)
        CONTAINER_NAME="$2"
        shift 2
        ;;
      --tag)
        TAG="$2"
        shift 2
        ;;
      --devcontainer)
        IS_DEVCONTAINER=true
        shift
        ;;
      --output)
        OUTPUT_DIR="$2"
        shift 2
        ;;
      *)
        print_usage
        ;;
    esac
  done
}

resolve_devcontainer_name() {
  if [[ ! -f ".devcontainer/devcontainer.json" ]]; then
    echo "❌ .devcontainer/devcontainer.json not found."
    exit 1
  fi

  CONTAINER_NAME=$(jq -r '.name // empty' .devcontainer/devcontainer.json)
  if [[ -z "$CONTAINER_NAME" ]]; then
    echo "❌ 'name' not found in devcontainer.json."
    exit 1
  fi
}

backup_container() {
  mkdir -p "$OUTPUT_DIR"

  echo "📦 Committing container: $CONTAINER_NAME"
  docker commit "$CONTAINER_NAME" "${CONTAINER_NAME}:${TAG}"

  echo "💾 Saving image to: $OUTPUT_DIR/${CONTAINER_NAME}-${TAG}.tar"
  docker save -o "${OUTPUT_DIR}/${CONTAINER_NAME}-${TAG}.tar" "${CONTAINER_NAME}:${TAG}"

  echo "✅ Backup complete: ${OUTPUT_DIR}/${CONTAINER_NAME}-${TAG}.tar"
}

main() {
  parse_args "$@"

  if [[ "$IS_DEVCONTAINER" = true ]]; then
    resolve_devcontainer_name
  fi

  if [[ -z "$CONTAINER_NAME" ]]; then
    echo "❌ Must provide --container or use --devcontainer."
    exit 1
  fi

  backup_container
}

main "$@"
