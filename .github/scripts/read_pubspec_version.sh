#!/usr/bin/env bash
# Print semver (default) or build number (--build) from pubspec.yaml.
set -euo pipefail

root="$(cd "$(dirname "$0")/../.." && pwd)"
version_line="$(grep -m1 '^version:' "${root}/pubspec.yaml")"
if [[ -z "${version_line}" ]]; then
  echo "Could not parse version from pubspec.yaml" >&2
  exit 1
fi

value="$(echo "${version_line#version:}" | tr -d ' ')"

case "${1:-}" in
  --build)
    if [[ "${value}" == *+* ]]; then
      echo "${value#*+}"
    else
      echo "0"
    fi
    ;;
  *)
    echo "${value%%+*}"
    ;;
esac
