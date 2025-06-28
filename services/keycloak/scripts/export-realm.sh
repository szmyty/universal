#!/usr/bin/env bash
set -euo pipefail

######################################
# 🔐 Export Keycloak Realm to JSON
# Exports realm from configured Postgres DB
# Globals:
#   KEYCLOAK_DB_VENDOR
#   KEYCLOAK_DB_HOSTNAME
#   KEYCLOAK_DB_NAME
#   KEYCLOAK_DB_USER
#   KEYCLOAK_DB_PASSWORD
######################################
export_keycloak_realm() {
  local realm_name="development"
  local export_path="/opt/keycloak/development-realm.json"

  echo "🔁 Exporting realm '${realm_name}' to ${export_path}..."

  /opt/keycloak/bin/kc.sh export \
    --file="${export_path}" \
    --realm="${realm_name}" \
    --users=same_file \
    --db="${KEYCLOAK_DB_VENDOR:-postgres}" \
    --db-url="jdbc:postgresql://${KEYCLOAK_DB_HOSTNAME:-keycloak-db}:5432/${KEYCLOAK_DB_NAME:-keycloak}" \
    --db-username="${KEYCLOAK_DB_USER:-keycloak}" \
    --db-password="${KEYCLOAK_DB_PASSWORD:-keycloak}"

  printf "✅ Export completed: %s\n" "${export_path}"
}

main() {
  export_keycloak_realm
}

main "$@"
