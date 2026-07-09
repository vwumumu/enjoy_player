# Contract: Collapsed expand affordance

**Feature**: 007-responsive-player-controls | **Location**: `lib/features/player/presentation/widgets/global_transport_bar.dart` (narrow branch)

Guarantees that a collapsed mini-player (`!onPlayer`) can always be expanded on every supported width, even when the expand icon does not fit (FR-005, FR-006, FR-007, FR-009, FR-011).

## Scope

Applies only when **both** are true:
- the player is collapsed: current route does **not** start with `/player/` (`onPlayer == false`), and
- the layout is narrow: `MediaQuery.sizeOf(context).width <= tokens.breakpointTranscriptSideBySide`.

When the player is expanded (`onPlayer == true`) or the layout is wide, this contract is inert (the wide layout already has its own meta-row tap-to-expand and artwork-tile tap, unchanged by this feature — FR-010).

## Behavioral contract

### E1. Neutral-area tap expands

Tapping a **neutral** (non-interactive) area of the controls row expands the player by calling `openPlayerRoute(context, chrome.mediaId)`. This MUST work at every supported width, including the smallest phone width where `showExpand == false`.

### E2. Interactive controls do not expand

Tapping any of these performs **only** that control's own action and MUST NOT expand: play/pause, previous, next, echo, blur, subtitle (CC), speed, volume, and the expand icon (when `showExpand == true`). (Relies on Flutter's gesture arena: child `IconButton` / play-ring `InkWell` consume their own taps.)

### E3. Seek strip does not expand

Interacting with the progress/seek strip (`TransportProgressStrip`) MUST seek (or do nothing on empty regions) and MUST NOT expand. The expand tap surface MUST NOT include the seek strip — scope it to the controls row.

### E4. No interference with dismiss

The existing collapsed-mini swipe-down-to-dismiss (`Dismissible(direction: DismissDirection.down)`) MUST continue to work. Tap (expand) and vertical drag (dismiss) are distinct gestures; the expand surface MUST NOT consume or block the dismiss gesture.

### E5. Feedback and affordance

- **Haptics**: expanding fires `Haptics.selection` (matching `TransportArtworkTile` and the wide meta-row).
- **Primitive**: use the shared `EnjoyTappableSurface` (Material ripple + hover scale + `Focus` + click cursor + `Semantics`) so presentation stays consistent with the rest of the app (Constitution III).
- **Semantics**: the surface exposes a button semantics label using the existing localized `transportExpand` ("Expand player" / "展开播放器").

### E6. Keyboard parity

No new hotkey required. The existing `player.toggleExpand` hotkey already calls `openPlayerRoute` when the user is not on the player route (`lib/features/hotkeys/presentation/app_hotkeys_keyboard_listener.dart`). The expand surface's `Focus` makes it keyboard-reachable as a secondary path.

### E7. No-op when already expanded

When `onPlayer == true`, no expand action or expand icon is offered (FR-011). Tapping the controls bar background does nothing extra.

## Test obligations (widget tests)

- **E1**: collapsed mini at 320 dp (expand icon hidden) → tap a neutral point of the controls row → assert navigation to `/player/:id`.
- **E2**: collapsed mini → tap play, echo (and other visible controls) → assert the control's effect fires and the route does **not** change.
- **E3**: collapsed mini → tap/drag the seek strip → assert seek behavior and no route change.
- **E4**: collapsed mini → swipe down → assert the mini is dismissed (existing behavior preserved).
- **E7**: expanded player route → tap controls background → assert no navigation / no error.
- **FR-010 no-regression**: wide layout (≥720 dp) collapsed mini → assert the existing meta-row tap and full control set behave as before.

## Manual verification

See `quickstart.md` for the device/rotation smoke test that complements these automated checks (TalkBack/VoiceOver announcement of the expand label, rotation smoothness).
