## Why

Users invest real effort shadow-reading on a video, but that progress stays invisible inside the app. A **mobile-first shareable practice poster** turns a session into a polished, branded image they can post to **WeChat Moments, chats, or other social apps** — celebrating their work while promoting Enjoy Player via a QR code to `https://player.enjoy.bot`.

## What Changes

- **Practice poster generation** for a single video/audio target: cover art (thumbnail or generative fallback), media title, a **hero sentence** (most-practiced transcript line, tie-break by length), and practice stats (takes, sentences practiced, spoken duration).
- **Mobile-first layout** optimized for phone screens and social sharing (primary **9:16** canvas; safe margins for WeChat crop).
- **Preview sheet** before export so users can confirm content.
- **Share flow**: render widget to PNG, then invoke the **system share sheet** on iOS/Android (`share_plus` with image + MIME type). Desktop (Windows/macOS) falls back to **save file** via existing `file_picker` pattern (same as diagnostic export).
- **Enjoy Player branding**: logo, brand gradient, dark zinc palette, QR code to download landing.
- **Entry point** on the player when the current media has at least one recording (overflow menu or shadow-reading affordance).
- **Localization** of poster chrome labels (`en`, `zh`).
- **Out of scope (MVP)**: user-picked hero line, multiple aspect-ratio templates, server-side rendering, deep links to specific videos, username/avatar on poster, remote upload.

## Capabilities

### New Capabilities

- `share-practice-poster`: Per-media practice poster data aggregation, branded mobile poster UI, PNG export, and platform share/save flows.

### Modified Capabilities

- (none — entry point lives in player/shadow-reading UI but does not change existing OpenSpec capability requirements)

## Impact

- New feature slice under `lib/features/share_poster/` (or `practice_poster/`) — domain aggregator, poster widget, export/share orchestration.
- `lib/features/player/presentation/` — share action entry when recordings exist.
- `pubspec.yaml` — `share_plus`, `qr_flutter` (or equivalent QR widget).
- `lib/l10n/` — poster preview, share, stat labels, errors.
- `docs/features/echo-mode.md` — document share entry and poster contents.
- Tests: hero-line selection, stats aggregation, PNG export smoke (widget test where feasible).
