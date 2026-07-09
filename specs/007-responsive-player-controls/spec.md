# Feature Specification: Responsive Player Controls & Collapsed-Expand Recovery

**Feature Branch**: `[007-responsive-player-controls]`

**Created**: 2026-07-09

**Status**: Draft

**Input**: User description: "When in small phone screen, the width is small, we cannot list all buttons in the player controls bar. We need to design it carefully. In a phone, user could tap transcript line to jump, the prev/next line button is not necessary, if the width is not enough, hide the prev button first, then the next button, then the vol button. We should always display the play/echo/blur/subtitle/speed buttons, we should design it carefully in small size screen. When the player is collapsed, the `expanded` button is never displayed, we cannot expand the player again. We need to handle this. Maybe tapping the controls bar should expand the player."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Core learning controls always fit on small phones (Priority: P1)

A language learner opens a media item on a small phone (the narrowest supported width). In both the full player view and the collapsed mini-player, the transport controls bar always shows the five controls they need to practice: **play/pause, echo mode, blur practice, subtitle (CC), and playback speed**. No matter how narrow the screen — even during a portrait-to-landscape rotation, or on the smallest device the app supports — none of these five controls is ever clipped, pushed off-screen, or hidden due to width pressure. The learner can always start echo practice, toggle the blur, turn subtitles on, change speed, and play/pause without expanding the player or scrolling the bar.

**Why this priority**: This is the headline guarantee. These five controls are the core of the listening/practice loop; if any of them disappears on a small screen the app becomes unusable for its primary purpose on the most common device class (phones). Everything else in this feature depends on this contract holding.

**Independent Test**: Can be fully tested by loading any media item with a transcript at the narrowest supported width and asserting that play/pause, echo, blur, subtitle, and speed are all visible and tappable in the controls bar, with no overflow or layout errors, both on the player route and in the collapsed mini-player.

**Acceptance Scenarios**:

1. **Given** a media item is open on the smallest supported phone width in the full player view, **When** the controls bar renders, **Then** play/pause, echo, blur, subtitle (CC), and speed are all visible and tappable; none is clipped or pushed off-screen.
2. **Given** the same item shown as the collapsed mini-player on the smallest supported width, **When** the mini transport bar renders, **Then** the same five controls are all visible and tappable.
3. **Given** the player is open on a small phone in portrait, **When** the user rotates to landscape (or back), **Then** the five always-on controls remain visible and the bar emits no overflow/layout errors at any point during the transition.
4. **Given** a media item with **no** transcript, **When** the controls bar renders on a narrow screen, **Then** play/pause and speed remain enabled and visible; echo, blur, and subtitle remain visible in their existing disabled/idle states (no new hiding behavior), and no width-induced hiding occurs for the always-on set.

---

### User Story 2 - Least-valuable controls drop in the right order (Priority: P1)

When the screen cannot fit every control, the app removes the least valuable ones first, in a deliberate order that matches how a phone user actually navigates. Because a phone user can **tap any transcript line to jump** to it, previous-line and next-line buttons are the most redundant and drop first: **previous drops before next** (next is kept a little longer because "next cue" is a common repeat-listen target), and **volume drops after both**. The five always-on controls (play, echo, blur, subtitle, speed) never drop. As the width grows, controls reappear in the reverse order: volume returns, then next, then previous. The transition is smooth and introduces no layout jumps or flicker.

**Why this priority**: This story is the other half of the responsive contract. Without a correct drop order, either the wrong controls survive (today prev/next are reserved first and push the practice tools off-screen) or the bar overflows. Getting the order right is what makes the narrow bar usable rather than just non-overflowing.

**Independent Test**: Can be tested by progressively reducing the available width (e.g., across a range of phone widths from widest to narrowest) and asserting the exact sequence in which controls disappear: previous first, then next, then volume — while play, echo, blur, subtitle, and speed are present at every step.

**Acceptance Scenarios**:

1. **Given** a transcript is loaded and the width is wide enough for everything on a narrow layout, **When** the bar renders, **Then** previous, next, and volume are all visible alongside the always-on five.
2. **Given** the width is reduced so that not everything fits, **When** the bar re-layouts, **Then** **previous** disappears first; next, volume, and the always-on five remain.
3. **Given** the width is reduced further, **When** the bar re-layouts, **Then** **next** also disappears (previous already gone); volume and the always-on five remain.
4. **Given** the width is reduced to the smallest supported width, **When** the bar re-layouts, **Then** **volume** has also disappeared; only the always-on five (play, echo, blur, subtitle, speed) remain.
5. **Given** previous is hidden but next is still visible, **When** the layout is rendered, **Then** play/pause and next remain grouped and usable (no broken gap or misaligned cluster); when next later hides, play/pause stands alone cleanly.
6. **Given** the width is increased again, **When** the bar re-layouts, **Then** controls reappear in reverse order — volume, then next, then previous — with no flicker.

