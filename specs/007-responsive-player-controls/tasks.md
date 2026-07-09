---

description: "Task list for responsive player controls & collapsed-expand recovery"
---

# Tasks: Responsive Player Controls & Collapsed-Expand Recovery

**Input**: Design documents from `/specs/007-responsive-player-controls/`

**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/transport-budget.md, contracts/collapsed-expand.md, quickstart.md

**Tests**: Automated tests are **required** for all changed behavior (Constitution II; plan.md §II). Tasks follow TDD ordering within each story: write/extend the failing test first, then implement.

**Organization**: Tasks are grouped by user story. US1, US2, US3 all edit `lib/features/player/presentation/widgets/global_transport_bar.dart` (and its narrow branch), so the stories are **sequential**, not parallel, despite all being P1. US4 adds cross-cutting verification + docs. See Dependencies.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3, US4)
- Include exact file paths in descriptions

## Path Conventions

- **Feature code**: `lib/features/player/presentation/widgets/` (transport bar + `transport/` widgets)
- **Shared code**: `lib/core/interaction/` (`EnjoyTappableSurface`, `Haptics`), `lib/core/routing/player_navigation.dart`
- **Tests**: `test/features/player/`
- **Feature docs**: `docs/features/player.md`
- **ADRs**: `docs/decisions/0035-responsive-transport-priorities.md`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Establish the baseline and identify doc/ADR touchpoints. No code changes.

- [X] T001 Audit current responsive behavior and encode the regression baseline: read `resolveNarrowTransportBudget` + the narrow branch in `lib/features/player/presentation/widgets/global_transport_bar.dart` against `test/features/player/narrow_transport_budget_test.dart` and `test/features/player/global_transport_bar_test.dart`, and record that today prev/next are reserved first while expand/volume drop first (the behavior this feature inverts).
- [X] T002 [P] Identify documentation and decision touchpoints: the "Line-level transport" note in `docs/features/player.md` (to be rewritten) and the candidate ADR `docs/decisions/0022-responsive-transport-priorities.md` (per plan.md QR-005).

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Split the budget data model into independent `showPrevious`/`showNext` flags so every story can read/write them. This is the shared foundation US1/US2 build behavior on and US3/US4 read from.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete (the model API must exist).

- [X] T003 Refactor `NarrowTransportBudget` in `lib/features/player/presentation/widgets/global_transport_bar.dart`: replace the single `showPrevNext` field with independent `showPrevious` and `showNext`, and update `resolveNarrowTransportBudget`'s return + the narrow-branch call site so the app compiles **behavior-preserving** (both flags mirror the old `showPrevNext` value; no ordering change yet).
- [X] T004 Update existing field references from `showPrevNext` to `showPrevious`/`showNext` (expectations still reflecting OLD behavior) in `test/features/player/narrow_transport_budget_test.dart` and `test/features/player/global_transport_bar_test.dart` so the suite compiles green against T003. (Depends on T003.)

**Checkpoint**: Foundation ready — independent prev/next flags exist; `flutter analyze` and `flutter test` are green with unchanged behavior.

---

## Phase 3: User Story 1 - Core learning controls always fit on small phones (Priority: P1) 🎯 MVP

**Goal**: On the narrowest supported phone width, play/pause, echo, blur, subtitle (CC), and speed are always visible and tappable in the controls bar — on both the player route and the collapsed mini-player — with no overflow.

**Independent Test**: Load a media item with a transcript at ~320 dp; assert all five always-on controls render (no overflow) on both `/player/:id` and the library mini-player. See `contracts/transport-budget.md` C1 and `quickstart.md` Scenario B.

### Tests for User Story 1

> Write these FIRST; they MUST fail before T007/T008.

- [X] T005 [P] [US1] Add unit tests asserting the always-on invariant (`showEcho`/`showBlur`/`showCc`/`showSpeed` are `true` across a swept width 200–500 px on player and mini routes) and eligibility gating (`hasTranscriptLines:false` ⇒ prev/next `false`; `onPlayer:true` ⇒ expand `false`) in `test/features/player/narrow_transport_budget_test.dart`.
- [X] T006 [P] [US1] Add widget test asserting play/pause, echo, blur, subtitle (CC), and speed icons are all found at 320 px on both the player route and the library mini route with `tester.takeException()` null in `test/features/player/global_transport_bar_test.dart`.

### Implementation for User Story 1

- [X] T007 [US1] Rewrite `resolveNarrowTransportBudget` in `lib/features/player/presentation/widgets/global_transport_bar.dart` to enforce the always-on base (play ring + slack + echo + blur + cc + speed ≈ 234 px) and greedily pack droppables in strict priority order (fullscreen → volume → next → previous → expand), per `contracts/transport-budget.md` C1–C6. (Depends on T005.)
- [X] T008 [US1] Update the narrow-branch rendering in `lib/features/player/presentation/widgets/global_transport_bar.dart` so echo/blur/cc/speed are rendered unconditionally and prev/next/expand/volume/fullscreen follow the budget flags, including the cluster-collapse cases (prev+play+next, play+next, play-alone) with no dangling gaps. (Depends on T007; same file.)

