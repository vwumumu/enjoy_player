#!/usr/bin/env bash
# Patches pub-cache Android Gradle files for AGP 9 compatibility.
# Run after `flutter pub get` when Android builds fail on older plugins.
set -euo pipefail

PUB_CACHE="${PUB_CACHE:-${HOME}/.pub-cache}/hosted/pub.dev"

INAPP="${PUB_CACHE}/flutter_inappwebview_android-1.1.3/android/build.gradle"
if [[ -f "${INAPP}" ]]; then
  if grep -q "proguard-android.txt" "${INAPP}"; then
    sed -i 's/proguard-android\.txt/proguard-android-optimize.txt/g' "${INAPP}"
    echo "Patched ${INAPP} (proguard-android-optimize.txt)"
  fi
fi

echo "AGP 9 pub plugin patches applied."
