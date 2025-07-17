# syntax=docker/dockerfile:1.4
# cspell:ignore rmid lmodern rdepends
######################################################################
# Development container image
#
# This Dockerfile builds the image used by the VS Code devcontainer.
# It extends the official devcontainers base image and installs a
# collection of common build tools, language runtimes and utilities.
#
# The image is pinned to a specific digest so that builds are
# reproducible. Feel free to add or remove packages to suit your
# project's needs.
######################################################################
FROM mcr.microsoft.com/devcontainers/base@sha256:daa08ddb48ad4e4e7367c348e0a6f250762f1f0d8348f1f9acbef5f884ce093d AS base

# Override the default temporary directory if needed. Useful when
# working on filesystems where /tmp has limited space.
ARG TMPDIR=/tmp

# Locale and timezone settings used during build and at runtime
ARG LANG=en_US.UTF-8
ARG LANGUAGE=en_US:en
ARG TZ=UTC
ARG LC_ALL=en_US.UTF-8

# Optional TeX Live installation
ARG INSTALL_TEXLIVE=false

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
    INSTALL_TEXLIVE=${INSTALL_TEXLIVE}

# Location where additional development utilities are installed
ENV DEVTOOLS_HOME=/opt/devtools
ENV DEVTOOLS_BIN="${DEVTOOLS_HOME}/bin"
ENV DEVTOOLS_TOOLBOX="${DEVTOOLS_HOME}/toolbox"
ENV DEVTOOLS_CACHE="${DEVTOOLS_HOME}/cache"
ENV DEVTOOLS_LOGS="${DEVTOOLS_HOME}/logs"
ENV DEVTOOLS_CONFIG="${DEVTOOLS_HOME}/config"
ENV DEVTOOLS_LIB="${DEVTOOLS_HOME}/lib"
ENV DEVTOOLS_LOCKS="${DEVTOOLS_HOME}/locks"
ENV DEVTOOLS_FONTS="${DEVTOOLS_HOME}/fonts"
ENV DEVTOOLS_RUNTIME="${DEVTOOLS_HOME}/runtime"

# Configure the ASDF version manager.
ENV ASDF_DIR="${DEVTOOLS_HOME}/.asdf"
ENV ASDF_DATA_DIR="${ASDF_DIR}/data"
ENV ASDF_SHIMS_DIR="${ASDF_DATA_DIR}/shims"

# Taskfile installation directory
ENV TASKFILE_HOME_DIR="${DEVTOOLS_HOME}/.task"

# Prepend devtool locations to the PATH for easy access
ENV PATH="${DEVTOOLS_BIN}:${DEVTOOLS_BIN}/install:${DEVTOOLS_BIN}/tests:${DEVTOOLS_TOOLBOX}:${TASKFILE_HOME_DIR}:${ASDF_DIR}/bin:${ASDF_SHIMS_DIR}:${PATH}"

# XDG Base Directories: https://wiki.archlinux.org/title/XDG_Base_Directory
ENV XDG_CONFIG_HOME=${DEVTOOLS_CONFIG} \
    XDG_CACHE_HOME=${DEVTOOLS_CACHE} \
    XDG_DATA_HOME=${DEVTOOLS_TOOLBOX} \
    XDG_STATE_HOME=${DEVTOOLS_RUNTIME}

# Set working directory
WORKDIR /workspace