**Checkpoint**: User Story 1 fully functional — the five always-on controls fit at the smallest width with no overflow, on both routes.

---

## Phase 4: User Story 2 - Least-valuable controls drop in the right order (Priority: P1)

**Goal**: As width shrinks, controls disappear in the exact order previous → next → volume (fullscreen last, desktop-video only); previous hides before next; the always-on five never drop.

**Independent Test**: Sweep `resolveNarrowTransportBudget` across decreasing widths and assert the flag-false sequence `showExpand → showPrevious → showNext → showVolume → showFullscreen` with no priority inversion; widget-test the visible sequence at 320/375/430 px. See `contracts/transport-budget.md` C3–C4 and `quickstart.md` Scenario A.

### Tests for User Story 2

- [X] T009 [P] [US2] Add unit tests asserting the exact drop order across a width sweep, that `showPrevious` turns false before `showNext`, strict-priority (no droppable survives while a higher-priority one is dropped), and determinism (two calls equal) in `test/features/player/narrow_transport_budget_test.dart`.
- [X] T010 [P] [US2] Add widget test asserting the visible drop sequence — previous gone before next before volume — across 320/375/430 px widths and that the prev-only state never occurs — in `test/features/player/global_transport_bar_test.dart`.

### Implementation for User Story 2

- [X] T011 [US2] Finalize/tune the ordering in `lib/features/player/presentation/widgets/global_transport_bar.dart` so the swept drop-order tests pass — confirm prev/next gap accounting (`kNarrowLineNavGap`) and slot widths (`kNarrowIconSlotWidth`, `kNarrowSpeedSlotExtra`) produce the contract thresholds, and remove any residual cluster logic that could invert priority. (Depends on T009, T010.)

**Checkpoint**: User Stories 1 AND 2 both hold — always-on five fit, and the drop order is pinned and verified.

---

## Phase 5: User Story 3 - A collapsed player can always be expanded again (Priority: P1)

**Goal**: From the collapsed mini-player on any supported width (including where the expand icon is dropped), tapping a neutral area of the controls bar opens the full player; interactive controls and the seek strip keep their own behavior; swipe-down dismiss is preserved.

**Independent Test**: Collapse to the mini bar at 320 px (expand icon hidden), tap a neutral point of the controls row, and assert navigation to `/player/:id`; then tap each visible control and the seek strip and assert no navigation; swipe down and assert dismiss. See `contracts/collapsed-expand.md` E1–E4 and `quickstart.md` Scenario C.

### Tests for User Story 3

- [X] T012 [P] [US3] Add widget tests in `test/features/player/global_transport_bar_test.dart`: (a) neutral-area tap expands at 320 px with expand icon hidden; (b) tapping play/echo/other visible controls fires only that control (no route change); (c) interacting with the seek strip does not navigate; (d) swipe-down dismiss still works; (e) tapping the controls background on the player route is a no-op.

### Implementation for User Story 3

- [X] T013 [US3] Wrap the collapsed (`!onPlayer`) narrow controls row — not the seek strip — in `EnjoyTappableSurface` with `onTap → openPlayerRoute(context, chrome.mediaId)`, `Haptics.selection`, and a `Semantics` label, in `lib/features/player/presentation/widgets/global_transport_bar.dart`; rely on the gesture arena so child `IconButton`s / the play-ring `InkWell` / seek strip consume their own taps, and ensure the `Dismissible` swipe-down still receives vertical drags. (Depends on T012.)

**Checkpoint**: User Stories 1, 2, AND 3 all hold — the mini-player is never a dead-end on any width.

---

## Phase 6: User Story 4 - Discoverability, accessibility, and no wide-layout regression (Priority: P2)

**Goal**: The expand affordance is announced with a localized label and keyboard-reachable; icon tooltips are intact; wide layouts (≥720 px) are visually and behaviorally identical to before this feature.

**Independent Test**: At ≥720 px collapsed mini, assert the full control set renders and the existing meta-row tap opens the player; assert the expand tap zone exposes the `transportExpand` semantics label; confirm the `player.toggleExpand` hotkey still opens the route when not on the player. See `contracts/collapsed-expand.md` E5–E6 and `quickstart.md` Scenario D / M4.

### Tests for User Story 4

- [X] T014 [US4] Add widget test in `test/features/player/global_transport_bar_test.dart` asserting the wide-layout (≥720 px) collapsed mini renders the full control set and the existing meta-row tap target opens the player (no regression vs. pre-feature).
- [X] T015 [US4] Add widget test in `test/features/player/global_transport_bar_test.dart` asserting the collapsed narrow expand tap zone exposes the localized `transportExpand` semantics label and that icon-only controls retain their tooltips. (Depends on T014; same file.)

### Implementation for User Story 4

