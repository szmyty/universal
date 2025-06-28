#!/usr/bin/env bash
# Create predefined realm roles in Keycloak using kcadm.sh

set -euo pipefail

REALM_NAME="${REALM_NAME:-universal}"
KEYCLOAK_SERVER="${KEYCLOAK_SERVER:-http://localhost:${KEYCLOAK_HTTP_PORT}/auth}"
KEYCLOAK_REALM="${KEYCLOAK_REALM:-master}"
KEYCLOAK_USER="${KEYCLOAK_USER:-admin}"
KEYCLOAK_PASSWORD="${KEYCLOAK_PASSWORD:-admin}"

ROLES=(
  "superuser:Full override/root-like access"
  "admin:Application or org-level admin"
  "editor:Can modify content but not users"
  "viewer:Read-only access"
  "contributor:Can submit content but not publish"
  "manager:High-level non-technical role (e.g. dashboard-only)"
  "analyst:Data-only visibility role"
  "developer:For internal/staging tools or preview builds"
)

# Adjust this path to where your Keycloak CLI tools are installed
KCADM="/opt/keycloak/bin/kcadm.sh"

login_keycloak() {
  printf "🔐 Logging into Keycloak admin CLI...\n"
  "$KCADM" config credentials \
    --server "$KEYCLOAK_SERVER" \
    --realm "$KEYCLOAK_REALM" \
    --user "$KEYCLOAK_USER" \
    --password "$KEYCLOAK_PASSWORD"
}

create_role() {
  local name="$1"
  local desc="$2"
  printf "➡️ Creating role: %s\n" "$name"
  "$KCADM" create roles \
    -r "$REALM_NAME" \
    -s name="$name" \
    -s description="$desc" \
    --no-config \
    || printf "⚠️ Role %s may already exist — skipping\n" "$name"
}

create_roles() {
  printf "🏗️ Creating roles in realm: %s\n" "$REALM_NAME"
  for entry in "${ROLES[@]}"; do
    IFS=":" read -r name desc <<< "$entry"
    create_role "$name" "$desc"
  done
}

main() {
  login_keycloak
  create_roles
  printf "✅ Done!\n"
}

main "$@"
