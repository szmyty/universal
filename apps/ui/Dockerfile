# syntax=docker/dockerfile:1.4

###############################################
# 🧱 Base Stage — includes devtools and Apache
###############################################
FROM httpd:2.4 AS base

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

# Arguments for the UI
ARG WEB_HTTP_PORT=80
ARG WEB_HTTPS_PORT=443
ARG FQDN=localhost
ARG API_PREFIX=/api

# Set environment variables.
ENV APP_USER=${APP_USER}
ENV APP_GROUP=${APP_GROUP}
ENV APP_UID=65532
ENV APP_GID=65532
ENV APP_USER_HOME=/${APP_USER}
ENV APP_HOME=/${APP_USER}/app
ENV APP_SERVE_DIR=${APP_HOME}/dist

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
    DEVTOOLS_HOME=/opt/devtools \
    TASKFILE_HOME_DIR=/opt/devtools/.task \
    ASDF_DIR=/opt/devtools/.asdf \
    ASDF_DATA_DIR=/opt/devtools/.asdf/data \
    ASDF_SHIMS_DIR=/opt/devtools/.asdf/data/shims \
    FQDN=${FQDN} \
    WEB_HTTP_PORT=${WEB_HTTP_PORT} \
    WEB_HTTPS_PORT=${WEB_HTTPS_PORT} \
    API_PREFIX=${API_PREFIX}

# Add devtools to PATH
ENV PATH="${TASKFILE_HOME_DIR}:${ASDF_DIR}/bin:${ASDF_SHIMS_DIR}:${PATH}"

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
    --home-dir ${APP_USER_HOME} \
    --shell /usr/sbin/nologin \
    ${APP_USER} \
    && mkdir --parents ${APP_USER_HOME} \
    && chown --recursive ${APP_USER}:${APP_GROUP} ${APP_USER_HOME} \
    && chmod --recursive 700 ${APP_USER_HOME}

# Install dependencies with pinned versions for reproducible builds
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=apt-cache \
    --mount=type=cache,target=/var/lib/apt,sharing=locked,id=apt-lib \
    apt-get update -qq && \
    apt-get install --yes --no-install-recommends \
    build-essential=12.9 \
    ca-certificates=20230311+deb12u1 \
    curl=7.88.1-10+deb12u12 \
    gettext=0.21-12 \
    git=1:2.39.5-0+deb12u2 \
    gnupg=2.2.40-1.1 \
    gosu=1.14-1+b10 \
    jq=1.6-2.1 \
    libapache2-mod-auth-openidc=2.4.12.3-2+deb12u4 \
    libssl-dev=3.0.16-1~deb12u1 \
    locales=2.36-9+deb12u10 \
    wget=1.21.3-1+deb12u1 \
    && rm -rf /var/lib/apt/lists/*

# Configure the system locale and timezone
RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && echo "LANG=en_US.UTF-8" > /etc/locale.conf \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8 \
    && dpkg-reconfigure locales

###############################################
# 🛠️ Build Stage
###############################################
FROM base as builder

# Change to the application directory.
WORKDIR ${APP_HOME}

# Install asdf-managed tools (NodeJS, pnpm, etc.)
COPY scripts/devtools.sh /tmp/devtools.sh
COPY apps/ui/.tool-versions .tool-versions
RUN chmod +x /tmp/devtools.sh && \
    bash /tmp/devtools.sh && \
    rm /tmp/devtools.sh

# Copy and build app
COPY apps/ui/ ./

# Install Node.js dependencies
RUN task install
RUN task build

###############################################
# 🚀 Runtime Stage — Serve via Apache
###############################################
FROM builder as runtime

COPY --from=builder ${APP_SERVE_DIR} /usr/local/apache2/htdocs
COPY apps/ui/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# COPY services/apache/index.html /usr/local/apache2/htdocs/index.html

# Copy and source custom shell aliases
COPY shell/aliases.sh /etc/profile.d/docker_aliases.sh

# Ensure correct permissions and sourcing
RUN chmod 644 /etc/profile.d/docker_aliases.sh && \
    echo '[ -d /etc/profile.d ] && for f in /etc/profile.d/*.sh; do [ -r "$f" ] && . "$f"; done' \
    >> /etc/bash.bashrc

# Take ownership of /app.
RUN chown -R ${APP_USER}:${APP_GROUP} ${APP_SERVE_DIR} ${APP_HOME}

ENV APACHE_RUNTIME_DIR=${APP_HOME}/runtime/apache
ENV APACHE_RUN_DIR=${APACHE_RUNTIME_DIR}
ENV APACHE_PID_FILE=${APACHE_RUNTIME_DIR}/apache2.pid

RUN mkdir -p /usr/local/apache2 \
    $APACHE_RUNTIME_DIR/lock \
    $APACHE_RUNTIME_DIR/logs \
    $APACHE_RUNTIME_DIR/socks && \
    chown -R ${APP_USER}:${APP_GROUP} \
    /usr/local/apache2 \
    $APACHE_RUNTIME_DIR/lock \
    $APACHE_RUNTIME_DIR/logs \
    $APACHE_RUNTIME_DIR/socks

RUN mkdir -p /etc/apache2 && \
    chown -R ${APP_USER}:${APP_GROUP} /etc/apache2

# Copy Apache configuration files
COPY services/apache/conf /usr/local/apache2/conf/

COPY services/apache/envvars /etc/apache2/envvars

# Copy mkcert root CA into container
COPY services/apache/certs/rootCA.pem /usr/local/share/ca-certificates/mkcert-root.crt

# Register it with the system trust store
RUN update-ca-certificates

# Switch to the non-root user.
# USER ${APP_USER}:${APP_GROUP}

# Expose the HTTP and HTTPS ports
EXPOSE ${WEB_HTTP_PORT} ${WEB_HTTPS_PORT}

# Set the default entrypoint and command.
ENTRYPOINT ["/entrypoint.sh"]
CMD []
