# syntax=docker/dockerfile:1

# ---------- Builder Stage ----------
FROM python:3.12-slim AS builder

ENV POETRY_HOME=/opt/poetry \
    POETRY_VERSION=1.8.2 \
    PATH="$POETRY_HOME/bin:$PATH"

WORKDIR /build

# Install system deps and Poetry
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl build-essential \
    && curl -sSL https://install.python-poetry.org | python3 - \
    && poetry config virtualenvs.in-project true \
    && apt-get purge -y --auto-remove curl \
    && rm -rf /var/lib/apt/lists/*

COPY pyproject.toml poetry.lock poetry.toml ./
RUN poetry install --only main --no-interaction --no-root

# ---------- Runtime Stage ----------
FROM python:3.12-slim AS runtime

ENV POETRY_HOME=/opt/poetry \
    PATH="$POETRY_HOME/bin:/app/.venv/bin:$PATH" \
    APP_ENV=production \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Install ca-certificates for HTTPS and refresh trust store
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy poetry + env from builder
COPY --from=builder $POETRY_HOME $POETRY_HOME
COPY --from=builder /build/.venv /app/.venv
COPY pyproject.toml poetry.lock poetry.toml ./
COPY src ./src
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD []
