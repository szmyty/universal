#!/usr/bin/env bash
# ------------------------------------------------------------------
# Entrypoint for Apache-based React/Vite app with OIDC + Reverse Proxy
# ------------------------------------------------------------------

set -euo pipefail

main() {
  printf "🔧 Rendering Apache configuration with envsubst..."

  printf 'Environment variables:\n'
  printf '  FQDN: %s\n' "${FQDN:-}"

  # Render httpd.conf from template
  envsubst '${APACHE_RUNTIME_DIR} ${APP_USER} ${APP_GROUP} ${FQDN} ${WEB_HTTP_PORT} ${WEB_HTTPS_PORT} ${SERVER_ADMIN_EMAIL} ${KEYCLOAK_REALM} ${KEYCLOAK_CLIENT_ID} ${KEYCLOAK_CLIENT_SECRET} ${KEYCLOAK_HTTP_RELATIVE_PATH} ${KEYCLOAK_HOSTNAME} ${KEYCLOAK_HTTP_PORT} ${API_PREFIX} ${API_HOSTNAME} ${API_PORT}' \
    < /usr/local/apache2/conf/httpd.template.conf \
    > /usr/local/apache2/conf/httpd.conf

  echo "🔁 Generating OIDC rewrite rule..."
  # Precompute the URL-encoded issuer for secure redirect matching
  OIDC_ESCAPED_ISSUER=$(printf 'https://%s:%s/auth/realms/' "${FQDN}" "${WEB_HTTPS_PORT}" | jq -sRr @uri)

  cat <<EOF > /usr/local/apache2/conf/extra/oidc-rewrite.conf
RewriteCond "%{REQUEST_URI}" "^/oauth2callback.*"
RewriteCond "%{QUERY_STRING}" "(.*(?:^|&))iss=([^&]*)&?(.*)&?$"
RewriteCond "%2" "!^${OIDC_ESCAPED_ISSUER}.*$" [NC]
RewriteRule "^.*$" "/?" [R]
EOF

  printf "🚀 Launching Apache HTTP Server in foreground as %s..." "${APP_USER:-root}"
#   exec gosu "${APP_USER}" httpd-foreground
    exec httpd-foreground

    printf "✅ Apache HTTP Server started successfully.\n"
}

main "$@"
