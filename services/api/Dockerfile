# syntax=docker/dockerfile:1.4

#############################
# Base stage with devtools
#############################
FROM ubuntu@sha256:b59d21599a2b151e23eea5f6602f4af4d7d31c4e236d22bf0b62b86d2e386b8f AS base

ENV DEVTOOLS_HOME=/opt/devtools \
    TASKFILE_HOME_DIR=/opt/devtools/.task \
    ASDF_DIR=/opt/devtools/.asdf \
    ASDF_DATA_DIR=/opt/devtools/.asdf/data \
    ASDF_SHIMS_DIR=/opt/devtools/.asdf/data/shims

ENV PATH="${TASKFILE_HOME_DIR}:${ASDF_DIR}/bin:${ASDF_SHIMS_DIR}:${PATH}"

WORKDIR /app

# Install asdf-managed tools (Python, Poetry, etc.)
COPY scripts/devtools.sh /tmp/devtools.sh
COPY services/api/.tool-versions .tool-versions
RUN chmod +x /tmp/devtools.sh && \
    bash /tmp/devtools.sh && \
    rm /tmp/devtools.sh

#############################
# Builder stage
#############################
FROM base AS builder

COPY services/api/pyproject.toml services/api/poetry.lock services/api/poetry.toml ./
RUN poetry install --only main --no-root

#############################
# Runtime stage
#############################
FROM base AS runtime
ENV APP_ENV=production \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

COPY --from=builder /app/.venv /app/.venv
COPY services/api/pyproject.toml services/api/poetry.lock services/api/poetry.toml ./
COPY services/api/src ./src
COPY services/api/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD []
