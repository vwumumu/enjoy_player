# Data Model: Responsive Player Controls & Collapsed-Expand Recovery

**Feature**: 007-responsive-player-controls | **Date**: 2026-07-09

This feature introduces **no persisted data** and **no new domain models**. The only structured artifact is the derived, per-layout `NarrowTransportBudget` decision produced by the pure `resolveNarrowTransportBudget` function, plus the behavioral `CollapsedExpandAffordance` contract. Both are ephemeral (recomputed every build from live inputs) and never stored.

---

## Entity: `NarrowTransportBudget`

**Kind**: Pure value object (derived, not persisted). Output of `resolveNarrowTransportBudget`.

**Purpose**: Decides which controls the narrow transport bar renders at a given available width, enforcing the always-on invariant and the drop priority.

### Fields

| Field | Type | Source / rule |
|-------|------|---------------|
| `showPrevious` | `bool` | Independently droppable. `false` when no transcript or when width is tight (drops 4th-highest priority; see Ordering). |
| `showNext` | `bool` | Independently droppable. `false` when no transcript or when width is tight (drops after previous). |
| `showEcho` | `bool` | **Always-on** (`true` unconditionally). Control may still render disabled per existing rules. |
| `showBlur` | `bool` | **Always-on** (`true` unconditionally). |
| `showCc` | `bool` | **Always-on** (`true` unconditionally). |
| `showSpeed` | `bool` | **Always-on** (`true` unconditionally). |
| `showVolume` | `bool` | Droppable. Drops after next, before fullscreen. |
| `showFullscreen` | `bool` | Droppable. Only eligible when `showFullscreenTransport` (desktop video). Highest priority among droppables. |
| `showExpand` | `bool` | Droppable. Only eligible when `!onPlayer`. Lowest priority (drops first). |

> **Migration note**: the current type exposes a single `showPrevNext` flag. This field is **split** into independent `showPrevious` / `showNext` to satisfy FR-002 (previous hides before next). All call sites and tests are updated accordingly.

### Inputs (to the resolver)

| Input | Type | Meaning |
|-------|------|---------|
| `maxWidth` | `double` | Inner width available to the controls row (inside horizontal padding), from `LayoutBuilder`. |
| `hasTranscriptLines` | `bool` | Whether a primary transcript is loaded; gates prev/next eligibility. |
| `onPlayer` | `bool` | Whether the current route is `/player/:id` (expanded) vs collapsed mini. Gates expand eligibility. |
| `showFullscreenTransport` | `bool` | Desktop-video fullscreen button eligibility. |

### Validation rules (invariants)

- **Always-on invariant (FR-001, FR-003)**: `showEcho && showBlur && showCc && showSpeed` MUST be `true` for every input. (Play/pause is rendered unconditionally outside this struct.) These MUST NOT become `false` for any `maxWidth` on a supported device.
- **Drop ordering (FR-002, FR-004)**: as `maxWidth` decreases, flags MUST turn `false` in this order (first dropped first): `showExpand` → `showPrevious` → `showNext` → `showVolume` → `showFullscreen`. Equivalently, as width increases they reappear in reverse.
- **Strict priority**: a higher-priority droppable MUST NOT be dropped while a lower-priority droppable is still shown.
- **Eligibility gating**: when `!hasTranscriptLines`, `showPrevious == showNext == false`. When `onPlayer`, `showExpand == false`. When `!showFullscreenTransport`, `showFullscreen == false`.
- **No partial clusters**: play/pause is always rendered; if both prev and next are hidden the cluster collapses to just the play ring (no dangling gaps).

### Slot width constants (unchanged, reused)

| Constant | Value | Used for |
|----------|------:|----------|
| `kNarrowPlayRingWidth` | 54 | Play/pause ring (always-on base) |
| `kNarrowIconSlotWidth` | 40 | Each icon slot (echo, blur, cc, volume, fullscreen, expand, prev, next) |
| `kNarrowSpeedSlotExtra` | 12 | Speed slot = 40 + 12 = 52 (room for the rate badge) |
| `kNarrowLayoutSlack` | 8 | Safety margin (always-on base) |
| `kNarrowLineNavGap` | 4 | Gap between play ring and prev/next when present |

Derived **always-on base cost** = 54 + 8 + 40 + 40 + 40 + 52 = **234 px** (play + echo + blur + cc + speed + slack).

### State transitions

None — the value is recomputed purely from inputs on every layout pass. There is no lifecycle, no caching, no mutation.

---

## Entity: `CollapsedExpandAffordance`

**Kind**: Behavioral contract (not a data structure). No fields, no persistence.

**Purpose**: Guarantees that a collapsed mini-player (`!onPlayer`) can always be expanded on every supported width, even when the expand icon does not fit.

### Contract summary (detailed in `contracts/collapsed-expand.md`)

- When collapsed **and** narrow: tapping a neutral (non-interactive) area of the controls row expands → `openPlayerRoute(context, chrome.mediaId)`.
- Interactive controls (play, prev, next, echo, blur, cc, speed, volume, expand icon when visible) consume their own taps and MUST NOT expand.
- The seek/progress strip MUST NOT expand.
- Keyboard parity: the existing `player.toggleExpand` hotkey opens the route when not on the player.
- Semantics: the tap surface exposes a localized button label (`transportExpand`).

### Relationships

- Reuses existing route navigation (`openPlayerRoute`), existing `PlaybackChrome.mediaId`, existing `Haptics.selection` feedback, and the shared `EnjoyTappableSurface` primitive.
- No relationship to persistence, sync, or playback-engine layers.

---

## Entities explicitly out of scope

- No new Drift tables, columns, or migrations.
- No new Riverpod providers or `@riverpod` annotations (→ no `build_runner` run).
- No new localized strings required (reuses `transportExpand`); an optional descriptive label may be added later without schema impact.
- No changes to `PlayerUi`, `PlayerController`, `PlayerEngine`, or any domain `PlaybackSession`/`EchoWindow` model.
