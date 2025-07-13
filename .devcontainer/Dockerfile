# syntax=docker/dockerfile:1.4

######################################################################
# Development container image
#
# This Dockerfile builds the image used by the VS Code devcontainer.
# It extends the official devcontainers base image and installs a
# collection of common build tools, language runtimes and utilities.
#
# The image is pinned to a specific digest so that builds are
# reproducible.  Feel free to add or remove packages to suit your
# project's needs.
######################################################################
FROM mcr.microsoft.com/devcontainers/base@sha256:daa08ddb48ad4e4e7367c348e0a6f250762f1f0d8348f1f9acbef5f884ce093d

# Override the default temporary directory if needed. Useful when
# working on filesystems where /tmp has limited space.
ARG TMPDIR=/tmp

# Locale and timezone settings used during build and at runtime
ARG LANG=en_US.UTF-8
ARG LANGUAGE=en_US:en
ARG TZ=UTC
ARG LC_ALL=en_US.UTF-8

# Optional Google Fonts installation
ARG INSTALL_GOOGLE_FONTS=true
ARG INSTALL_TEXLIVE=false
ARG GOOGLE_FONTS_SHA_COMMIT=2b5bd4077bd9269cdf3114266603372af6c3222d
ARG GOOGLE_FONTS_SHA256=e413e29c18fa727ff4d509280fd432fc0ecb1f6117eb29f2c0a87918d30fe3ad

# Core environment variables for non-interactive apt operations and consistent Python behavior.
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
    GOOGLE_FONTS_SHA_COMMIT=${GOOGLE_FONTS_SHA_COMMIT} \
    GOOGLE_FONTS_SHA256=${GOOGLE_FONTS_SHA256} \
    INSTALL_GOOGLE_FONTS=${INSTALL_GOOGLE_FONTS} \
    INSTALL_TEXLIVE=${INSTALL_TEXLIVE}

# Set working directory
WORKDIR /workspace

# Disable the automatic removal of downloaded packages
RUN rm -f /etc/apt/apt.conf.d/docker-clean

# Fix for update-alternatives: error:
# 'error creating symbolic link '/usr/share/man/man1/rmid.1.gz.dpkg-tmp': No such file or directory'
# See https://github.com/debuerreotype/docker-debian-artifacts/issues/24#issuecomment-360870939
RUN mkdir --parents /usr/share/man/man1