---

### User Story 3 - A collapsed player can always be expanded again (Priority: P1)

On a phone, the user collapses the full player down to the mini transport bar (for example by pressing back, so they are no longer on the player route). From this collapsed state they must always be able to get back to the full player. Today, on narrow screens, the expand button is the first thing dropped for width and there is no other expand affordance — leaving the user trapped in the mini-player. Now, **tapping a neutral area of the controls bar expands the player**, and this works on every supported width regardless of which buttons currently fit. Tapping an actual control (play, echo, etc.) still performs only that control's action and does not expand. The seek/progress strip remains a seek surface and does not expand.

**Why this priority**: A collapsed player that cannot be re-expanded is a dead-end that blocks the primary flow (returning to transcript/practice view). It is a regression-level fix and therefore P1 alongside the other two core guarantees.

**Independent Test**: Can be tested by collapsing the player on the narrowest supported width (where the expand icon is not shown) and tapping a neutral part of the controls bar, then asserting the full player route opens. Also by tapping each visible control and asserting it performs only its own action (no expand).

**Acceptance Scenarios**:

1. **Given** the player is collapsed to the mini transport on the smallest supported width (so the expand icon is not visible), **When** the user taps a neutral area of the controls bar (not a button, not the seek strip), **Then** the full player opens.
2. **Given** the player is collapsed on a wider phone where the expand icon still fits, **When** the user taps the expand icon, **Then** the full player opens (the icon remains a valid, discoverable affordance when room allows).
3. **Given** the player is collapsed, **When** the user taps play/pause, echo, blur, subtitle, speed, volume (when visible), or prev/next (when visible), **Then** only that control's action fires; the player does **not** expand.
4. **Given** the player is collapsed, **When** the user interacts with the progress/seek strip, **Then** seeking happens (or nothing, on empty areas of the strip) and the player does **not** expand.
5. **Given** the player is collapsed and the existing swipe-down-to-dismiss gesture is available, **When** the user swipes the bar down, **Then** the player is dismissed as before; the tap-to-expand behavior does not interfere with dismiss.
6. **Given** the player is already expanded (the user is on the player route), **When** the user taps the controls bar background, **Then** nothing extra happens (no expand action, since they are already expanded).

---

### User Story 4 - Discoverability, accessibility, and no wide-layout regression (Priority: P2)

The expand affordance is discoverable and accessible: the tap-to-expand zone has a clear semantics label so screen readers and keyboard users understand they can open the full player, and haptic feedback follows the project's shared interaction patterns when expanding. Icon-only controls keep their tooltips. Meanwhile, wide layouts (tablets, desktop) are completely unaffected: the full control set, the existing meta-row tap-to-expand, and the current layout remain exactly as today.

**Why this priority**: Discoverability and accessibility make the P1 expand path actually usable for everyone, and the no-regression guard protects the larger screens that already work. These are essential for quality but do not block the core narrow-screen fix.

**Independent Test**: Can be tested by enabling a screen reader / keyboard focus on the collapsed narrow bar and asserting the expand zone is announced and reachable; and by loading the app at a wide width and asserting the controls bar is visually and behaviorally identical to before this feature.

**Acceptance Scenarios**:

1. **Given** the player is collapsed on a narrow screen, **When** a screen reader / keyboard focus reaches the expand zone, **Then** it is announced as an action that opens the full player (using a localized label).
2. **Given** a wide layout (width above the narrow breakpoint) on tablet or desktop, **When** the controls bar renders, **Then** the full control set and the existing meta-row tap-to-expand behave exactly as before; no new hiding, tapping, or layout behavior is introduced.
3. **Given** any narrow controls bar, **When** the user focuses or hovers an icon-only control, **Then** its localized tooltip is shown as today.

---

### Edge Cases

