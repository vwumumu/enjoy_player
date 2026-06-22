## Context

Enjoy Player uses `package:logging` via [`setup_logging.dart`](../../../lib/core/logging/setup_logging.dart). In release, root level is INFO; output goes to `debugPrint` and `developer.log` only. Windows GUI releases have no visible console, so production issues (e.g. YouTube WebView passive sign-in stall) require custom debug builds to diagnose.

Existing **Developer** settings (`!kReleaseMode`) change API endpoints and internal tools — intentionally hidden from release. Phase 1 adds **support diagnostics**: local logs + export, without changing app behavior or exposing developer overrides.

Constraints: local-first product, privacy-sensitive (recordings, auth tokens, Enjoy API), direct-download channel on desktop, no new backend endpoint in Phase 1.

## Goals / Non-Goals

**Goals:**

- Persist redacted logs to a rotating file in all builds (release included).
- Let users export a diagnostic zip from Settings → About without knowing `%APPDATA%` paths.
- Optional verbose logging via allowlisted loggers (not global ALL).
- Emit a default-tier WARNING when YouTube playback stalls after page load.
- Document privacy expectations for support handoff.

**Non-Goals:**

- Remote upload / Enjoy API diagnostics endpoint (Phase 2).
- Sentry, Crashlytics, or third-party crash reporters.
- Developer section in release (API base URL override, AI playground routes).
- Logging WebView console at default tier.
- `dart-define` debug flags for end-user support.

## Decisions

### 1. File sink on `Logger.root` with rotation

**Decision:** Attach a single listener in `setupAppLogging()` that writes redacted lines to `{applicationSupport}/logs/enjoy-player.log` with size-based rotation (e.g. 2 MB × 3 files).

**Rationale:** Reuses existing `Log.named` call sites; no per-feature file APIs.

**Alternatives:** Separate diagnostic subsystem — rejected (duplication). SQLite log table — rejected (overkill, harder to export).

### 2. Default vs diagnostic verbosity (allowlist)

**Decision:**

- **Default:** `Logger.root.level = INFO` (unchanged).
- **Diagnostic toggle on:** bump **allowlisted** logger names to FINE: `YouTubePlayerEngine`, `YouTubeWebView`, `sync`, `api`, `auth`, `update` (prefix or exact match — implement as documented set). Root stays INFO for everything else.

**Rationale:** Avoids megabytes from unrelated FINE logs (e.g. library palette work). Matches how we debugged YouTube without enabling global noise.

**Alternatives:** Global ALL when toggle on — rejected. Separate debug executable — rejected.

Persist toggle in `SettingsKeys.diagnosticsVerboseEnabled` (`settings` KV table).

### 3. Redaction before write

**Decision:** Central `redactLogLine(String line)` applied to every file write:

- Replace `Authorization: …` / bearer tokens
- Strip or truncate cookie-like patterns if ever logged
- Truncate absolute Windows/macOS home paths to `…/<basename>` where feasible
- Do not log response bodies (already absent at call sites; enforce in HTTP logger if needed)

**Rationale:** Users email zips privately; redaction must be default, not opt-in.

### 4. Session header

**Decision:** On each cold start, write one INFO block: app version (`package_info_plus`), platform, `DISTRIBUTION_CHANNEL`, locale, diagnostic toggle state.

**Rationale:** Support can correlate builds without asking user to copy version separately (still shown in About).

### 5. Export diagnostic report

**Decision:** About section actions:

1. **Export diagnostic report** — always available; builds zip containing:
   - Rotated log files (`enjoy-player.log`, `.1`, `.2`)
   - `manifest.json` (version, platform, channel, build mode, export timestamp, verbose flag)
2. Use `archive` package + `file_picker` or platform save dialog; default filename `EnjoyPlayer-diagnostics-<date>.zip`.

**Rationale:** Windows users cannot find AppData; export is the support contract.

**Alternatives:** Copy path only — rejected as primary UX.

### 6. YouTube stall detector (default tier)

**Decision:** In `YoutubePlayerEngine`, if `load_stop` fires and no `first_playing` within 30s, log one WARNING: `youtube playback stalled after load_stop vid=…`.

**Rationale:** Surfaces release-only stalls in default logs without verbose mode; complements ADR-0025 navigation fix.

### 7. UI placement and copy

**Decision:** Add to [`AboutSectionCard`](../../../lib/features/player/presentation/widgets/about_section_card.dart):

- Toggle: “Diagnostic logging” + short privacy note
- Button: “Export diagnostic report”

Do **not** add to release Developer section or require `kReleaseMode` gates for export.

### 8. Documentation

**Decision:** Add `docs/features/diagnostics.md`; link from `docs/README.md`. Optional ADR if we record privacy default (local-only, opt-in verbose).

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Disk growth from HTTP INFO spam | Rotation + cap; consider trimming api logger to WARNING-only later |
| Redaction misses a secret | Code review allowlist; never log bodies/tokens at call sites |
| Zip contains video IDs / media UUIDs | Acceptable for support; document in privacy copy |
| Toggle left on forever | UI recommends turning off after report; default off |
| `archive` dependency | Small, well-used; add to pubspec |

## Migration Plan

1. Ship behind no feature flag — logging is passive.
2. No DB schema migration (settings KV only).
3. Rollback: disable file sink in `setupAppLogging` if critical bug; export button harmless.

## Open Questions

- Exact allowlist logger name matching (prefix `YouTube` vs explicit list) — resolve in implementation.
- Android/iOS share sheet vs desktop save dialog — use platform-idiomatic export via existing `file_picker` / share patterns.
