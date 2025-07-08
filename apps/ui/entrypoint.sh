#!/usr/bin/env bash
# If 'bash' isn't available in /usr/bin/env, fallback
[[ -z "${BASH_VERSION}" ]] && exec /bin/bash "$0" "$@"
# ------------------------------------------------------------------
# Entrypoint for Apache-based React/Vite app with OIDC + Reverse Proxy
# ------------------------------------------------------------------

set -euo pipefail

DEV_REVERSE_PROXY_TEMPLATE=/usr/local/apache2/conf/extra/dev-reverse-proxy.template.conf
DEV_REVERSE_PROXY_RENDERED=/usr/local/apache2/conf/extra/dev-reverse-proxy.conf

HTTPD_TEMPLATE=/usr/local/apache2/conf/httpd.template.conf
HTTPD_CONF=/usr/local/apache2/conf/httpd.conf

OIDC_REWRITE_CONF=/usr/local/apache2/conf/extra/oidc-rewrite.conf

# ------------------------------------------------------------------------------
# Function: render_template
# Description:
#   Dynamically renders a template file using envsubst by substituting environment
#   variables with their current or default values. Outputs a final config file.
#
# Usage:
#   render_template input.template output.conf VAR1=default1 VAR2=default2 ...
# ------------------------------------------------------------------------------
render_template() {
    # Path to the input template (e.g. .template.conf)
    local template_path="$1"

    # Path where rendered output will be written
    local output_path="$2"

    # Shift off the first two arguments
    shift 2

    # Remaining args are VAR=default pairs
    local var_defs=("$@")

    printf "🛠️  Rendering template:\n  from: %s\n  to:   %s\n" "${template_path}" "${output_path}"
    printf "🔐 Using environment variables:\n"

    local varlist=""

    # Loop through all passed VAR=default definitions
    for pair in "${var_defs[@]}"; do
        # Extract the variable name (before =)
        local var="${pair%%=*}"

        # Extract the default value (after =)
        local default="${pair#*=}"

        # If the variable is not already set in the environment, use the default
        if [[ -z "${!var:-}" ]]; then
            export "${var}"="${default}"
        fi

        # Log the resolved value and default (helpful for debugging)
        printf "  - %-25s = %s (default: %s)\n" "${var}" "${!var}" "${default}"

        # Append the literal variable reference to the envsubst varlist
        varlist="${varlist} \${${var}}"
    done

    # Use envsubst to substitute all the requested variables in the template
    envsubst "${varlist}" <"${template_path}" >"${output_path}"
}

# ------------------------------------------------------------------------------
# Function: generate_oidc_rewrite_rule
# Description:
#   Generates a Keycloak OIDC issuer validation rewrite rule used to prevent
#   token hijacking via manipulated `iss` parameters in the OAuth2 redirect.
#   The generated rule is written to Apache's extra config directory.
# ------------------------------------------------------------------------------

generate_oidc_rewrite_rule() {
    local fqdn="${FQDN:-localhost}"
    local port="${WEB_HTTPS_PORT:-443}"
    local output_path="${OIDC_REWRITE_CONF}"

    printf "🔁 Generating OIDC rewrite rule for FQDN: %s on port: %s\n" "${fqdn}" "${port}"

    # Build the OIDC issuer URL and escape it using jq @uri
    local issuer_url="https://${fqdn}:${port}/auth/realms/"
    local escaped_issuer
    escaped_issuer=$(printf '%s' "${issuer_url}" | jq --slurp --raw-input --raw-output @uri)

    # Write the Apache rewrite rule for secure issuer checking
    cat >"${output_path}" <<EOF
RewriteCond "%{REQUEST_URI}" "^/oauth2callback.*"
RewriteCond "%{QUERY_STRING}" "(.*(?:^|&))iss=([^&]*)&?(.*)&?$"
RewriteCond "%2" "!^${escaped_issuer}.*$" [NC]
RewriteRule "^.*$" "/?" [R]
EOF

    printf "✅ OIDC rewrite rule written to: %s\n" "${output_path}"
}

render_httpd_conf() {
    printf "🔧 Rendering Apache HTTPD configuration from template...\n"

    render_template \
        "${HTTPD_TEMPLATE}" \
        "${HTTPD_CONF}" \
        APACHE_RUNTIME_DIR=/tmp/apache \
        APP_USER=www-data \
        APP_GROUP=www-data \
        FQDN=localhost \
        WEB_HTTP_PORT=80 \
        WEB_HTTPS_PORT=443 \
        SERVER_ADMIN_EMAIL=admin@localhost \
        KEYCLOAK_REALM=dev \
        KEYCLOAK_CLIENT_ID=app \
        KEYCLOAK_CLIENT_SECRET=changeme \
        KEYCLOAK_HTTP_RELATIVE_PATH=/auth \
        KEYCLOAK_HOSTNAME=keycloak \
        KEYCLOAK_HTTP_PORT=8080 \
        API_PREFIX=/api \
        API_HOSTNAME=api \
        API_PORT=4000

    printf "✅ Rendered Apache HTTPD config to %s\n" "${HTTPD_CONF}"
}

render_dev_reverse_proxy() {
    if [[ -f "${DEV_REVERSE_PROXY_TEMPLATE}" ]]; then
        printf "🔧 Rendering development reverse proxy configuration...\n"

        render_template \
            "${DEV_REVERSE_PROXY_TEMPLATE}" \
            "${DEV_REVERSE_PROXY_RENDERED}" \
            UI_PORT=5173

        printf "✅ Rendered dev reverse proxy config to %s\n" "${DEV_REVERSE_PROXY_RENDERED}"
    else
        printf "⚠️  No dev reverse proxy template found, skipping rendering.\n"
    fi
}

start_apache() {
    printf "🚀 Starting Apache HTTP Server in foreground as %s...\n" "${APP_USER:-root}"
    exec httpd-foreground
}

main() {
    printf "🔧 Rendering Apache configuration with envsubst..."

    # Render httpd.conf from template
    render_httpd_conf

    # Generate OIDC rewrite rule for secure issuer checking
    generate_oidc_rewrite_rule

    # If in local development, render the dev reverse proxy config.
    render_dev_reverse_proxy

    # Start Apache HTTP Server
    start_apache

    printf "✅ Apache HTTP Server started successfully.\n"
}

main "$@"