# Copy custom shell scripts and binaries
COPY --chown=vscode:vscode shell/bin/ ${DEVTOOLS_BIN}/
RUN chmod +x ${DEVTOOLS_BIN}/*

# COPY custom shell library
COPY --chown=vscode:vscode shell/lib/ ${DEVTOOLS_LIB}/
RUN find ${DEVTOOLS_LIB} -type f -name "*.sh" -exec chmod +x {} \;

# Copy configuration files for apt and dpkg
COPY shell/etc/dpkg/dpkg.cfg.d/*.conf /etc/dpkg/dpkg.cfg.d/
COPY shell/etc/apt/apt.conf.d/*.conf /etc/apt/apt.conf.d/

COPY --chown=vscode:vscode shell/locks/ ${DEVTOOLS_LOCKS}/

RUN install-apt-base --from-lock

FROM base AS fonts

# Optional Google Fonts installation
ARG INSTALL_GOOGLE_FONTS=false
ARG GOOGLE_FONTS_SHA_COMMIT=2b5bd4077bd9269cdf3114266603372af6c3222d
ARG GOOGLE_FONTS_SHA256=e413e29c18fa727ff4d509280fd432fc0ecb1f6117eb29f2c0a87918d30fe3ad

ENV INSTALL_GOOGLE_FONTS=${INSTALL_GOOGLE_FONTS} \
    GOOGLE_FONTS_SHA_COMMIT=${GOOGLE_FONTS_SHA_COMMIT} \
    GOOGLE_FONTS_SHA256=${GOOGLE_FONTS_SHA256}

FROM base AS imagemagick

# Optional ImageMagick installation
ARG INSTALL_IMAGEMAGICK=false
ARG IMAGEMAGICK_VERSION=7.1.1-47
ARG IMAGEMAGICK_SHA256=53ea43035cf0a1573bebd215932ea6ffeaa7ca1703f4e57d1e849b5bc0bed859
ARG IMAGEMAGICK_MD5=895118664de9d97a10c2d86e222c60c5

ENV INSTALL_IMAGEMAGICK=${INSTALL_IMAGEMAGICK} \
    IMAGEMAGICK_VERSION=${IMAGEMAGICK_VERSION} \
    IMAGEMAGICK_SHA256=${IMAGEMAGICK_SHA256} \
    IMAGEMAGICK_MD5=${IMAGEMAGICK_MD5} \
    IMAGEMAGICK_PREFIX=${DEVTOOLS_TOOLBOX}/imagemagick

ENV PATH="${IMAGEMAGICK_PREFIX}/bin:${PATH}" \
    PKG_CONFIG_PATH="${IMAGEMAGICK_PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH}" \
    LD_LIBRARY_PATH="${IMAGEMAGICK_PREFIX}/lib:${LD_LIBRARY_PATH}"

RUN if [ "${INSTALL_IMAGEMAGICK}" = "true" ]; then install-imagemagick; fi














# RUN --mount=type=cache,target=/var/cache/fonts,sharing=locked,id=google-fonts \
#     if [ "${INSTALL_GOOGLE_FONTS}" = "true" ]; then \
#     chmod +x /workspace/scripts/install-google-fonts.sh && \
#     bash /workspace/scripts/install-google-fonts.sh "/usr/local/share/fonts/google" && \
#     fc-cache -f -v; \
#     else \
#     echo "📁 Skipping Google Fonts install"; \
#     fi

FROM base AS final

# Copy over compiled ImageMagick (and other devtools) from build stage
COPY --from=imagemagick --chown=vscode:vscode ${DEVTOOLS_HOME} ${DEVTOOLS_HOME}

ENV PATH="${IMAGEMAGICK_PREFIX}/bin:${PATH}" \
    PKG_CONFIG_PATH="${IMAGEMAGICK_PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH}" \
    LD_LIBRARY_PATH="${IMAGEMAGICK_PREFIX}/lib:${LD_LIBRARY_PATH}"



# COPY --from=fonts /opt/devtools/fonts /opt/devtools/fonts
# RUN fc-cache -f


# Disable the automatic removal of downloaded packages
# RUN rm -f /etc/apt/apt.conf.d/docker-clean

# Fix for update-alternatives: error:
# 'error creating symbolic link '/usr/share/man/man1/rmid.1.gz.dpkg-tmp': No such file or directory'
# See https://github.com/debuerreotype/docker-debian-artifacts/issues/24#issuecomment-360870939
# RUN mkdir --parents /usr/share/man/man1

# RUN apt-config dump > /workspace/_apt-config.dump
# RUN grep -r . /etc/dpkg/dpkg.cfg.d/ > /workspace/_dpkg-config.dump

# Install build tools and common utilities. The package list is
# intentionally explicit so that version locks in apt-packages.lock
# reflect exactly what was installed.
# RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=apt-cache --mount=type=cache,target=/var/lib/apt,sharing=locked,id=apt-lib --mount=type=cache,target=/var/lib/apt,sharing=locked,id=apt-lib apt-get update -qq \
#     && apt-get install --yes --no-install-recommends \
#     RUN apt-get update && apt-get install -y \


# # Optional TeX Live installation
# RUN if [ "${INSTALL_TEXLIVE}" = "true" ]; then \
#     apt-get install --yes --no-install-recommends texlive-full=2023.20240207-1; \
#     else \
#     echo "📁 Skipping texlive-full install"; \
#     fi

# Set texlive directories.
# export TEXLIVE_INSTALL_PREFIX="$USER_SYS_APPS/texlive"
# export TEXMFHOME="$TEXLIVE_INSTALL_PREFIX/texmf"
# export TEXMFVAR="$TEXLIVE_INSTALL_PREFIX/.texlive/texmf-var"
# export TEXMFCONFIG="$TEXLIVE_INSTALL_PREFIX/.texlive/texmf-config"



# # Configure the system locale and timezone
# RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment \
#     && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
#     && echo "LANG=en_US.UTF-8" > /etc/locale.conf \
#     && locale-gen en_US.UTF-8 \
#     && update-locale LANG=en_US.UTF-8 \
#     && dpkg-reconfigure locales

# # Record the installed versions of apt packages for reference
# RUN dpkg-query -W -f='${Package}=${Version}\n' > apt-packages.lock

# # Install Perl modules needed for Perl Language Server
# RUN cpanm AnyEvent::AIO@1.1 IO::AIO@4.81 Perl::LanguageServer@2.6.2

# # Ensure SYS_UID_MAX and SYS_GID_MAX are set to high values, uncommented or inserted
# RUN sed -i '/^#\?SYS_UID_MAX/ d' /etc/login.defs && echo 'SYS_UID_MAX 99999' >>/etc/login.defs \
#     && sed -i '/^#\?SYS_GID_MAX/ d' /etc/login.defs && echo 'SYS_GID_MAX 99999' >>/etc/login.defs

# # Copy install-google-fonts script
# COPY scripts/install-google-fonts.sh /workspace/scripts/install-google-fonts.sh



# # Record installed font families for reference
# RUN fc-list : family | sort -u > fonts.lock


# # Create the directory in advance so ownership can be adjusted later
# RUN mkdir -p "${DEVTOOLS_HOME}"




# # Helper script that installs asdf plugins and other tooling
# COPY scripts/devtools.sh /workspace/scripts/devtools.sh

# # Copy .tool-versions file
# COPY .tool-versions /workspace/.tool-versions

# # Run the helper script and change ownership so the vscode user can
# # manage the installed tools.
# RUN chmod +x /workspace/scripts/devtools.sh && \
#     bash /workspace/scripts/devtools.sh && \
#     rm -rf /workspace/scripts && \
#     chown --recursive vscode:vscode "${DEVTOOLS_HOME}"

# # Copy and source custom shell aliases
# COPY shell/aliases.sh /etc/profile.d/docker_aliases.sh

# # Ensure correct permissions and sourcing
# RUN chmod 644 /etc/profile.d/docker_aliases.sh && \
#     echo '[ -d /etc/profile.d ] && for f in /etc/profile.d/*.sh; do [ -r "$f" ] && . "$f"; done' \
#     >> /etc/bash.bashrc
