#!/usr/bin/env bash
# Compile-only macOS smoke build for CI without Apple Development signing.
#
# flutter build macos does not forward xcodebuild settings after "--"; those
# positional args are treated as Dart entrypoints. Use config-only + xcodebuild
# with CODE_SIGNING_ALLOWED=NO instead (see ADR/docs in packaging.md for why
# local dev keeps Apple Development signing on the Runner target).
set -euo pipefail

configuration="${1:?Usage: $0 Debug|Release}"

case "${configuration}" in
  Debug)
    flutter build macos --debug --config-only
    ;;
  Release)
    flutter build macos --release --config-only
    ;;
  *)
    echo "Unsupported configuration: ${configuration}" >&2
    exit 1
    ;;
esac

xcodebuild \
  -workspace macos/Runner.xcworkspace \
  -scheme Runner \
  -configuration "${configuration}" \
  -derivedDataPath build/macos \
  CODE_SIGNING_ALLOWED=NO \
  build
