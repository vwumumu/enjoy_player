## 1. Transport bar layout

- [ ] 1.1 Extract a narrow-layout budget helper in `global_transport_bar.dart` (slot widths, play ring width, secondary list, defer order)
- [ ] 1.2 Replace `showTranscriptControls` with `showPrevNext` (always true on narrow when `hasTranscriptLines`) and omit replay on narrow
- [ ] 1.3 Apply compact `IconButton` constraints (~40px) on narrow branch; group prev / play / next with tight spacing
- [ ] 1.4 Implement secondary deferral: expand (mini only), then volume, without dropping prev/next when transcript exists
- [ ] 1.5 Verify wide layout branch unchanged (play + prev + next + replay + scrollable secondary)

## 2. Tests

- [ ] 2.1 Add widget tests for narrow transport at 320 / 375 / 430 px (player route): prev/next present, replay absent, no overflow
- [ ] 2.2 Add widget test for mini transport at 320 px: prev/next present, expand deferred before line nav
- [ ] 2.3 Run `flutter test` and `flutter analyze` for touched files

## 3. Documentation

- [ ] 3.1 Update `docs/features/player.md` — narrow bar shows prev/next; replay via transcript line tap on mobile
- [ ] 3.2 Update `docs/features/app-ui.md` if transport control summary needs a one-line note
