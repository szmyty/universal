#!/usr/bin/env bash
set -euo pipefail

main() {
    echo "🔐 Updating certs in trust store..."
    update-ca-certificates

    if [[ "${APP_ENV:-production}" == "development" ]]; then
        echo "🧪 Development mode detected: starting Vite dev server and Apache"
        pnpm dev -- --host 0.0.0.0 --port "${UI_PORT:-5173}" &
        exec apachectl -DFOREGROUND
    else
        echo "🚀 Serving built UI with Apache"
        exec apachectl -DFOREGROUND
    fi
}

main "$@"
