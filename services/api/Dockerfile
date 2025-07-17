# syntax=docker/dockerfile:1.4

#############################
# Builder stage with devtools
#############################
FROM ubuntu:24.04 AS builder

USER root

ARG TMPDIR=/tmp
ARG LANG=en_US.UTF-8
ARG LANGUAGE=en_US:en
ARG TZ=UTC
ARG LC_ALL=en_US.UTF-8

ARG APP_USER=universal
ARG APP_GROUP=universal

ENV APP_USER=${APP_USER}
ENV APP_GROUP=${APP_GROUP}
ENV APP_UID=65532
ENV APP_GID=65532
ENV APP_USER_HOME=/${APP_USER}
ENV APP_HOME=/${APP_USER}/api

ENV DEBIAN_FRONTEND=noninteractive \
    TERM=xterm-256color \
    LANG=${LANG} \
    LANGUAGE=${LANGUAGE} \
    TZ=${TZ} \
    LC_ALL=${LC_ALL} \
    TMPDIR=${TMPDIR} \
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
    ASDF_SHIMS_DIR=/opt/devtools/.asdf/data/shims

ENV PATH="${TASKFILE_HOME_DIR}:${ASDF_DIR}/bin:${ASDF_SHIMS_DIR}:${PATH}"
ENV PYTHONPATH="${PYTHONPATH}:${APP_HOME}"

RUN rm -f /etc/apt/apt.conf.d/docker-clean
RUN mkdir -p /usr/share/man/man1

COPY config/dpkg/*.conf /etc/dpkg/dpkg.cfg.d/
COPY config/apt/*.conf /etc/apt/apt.conf.d/

RUN groupadd --gid ${APP_GID} --force ${APP_GROUP} && \
    useradd --no-log-init --create-home --uid ${APP_UID} \
    --gid ${APP_GID} --comment "Non-root User for Running Applications" \
    --home-dir ${APP_USER_HOME} --shell /usr/sbin/nologin ${APP_USER} && \
    mkdir -p ${APP_USER_HOME} ${APP_HOME} && \
    chown -R ${APP_USER}:${APP_GROUP} ${APP_USER_HOME} ${APP_HOME} && \
    chmod -R 700 ${APP_USER_HOME} ${APP_HOME}

RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
    apt-get update && \
    apt-get install --yes --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    jq \
    locales \
    libbz2-dev \
    libffi-dev \
    libjpeg-dev \
    liblzma-dev \
    libncurses-dev \
    libpq-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    python3-dev \
    python3-pip \
    python3-venv \
    unzip \
    uuid-dev \
    wget \
    zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    echo "LANG=en_US.UTF-8" > /etc/locale.conf && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8 && \
    dpkg-reconfigure locales

WORKDIR ${APP_HOME}

COPY scripts/devtools.sh /tmp/devtools.sh
COPY services/api/.tool-versions .tool-versions
RUN chmod +x /tmp/devtools.sh && \
    bash /tmp/devtools.sh && \
    rm /tmp/devtools.sh

COPY services/api ./
RUN task install

#############################
# Final stage
#############################
FROM ubuntu:24.04 AS base

USER root

ARG TMPDIR=/tmp
ARG LANG=en_US.UTF-8
ARG LANGUAGE=en_US:en
ARG TZ=UTC
ARG LC_ALL=en_US.UTF-8

ARG APP_USER=universal
ARG APP_GROUP=universal
ARG API_PORT=8000
ARG API_PREFIX=/api

ENV APP_USER=${APP_USER}
ENV APP_GROUP=${APP_GROUP}
ENV APP_UID=65532
ENV APP_GID=65532
ENV APP_USER_HOME=/${APP_USER}
ENV APP_HOME=/${APP_USER}/api

ENV DEBIAN_FRONTEND=noninteractive \
    TERM=xterm-256color \
    LANG=${LANG} \
    LANGUAGE=${LANGUAGE} \
    TZ=${TZ} \
    LC_ALL=${LC_ALL} \
    TMPDIR=${TMPDIR} \
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
    API_PORT=${API_PORT} \
    API_PREFIX=${API_PREFIX}

ENV PATH="${TASKFILE_HOME_DIR}:${ASDF_DIR}/bin:${ASDF_SHIMS_DIR}:${PATH}"
ENV PYTHONPATH="${PYTHONPATH}:${APP_HOME}"

RUN rm -f /etc/apt/apt.conf.d/docker-clean
RUN mkdir -p /usr/share/man/man1

COPY config/dpkg/*.conf /etc/dpkg/dpkg.cfg.d/
COPY config/apt/*.conf /etc/apt/apt.conf.d/

RUN groupadd --gid ${APP_GID} --force ${APP_GROUP} && \
    useradd --no-log-init --create-home --uid ${APP_UID} \
    --gid ${APP_GID} --comment "Non-root User for Running Applications" \
    --home-dir ${APP_USER_HOME} --shell /usr/sbin/nologin ${APP_USER} && \
    mkdir -p ${APP_USER_HOME} ${APP_HOME} && \
    chown -R ${APP_USER}:${APP_GROUP} ${APP_USER_HOME} ${APP_HOME} && \
    chmod -R 700 ${APP_USER_HOME} ${APP_HOME}

RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
    apt-get update && \
    apt-get install --yes --no-install-recommends \
    ca-certificates \
    curl \
    git \
    python3 \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    echo "LANG=en_US.UTF-8" > /etc/locale.conf && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8 && \
    dpkg-reconfigure locales

WORKDIR ${APP_HOME}

COPY --from=builder ${APP_HOME} ${APP_HOME}
COPY --from=builder ${APP_USER_HOME}/.tool-versions ${APP_USER_HOME}/.tool-versions
COPY --from=builder ${APP_HOME}/.venv ${APP_HOME}/.venv

COPY services/api/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY shell/aliases.sh /etc/profile.d/docker_aliases.sh
RUN chmod 644 /etc/profile.d/docker_aliases.sh && \
    echo '[ -d /etc/profile.d ] && for f in /etc/profile.d/*.sh; do [ -r "$f" ] && . "$f"; done' \
    >> /etc/bash.bashrc

RUN chown -R ${APP_USER}:${APP_GROUP} ${APP_HOME}
USER ${APP_USER}:${APP_GROUP}

EXPOSE ${API_PORT}
ENTRYPOINT ["/entrypoint.sh"]
CMD []
