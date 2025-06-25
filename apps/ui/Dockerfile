# syntax=docker/dockerfile:1.4

#############################
# Base stage with devtools
#############################
FROM ubuntu@sha256:b59d21599a2b151e23eea5f6602f4af4d7d31c4e236d22bf0b62b86d2e386b8f AS base

# Ensure the build process uses the root user.
USER root

# Arguments for creating a non-root user.
ARG APP_USER=universal
ARG APP_GROUP=universal

# Arguments for the UI
ARG UI_PORT=8080

# Set environment variables.
ENV APP_USER=${APP_USER}
ENV APP_GROUP=${APP_GROUP}
ENV APP_UID=65532
ENV APP_GID=65532
ENV APP_HOME=/home/${APP_USER}

# Set environment variables for devtools
ENV DEVTOOLS_HOME=/opt/devtools \
    TASKFILE_HOME_DIR=/opt/devtools/.task \
    ASDF_DIR=/opt/devtools/.asdf \
    ASDF_DATA_DIR=/opt/devtools/.asdf/data \
    ASDF_SHIMS_DIR=/opt/devtools/.asdf/data/shims \
    PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Add devtools to PATH
ENV PATH="${TASKFILE_HOME_DIR}:${ASDF_DIR}/bin:${ASDF_SHIMS_DIR}:${PATH}"

# Change to the application directory.
WORKDIR /app

# Create a non-root user with specific configurations.
RUN groupadd \
    --gid ${APP_GID} \
    --force ${APP_GROUP} \
    && useradd \
    --no-log-init \
    --create-home \
    --uid ${APP_UID} \
    --gid ${APP_GID} \
    --comment "Non-root User for Running Applications" \
    --home-dir ${APP_HOME} \
    --shell /usr/sbin/nologin \
    ${APP_USER} \
    && mkdir --parents ${APP_HOME} \
    && chown --recursive ${APP_USER}:${APP_GROUP} ${APP_HOME} \
    && chmod --recursive 700 ${APP_HOME}

# Install dependencies with pinned versions for reproducible builds
RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
    ca-certificates \
    curl \
    apache2 \
    gnupg \
    git \
    jq \
    libssl-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install asdf-managed tools (NodeJS, pnpm, etc.)
COPY scripts/devtools.sh /tmp/devtools.sh
COPY services/api/.tool-versions .tool-versions
RUN chmod +x /tmp/devtools.sh && \
    bash /tmp/devtools.sh && \
    rm /tmp/devtools.sh

# Copy package.json and lockfile to leverage Docker cache
COPY apps/ui/package.json apps/ui/pnpm-lock.yaml ./

# Install Node.js dependencies
RUN pnpm install --frozen-lockfile

# Build the UI
COPY apps/ui/ ./
RUN pnpm build

COPY --from=builder /app/dist /usr/local/apache2/htdocs
COPY apps/ui/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80 443 $UI_PORT

ENTRYPOINT ["/entrypoint.sh"]
CMD []
