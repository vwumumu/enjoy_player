#!/bin/sh
# Notarize a release-built macOS .app for direct distribution (Developer ID).
#
# Prerequisites (one-time on the release machine):
#   1. Developer ID Application certificate in Keychain (team 46X685R747).
#   2. App-specific password stored for notarytool, e.g.:
#        xcrun notarytool store-credentials "enjoy-notary" \
#          --apple-id "you@example.com" \
#          --team-id "46X685R747" \
#          --password "@keychain:AC_PASSWORD"
#
# Usage:
#   ./macos/scripts/notarize_release.sh build/macos/Build/Products/Release/Enjoy\ Player.app
#
set -eu

APP_BUNDLE="${1:-}"
if [ -z "${APP_BUNDLE}" ] || [ ! -d "${APP_BUNDLE}" ]; then
  echo "usage: $0 <path/to/Enjoy Player.app>" >&2
  exit 1
fi

NOTARY_PROFILE="${NOTARY_PROFILE:-enjoy-notary}"
SIGN_IDENTITY="${SIGN_IDENTITY:-Developer ID Application: An Li (46X685R747)}"
SCRIPT_DIR="$(CDPATH= cd "$(dirname "$0")" && pwd)"
MACOS_DIR="$(dirname "${SCRIPT_DIR}")"
ENTITLEMENTS="${MACOS_DIR}/Runner/Release.entitlements"
ZIP_PATH="$(mktemp -t enjoy-player-notarize).zip"

cleanup() {
  rm -f "${ZIP_PATH}"
}
trap cleanup EXIT

echo "==> Re-signing for direct distribution (${SIGN_IDENTITY})"
codesign --force --deep --sign "${SIGN_IDENTITY}" \
  --options runtime \
  --timestamp \
  --entitlements "${ENTITLEMENTS}" \
  "${APP_BUNDLE}"

echo "==> Verifying signature"
codesign --verify --deep --strict --verbose=2 "${APP_BUNDLE}"

echo "==> Creating notarization zip"
ditto -c -k --keepParent "${APP_BUNDLE}" "${ZIP_PATH}"

echo "==> Submitting to Apple notary service (profile: ${NOTARY_PROFILE})"
SUBMIT_OUT="$(mktemp)"
xcrun notarytool submit "${ZIP_PATH}" \
  --keychain-profile "${NOTARY_PROFILE}" \
  --wait \
  --output-format json >"${SUBMIT_OUT}"

if ! grep -q '"status"[[:space:]]*:[[:space:]]*"Accepted"' "${SUBMIT_OUT}"; then
  echo "notarytool submission failed:" >&2
  cat "${SUBMIT_OUT}" >&2
  rm -f "${SUBMIT_OUT}"
  exit 1
fi
rm -f "${SUBMIT_OUT}"

echo "==> Stapling notarization ticket"
xcrun stapler staple "${APP_BUNDLE}"

echo "==> Gatekeeper assessment"
spctl --assess --type execute --verbose=4 "${APP_BUNDLE}"

echo "Done: ${APP_BUNDLE} is notarized and stapled."
