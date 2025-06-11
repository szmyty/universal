# syntax=docker/dockerfile:1.4

# Pinned base image for consistency
FROM mcr.microsoft.com/devcontainers/base@sha256:cdff177dd5755c0ba2afea60cdc0ab07d933c60d50c6c90dccbcc42b4b4ab76d

# Override the temporary directory if needed
ARG TMPDIR=/tmp

# Locale and timezone settings
ARG LANG=en_US.UTF-8
ARG LANGUAGE=en_US:en
ARG TZ=UTC
ARG LC_ALL=en_US.UTF-8

# Google Fonts
ARG INSTALL_GOOGLE_FONTS=true
ARG GOOGLE_FONTS_SHA=2b5bd4077bd9269cdf3114266603372af6c3222d

# Set environment variables
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
    PYTHONHASHSEED=random \
    PIP_NO_CACHE_DIR=1 \
    PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    GOOGLE_FONTS_SHA=${GOOGLE_FONTS_SHA} \
    INSTALL_GOOGLE_FONTS=${INSTALL_GOOGLE_FONTS}

# Disable the automatic removal of downloaded packages
RUN rm -f /etc/apt/apt.conf.d/docker-clean; \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

# Fix for update-alternatives: error:
# 'error creating symbolic link '/usr/share/man/man1/rmid.1.gz.dpkg-tmp': No such file or directory'
# See https://github.com/debuerreotype/docker-debian-artifacts/issues/24#issuecomment-360870939
RUN mkdir --parents /usr/share/man/man1

# Install system dependencies required for building Python + Python packages
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=apt-cache \
    --mount=type=cache,target=/var/lib/apt,sharing=locked,id=apt-lib \
    apt-get update -qq && \
    apt-get install --yes --no-install-recommends \
    build-essential=12.10ubuntu1 \
    ca-certificates=20240203 \
    ccache=4.9.1-1 \
    clang-format=1:18.0-59~exp2 \
    clang-tidy=1:18.0-59~exp2 \
    clang=1:18.0-59~exp2 \
    cmake=3.28.3-1build7 \
    cpanminus=1.7047-1 \
    curl=8.5.0-2ubuntu10.6 \
    debtree=1.1.2 \
    dnsutils=1:9.18.30-0ubuntu0.24.04.2 \
    dos2unix=7.5.1-1 \
    ffmpeg=7:6.1.1-3ubuntu5 \
    gettext=0.21-14ubuntu2 \
    ghostscript=10.02.1~dfsg1-0ubuntu7.6 \
    git=1:2.43.0-1ubuntu7.2 \
    gnupg=2.4.4-2ubuntu17.2 \
    graphviz=2.42.2-9ubuntu0.1 \
    htop=3.3.0-4build1 \
    iputils-ping=3:20240117-1build1 \
    jq=1.7.1-3build1 \
    less=590-2ubuntu2.1 \
    libblosc-dev=1.21.5+ds-1build1 \
    libboost-all-dev=1.83.0.1ubuntu2 \
    libbz2-dev=1.0.8-5.1build0.1 \
    libcurl4-openssl-dev=8.5.0-2ubuntu10.6 \
    libdb-dev=1:5.3.21ubuntu2 \
    libev-dev=1:4.33-2.1build1 \
    libffi-dev=3.4.6-1build1 \
    libgdbm-dev=1.23-5.1build1 \
    liblz4-dev=1.9.4-1build1.1 \
    liblzma-dev=5.6.1+really5.4.5-1ubuntu0.2 \
    libncurses-dev=6.4+20240113-1ubuntu2 \
    libnss3-dev=2:3.98-1build1 \
    libperl-dev=5.38.2-3.2ubuntu0.1 \
    libreadline-dev=8.2-4build1 \
    libsqlite3-dev=3.45.1-1ubuntu2.3 \
    libssl-dev=3.0.13-0ubuntu3.5 \
    libxi-dev=2:1.8.1-1build1 \
    libxml2-dev=2.9.14+dfsg-1.3ubuntu3.3 \
    libxmlsec1-dev=1.2.39-5build2 \
    libxslt1-dev=1.1.39-0exp1ubuntu0.24.04.2 \
    libzstd-dev=1.5.5+dfsg2-2build1.1 \
    llvm=1:18.0-59~exp2 \
    locales=2.39-0ubuntu8.4 \
    locales-all=2.39-0ubuntu8.4 \
    logrotate=3.21.0-2build1 \
    lsof=4.95.0-1build3 \
    make=4.3-4.1build2 \
    moreutils=0.69-1 \
    nano=7.2-2ubuntu0.1 \
    net-tools=2.10-0.1ubuntu4.4 \
    ninja-build=1.11.1-2 \
    openssh-client=1:9.6p1-3ubuntu13.12 \
    pandoc=3.1.3+ds-2 \
    pkg-config=1.8.1-2build1 \
    python3-dev=3.12.3-0ubuntu2 \
    python3-pip=24.0+dfsg-1ubuntu1.1 \
    python3-venv=3.12.3-0ubuntu2 \
    python3=3.12.3-0ubuntu2 \
    ripgrep=14.1.0-1 \
    strace=6.8-0ubuntu2 \
    sudo=1.9.15p5-3ubuntu5 \
    sysdig=0.36.0+repack-1 \
    sysstat=12.6.1-2 \
    tar=1.35+dfsg-3build1 \
    tcpdump=4.99.4-3ubuntu4 \
    tk-dev=8.6.14build1 \
    tzdata=2025b-0ubuntu0.24.04.1 \
    unzip=6.0-28ubuntu4.1 \
    uuid-dev=2.39.3-9ubuntu6.2 \
    vim=2:9.1.0016-1ubuntu7.8 \
    wget=1.21.4-1ubuntu4.1 \
    xz-utils=5.6.1+really5.4.5-1ubuntu0.2 \
    zlib1g-dev=1:1.3.dfsg-3.1ubuntu2.1 \
    zsh=5.9-6ubuntu2 \
    texlive-full \
    fonts-noto \
    fonts-noto-cjk \
    fonts-noto-color-emoji \
    fonts-lmodern \
    pwgen=2.08-2build2

