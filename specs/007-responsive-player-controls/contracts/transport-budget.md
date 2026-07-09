# Contract: `resolveNarrowTransportBudget` (pure function)

**Feature**: 007-responsive-player-controls | **Location**: `lib/features/player/presentation/widgets/global_transport_bar.dart`

This is the core testable unit of the responsive behavior. It is a **pure function** with no side effects, no widget access, and no provider reads — fully unit-testable without a Flutter binding.

## Signature

```text
NarrowTransportBudget resolveNarrowTransportBudget(
  double maxWidth, {
  required bool hasTranscriptLines,
  required bool onPlayer,
  required bool showFullscreenTransport,
})
```

## Inputs

| Parameter | Meaning |
|-----------|---------|
| `maxWidth` | Inner width available to the controls row, in logical px (after horizontal padding). On a 320 dp device this is ~296. |
| `hasTranscriptLines` | A primary transcript is loaded. Gates previous/next eligibility. |
| `onPlayer` | Current route starts with `/player/`. Gates expand-icon eligibility. |
| `showFullscreenTransport` | Desktop-video fullscreen button is eligible. |

## Output

A `NarrowTransportBudget` with boolean visibility flags (see `data-model.md`): `showPrevious`, `showNext` (independent), `showEcho`, `showBlur`, `showCc`, `showSpeed`, `showVolume`, `showFullscreen`, `showExpand`.

## Behavioral contract

### C1. Always-on invariant

`showEcho`, `showBlur`, `showCc`, `showSpeed` MUST be `true` for **every** combination of inputs and every `maxWidth` on a supported device (smallest supported inner width ~296 px > always-on base 234 px). Play/pause is rendered unconditionally outside this struct.

### C2. Eligibility gating

- `!hasTranscriptLines` ⇒ `showPrevious == false && showNext == false`.
- `onPlayer` ⇒ `showExpand == false`.
- `!showFullscreenTransport` ⇒ `showFullscreen == false`.

### C3. Drop ordering (as `maxWidth` shrinks)

Droppables turn `false` in this exact order — first listed is dropped first:

1. `showExpand` (only when eligible)
2. `showPrevious` (only when eligible)
3. `showNext` (only when eligible)
4. `showVolume`
5. `showFullscreen` (only when eligible)

As `maxWidth` grows, they reappear in reverse order. Equivalently, droppables are packed **highest priority first** (fullscreen → volume → next → previous → expand), and the first one that does not fit terminates packing.

### C4. Strict priority

A higher-priority droppable MUST NOT be `false` while a lower-priority droppable is `true` (when both are eligible). Example violation to reject: `showVolume == false` but `showNext == true`.

### C5. Per-control width cost

- Always-on base: `kNarrowPlayRingWidth` (54) + `kNarrowLayoutSlack` (8) + 3 × `kNarrowIconSlotWidth` (echo/blur/cc, 120) + (`kNarrowIconSlotWidth + kNarrowSpeedSlotExtra`) (speed, 52) = **234**.
- Each standalone droppable (volume, fullscreen, expand): `kNarrowIconSlotWidth` = **40**.
- `previous` / `next`: `kNarrowIconSlotWidth + kNarrowLineNavGap` = **44** each (the gap flanks the play ring).

### C6. Determinism

The function MUST be deterministic and total. Same inputs ⇒ same output. It MUST NOT throw for any non-negative `maxWidth` (including 0 and very small values — below the base, only the always-on set is reported `true` and droppables are all `false`; overflow handling at sub-minimum widths is the widget's concern, not the function's).

## Representative expected values (reference, not exhaustive)

Assuming `hasTranscriptLines: true`, `onPlayer: false`, `showFullscreenTransport: false` (typical phone, collapsed mini):

| `maxWidth` | prev | next | echo | blur | cc | speed | volume | expand | Notes |
|-----------:|:----:|:----:|:----:|:----:|:--:|:-----:|:------:|:------:|-------|
| 296 (320 dp phone) | ✗ | ✗ | ✓ | ✓ | ✓ | ✓ | ✓ | ✗ | 5 always-on + volume fit |
| 254 | ✗ | ✗ | ✓ | ✓ | ✓ | ✓ | ✗ | ✗ | volume just dropped (base+40=274) |
| 234 | ✗ | ✗ | ✓ | ✓ | ✓ | ✓ | ✗ | ✗ | exactly the always-on base |
| 340 | ✗ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✗ | next fits (base+40+44=318) |
| 384 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✗ | prev fits (base+40+44+44=362) |
| 424 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | expand fits (base+40+44+44+40=402) |

> The exact threshold widths are derived from the constants in C5; the unit tests assert the **flag pattern** across a swept range rather than hard-coding pixel thresholds, so the contract stays stable if constants are tuned.

## Test obligations

- Assert C1 across a swept `maxWidth` range (e.g. 200 → 500) for player + mini routes.
- Assert C3 ordering: at decreasing widths, flags turn false in expand → prev → next → volume order.
- Assert C4 (no priority inversion) for all sampled widths.
- Assert C2 for `hasTranscriptLines: false` and `onPlayer: true`.
- Assert C6 determinism (call twice, expect equal).
