#!/usr/bin/env bash
# Import Apple distribution certs from GitHub secrets into a temporary keychain.
#
# Skip when the self-hosted runner already has valid certs (recommended for your Mac):
#   APPLE_USE_RUNNER_KEYCHAIN=true
#
# Required secrets when importing:
#   KEYCHAIN_PASSWORD
#   IOS_DISTRIBUTION_CERT_BASE64 + IOS_DISTRIBUTION_CERT_PASSWORD
#   MACOS_DEVELOPER_ID_CERT_BASE64 + MACOS_DEVELOPER_ID_CERT_PASSWORD
set -euo pipefail

if [ "${APPLE_USE_RUNNER_KEYCHAIN:-true}" = "true" ]; then
  echo "Using existing login keychain on self-hosted runner."
  security find-identity -v -p codesigning | head -10 || true
  exit 0
fi

for var in KEYCHAIN_PASSWORD IOS_DISTRIBUTION_CERT_BASE64 IOS_DISTRIBUTION_CERT_PASSWORD \
  MACOS_DEVELOPER_ID_CERT_BASE64 MACOS_DEVELOPER_ID_CERT_PASSWORD; do
  if [ -z "${!var:-}" ]; then
    echo "Missing ${var}. Set APPLE_USE_RUNNER_KEYCHAIN=true or provide cert secrets." >&2
    exit 1
  fi
done

KEYCHAIN_PATH="${RUNNER_TEMP:-/tmp}/enjoy-release.keychain-db"
KEYCHAIN_PASSWORD="${KEYCHAIN_PASSWORD}"

security create-keychain -p "${KEYCHAIN_PASSWORD}" "${KEYCHAIN_PATH}"
security set-keychain-settings -lut 21600 "${KEYCHAIN_PATH}"
security unlock-keychain -p "${KEYCHAIN_PASSWORD}" "${KEYCHAIN_PATH}"

import_p12() {
  local name="$1"
  local b64="$2"
  local password="$3"
  local p12_path="${RUNNER_TEMP:-/tmp}/${name}.p12"

  echo "${b64}" | base64 --decode >"${p12_path}"
  security import "${p12_path}" -k "${KEYCHAIN_PATH}" -P "${password}" \
    -T /usr/bin/codesign -T /usr/bin/security -T /usr/bin/xcrun
  rm -f "${p12_path}"
}

import_p12 "ios_distribution" "${IOS_DISTRIBUTION_CERT_BASE64}" "${IOS_DISTRIBUTION_CERT_PASSWORD}"
import_p12 "macos_developer_id" "${MACOS_DEVELOPER_ID_CERT_BASE64}" "${MACOS_DEVELOPER_ID_CERT_PASSWORD}"

security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "${KEYCHAIN_PASSWORD}" "${KEYCHAIN_PATH}"
security list-keychains -d user -s "${KEYCHAIN_PATH}" login.keychain-db
security default-keychain -s "${KEYCHAIN_PATH}"

echo "Imported signing certificates:"
security find-identity -v -p codesigning "${KEYCHAIN_PATH}"