- **Very narrow width (smallest supported phone, ~320 logical px):** only the always-on five appear; prev, next, volume, and the expand icon are all dropped; the tap-to-expand zone still provides a non-trivial tappable area and the bar emits no overflow.
- **Rotation between portrait and landscape:** the drop order is recomputed live; controls reappear/disappear smoothly with no flicker, jank, or transient overflow errors.
- **No transcript loaded:** prev/next are not rendered (unchanged); echo/blur/subtitle remain visible in their disabled/idle states; the always-on guarantee still holds and the expand affordance still works when collapsed.
- **Active echo / blur state when their button would be "disabled":** echo stays enabled while active (existing rule) so the user can exit echo; the always-on visibility guarantee is about being *shown*, not necessarily enabled — disabled-but-visible is acceptable per existing patterns.
- **Tap target collisions:** tapping a control must never also expand; tapping the seek strip must seek, not expand. The expand tap zone must not shrink to zero when many buttons are visible — the bar background/padding participates as the neutral zone so there is always a reachable expand area.
- **Swipe-down to dismiss (collapsed mini):** the tap-to-expand gesture must not consume or block the dismiss gesture; taps and swipes remain distinct.
- **Already expanded (on player route):** the expand affordance is a no-op; there is no "expand" button or action shown when already on the player route (unchanged).
- **Desktop fullscreen button:** remains desktop-video-only and is rarely a factor on phone widths; if width pressure requires, it drops after volume and does not affect the always-on five.
- **Reduced motion / accessibility:** transitions of controls in/out are instant or follow the existing motion tokens; the expand zone is semantics-labeled regardless of motion settings.
- **Localization / long labels:** tooltips and the expand-zone semantics label come from the existing localization files; no hardcoded user-facing strings.
- **Offline / sync:** responsive layout and tap-to-expand are purely local UI behavior with no network or sync dependency; they work offline.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: On a narrow layout, the system MUST always render the play/pause, echo mode, blur practice, subtitle (CC), and playback speed controls in the transport bar, regardless of available width. These five controls MUST never be hidden, clipped, pushed off-screen, or made unreachable due to insufficient width.
- **FR-002**: The system MUST treat previous-line and next-line as independently droppable controls (not a single inseparable cluster). When transcript lines are present and width is insufficient, the system MUST hide **previous-line first**, then **next-line**, then **volume**, in that exact order.
- **FR-003**: The system MUST NOT drop play/pause, echo, blur, subtitle, or speed from the narrow bar at any width. Volume, next, and previous are the only controls that may be dropped for width, in the order defined by FR-002.
- **FR-004**: As width increases on a narrow layout, the system MUST restore dropped controls in reverse order — volume first, then next, then previous — and MUST do so without flicker, layout jumps, or overflow errors.
- **FR-005**: When the player is collapsed (the mini transport shown outside the full player route), the system MUST guarantee a way to expand back to the full player on every supported width, even when an expand icon button cannot fit.
- **FR-006**: When collapsed on a narrow layout, tapping a neutral (non-interactive) area of the controls bar MUST open the full player route. Tapping any interactive control (play/pause, previous, next, echo, blur, subtitle, speed, volume, and the expand icon when visible) MUST perform only that control's action and MUST NOT expand.
- **FR-007**: The progress/seek strip MUST remain a seek surface. Interacting with it MUST NOT expand the player. The expand tap zone MUST be implemented so that it never consumes taps intended for buttons or the seek strip.
- **FR-008**: The expand affordance (tap zone and, when visible, the expand icon) MUST be announced to assistive technologies with a localized semantics label describing that it opens the full player, and MUST be reachable by keyboard where the platform supports it, following the project's shared UI and interaction patterns (including haptic feedback on expand).
- **FR-009**: The system MUST preserve existing collapsed-mini behaviors — including swipe-down to dismiss the player — and the tap-to-expand zone MUST NOT interfere with the dismiss gesture or with control button taps.
- **FR-010**: Wide layouts (width above the narrow breakpoint) MUST be unaffected by this feature: the full control set, the existing meta-row tap-to-expand, and the current layout MUST remain as before, with no new hiding, tapping, or layout behavior.
- **FR-011**: The system MUST NOT display an expand action when the user is already on the full player route; expanding is only relevant from the collapsed mini-player (unchanged behavior, restated for clarity).
- **FR-012**: The responsive behavior MUST be computed from the live available width, so that the correct control set and expand affordance are presented immediately after orientation changes, window resizing, or route changes, with no stale state.

### Quality, UX, and Performance Requirements

