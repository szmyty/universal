#!/usr/bin/env bash
# ------------------------------------------------------------------
# Entry point script for the FastAPI service in a Docker container.
# Supports reload mode in development.
# ------------------------------------------------------------------

set -euo pipefail

main() {
    # echo "🔐 Updating certs in trust store..."
    # update-ca-certificates

    echo "🚀 Starting FastAPI (${APP_ENV})..."

    cmd="poetry run uvicorn app.main:app \
      --host=0.0.0.0 \
      --port=${API_PORT:-8000} \
      --log-level debug \
      --proxy-headers \
      --root-path /api"

    # Add reload flag only for dev mode
    if [[ "${APP_ENV:-production}" == "development" ]]; then
        echo "🧪 Development mode detected: enabling --reload"
        cmd="$cmd --reload"
    else
        cmd="$cmd --no-reload"
    fi

    echo "👉 Executing: $cmd"
    exec $cmd
}

main "$@"
