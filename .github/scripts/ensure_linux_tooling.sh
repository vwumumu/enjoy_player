#!/usr/bin/env bash
# Install Linux build packages only when missing (self-hosted runners).
set -euo pipefail

packages=(
  clang
  cmake
  curl
  git
  ninja-build
  pkg-config
  unzip
  xz-utils
  zip
  libgtk-3-dev
  liblzma-dev
  libsqlite3-dev
)

missing=()
for pkg in "${packages[@]}"; do
  if ! dpkg-query -W -f='${Status}' "${pkg}" 2>/dev/null | grep -q 'install ok installed'; then
    missing+=("${pkg}")
  fi
done

if [ "${#missing[@]}" -eq 0 ]; then
  echo "Linux build packages already installed."
  exit 0
fi

echo "Installing missing packages: ${missing[*]}"
sudo apt-get update -y
sudo apt-get install -y "${missing[@]}"
