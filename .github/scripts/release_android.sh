#!/usr/bin/env bash
# Android release — same steps as release_android.yml (Play AAB + direct APKs).
#
# Usage:
#   bash .github/scripts/release_android.sh
#   bash .github/scripts/release_android.sh --publish
#   bash .github/scripts/release_android.sh --feeds-only --publish-only --publish
set -euo pipefail

lib="$(dirname "$0")/release_lib.sh"
# shellcheck source=release_lib.sh
source "${lib}"

root="$(release_repo_root)"
cd "${root}"

BUILD_APK=true
BUILD_AAB=true

release_parse_common_args "$@"
for arg in "${RELEASE_EXTRA_ARGS[@]}"; do
  case "${arg}" in
    --no-apk) BUILD_APK=false ;;
    --no-aab) BUILD_AAB=false ;;
    -h | --help)
      sed -n '2,8p' "$0"
      exit 0
      ;;
    *)
      echo "Unknown option: ${arg}" >&2
      exit 1
      ;;
  esac
done

release_log_publish_only

if [[ "${RELEASE_SKIP_CHECKS}" != true ]]; then
  echo ">>> Pre-release checks"
  release_run_android_checks "${root}"
fi

if [[ "${RELEASE_SKIP_BUILD}" != true ]]; then
  if [[ -f "${root}/.github/scripts/setup_android_signing.sh" ]]; then
    bash "${root}/.github/scripts/setup_android_signing.sh" || true
  fi

  if [[ "${BUILD_AAB}" == true ]]; then
    echo ">>> Build App Bundle (store / Play)"
    flutter build appbundle --release --flavor store
  fi

  if [[ "${BUILD_APK}" == true ]]; then
    echo ">>> Build sideload APKs (direct / per ABI)"
    flutter build apk --release --split-per-abi --flavor direct \
      --dart-define=DISTRIBUTION_CHANNEL=direct
  fi

  bash "${root}/.github/scripts/rename_release_artifacts.sh" android
fi

if [[ "${RELEASE_PUBLISH}" == true ]]; then
  release_load_publish_env "${root}"
  version="$(release_version)"
  prefix="EnjoyPlayer-v${version}"
  apk_dir="${root}/build/app/outputs/flutter-apk"
  publish_args=()
  for abi in arm64-v8a armeabi-v7a x86_64; do
    f="${apk_dir}/${prefix}-${abi}.apk"
    if [[ -f "${f}" ]]; then
      publish_args+=(--android-apk "android_${abi//-/_}" "${f}")
    fi
  done
  if [[ ${#publish_args[@]} -eq 0 ]]; then
    echo "No sideload APKs to publish in ${apk_dir}" >&2
    exit 1
  fi
  if [[ "${RELEASE_FEEDS_ONLY}" == true ]]; then
    publish_args=(--feeds-only "${publish_args[@]}")
  else
    export RELEASE_REQUIRE_S3=1
  fi
  echo ">>> Publish Android sideload APKs"
  bash "${root}/.github/scripts/publish_player_release_to_s3.sh" "${publish_args[@]}"
fi

release_print_artifacts "${root}" android
echo "Done."
