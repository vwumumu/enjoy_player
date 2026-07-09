# Implementation Plan: Responsive Player Controls & Collapsed-Expand Recovery

**Branch**: `main` (no git extension; spec dir `007-responsive-player-controls`) | **Date**: 2026-07-09 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/007-responsive-player-controls/spec.md`

## Summary

Fix two narrow-screen defects in the player transport bar:

1. **Wrong responsive drop priority.** Today `resolveNarrowTransportBudget` *reserves* previous/next line buttons first and then drops secondary tools from the end of the list, so on a phone the practice tools (echo/blur/subtitle/speed) get pushed off-screen while the redundant prev/next buttons survive. The priority is inverted: previous/next are the *most* droppable (a phone user can tap any transcript line to jump), and play/echo/blur/subtitle/speed must **always** fit. New drop order as width shrinks: expand icon → previous → next → volume (fullscreen, desktop-video-only, drops last). Previous and next become independently droppable (previous hides before next).

2. **Collapsed expand dead-end.** On narrow widths the expand icon is the first control dropped and the narrow layout has no meta-row tap target (only the wide layout does), so a phone user can collapse the player but cannot expand it again. Add a guaranteed expand path: tapping a **neutral area** of the collapsed narrow controls bar opens the full player, while interactive controls and the seek strip keep their own behavior. This mirrors the existing wide-layout meta-row tap and artwork-tile tap patterns, and complements the existing `player.toggleExpand` keyboard hotkey.

Technical approach: rewrite the pure `resolveNarrowTransportBudget` budget function (already a unit-testable pure function in `global_transport_bar.dart`) to model prev/next independently with an always-on invariant for the five core controls, then wrap the collapsed narrow controls row in a tappable expand affordance using the shared `EnjoyTappableSurface` primitive. No persistence, no engine, no new providers.

## Technical Context

**Language/Version**: Dart / Flutter (stable channel); exact SDK bound in `pubspec.yaml` (`environment: sdk`). No version change required.

**Primary Dependencies**: `flutter_riverpod` (existing providers, read-only here), `go_router` (`openPlayerRoute`), project shared UI (`EnjoyTappableSurface`, `Haptics`, `EnjoyThemeTokens`), `package:logging` via `logNamed`. No new dependencies.

**Storage**: N/A — no persistence changes. The responsive layout and expand affordance are fully derived from live width + transcript presence + route. No Drift, no preferences, no new keys.

**Testing**: `flutter test` — unit tests for `resolveNarrowTransportBudget` (`test/features/player/narrow_transport_budget_test.dart`) and widget tests for `GlobalTransportBar` (`test/features/player/global_transport_bar_test.dart`). No `dart run build_runner build` required (no `@riverpod` or Drift schema changes).

**Target Platform**: Android, iOS, macOS, Windows (no Flutter web — ADR-0003). The responsive behavior is most load-bearing on Android/iOS phone widths; desktop benefits in narrow windows.

**Project Type**: Flutter native mobile/desktop app.

**Performance Goals**: Transport bar stays at 60 fps with no dropped frames during portrait/landscape rotation and window resize; **zero** `RenderFlex overflow` exceptions on every supported width down to the smallest phone (~320 dp). The budget resolver is O(1) and runs inside the existing `LayoutBuilder`, so relayout adds no per-frame cost.

**Constraints**: Local-first; purely presentational change; must not interfere with the existing collapsed-mini swipe-down-to-dismiss `Dismissible` or with child control taps / seek-strip scrubbing. The five always-on controls must fit at the smallest supported width (guaranteed by the always-on base cost, ~234 px, being below the smallest supported inner width of ~296 px).

**Scale/Scope**: Phone widths 320–430 dp + rotation; tablet/desktop narrow windows. Largest relevant variable is available width (continuous). No library/transcript-size dependency.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### I. Architecture and Code Quality

- ✅ Affected code stays in `lib/features/player/presentation/` (`global_transport_bar.dart` and the `transport/` widgets). No cross-feature shortcuts.
- ✅ The width-budget decision remains a **pure function** (`resolveNarrowTransportBudget`) — kept testable, not embedded in widget state. QR-001 reinforces this.
- ✅ No domain-model changes; no persistence; Riverpod is read-only (existing providers only); no new mutable global singletons.
- ✅ No `print()`; no new `media_kit` `Player()` (single-engine rule, ADR-0003/0015, untouched).

### II. Testing Defines the Contract

- ✅ Unit: rewrite `narrow_transport_budget_test.dart` for the new contract — independent `showPrevious`/`showNext`, the exact drop order (expand → prev → next → volume → fullscreen), the always-on invariant (play/echo/blur/cc/speed never false) at the narrowest width, and the no-transcript case.
- ✅ Widget: extend `global_transport_bar_test.dart` — (a) always-on five visible at 320 px on both player and mini routes; (b) tapping a neutral area of the collapsed mini bar navigates to `/player/:id`; (c) tapping play/echo/etc. fires only that control (no navigation); (d) seeking via the progress strip does not navigate; (e) wide layout (≥720 px) unchanged.
- ✅ Manual verification: real-device/rotation smoke on a small phone (documented in `quickstart.md`).
- ✅ `dart run build_runner build` **not** required (no Drift/`@riverpod` changes).

### III. User Experience Consistency

- ✅ Strings: reuse the existing localized `transportExpand` ("Expand player" — already in `app_en.arb`, `app_zh.arb`, `app_zh_CN.arb`) for the expand tap-zone semantics label and the expand-icon tooltip. No new ARB keys required unless planning opts for a more descriptive label (optional, tracked in QR-006).
- ✅ Tappable controls, haptics, tooltips, keyboard: use `EnjoyTappableSurface` (Material ripple + `Haptics.selection` + `Focus` + click cursor + `Semantics`) for the expand tap zone, matching `TransportArtworkTile` and the wide-layout meta-row `InkWell`. Icon-only controls retain tooltips. Keyboard parity already exists via the `player.toggleExpand` hotkey (`app_hotkeys_keyboard_listener.dart`).
- ✅ Docs: update `docs/features/player.md` → "Line-level transport" note (currently states prev/next always shown on narrow and expand/volume defer before line navigation — now inverted).

### IV. Performance Is a Requirement

- ✅ Budget: bar must remain smooth during rotation/resize on the slowest supported target; no per-frame expensive work (resolver is O(1), already in `LayoutBuilder`). No new streams, isolates, or caches needed.
- ✅ The always-on invariant structurally prevents overflow on supported widths (base cost < smallest inner width). Below the supported minimum (e.g. extreme split-screen), the always-on set still renders as today (no worse than current behavior).

### V. Documentation and Traceability

- ✅ Update `docs/features/player.md` (Line-level transport + collapsed mini behavior).
- ✅ Consider a short ADR capturing the responsive drop-priority model + tap-to-expand affordance (QR-005 marks this SHOULD, not MUST). Candidate: `docs/decisions/0022-responsive-transport-priorities.md`.
- ✅ No release/signing/CI runbook impact.

**Gate result**: PASS — no violations. Complexity Tracking table left empty.

## Project Structure

### Documentation (this feature)

```text
specs/007-responsive-player-controls/
├── plan.md              # This file
├── spec.md              # Feature spec (/speckit-specify output)
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output (NarrowTransportBudget model)
├── quickstart.md        # Phase 1 output (validation guide)
├── contracts/
│   ├── transport-budget.md   # Pure budget-resolver contract
│   └── collapsed-expand.md   # Expand affordance contract
└── tasks.md             # Phase 2 output (/speckit-tasks — NOT created here)
```

### Source Code (repository root)

```text
lib/features/player/presentation/widgets/
├── global_transport_bar.dart        # resolveNarrowTransportBudget rewrite + narrow expand tap zone
└── transport/
    └── (existing transport_*.dart widgets — unchanged)

lib/l10n/
└── app_*.arb / app_localizations*.dart  # reuse transportExpand (no new keys required)

test/features/player/
├── narrow_transport_budget_test.dart   # updated to new contract
└── global_transport_bar_test.dart      # extended: always-on + tap-to-expand + no-regression

docs/
├── features/player.md                  # Line-level transport + mini behavior updated
└── decisions/0022-responsive-transport-priorities.md   # (optional ADR)
```

**Structure Decision**: No new modules or layers. The change is confined to the existing transport presentation layer (`global_transport_bar.dart`) plus its tests and one docs page. The pure budget function stays co-located in `global_transport_bar.dart` (its existing home) so the widget and its unit tests share one import path; if it grows, it can move to `transport/narrow_transport_budget.dart`, but that refactor is out of scope here.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

*(No violations — table intentionally empty.)*
