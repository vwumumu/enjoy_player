#!/bin/sh
# Bundles Homebrew dylibs required by ffmpeg_kit_flutter_new prebuilt macOS frameworks.
# Those binaries were linked against /opt/homebrew/opt/* at build time; without this
# step (or the same libs installed on the machine), dyld fails at launch.
set -eu

APP_BUNDLE="${1:-}"
if [ -z "${APP_BUNDLE}" ] || [ ! -d "${APP_BUNDLE}" ]; then
  echo "usage: $0 <path/to/Enjoy Player.app>" >&2
  exit 1
fi

FRAMEWORKS_DIR="${APP_BUNDLE}/Contents/Frameworks"
if [ ! -d "${FRAMEWORKS_DIR}" ]; then
  echo "bundle_ffmpeg_homebrew_deps: missing Frameworks dir in ${APP_BUNDLE}" >&2
  exit 1
fi

is_macho() {
  file "$1" 2>/dev/null | grep -q 'Mach-O'
}

homebrew_deps_for() {
  otool -L "$1" 2>/dev/null | awk '/\/opt\/homebrew\// { print $1 }'
}

references_homebrew() {
  homebrew_deps_for "$1" | grep -q .
}

MACHO_LIST="$(mktemp)"
DEPS="$(mktemp)"
BUNDLED="$(mktemp)"
: >"${MACHO_LIST}"
: >"${DEPS}"
: >"${BUNDLED}"

find "${APP_BUNDLE}/Contents" -type f 2>/dev/null | while read -r f; do
  if is_macho "$f" && references_homebrew "$f"; then
    echo "$f"
  fi
done >"${MACHO_LIST}"

while read -r bin; do
  [ -n "${bin}" ] || continue
  homebrew_deps_for "${bin}" >>"${DEPS}" || true
done <"${MACHO_LIST}"

sort -u "${DEPS}" -o "${DEPS}"

bundle_one() {
  src="$1"
  base="$(basename "${src}")"
  dest="${FRAMEWORKS_DIR}/${base}"

  if [ ! -f "${src}" ]; then
    formula="$(echo "${src}" | sed -n 's#/opt/homebrew/opt/\([^/]*\)/.*#\1#p')"
    echo "bundle_ffmpeg_homebrew_deps: missing ${src}" >&2
    if [ -n "${formula}" ]; then
      echo "Install Homebrew deps: brew bundle install --file=macos/Brewfile" >&2
      echo "  (or: brew install ${formula})" >&2
    fi
    exit 1
  fi

  if grep -Fxq "${src}" "${BUNDLED}" 2>/dev/null; then
    return 0
  fi

  if [ ! -f "${dest}" ]; then
    cp -f "${src}" "${dest}"
    chmod 755 "${dest}"
    install_name_tool -id "@rpath/${base}" "${dest}" >/dev/null 2>&1 || true
  fi
  echo "${src}" >>"${BUNDLED}"
  homebrew_deps_for "${dest}" >>"${DEPS}" || true
}

while :; do
  ADDED=0
  PENDING="$(mktemp)"
  cp "${DEPS}" "${PENDING}"
  while read -r dep; do
    [ -n "${dep}" ] || continue
    if grep -Fxq "${dep}" "${BUNDLED}" 2>/dev/null; then
      continue
    fi
    ADDED=1
    bundle_one "${dep}"
  done <"${PENDING}"
  rm -f "${PENDING}"
  sort -u "${DEPS}" -o "${DEPS}"
  if [ "${ADDED}" -eq 0 ]; then
    break
  fi
done

BUNDLED_COUNT="$(wc -l <"${BUNDLED}" | tr -d ' ')"
if [ "${BUNDLED_COUNT}" -eq 0 ]; then
  rm -f "${MACHO_LIST}" "${DEPS}" "${BUNDLED}"
  exit 0
fi

while read -r bin; do
  [ -n "${bin}" ] || continue
  while read -r src; do
    [ -n "${src}" ] || continue
    base="$(basename "${src}")"
    install_name_tool -change "${src}" "@rpath/${base}" "${bin}" 2>/dev/null || true
  done <"${BUNDLED}"
done <"${MACHO_LIST}"

echo "bundle_ffmpeg_homebrew_deps: bundled ${BUNDLED_COUNT} Homebrew dylib(s) into ${FRAMEWORKS_DIR}"
rm -f "${MACHO_LIST}" "${DEPS}" "${BUNDLED}"
