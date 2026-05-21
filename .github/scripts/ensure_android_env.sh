#!/usr/bin/env bash
# Verify pre-installed Java + Android SDK on self-hosted Linux runners.
set -euo pipefail

if ! command -v java >/dev/null 2>&1; then
  echo "::error::Java 17+ must be installed and on PATH (see docs/ci-self-hosted-runners.md)."
  exit 1
fi

sdk="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-}}"
if [ -z "${sdk}" ] || [ ! -d "${sdk}" ]; then
  echo "::error::ANDROID_SDK_ROOT or ANDROID_HOME must point to a pre-installed Android SDK."
  exit 1
fi

for rel in "platforms/android-35" "build-tools/35.0.0"; do
  if [ ! -d "${sdk}/${rel}" ]; then
    echo "::error::Missing ${sdk}/${rel}. Install with sdkmanager on the runner."
    exit 1
  fi
done

flutter config --android-sdk "${sdk}"
echo "Android SDK: ${sdk}"
java -version
