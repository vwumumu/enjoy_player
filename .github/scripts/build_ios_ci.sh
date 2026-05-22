#!/usr/bin/env bash
# Compile-only iOS smoke build for CI without device SDK or code signing.
#
# flutter build ios targets a connected device / latest iphoneos SDK by default.
# Use config-only + xcodebuild against iphonesimulator so CI does not require
# the newest device platform package in Xcode > Settings > Components.
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
  -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  build