RUN fc-cache -f

RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && echo "LANG=en_US.UTF-8" > /etc/locale.conf \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8 \
    && dpkg-reconfigure locales

RUN dpkg-query -W -f='${Package}=${Version}\n' > apt-packages.lock

RUN cpanm AnyEvent::AIO@1.1 IO::AIO@4.81 Perl::LanguageServer@2.6.2

# Ensure SYS_UID_MAX and SYS_GID_MAX are set to high values, uncommented or inserted
RUN sed -i '/^#\?SYS_UID_MAX/ d' /etc/login.defs && echo 'SYS_UID_MAX 99999' >> /etc/login.defs && \
    sed -i '/^#\?SYS_GID_MAX/ d' /etc/login.defs && echo 'SYS_GID_MAX 99999' >> /etc/login.defs

# Copy install-google-fonts script
COPY scripts/install-google-fonts.sh /workspace/scripts/install-google-fonts.sh

# Conditionally run the installer if the flag is true
RUN if [ "${INSTALL_GOOGLE_FONTS}" = "true" ]; then \
    chmod +x /workspace/scripts/install-google-fonts.sh && \
    bash /workspace/scripts/install-google-fonts.sh "${GOOGLE_FONTS_SHA}" && \
    rm -rf /workspace/scripts; \
    else \
    echo "📁 Skipping Google Fonts install"; \
    fi

RUN fc-list : family | sort -u > fonts.lock

# Set devtools directory
ENV DEVTOOLS_HOME=/opt/devtools

# Create devtools directory
RUN mkdir -p "${DEVTOOLS_HOME}"

ENV TASKFILE_HOME_DIR="${DEVTOOLS_HOME}/.task"

# Set up ASDF version manager
ENV ASDF_DIR="${DEVTOOLS_HOME}/.asdf"
ENV ASDF_DATA_DIR="${ASDF_DIR}/data"
ENV ASDF_SHIMS_DIR="${ASDF_DATA_DIR}/shims"

ENV PATH="${TASKFILE_HOME_DIR}:${ASDF_DIR}/bin:${ASDF_SHIMS_DIR}:${PATH}"

# Set working directory
WORKDIR /workspace

# Copy devtools scripts
COPY scripts/devtools.sh /workspace/scripts/devtools.sh

# Copy .tool-versions file
COPY .tool-versions /workspace/.tool-versions

# Install devtools
RUN chmod +x /workspace/scripts/devtools.sh && \
    bash /workspace/scripts/devtools.sh && \
    rm -rf /workspace/scripts && \
    chown --recursive vscode:vscode "${DEVTOOLS_HOME}"

# Copy Taskfile and project configuration files
COPY Taskfile.yml pyproject.toml poetry.toml package.json /workspace/

# Install project dependencies
RUN task \
    --dir /workspace \
    --taskfile /workspace/Taskfile.yml \
    --yes \
    setup
