## Why

Release and installed builds are hard to debug when issues only appear in production: logs go to `debugPrint` (invisible on Windows GUI apps), verbose player/WebView detail is gated at `FINE`, and support relies on ad-hoc debug builds. The recent YouTube passive sign-in stall required a custom `DEBUG_YOUTUBE` build to diagnose. Phase 1 adds **local, redacted diagnostic logs** and **in-app export** so users can privately send reports without a special build or remote telemetry.

## What Changes

- **Rotating file log sink** attached to `Logger.root` in all builds (default release verbosity: INFO+ with redaction).
- **Session header** on each app start (version, platform, distribution channel, locale).
- **Optional “Diagnostic logging” toggle** in Settings → About (persisted in `SettingsDao`); when on, elevates an allowlisted set of loggers (YouTube, sync, api, auth, update) to FINE — not a Developer/API-override mode.
- **Export diagnostic report** in Settings → About: bundles rotated log file(s) + `manifest.json` into a zip saved via file picker / Downloads (platform-appropriate).
- **YouTube playback stall signal** at default tier: WARNING when `load_stop` occurs without `first_playing` within a timeout (no verbose mode required).
- **Privacy**: central redaction for tokens, cookies, auth headers, and sensitive paths before write.
- **Out of scope (Phase 1)**: remote upload to Enjoy API, Sentry/third-party crash reporting, exposing existing Developer section in release builds.

## Capabilities

### New Capabilities

- `production-diagnostics`: Local rotating logs, redaction, diagnostic logging toggle, export bundle, and session metadata for support.

### Modified Capabilities

- (none — no existing OpenSpec capability specs for logging or settings)

## Impact

- `lib/core/logging/` — file sink, redaction, session header
- `lib/core/logging/setup_logging.dart` — wire sink; respect diagnostic toggle
- `lib/data/db/settings_keys.dart` — `diagnostics.verbose_enabled` (or similar)
- `lib/features/settings/presentation/widgets/about_section_card.dart` — toggle + export action
- `lib/features/player/application/engines/youtube/youtube_player_engine.dart` — stall detector WARNING
- `docs/features/` — new or updated diagnostics/support doc; optional ADR for privacy defaults
- `pubspec.yaml` — likely `archive` for zip export (if not already present)
- Tests: redaction unit tests, export manifest tests, navigation/stall policy where applicable
