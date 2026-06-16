#!/usr/bin/env bash
# Drop stale AGP JNI merge outputs before flavored release builds.
# Workaround for flutter/flutter#187553 (Flutter 3.44 + product flavors).
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
intermediates="${root}/build/app/intermediates"

for dir in merged_jni_libs merged_native_libs stripped_native_libs; do
  target="${intermediates}/${dir}"
  if [[ -d "${target}" ]]; then
    rm -rf "${target}"
    echo "Pruned ${target}"
  fi
done
