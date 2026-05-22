#!/usr/bin/env bash
# Create android/key.properties + upload keystore for Play-ready release builds.
#
# Skip when the self-hosted runner already has signing files (local release machine):
#   ANDROID_USE_RUNNER_KEYSTORE=true
#
# Required secrets when importing:
#   ANDROID_KEYSTORE_BASE64
#   ANDROID_KEYSTORE_PASSWORD
#   ANDROID_KEY_ALIAS
#   ANDROID_KEY_PASSWORD
set -euo pipefail

KEYSTORE_NAME="ci-release-keystore.jks"
KEYSTORE_PATH="android/${KEYSTORE_NAME}"
PROPS_PATH="android/key.properties"

if [ "${ANDROID_USE_RUNNER_KEYSTORE:-false}" = "true" ]; then
  if [ ! -f "${PROPS_PATH}" ]; then
    echo "ANDROID_USE_RUNNER_KEYSTORE=true but ${PROPS_PATH} is missing." >&2
    exit 1
  fi
  echo "Using existing ${PROPS_PATH} on self-hosted runner."
  exit 0
fi

for var in ANDROID_KEYSTORE_BASE64 ANDROID_KEYSTORE_PASSWORD ANDROID_KEY_ALIAS ANDROID_KEY_PASSWORD; do
  if [ -z "${!var:-}" ]; then
    echo "Missing ${var}. Set ANDROID_USE_RUNNER_KEYSTORE=true or provide keystore secrets." >&2
    exit 1
  fi
done

echo "${ANDROID_KEYSTORE_BASE64}" | base64 --decode >"${KEYSTORE_PATH}"
chmod 600 "${KEYSTORE_PATH}"

cat >"${PROPS_PATH}" <<EOF
storePassword=${ANDROID_KEYSTORE_PASSWORD}
keyPassword=${ANDROID_KEY_PASSWORD}
keyAlias=${ANDROID_KEY_ALIAS}
storeFile=${KEYSTORE_NAME}
EOF
chmod 600 "${PROPS_PATH}"

echo "Created ${PROPS_PATH} for CI signing (keystore: ${KEYSTORE_PATH})."
