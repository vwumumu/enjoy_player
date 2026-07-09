# Quickstart: Responsive Player Controls & Collapsed-Expand Recovery

**Feature**: 007-responsive-player-controls | **Date**: 2026-07-09

A validation/run guide that proves the feature works end-to-end. It does **not** contain implementation code; implementation detail lives in `tasks.md`. Reference: [transport-budget contract](contracts/transport-budget.md), [collapsed-expand contract](contracts/collapsed-expand.md), [data model](data-model.md).

## Prerequisites

- Flutter SDK (stable) matching `pubspec.yaml`; a working device or emulator for at least one phone size.
- Dependencies installed (`flutter pub get`).
- No codegen step required for this feature (no Drift/`@riverpod` changes). If the working tree has unrelated generated-code changes, run `dart run build_runner build` once before validating.

## Automated validation

```bash
flutter analyze
flutter test test/features/player/narrow_transport_budget_test.dart
flutter test test/features/player/global_transport_bar_test.dart
flutter test
```

### Scenario A — Budget resolver contract (unit)

**Covers**: [transport-budget contract](contracts/transport-budget.md) C1–C6.

1. Run `flutter test test/features/player/narrow_transport_budget_test.dart`.
2. **Expected**: all assertions pass:
   - Always-on invariant: `showEcho/showBlur/showCc/showSpeed` are `true` for every sampled width (200–500 px) on both player and mini routes.
   - Drop order at decreasing widths (phone, `hasTranscriptLines: true`, `onPlayer: false`): `showExpand` → `showPrevious` → `showNext` → `showVolume` turn `false` in that order.
   - No priority inversion (a higher-priority droppable never drops while a lower-priority one survives).
   - `hasTranscriptLines: false` ⇒ prev/next both `false`; `onPlayer: true` ⇒ expand `false`.

### Scenario B — Always-on five render at the smallest width (widget)

**Covers**: spec Story 1, FR-001/FR-003.

1. Run the `GlobalTransportBar narrow layout` widget tests at 320 px for both the player route and the library (mini) route.
2. **Expected**: play/pause, echo, blur, subtitle (CC), and speed icons are all found; no `RenderFlex overflow` exception is thrown (`expect(tester.takeException(), isNull)` already in the harness).

### Scenario C — Tap neutral area expands; controls/seek do not (widget)

**Covers**: [collapsed-expand contract](contracts/collapsed-expand.md) E1–E3, spec Story 3.

1. Render the collapsed mini bar at 320 px (expand icon not shown).
2. Tap a neutral point of the controls row (between the play cluster and the trailing controls).
3. **Expected**: the route navigates to `/player/<mediaId>`.
4. Tap each visible control (play, echo, …) and tap/drag the seek strip.
5. **Expected**: only that control's effect fires; the route does **not** change.

### Scenario D — No regression on wide layout (widget)

**Covers**: FR-010, contract E (no-regression).

1. Render the transport bar at ≥720 px (wide layout), collapsed mini.
2. **Expected**: the full control set renders and the existing meta-row tap target opens the player (behavior identical to before this feature).

## Manual validation (device)

Run on a small phone emulator/device (e.g. ~360 dp) with a media item that has a transcript.

### M1 — Always-on + drop order across rotation

1. Open the player in portrait. Confirm play/echo/blur/subtitle/speed are all visible.
2. Rotate to landscape and back. Confirm the five stay visible throughout, no overflow/jank, and prev/next/volume appear/disappear smoothly with width (prev before next before volume).

### M2 — Collapsed expand on a phone

1. From the full player, press back to collapse to the mini bar.
2. Confirm there is no expand icon (width too small) but tapping the empty area of the bar reopens the full player.
3. Confirm tapping play/echo/etc. still works and does not expand; scrubbing the seek strip seeks.

### M3 — Dismiss preserved

1. On the collapsed mini bar, swipe down.
2. Confirm the player is dismissed (stops/clears) as before — the tap-to-expand did not break swipe-down.

### M4 — Accessibility

1. Enable TalkBack (Android) or VoiceOver (iOS) on the collapsed mini bar.
2. Confirm the expand surface is announced with the localized "Expand player" label; confirm the `player.toggleExpand` keyboard hotkey still opens the player on desktop.

## Done criteria for this guide

- Scenarios A–D pass in `flutter test` with no overflow exceptions.
- Manual M1–M4 pass on at least one phone form factor.
- `docs/features/player.md` Line-level-transport note reflects the new drop order and the tap-to-expand affordance.
