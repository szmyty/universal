#!/usr/bin/env bash
# ------------------------------------------------------------------
# Entrypoint for Apache-based React/Vite app with OIDC + Reverse Proxy
# ------------------------------------------------------------------

set -euo pipefail

DEV_REVERSE_PROXY_TEMPLATE=/usr/local/apache2/conf/extra/dev-reverse-proxy.template.conf
DEV_REVERSE_PROXY_RENDERED=/usr/local/apache2/conf/extra/dev-reverse-proxy.conf

main() {
  printf "🔧 Rendering Apache configuration with envsubst..."

  printf 'Environment variables:\n'
  printf '  FQDN: %s\n' "${FQDN:-}"

  # Render httpd.conf from template
  envsubst '${APACHE_RUNTIME_DIR} ${APP_USER} ${APP_GROUP} ${FQDN} ${WEB_HTTP_PORT} ${WEB_HTTPS_PORT} ${SERVER_ADMIN_EMAIL} ${KEYCLOAK_REALM} ${KEYCLOAK_CLIENT_ID} ${KEYCLOAK_CLIENT_SECRET} ${KEYCLOAK_HTTP_RELATIVE_PATH} ${KEYCLOAK_HOSTNAME} ${KEYCLOAK_HTTP_PORT} ${API_PREFIX} ${API_HOSTNAME} ${API_PORT}' \
    < /usr/local/apache2/conf/httpd.template.conf \
    > /usr/local/apache2/conf/httpd.conf

  printf "🔁 Generating OIDC rewrite rule..."
  # Precompute the URL-encoded issuer for secure redirect matching
  OIDC_ESCAPED_ISSUER=$(printf 'https://%s:%s/auth/realms/' "${FQDN}" "${WEB_HTTPS_PORT}" | jq -sRr @uri)

  cat <<EOF > /usr/local/apache2/conf/extra/oidc-rewrite.conf
RewriteCond "%{REQUEST_URI}" "^/oauth2callback.*"
RewriteCond "%{QUERY_STRING}" "(.*(?:^|&))iss=([^&]*)&?(.*)&?$"
RewriteCond "%2" "!^${OIDC_ESCAPED_ISSUER}.*$" [NC]
RewriteRule "^.*$" "/?" [R]
EOF

    # Render the dev reverse proxy file if it exists
    if [[ -f "$DEV_REVERSE_PROXY_TEMPLATE" ]]; then
        printf "🔁 Found dev reverse proxy template. Rendering with UI_PORT=%s...\n" "${UI_PORT:-5173}"

        envsubst '${UI_PORT}' < "$DEV_REVERSE_PROXY_TEMPLATE" > "$DEV_REVERSE_PROXY_RENDERED"
        printf "✅ Rendered dev reverse proxy config to %s\n" "$DEV_REVERSE_PROXY_RENDERED"
    else
        printf "ℹ️ No dev reverse proxy template found. Skipping.\n"
    fi

    printf "🚀 Launching Apache HTTP Server in foreground as %s..." "${APP_USER:-root}"
#   exec gosu "${APP_USER}" httpd-foreground
    exec httpd-foreground

    printf "✅ Apache HTTP Server started successfully.\n"
}

main "$@"
