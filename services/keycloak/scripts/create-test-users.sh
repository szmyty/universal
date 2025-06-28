#!/usr/bin/env bash
set -euo pipefail

REALM_NAME="${REALM_NAME:-development}"
KEYCLOAK_SERVER="${KEYCLOAK_SERVER:-http://localhost:${KEYCLOAK_HTTP_PORT}/auth}"
KEYCLOAK_REALM="${KEYCLOAK_REALM:-master}"
KEYCLOAK_USER="${KEYCLOAK_ADMIN_USER:-admin}"
KEYCLOAK_PASSWORD="${KEYCLOAK_ADMIN_PASSWORD:-admin}"

ROLES=(superuser admin editor viewer contributor manager analyst developer)

declare -A USERS=(
  [root.smith]="Root Smith root@universal.dev Root123! superuser"
  [admin.jane]="Jane Admin jane.admin@universal.dev Admin123! admin"
  [edit.alex]="Alex Editor alex.editor@universal.dev Edit123! editor"
  [view.emma]="Emma Viewer emma.viewer@universal.dev View123! viewer"
  [contrib.lee]="Lee Contributor lee.contrib@universal.dev Cont123! contributor"
  [mgr.davis]="Davis Manager davis.manager@universal.dev Mgr123! manager"
  [ana.kim]="Kim Analyst kim.analyst@universal.dev Data123! analyst"
  [dev.sam]="Sam Developer sam.dev@universal.dev Dev123! developer"
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

create_user() {
  local username="$1"
  IFS=" " read -r first last email password role <<<"${USERS[$username]}"

  printf "👤 Creating user: %s" "$username\n"

  "$KCADM" create users -r "$REALM" -s username="$username" -s enabled=true \
    -s email="$email" -s firstName="$first" -s lastName="$last"

  user_id=$("$KCADM" get users -r "$REALM" -q username="$username" --fields id --format csv | tail -n1)

  "$KCADM" set-password -r "$REALM" --username "$username" --new-password "$password" --no-temporary

  printf "🔗 Assigning role '%s' to user '%s'\n" "$role" "$username"
  "$KCADM" add-roles -r "$REALM" --username "$username" --rolename "$role"
}

main() {
  printf "🛠️ Creating users in realm: %s\n" "$REALM"
  for user in "${!USERS[@]}"; do
    create_user "$user"
  done
  printf "✅ Done creating users and assigning roles.\n"
}

main "$@"
