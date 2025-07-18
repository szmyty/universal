#!/usr/bin/env bash
set -euo pipefail

######################################
# 🔐 Export Keycloak Realm to JSON
# Usage:
#   ./export-keycloak.sh [--realm name] [--export-path path]
#                        [--db-vendor postgres] [--db-host host]
#                        [--db-name name] [--db-user user]
#                        [--db-password pass]
######################################

# Defaults
REALM_NAME="${KEYCLOAK_REALM:-development}"
EXPORT_PATH="${KEYCLOAK_EXPORT_PATH:-/opt/keycloak/development-realm.json}"
DB_VENDOR="${KEYCLOAK_DB_VENDOR:-postgres}"
DB_HOST="${KEYCLOAK_DB_HOSTNAME:-keycloak-db}"
DB_NAME="${KEYCLOAK_DB_NAME:-keycloak}"
DB_USER="${KEYCLOAK_DB_USER:-keycloak}"
DB_PASSWORD="${KEYCLOAK_DB_PASSWORD:-keycloak}"

print_help() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  --realm NAME           Name of the realm to export (default: ${REALM_NAME})
  --export-path PATH     File path to export the realm JSON (default: ${EXPORT_PATH})
  --db-vendor NAME       Database vendor (default: ${DB_VENDOR})
  --db-host HOST         Database hostname (default: ${DB_HOST})
  --db-name NAME         Database name (default: ${DB_NAME})
  --db-user USER         Database username (default: ${DB_USER})
  --db-password PASS     Database password (default: ${DB_PASSWORD})
  -h, --help             Show this help message and exit
EOF
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --realm) REALM_NAME="$2"; shift ;;
      --export-path) EXPORT_PATH="$2"; shift ;;
      --db-vendor) DB_VENDOR="$2"; shift ;;
      --db-host) DB_HOST="$2"; shift ;;
      --db-name) DB_NAME="$2"; shift ;;
      --db-user) DB_USER="$2"; shift ;;
      --db-password) DB_PASSWORD="$2"; shift ;;
      -h|--help) print_help; exit 0 ;;
      *) echo "❌ Unknown option: $1" >&2; print_help; exit 1 ;;
    esac
    shift
  done
}

export_keycloak_realm() {
  echo "🔁 Exporting realm '${REALM_NAME}' to ${EXPORT_PATH}..."

  /opt/keycloak/bin/kc.sh export \
    --file="${EXPORT_PATH}" \
    --realm="${REALM_NAME}" \
    --users=same_file \
    --db="${DB_VENDOR}" \
    --db-url="jdbc:postgresql://${DB_HOST}:5432/${DB_NAME}" \
    --db-username="${DB_USER}" \
    --db-password="${DB_PASSWORD}"

  printf "✅ Export completed: %s\n" "${EXPORT_PATH}"
}

main() {
  parse_args "$@"
  export_keycloak_realm
}

main "$@"
