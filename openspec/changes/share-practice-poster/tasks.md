## 1. Dependencies and module scaffold

- [x] 1.1 Add `share_plus` and `qr_flutter` to `pubspec.yaml`; run `flutter pub get`
- [x] 1.2 Create `lib/features/share_poster/` layout (`domain/`, `application/`, `presentation/`)

## 2. Domain and data aggregation

- [x] 2.1 Add `PracticePosterData` model (title, cover sources, hero text, takes, sentences, spoken duration ms)
- [x] 2.2 Implement hero-line resolver (most-practiced transcript line, tie-break length, `referenceText` fallback)
- [x] 2.3 Implement `PracticePosterBuilder` — load media, transcript lines, recordings from Drift DAOs; compute stats
- [x] 2.4 Unit tests for hero-line selection and stats aggregation (edge cases: no transcript, ties, empty text)

## 3. Poster UI (9:16 mobile layout)

- [x] 3.1 Build `PracticePosterWidget` — fixed 9:16 canvas, brand gradient, logo, cover, title, quote card, stat tiles, QR to `https://player.enjoy.bot`
- [x] 3.2 Resolve cover art async (local file, network URL via existing helpers, generative fallback from `coverSeed`)
- [x] 3.3 Truncate long hero text (3–4 lines) and apply safe margins for WeChat crop
- [x] 3.4 Widget/golden smoke test for poster layout with fixture data (optional golden if stable)

## 4. Export and platform share

- [x] 4.1 Implement `practice_poster_export.dart` — `RepaintBoundary` capture to PNG (`pixelRatio: 3`)
- [x] 4.2 Mobile path: `Share.shareXFiles` with PNG bytes via `share_plus` (iOS/Android)
- [x] 4.3 Desktop path: `FilePicker.saveFile` with PNG bytes (Windows/macOS), mirroring diagnostic export pattern
- [x] 4.4 Handle share/save errors with localized notices via `AppNotice`

## 5. Preview sheet and player entry

- [x] 5.1 Build `PracticePosterPreviewSheet` — loading state, poster preview, Share/Save primary action, dismiss
- [x] 5.2 Add player overflow (or equivalent) entry **Share practice poster**, enabled when current media has recordings
- [x] 5.3 Wire entry → builder → preview sheet → export flow

## 6. Localization and docs

- [x] 6.1 Add l10n strings (`en`, `zh`): menu label, preview title, stat labels, tagline, share/save buttons, loading/errors
- [x] 6.2 Run `flutter gen-l10n`
- [x] 6.3 Update `docs/features/echo-mode.md` with share poster behavior and entry point

## 7. Verification

- [ ] 7.1 Manual test: iOS or Android share sheet → WeChat (or save to album)
- [ ] 7.2 Manual test: desktop save PNG
- [x] 7.3 Run `flutter analyze` and `flutter test`
