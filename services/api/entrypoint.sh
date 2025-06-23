#!/usr/bin/env bash
set -euo pipefail

main() {
    echo "🔐 Updating certs in trust store..."
    update-ca-certificates

    if [[ "${APP_ENV:-production}" == "development" ]]; then
        RELOAD="--reload"
    else
        RELOAD="--no-reload"
    fi

    echo "🚀 Starting FastAPI service..."
    exec poetry run python -m fastapi run app/main.py \
        --host 0.0.0.0 \
        --port "${API_PORT:-8000}" \
        $RELOAD \
        --proxy-headers \
        --root-path /api
}

main "$@"

