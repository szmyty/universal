# syntax=docker/dockerfile:1.4

#############################
# Base stage with devtools
#############################
FROM ubuntu@sha256:b59d21599a2b151e23eea5f6602f4af4d7d31c4e236d22bf0b62b86d2e386b8f AS base

ENV DEVTOOLS_HOME=/opt/devtools \
    TASKFILE_HOME_DIR=/opt/devtools/.task \
    ASDF_DIR=/opt/devtools/.asdf \
    ASDF_DATA_DIR=/opt/devtools/.asdf/data \
    ASDF_SHIMS_DIR=/opt/devtools/.asdf/data/shims \
    PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

ENV PATH="${TASKFILE_HOME_DIR}:${ASDF_DIR}/bin:${ASDF_SHIMS_DIR}:${PATH}"

WORKDIR /app

# Install asdf-managed tools and Apache
COPY scripts/devtools.sh /tmp/devtools.sh
COPY apps/ui/.tool-versions .tool-versions
RUN chmod +x /tmp/devtools.sh && \
    bash /tmp/devtools.sh && \
    apt-get update && apt-get install --yes apache2 && \
    rm -rf /var/lib/apt/lists/* && \
    rm /tmp/devtools.sh

#############################
# Builder stage
#############################
FROM base AS builder

COPY apps/ui/package.json apps/ui/pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

COPY apps/ui/ ./
RUN pnpm build

#############################
# Runtime stage
#############################
FROM base AS runtime

ENV APP_ENV=production \
    UI_PORT=5173

COPY --from=builder /app/dist /usr/local/apache2/htdocs
COPY apps/ui/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80 443 $UI_PORT

ENTRYPOINT ["/entrypoint.sh"]
CMD []

