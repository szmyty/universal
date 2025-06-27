# syntax=docker/dockerfile:1.4

#############################
# Base stage with devtools
#############################
FROM ubuntu@sha256:b59d21599a2b151e23eea5f6602f4af4d7d31c4e236d22bf0b62b86d2e386b8f AS base

# Ensure the build process uses the root user.
USER root

# Override the default temporary directory if needed. Useful when
# working on filesystems where /tmp has limited space.
ARG TMPDIR=/tmp

# Locale and timezone settings used during build and at runtime
ARG LANG=en_US.UTF-8
ARG LANGUAGE=en_US:en
ARG TZ=UTC
ARG LC_ALL=en_US.UTF-8

# Arguments for creating a non-root user.
ARG APP_USER=universal
ARG APP_GROUP=universal

# API server port
ARG API_PORT=8000

# Set environment variables.
ENV APP_USER=${APP_USER}
ENV APP_GROUP=${APP_GROUP}
ENV APP_UID=65532
ENV APP_GID=65532
ENV APP_HOME=/home/${APP_USER}

# Core environment variables for non-interactive apt operations and consistent behaviour.
ENV DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true \
    DEBIAN_PRIORITY=critical \
    DEBCONF_NOWARNINGS=yes \
    TERM=xterm-256color \
    APT_LISTCHANGES_FRONTEND=none \
    APT_LISTBUGS_FRONTEND=none \
    TMPDIR=${TMPDIR} \
    LANG=${LANG} \
    LANGUAGE=${LANGUAGE} \
    TZ=${TZ} \
    LC_ALL=${LC_ALL} \
    PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8 \
    PYTHONUTF8=1 \
    PYTHONHASHSEED=random \
    PIP_NO_CACHE_DIR=1 \
    PYTHONFAULTHANDLER=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_NO_WARN_SCRIPT_LOCATION=on \
    PIP_DEFAULT_TIMEOUT=200 \
    GNUTLS_FORCE_FIPS_MODE=1 \
    PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    DEVTOOLS_HOME=/opt/devtools \
    TASKFILE_HOME_DIR=/opt/devtools/.task \
    ASDF_DIR=/opt/devtools/.asdf \
    ASDF_DATA_DIR=/opt/devtools/.asdf/data \
    ASDF_SHIMS_DIR=/opt/devtools/.asdf/data/shims \
    API_PORT=${API_PORT}

# Add devtools to PATH
ENV PATH="${TASKFILE_HOME_DIR}:${ASDF_DIR}/bin:${ASDF_SHIMS_DIR}:${PATH}"

# Set the Python path to include the application source code.
ENV PYTHONPATH="/app/src"

# Change to the application directory.
WORKDIR /app

# Disable the automatic removal of downloaded packages
RUN rm -f /etc/apt/apt.conf.d/docker-clean

# Fix for update-alternatives: error:
# 'error creating symbolic link '/usr/share/man/man1/rmid.1.gz.dpkg-tmp': No such file or directory'
# See https://github.com/debuerreotype/docker-debian-artifacts/issues/24#issuecomment-360870939
RUN mkdir --parents /usr/share/man/man1

# Copy configuration files for apt and dpkg
COPY config/dpkg/*.conf /etc/dpkg/dpkg.cfg.d/
COPY config/apt/*.conf /etc/apt/apt.conf.d/

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
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=apt-cache \
    --mount=type=cache,target=/var/lib/apt,sharing=locked,id=apt-lib \
    apt-get update -qq && \
    apt-get install --yes --no-install-recommends \
    build-essential=12.10ubuntu1 \
    ca-certificates=20240203 \
    curl=8.5.0-2ubuntu10.6 \
    git=1:2.43.0-1ubuntu7.2 \
    jq=1.7.1-3build1 \
    locales \
    locales-all \
    libbz2-dev=1.0.8-5.1build0.1 \
    libffi-dev=3.4.6-1build1 \
    libjpeg-dev=8c-2ubuntu11 \
    liblzma-dev=5.6.1+really5.4.5-1ubuntu0.2 \
    libncurses-dev=6.4+20240113-1ubuntu2 \
    libpq-dev=16.9-0ubuntu0.24.04.1 \
    libreadline-dev=8.2-4build1 \
    libsqlite3-dev=3.45.1-1ubuntu2.3 \
    libssl-dev=3.0.13-0ubuntu3.5 \
    libxml2-dev=2.9.14+dfsg-1.3ubuntu3.3 \
    libxslt1-dev=1.1.39-0exp1ubuntu0.24.04.2 \
    python3-dev=3.12.3-0ubuntu2 \
    python3-pip=24.0+dfsg-1ubuntu1.1 \
    python3-venv=3.12.3-0ubuntu2 \
    unzip=6.0-28ubuntu4.1 \
    uuid-dev=2.39.3-9ubuntu6.2 \
    wget=1.21.4-1ubuntu4.1 \
    zlib1g-dev=1:1.3.dfsg-3.1ubuntu2.1 \
    && rm -rf /var/lib/apt/lists/*

# Configure the system locale and timezone
RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && echo "LANG=en_US.UTF-8" > /etc/locale.conf \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8 \
    && dpkg-reconfigure locales

# Install asdf-managed tools (Python, Poetry, etc.)
COPY scripts/devtools.sh /tmp/devtools.sh
COPY services/api/.tool-versions .tool-versions
RUN chmod +x /tmp/devtools.sh && \
    bash /tmp/devtools.sh && \
    rm /tmp/devtools.sh

# Copy application files
COPY services/api /app/
RUN cp entrypoint.sh /entrypoint.sh && chmod +x /entrypoint.sh

# Install Python dependencies via Poetry
RUN task install

# Copy and source custom shell aliases
COPY shell/aliases.sh /etc/profile.d/docker_aliases.sh

# Ensure correct permissions and sourcing
RUN chmod 644 /etc/profile.d/docker_aliases.sh && \
    echo '[ -d /etc/profile.d ] && for f in /etc/profile.d/*.sh; do [ -r "$f" ] && . "$f"; done' \
    >> /etc/bash.bashrc

# Take ownership of /app.
RUN chown -R ${APP_USER}:${APP_GROUP} /app

# Switch to the non-root user.
USER ${APP_USER}:${APP_GROUP}

# Expose the API port.
EXPOSE ${API_PORT}

# Set the default entrypoint and command.
ENTRYPOINT ["/entrypoint.sh"]
CMD []