- [X] T016 [US4] Verify/ensure the expand tap zone in `lib/features/player/presentation/widgets/global_transport_bar.dart` uses the localized `transportExpand` via `AppLocalizations` for its `Semantics` label (reusing the existing ARB key — no new strings) and that `EnjoyTappableSurface` provides focus/hover; read-only confirm the `player.toggleExpand` hotkey path in `lib/features/hotkeys/presentation/app_hotkeys_keyboard_listener.dart` is unchanged.
- [X] T017 [P] [US4] Rewrite the "Line-level transport" and collapsed-mini behavior note in `docs/features/player.md` to state the new drop order (previous → next → volume) and the neutral-area tap-to-expand affordance. (Different file from T016; can run in parallel with it.)

**Checkpoint**: All four user stories complete; accessibility and wide-layout parity verified.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Traceability, full-suite verification, and validation against the quickstart guide.

- [X] T018 [P] Add the optional ADR `docs/decisions/0035-responsive-transport-priorities.md` recording the responsive drop-priority model and the tap-to-expand affordance (plan.md QR-005 marks this SHOULD).
- [X] T019 Run the automated validation scenarios A–D from `specs/007-responsive-player-controls/quickstart.md` and confirm all pass with no overflow exceptions.
- [X] T020 Run `flutter analyze` from repo root and resolve any new diagnostics introduced by this feature.
- [X] T021 Run `flutter test` from repo root and confirm the full suite is green. (`dart run build_runner build` is **not** required — no Drift/`@riverpod` changes in this feature.)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately.
- **Foundational (Phase 2)**: Depends on Setup — **BLOCKS** all user stories (model API must exist).
- **User Stories (Phase 3–6)**: Sequential because US1–US3 all edit `lib/features/player/presentation/widgets/global_transport_bar.dart` and its narrow branch.
- **Polish (Phase 7)**: Depends on all user stories being complete.

### User Story Dependencies

- **US1 (P1, MVP)**: After Foundational. No dependency on other stories. Implements the budget rewrite + always-on rendering.
- **US2 (P1)**: After US1. Builds on US1's rewritten resolver to pin/verify the exact drop order. Independently testable (its swept unit tests run against the resolver).
- **US3 (P1)**: After US2 (same file/narrow branch). Logically independent (different concern: expand affordance) but shares the file, so ordered.
- **US4 (P2)**: After US1 + US3. Verifies a11y + wide-layout no-regression on the finished bar; updates docs.

### Within Each User Story

- Tests written/extended FIRST and confirmed failing before implementation.
- Pure-function logic before widget rendering.
- Story checkpoint green before the next story.

### Parallel Opportunities

- T001 ∥ T002 (both read-only analysis, different focus).
- T005 ∥ T006 (different test files); T009 ∥ T010 (different test files).
- T016 ∥ T017 (different files: `global_transport_bar.dart` vs `docs/features/player.md`).
- T018 ∥ T019 ∥ T020 are independent polish activities (ADR, quickstart run, analyze) — but T021 (full `flutter test`) must run last.

> Note: within a single test file, multiple test tasks (e.g. T014 then T015) are sequential (same-file edit), so they are not marked `[P]`.

---

## Parallel Example: User Story 1

```bash
# Launch US1 test-writing tasks together (different files, no dependencies):
Task: "T005 always-on + eligibility unit tests in test/features/player/narrow_transport_budget_test.dart"
Task: "T006 five-render-at-320 widget test in test/features/player/global_transport_bar_test.dart"

# After both fail, implement sequentially (same source file):
Task: "T007 rewrite resolveNarrowTransportBudget in lib/features/player/presentation/widgets/global_transport_bar.dart"
Task: "T008 narrow-branch rendering + cluster-collapse in lib/features/player/presentation/widgets/global_transport_bar.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 (Setup) + Phase 2 (Foundational model split).
2. Complete Phase 3 (US1): always-on five fit on the smallest phone, both routes.
3. **STOP and VALIDATE**: `flutter test test/features/player/` green; manual smoke at 320 dp (quickstart M1).
4. Ship/demo — the headline defect (practice tools pushed off-screen) is fixed.

### Incremental Delivery

1. Setup + Foundational → independent prev/next flags exist.
2. + US1 → five always-on controls fit (MVP).
3. + US2 → drop order pinned (prev → next → volume).
4. + US3 → collapsed expand never a dead-end.
5. + US4 → a11y + wide-layout no-regression + docs.
6. Polish → ADR, full `flutter analyze` / `flutter test`, quickstart validation.

### Solo-developer note

Because US1–US3 share one source file and one narrow branch, a single contributor should work them in strict order (US1 → US2 → US3 → US4). The `[P]` marks mainly enable parallelizing test-writing across the two test files within a story.

---

## Notes

- `[P]` tasks = different files, no dependencies.
- `[Story]` label maps a task to its user story for traceability.
- The existing tests `narrow_transport_budget_test.dart` and `global_transport_bar_test.dart` currently encode the OLD behavior (prev/next reserved first, expand/volume defer first); they are rewritten across US1–US2.
- No new persisted data, providers, engine surface, or ARB keys; `transportExpand` is reused.
- `dart run build_runner build` is intentionally NOT in the plan (no Drift/`@riverpod` changes).
- Commit after each task or logical group; stop at any checkpoint to validate a story independently.
