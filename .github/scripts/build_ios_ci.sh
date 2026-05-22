#!/usr/bin/env bash
# Compile-only iOS smoke build for CI without code signing.
#
# Builds for iphoneos (generic iOS device), not the simulator:
# - ffmpeg_kit_flutter_new lacks arm64 for Apple Silicon iOS 26+ simulators.
# - Simulator destinations require a current CoreSimulator framework from
#   xcodebuild -runFirstLaunch (see ensure_ios_ci_toolchain.sh).
#
# Requires the iOS platform matching the active Xcode SDK (install via
# ensure_ios_ci_toolchain.sh or Xcode > Settings > Components).
set -euo pipefail

configuration="${1:?Usage: $0 Debug|Release}"

case "${configuration}" in
  Debug)
    flutter build ios --debug --config-only --no-codesign
    ;;
  Release)
    flutter build ios --release --config-only --no-codesign
    ;;
  *)
    echo "Unsupported configuration: ${configuration}" >&2
    exit 1
    ;;
esac

xcodebuild \
  -workspace ios/Runner.xcworkspace \
  -scheme Runner \
  -configuration "${configuration}" \
  -sdk iphoneos \
  -destination 'generic/platform=iOS' \
  -derivedDataPath build/ios/DerivedData \
  CODE_SIGNING_ALLOWED=NO \
  build
