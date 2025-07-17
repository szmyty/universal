#!/usr/bin/env bash
# install-docker-desktop.sh
# Cross-platform Docker Desktop installer: macOS (Intel/ARM) & Windows (via WSL)

set -euo pipefail

log() {
  printf "🌀 %s\n" "$@"
}

detect_os() {
  local os
  os="$(uname -s)"
  case "${os}" in
    Darwin) echo "macos" ;;
    Linux)
      if grep -qi microsoft /proc/version; then
        echo "wsl"
      else
        echo "linux"
      fi
      ;;
    *) echo "unsupported" ;;
  esac
}

detect_arch() {
  local arch
  arch="$(uname -m)"
  case "${arch}" in
    x86_64) echo "x86_64" ;;
    arm64 | aarch64) echo "arm64" ;;
    *) echo "unsupported" ;;
  esac
}

install_docker_macos() {
  local arch="$1"
  local dmg_url
  local tmp_dir
  local dmg_file
  local mount_point="/Volumes/Docker"

  if [[ "${arch}" == "arm64" ]]; then
    dmg_url="https://desktop.docker.com/mac/main/arm64/Docker.dmg"
  else
    dmg_url="https://desktop.docker.com/mac/main/amd64/Docker.dmg"
  fi

  tmp_dir="$(mktemp -d)"
  dmg_file="${tmp_dir}/Docker.dmg"

  log "Downloading Docker Desktop for macOS [${arch}]..."
  curl -L "${dmg_url}" -o "${dmg_file}"

  log "Mounting DMG..."
  hdiutil attach "${dmg_file}" -mountpoint "${mount_point}" -nobrowse -quiet

  log "Copying Docker.app to /Applications..."
  cp -R "${mount_point}/Docker.app" /Applications

  log "Ejecting disk image..."
  hdiutil detach "${mount_point}" -quiet

  log "Cleaning up..."
  rm -rf "${tmp_dir}"

  log "✅ Docker Desktop installed. You can launch it with:"
  echo "   open -a Docker"
}

install_docker_windows_wsl() {
  local docker_installer_url="https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe"
  local docker_installer
  docker_installer="/mnt/c/Users/$(whoami)/Downloads/DockerInstaller.exe"

  log "Downloading Docker Desktop for Windows to ${docker_installer} ..."
  curl --location --output "${docker_installer}" "${docker_installer_url}"

  log "Launching Windows installer via PowerShell..."
  powershell.exe -Command "Start-Process -FilePath '${docker_installer}' -Verb RunAs"

  log "🟡 Please follow the GUI installer prompts manually."
  log "🔁 After installation, restart Docker Desktop from Windows and ensure WSL integration is enabled."
}

main() {
  local os arch
  os=$(detect_os)
  arch=$(detect_arch)

  log "Detected OS: ${os}"
  log "Detected Arch: ${arch}"

  if [[ "${os}" == "macos" ]]; then
    install_docker_macos "${arch}"
  elif [[ "${os}" == "wsl" ]]; then
    install_docker_windows_wsl
  else
    echo "❌ Unsupported OS: ${os}"
    exit 1
  fi
}

main "$@"