# Copy configuration files for apt and dpkg
COPY config/dpkg/*.conf /etc/dpkg/dpkg.cfg.d/
COPY config/apt/*.conf /etc/apt/apt.conf.d/

# RUN apt-config dump > /workspace/_apt-config.dump
# RUN grep -r . /etc/dpkg/dpkg.cfg.d/ > /workspace/_dpkg-config.dump

# Install build tools and common utilities. The package list is
# intentionally explicit so that version locks in apt-packages.lock
# reflect exactly what was installed.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=apt-cache --mount=type=cache,target=/var/lib/apt,sharing=locked,id=apt-lib --mount=type=cache,target=/var/lib/apt,sharing=locked,id=apt-lib apt-get update -qq \
    && apt-get install --yes --no-install-recommends \
    RUN apt-get update && apt-get install -y \
    ansible \
    apt-rdepends \
    bat \
    build-essential \
    ca-certificates \
    ccache \
    chktex \
    clang \
    clang-format \
    clang-tidy \
    cmake \
    cpanminus \
    curl \
    debtree \
    dnsutils \
    dos2unix \
    ffmpeg \
    fonts-lmodern \
    fonts-noto \
    fonts-noto-cjk \
    fonts-noto-color-emoji \
    fzf \
    gdal-bin \
    gettext \
    ghostscript \
    git \
    gnupg \
    graphviz \
    htop \
    inkscape \
    iputils-ping \
    jq \
    less \
    libblosc-dev \
    libboost-all-dev \
    libbz2-dev \
    libcurl4-openssl-dev \
    libdb-dev \
    libev-dev \
    libffi-dev \
    libgdal-dev \
    libgdbm-dev \
    libgeos-dev \
    liblcms2-dev \
    liblz4-dev \
    liblzma-dev \
    libncurses-dev \
    libnss3-dev \
    libperl-dev \
    libproj-dev \
    libreadline-dev \
    libspatialindex-dev \
    libsqlite3-dev \
    libssl-dev \
    libtool \
    libxi-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libxslt1-dev \
    libzstd-dev \
    llvm \
    locales \
    locales-all \
    logrotate \
    lsof \
    make \
    moreutils \
    nano \
    net-tools \
    netcat-openbsd \
    ninja-build \
    nmap \
    openssh-client \
    pandoc \
    pkg-config \
    potrace \
    proj-bin \
    pwgen \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
    ripgrep \
    strace \
    sudo \
    sysdig \
    sysstat \
    tar \
    tcpdump \
    tk-dev \
    tzdata \
    unzip \
    uuid-dev \
    vim \
    wget \
    xz-utils \
    zlib1g-dev \
    zsh

# Optional TeX Live installation
RUN if [ "${INSTALL_TEXLIVE}" = "true" ]; then \
    apt-get install --yes --no-install-recommends texlive-full=2023.20240207-1; \
    else \
    echo "📁 Skipping texlive-full install"; \
    fi

# Configure the system locale and timezone
RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && echo "LANG=en_US.UTF-8" > /etc/locale.conf \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8 \
    && dpkg-reconfigure locales

# Record the installed versions of apt packages for reference
RUN dpkg-query -W -f='${Package}=${Version}\n' > apt-packages.lock

# Install Perl modules needed for Perl Language Server
RUN cpanm AnyEvent::AIO@1.1 IO::AIO@4.81 Perl::LanguageServer@2.6.2

# Ensure SYS_UID_MAX and SYS_GID_MAX are set to high values, uncommented or inserted
RUN sed -i '/^#\?SYS_UID_MAX/ d' /etc/login.defs && echo 'SYS_UID_MAX 99999' >>/etc/login.defs \
    && sed -i '/^#\?SYS_GID_MAX/ d' /etc/login.defs && echo 'SYS_GID_MAX 99999' >>/etc/login.defs

# Copy install-google-fonts script
COPY scripts/install-google-fonts.sh /workspace/scripts/install-google-fonts.sh

RUN --mount=type=cache,target=/var/cache/fonts,sharing=locked,id=google-fonts \
    if [ "${INSTALL_GOOGLE_FONTS}" = "true" ]; then \
    chmod +x /workspace/scripts/install-google-fonts.sh && \
    bash /workspace/scripts/install-google-fonts.sh "/usr/local/share/fonts/google" && \
    fc-cache -f -v; \
    else \
    echo "📁 Skipping Google Fonts install"; \
    fi

# Record installed font families for reference
RUN fc-list : family | sort -u > fonts.lock

# Location where additional development utilities are installed
ENV DEVTOOLS_HOME=/opt/devtools

# Create the directory in advance so ownership can be adjusted later
RUN mkdir -p "${DEVTOOLS_HOME}"

ENV TASKFILE_HOME_DIR="${DEVTOOLS_HOME}/.task"

# Configure the ASDF version manager which provides language runtimes
# such as Node.js, Python, etc.
ENV ASDF_DIR="${DEVTOOLS_HOME}/.asdf"
ENV ASDF_DATA_DIR="${ASDF_DIR}/data"
ENV ASDF_SHIMS_DIR="${ASDF_DATA_DIR}/shims"

# Prepend devtool locations to the PATH for easy access
ENV PATH="${TASKFILE_HOME_DIR}:${ASDF_DIR}/bin:${ASDF_SHIMS_DIR}:${PATH}"

# Helper script that installs asdf plugins and other tooling
COPY scripts/devtools.sh /workspace/scripts/devtools.sh

# Copy .tool-versions file
COPY .tool-versions /workspace/.tool-versions

# Run the helper script and change ownership so the vscode user can
# manage the installed tools.
RUN chmod +x /workspace/scripts/devtools.sh && \
    bash /workspace/scripts/devtools.sh && \
    rm -rf /workspace/scripts && \
    chown --recursive vscode:vscode "${DEVTOOLS_HOME}"

# Copy and source custom shell aliases
COPY shell/aliases.sh /etc/profile.d/docker_aliases.sh

# Ensure correct permissions and sourcing
RUN chmod 644 /etc/profile.d/docker_aliases.sh && \
    echo '[ -d /etc/profile.d ] && for f in /etc/profile.d/*.sh; do [ -r "$f" ] && . "$f"; done' \
    >> /etc/bash.bashrc
