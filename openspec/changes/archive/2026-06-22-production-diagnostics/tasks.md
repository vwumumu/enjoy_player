## 1. Dependencies and settings

- [x] 1.1 Add `archive` dependency to `pubspec.yaml` for zip export
- [x] 1.2 Add `SettingsKeys.diagnosticsVerboseEnabled` and read/write helpers via `SettingsDao`

## 2. Core logging infrastructure

- [x] 2.1 Create `lib/core/logging/log_redaction.dart` with unit tests for token/path redaction
- [x] 2.2 Create `lib/core/logging/log_file_sink.dart` — rotating file writer under `{applicationSupport}/logs/`
- [x] 2.3 Create `lib/core/logging/diagnostic_log_config.dart` — allowlisted logger names + verbose level resolver
- [x] 2.4 Wire file sink and session header into `setupAppLogging()` (sync init; flush on write)
- [x] 2.5 Write session header on startup (version, platform, channel, locale, verbose flag)

## 3. Diagnostic export

- [x] 3.1 Create `lib/core/diagnostics/diagnostic_export.dart` — build zip (logs + `manifest.json`)
- [x] 3.2 Add platform save/share flow from About (file picker / save dialog)
- [x] 3.3 Unit tests for manifest contents and zip includes rotated log files

## 4. Settings UI

- [x] 4.1 Add diagnostic logging toggle + privacy copy to `AboutSectionCard`
- [x] 4.2 Add Export diagnostic report button with success/error notices
- [x] 4.3 Add l10n strings (`en`, `zh`) for toggle, export, and privacy text
- [x] 4.4 Connect toggle to `SettingsDao` and refresh `setupAppLogging` / verbose allowlist at runtime

## 5. YouTube stall detector

- [x] 5.1 Add post-`load_stop` timeout in `YoutubePlayerEngine`; log WARNING on stall with video id
- [x] 5.2 Cancel timeout on `first_playing` or engine dispose / new open
- [x] 5.3 Unit or widget-level test for stall timer behavior where feasible without WebView

## 6. Documentation

- [x] 6.1 Add `docs/features/diagnostics.md` (default vs verbose tiers, export steps, privacy)
- [x] 6.2 Link from `docs/README.md`
- [x] 6.3 Optional ADR for local-only diagnostics default (if recorded separately from feature doc)

## 7. Verification

- [x] 7.1 `flutter analyze` and `flutter test` pass
- [x] 7.2 Manual: release build → export zip → confirm session header and redaction
- [x] 7.3 Manual: enable verbose toggle → reproduce YouTube open → confirm FINE lines in export
