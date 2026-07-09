# Research: Responsive Player Controls & Collapsed-Expand Recovery

**Feature**: 007-responsive-player-controls | **Date**: 2026-07-09

No `NEEDS CLARIFICATION` markers were carried into planning — the spec resolved every decision with documented assumptions. This file records the technical decisions that turn the spec into an implementable design, each with rationale and alternatives considered.

---

## R1. Responsive drop-priority model and the always-on invariant

**Decision**: Rewrite `resolveNarrowTransportBudget` (`lib/features/player/presentation/widgets/global_transport_bar.dart`) so that five controls are **unconditionally always-on** — play/pause, echo, blur, subtitle (CC), speed — and only a fixed set of *droppables* are subject to width-fitting, added greedily in strict priority order (highest priority added first; the first that does not fit ends the pass, so a lower-priority control can never survive at the expense of a higher-priority one).

Droppables, highest priority → lowest priority (lowest = dropped first):

1. fullscreen (only when `showFullscreenTransport`, i.e. desktop video)
2. volume
3. next (only when `hasTranscriptLines`)
4. previous (only when `hasTranscriptLines`)
5. expand icon (only when `!onPlayer`)

Observed drop sequence on a phone (no fullscreen) as width shrinks: **expand → previous → next → volume**, leaving the always-on five. This matches the user's "hide prev first, then next, then volume," with the expand icon dropping before prev because the tap-zone (R2) makes it non-essential.

Per-control width cost (reusing existing constants): play ring `kNarrowPlayRingWidth` (54) + `kNarrowLayoutSlack` (8) + echo/blur/cc `kNarrowIconSlotWidth` (40 each) + speed `kNarrowIconSlotWidth + kNarrowSpeedSlotExtra` (52) = **~234 px always-on base**. Each droppable adds 40 px; previous/next add 40 + `kNarrowLineNavGap` (4) = 44 because they flank the play ring with a gap.

At the smallest supported phone (device 320 dp → inner ~296 px after `space12` horizontal padding), `296 − 234 = 62` px remain → volume (40) fits, prev/next/expand drop → bar shows `[play] [echo][blur][cc][speed][volume]`, no overflow. Below ~274 px inner, volume also drops, leaving exactly the always-on five. The base (234) is below the smallest supported inner width (296), so the always-on invariant holds structurally on every supported device.

**Rationale**: The current function *reserves* prev/next first and then `removeLast()`s secondary tools, which is the opposite of phone UX where tapping a transcript line already jumps to it. Modeling prev/next as independently droppable (previous before next) directly implements the user's drop order and keeps the five practice controls guaranteed.

**Alternatives considered**:
- *Keep prev/next as a single cluster, drop cluster-first.* Rejected: the user explicitly wants previous to hide before next ("hide the prev button first, then the next button"), which requires independent flags.
- *Make the always-on set scrollable horizontally.* Rejected: a scrolling transport bar hides the speed/echo controls off-screen, defeating the "always visible" guarantee, and adds scroll-complexity to a 56 px control row.
- *Drop volume before next/prev.* Rejected: contradicts the user's stated order.

---

## R2. Collapsed expand affordance: tap neutral area to expand

**Decision**: When the player is collapsed (`!onPlayer`) **and** the layout is narrow, make the controls-row background expand the player. Implement with the shared `EnjoyTappableSurface` (Material ripple + `Haptics.selection` + `Focus` for keyboard + click cursor + `Semantics` label) wrapping the narrow controls `Row`, with `onTap` → `openPlayerRoute(context, chrome.mediaId)`. Flutter's gesture arena guarantees child `IconButton`s / the play-ring `InkWell` / the seek strip consume their own taps, so only genuinely neutral area (the `Spacer` and row padding) triggers expand — identical in principle to the existing wide-layout meta-row `InkWell` (`global_transport_bar.dart`) and `TransportArtworkTile`.

**Rationale**: This is the user's suggested fix and the only approach that guarantees expand on *every* width regardless of which buttons fit, without reserving permanent space (which the bar does not have). It reuses the project's canonical tappable primitive, so ripple/haptics/focus/semantics come for free and stay consistent with the rest of the app (Constitution III).

**Alternatives considered**:
- *Reserve a permanent expand icon.* Rejected: there is no spare width on a 320 dp phone; reserving it would re-violate the always-on invariant.
- *Make the whole `GlassSurface` (including the seek strip) tappable.* Rejected: the seek strip is a scrub surface — tapping it must seek, not expand. Scope the tap surface to the controls row, not the progress strip.
- *Plain `GestureDetector`.* Rejected as primary: loses ripple/hover/focus affordances that `EnjoyTappableSurface` provides and that Constitution III requires for tappable UI.

---

## R3. Accessibility of the expand affordance

**Decision**: Rely on three complementary paths so expand is reachable for every user:
- **Sighted touch**: tap neutral area (R2).
- **Keyboard**: the existing `player.toggleExpand` hotkey already calls `openPlayerRoute` when not on the player route (`app_hotkeys_keyboard_listener.dart`). No new hotkey needed.
- **Screen-reader / semantics**: the `EnjoyTappableSurface` exposes a `Semantics` button labeled with the existing localized `transportExpand` ("Expand player"). The expand `IconButton` (when it fits) continues to expose its own tooltip.

**Rationale**: "Tap the background" is inherently hard for TalkBack/VoiceOver to discover, so the labeled surface plus the existing hotkey plus the icon-when-fits together ensure no user is trapped in the mini-player. Reusing `transportExpand` avoids new strings (Constitution III; QR-006).

**Alternatives considered**:
- *Add a new descriptive ARB string (e.g. "Tap to open full player").* Optional follow-up; `transportExpand` already conveys the action. Deferred unless UX review wants it.
- *Force the expand icon to always render for a11y even when "hidden" visually.* Rejected: a visually-hidden but semantics-present control is confusing and inconsistent with the tap-zone model.

---

## R4. No new persistence / providers / engine surface

**Decision**: The feature is fully presentational. The budget is derived live from `LayoutBuilder` constraints + `hasTranscriptLines` + route; the expand affordance reads the existing `chrome.mediaId` and calls the existing `openPlayerRoute`. No new Riverpod providers, no Drift columns, no preference keys, no `media_kit` changes.

**Rationale**: Constitution I (persistence through Drift DAOs) and ADR-0003 (single `media_kit` Player) are untouched. Keeping the change presentation-only minimizes blast radius and test surface.

**Alternatives considered**:
- *Persist a "compact mode" preference.* Rejected: the user wants behavior derived from width, not a toggle; adding storage would violate the spec's "no new persisted preference" assumption.

---

## R5. Non-interference with swipe-to-dismiss and seek

**Decision**: The collapsed mini bar is already wrapped in a `Dismissible(direction: down)` for swipe-to-dismiss. Adding an `InkWell`/`EnjoyTappableSurface` tap inside it is safe: tap (arena-discrete) and vertical drag (dismiss) are distinct gestures and do not conflict. The seek strip remains the only consumer of horizontal/pointer drag in the row.

**Rationale**: Confirms FR-009 (preserve dismiss) and FR-007 (seek strip does not expand). The widget tests (R-section in plan) will assert both: tapping seek does not navigate; swiping still dismisses.

**Alternatives considered**: none needed — this is a verification point, not an open question.

---

## Open questions remaining for planning

None. All design decisions are resolved; implementation detail (exact slot reordering statements, the precise `Row`/`EnjoyTappableSurface` composition) belongs in `tasks.md`.
