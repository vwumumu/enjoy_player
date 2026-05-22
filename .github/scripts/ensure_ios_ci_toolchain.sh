#!/usr/bin/env bash
# Ensure Xcode components required for iOS compile-only CI on self-hosted macOS runners.
#
# Xcode 26.x smoke builds need the matching iOS platform/simulator runtime and an
# up-to-date CoreSimulator framework (installed via -runFirstLaunch). Without these,
# xcodebuild exits 70 with "CoreSimulator is out of date" or "iOS 26.x is not installed".
set -euo pipefail

log() {
  echo "[ensure_ios_ci_toolchain] $*"
}

run_first_launch() {
  log "Running xcodebuild -runFirstLaunch (CoreSimulator + required components)…"
  if xcodebuild -runFirstLaunch; then
    return 0
  fi
  local status=$?
  log "xcodebuild -runFirstLaunch failed (exit ${status})."
  log "On the runner Mac, run once with admin rights: sudo xcodebuild -runFirstLaunch"
  return "${status}"
}

download_ios_platform() {
  log "Downloading iOS platform for active Xcode (xcodebuild -downloadPlatform iOS)…"
  local output status
  # arm64 matches Apple Silicon runners; universal is the fallback on ambiguous feeds.
  if output="$(xcodebuild -downloadPlatform iOS -architectureVariant arm64 2>&1)"; then
    log "${output}"
    return 0
  fi
  status=$?
  log "${output}"
  if echo "${output}" | grep -qE 'already downloaded|No needed downloadables'; then
    log "iOS platform/runtime already present."
    return 0
  fi
  log "arm64 variant unavailable; retrying with universal…"
  if output="$(xcodebuild -downloadPlatform iOS -architectureVariant universal 2>&1)"; then
    log "${output}"
    return 0
  fi
  status=$?
  log "${output}"
  if echo "${output}" | grep -qE 'already downloaded|No needed downloadables'; then
    log "iOS platform/runtime already present."
    return 0
  fi
  return "${status}"
}

restart_simulator_services() {
  # After -runFirstLaunch updates CoreSimulator, stale ibtoold/simctl daemons break storyboard compiles.
  log "Restarting CoreSimulator-related daemons after toolchain update…"
  killall ibtoold 2>/dev/null || true
  killall SimulatorTrampoline 2>/dev/null || true
  xcrun simctl shutdown all 2>/dev/null || true
}

assert_ios_destination() {
  log "Checking for a usable generic iOS device destination…"
  if xcodebuild -showdestinations -workspace ios/Runner.xcworkspace -scheme Runner -sdk iphoneos 2>&1 \
    | grep -q "platform:iOS, id:dvtdevice-DVTiPhonePlaceholder-iphoneos:placeholder"; then
    log "generic iOS device destination is available."
    return 0
  fi
  log "No generic iOS device destination. Install components in Xcode > Settings > Components," >&2
  log "or run: xcodebuild -downloadPlatform iOS && sudo xcodebuild -runFirstLaunch" >&2
  return 1
}

run_first_launch
download_ios_platform
restart_simulator_services
assert_ios_destination