- **QR-001**: Implementation MUST preserve Enjoy Player's feature-first architecture (transport lives under `lib/features/player/presentation/`) and avoid feature-to-feature shortcuts. The width-budget logic should remain a pure, unit-testable function rather than widget-embedded logic where practical.
- **QR-002**: Behavior changes MUST include automated tests. Required coverage at minimum: the new drop order (previous → next → volume) including independent prev/next hiding; the always-on guarantee for play/echo/blur/subtitle/speed at the narrowest width; tap-neutral-area expands while control taps and seek-strip taps do not; no-regression for the wide layout. The existing narrow transport budget test MUST be updated to the new contract.
- **QR-003**: All user-facing strings, controls, haptics, tooltips, the expand-zone semantics label, and keyboard affordances MUST follow existing localization (`AppLocalizations`) and shared UI primitive patterns (`EnjoyTappableSurface` / `EnjoyTappableIcon` / `EnjoyButton` / `Haptics` where they fit).
- **QR-004**: Responsive relayout and the expand hit-testing MUST NOT degrade transport bar performance. Width-driven control show/hide MUST remain smooth during rotation and resize on the slowest supported target, with no per-frame expensive work in the bar's build path and no layout overflow exceptions.
- **QR-005**: Feature behavior MUST update `docs/features/player.md`, specifically the existing "Line-level transport" note that currently states prev/next are always shown on narrow and that expand/volume defer before line navigation — this must be replaced with the new drop order and the tap-to-expand affordance. A short ADR SHOULD be added if the drop-priority / tap-to-expand model is a decision worth recording.
- **QR-006**: Any new localized strings (e.g., the expand-zone semantics label) MUST be added to the ARB files and the feature MUST NOT introduce hardcoded user-facing text.

### Key Entities *(include if feature involves data)*

- **NarrowTransportBudget** (derived, not persisted): the per-layout decision of which controls are visible. Extended so that previous and next are modeled as independent flags (e.g., `showPrevious` and `showNext`) rather than a single `showPrevNext`, alongside the existing `showEcho`, `showBlur`, `showCc`, `showSpeed`, `showVolume`, `showFullscreen`, and `showExpand`. Computed live from available width and transcript presence; never stored.
- **CollapsedExpandAffordance** (behavioral, not an entity): the contract that a collapsed mini-player always exposes an expand action — either the expand icon (when it fits) or the neutral-area tap zone on the controls bar. No new persisted data; reuses the existing player route navigation and `PlayerUi` collapsed/expanded state.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: On the smallest supported phone width — in both the full player view and the collapsed mini-player — play/pause, echo, blur, subtitle (CC), and speed are simultaneously visible and tappable in the controls bar, with zero overflow or layout errors.
- **SC-002**: As width decreases across the narrow range, controls disappear in the exact sequence previous → next → volume; play/pause, echo, blur, subtitle, and speed are present at every width step with no exceptions.
- **SC-003**: From the collapsed mini-player, users can expand to the full player on 100% of supported widths — including the narrowest width where no expand icon is shown — with no dead-end state.
- **SC-004**: Tapping an interactive control performs only that control's action (no expand), and tapping the seek strip seeks (no expand); only a neutral area of the controls bar expands the player.
- **SC-005**: Wide layouts (tablet/desktop) are visually and behaviorally identical to before this feature: same control set, same meta-row tap-to-expand, no new regressions.
- **SC-006**: The controls bar remains smooth (no dropped frames beyond the existing baseline and no layout overflow exceptions) during portrait/landscape rotation and window resize on the slowest supported target.
- **SC-007**: The expand affordance is discoverable via assistive technology (announced with a localized label) and reachable by keyboard where supported; all icon-only controls retain localized tooltips.

## Assumptions

- "Narrow layout" reuses the project's existing width breakpoint (the same one that already switches the controls bar to its compact single-row form). This feature changes *what* fits in that form, not the breakpoint itself.
- The smallest supported width is a typical small phone (~320–360 logical px). Exact pixel budgets and slot sizing are owned by the design/planning pass and the existing transport slot constants.
- Tap-to-expand applies to the **collapsed narrow mini-player**, where there is no meta-row tap target today. The wide layout already has a meta-row tap-to-expand and is left unchanged.
- The expand icon button remains a valid, discoverable affordance **when it fits**, but it is no longer the sole way to expand; the neutral-area tap zone is the guaranteed mechanism. The expand icon may be dropped first for width (most droppable) because the tap zone covers it.
- The fullscreen button stays desktop-video-only; on phone widths it is effectively absent and is not part of the always-on set. If width pressure ever requires, it drops after volume.
- The replay-line control continues to be omitted on narrow layouts (unchanged); the user did not ask to change replay.
- When no transcript is loaded, previous/next are not rendered (unchanged). The drop order in FR-002 applies only when transcript lines are present.
- "Always display" means always *visible and reachable*; a control may still be in a disabled/idle state per existing rules (e.g., echo/blur/subtitle disabled when there is no transcript, echo enabled while active so the user can exit it).
- No new persisted user preference is required: the responsive behavior is fully derived from live width and transcript presence.
- This feature introduces no new network, sync, or playback-engine surface; it is confined to transport bar presentation and player-route navigation.
