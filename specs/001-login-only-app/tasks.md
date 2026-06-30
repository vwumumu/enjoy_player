---
description: "Task list for login-only application access"
---

# Tasks: Login-Only Application Access

**Input**: Design documents from `/specs/001-login-only-app/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: Required per plan Constitution Check — unit tests for `auth_redirect.dart`, widget tests for sign-in welcome UI.

**Organization**: Tasks grouped by user story (US1–US5) plus guest-migration removal and polish.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Maps to user stories in spec.md (US1–US5)

## Path Conventions

- **Routing**: `lib/core/routing/`
- **Auth UI**: `lib/features/auth/presentation/`
- **Tests**: `test/core/routing/`, `test/features/auth/`
- **Docs**: `docs/features/auth.md`, `docs/decisions/0028-login-only-access.md`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirm design artifacts and implementation targets before coding.

- [x] T001 Review spec, plan, contracts, and quickstart in `specs/001-login-only-app/`
- [x] T002 [P] Inventory guest-migration touchpoints: `lib/features/library/presentation/home_screen.dart`, `lib/features/settings/presentation/settings_screen.dart`, `test/features/auth/guest_migration_discover_test.dart`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Pure redirect resolver and test scaffold — MUST complete before user story phases.

**⚠️ CRITICAL**: No user story work until this phase is complete.

- [x] T003 Create `resolveAuthRedirect` and `encodeSignInFrom` in `lib/core/routing/auth_redirect.dart` per `specs/001-login-only-app/contracts/auth-gate-routing.md`
- [x] T004 [P] Create `resolvePostSignInPath` for `from` query decoding in `lib/core/routing/auth_redirect.dart`
- [x] T005 [P] Create test scaffold with redirect matrix cases in `test/core/routing/auth_redirect_test.dart`

**Checkpoint**: Redirect helpers exist and test file compiles (tests may fail until wired).

---

## Phase 3: User Story 1 — Sign in before using the app (Priority: P1) 🎯 MVP

**Goal**: Signed-out users can only reach the welcome sign-in flow; all primary app routes are gated.

**Independent Test**: Launch signed out → lands on `/sign-in`; navigating to `/`, `/library`, `/discover`, `/settings` redirects to sign-in.

### Tests for User Story 1

- [x] T006 [P] [US1] Add unit tests for signed-out protected-route redirects in `test/core/routing/auth_redirect_test.dart`
- [x] T007 [P] [US1] Add unit tests for auth-loading redirect (no home flash) in `test/core/routing/auth_redirect_test.dart`

### Implementation for User Story 1

- [x] T008 [US1] Wire `resolveAuthRedirect` into redirect callback in `lib/core/routing/app_router.dart`
- [x] T009 [US1] Move `/sign-in` and `/sign-in/email` GoRoutes outside `ShellRoute` in `lib/core/routing/app_router.dart`
- [x] T010 [US1] Ensure unsigned allowlist only includes sign-in routes in `lib/core/routing/auth_redirect.dart`
- [x] T011 [US1] Run `dart run build_runner build` if `app_router.g.dart` requires regeneration

**Checkpoint**: Signed-out cold start and direct navigation to protected routes redirect to sign-in with no shell chrome.

---

## Phase 4: User Story 2 — Seamless return for signed-in users (Priority: P1)

**Goal**: Valid session cold start reaches home without sign-in screen.

**Independent Test**: Sign in, restart app → lands on `/` with no `/sign-in` redirect.

### Tests for User Story 2

- [x] T012 [P] [US2] Add unit tests for signed-in no-redirect and `/sign-in` bounce in `test/core/routing/auth_redirect_test.dart`

### Implementation for User Story 2

- [x] T013 [US2] Verify signed-in users skip auth gate for `/`, `/library`, `/discover`, `/settings` in `lib/core/routing/auth_redirect.dart`
- [x] T014 [US2] Confirm auth-loading resolves to signed-in without intermediate sign-in flash in `lib/core/routing/app_router.dart`

**Checkpoint**: Returning signed-in users enter main app directly (SC-002, SC-003).

---

## Phase 5: User Story 5 — Friendly welcome and smooth sign-in (Priority: P1)

**Goal**: Single-screen welcome hub with approachable copy and no guest bypass controls.

**Independent Test**: Signed-out user sees headline, subtitle, sign-in actions; no cancel/close to home.

### Tests for User Story 5

- [x] T015 [P] [US5] Add widget test for welcome copy visibility in `test/features/auth/presentation/sign_in_screen_test.dart`
- [x] T016 [P] [US5] Add widget test asserting no cancel/close-to-home controls in `test/features/auth/presentation/sign_in_screen_test.dart`

### Implementation for User Story 5

- [x] T017 [P] [US5] Update `authSignInTitle` and `authSignInSubtitle` in `lib/l10n/app_en.arb`
- [x] T018 [P] [US5] Update `authSignInTitle` and `authSignInSubtitle` in `lib/l10n/app_zh.arb`
- [x] T019 [US5] Run `flutter gen-l10n` after ARB changes
- [x] T020 [US5] Remove AppBar close button and `_close` home escape in `lib/features/auth/presentation/sign_in_screen.dart`
- [x] T021 [US5] Remove `authCancel` ghost button from `_SignInHub` in `lib/features/auth/presentation/sign_in_screen.dart`
- [x] T022 [US5] Keep email OTP back navigation to hub only (not home) in `lib/features/auth/presentation/sign_in_screen.dart`

**Checkpoint**: Welcome screen matches `specs/001-login-only-app/contracts/sign-in-welcome-ui.md`.

---

## Phase 6: User Story 4 — Preserve intended destination after sign-in (Priority: P2)

**Goal**: Deep links and protected routes restore after successful authentication.

**Independent Test**: Signed out → open `/profile` → sign in → arrive at `/profile`.

### Tests for User Story 4

- [x] T023 [P] [US4] Add unit tests for `from` encoding and `resolvePostSignInPath` in `test/core/routing/auth_redirect_test.dart`

### Implementation for User Story 4

- [x] T024 [US4] Append `?from=` when redirecting unsigned users in `lib/core/routing/auth_redirect.dart`
- [x] T025 [US4] Navigate to `resolvePostSignInPath(from)` on `AuthSignedIn` in `lib/features/auth/presentation/sign_in_screen.dart`
- [x] T026 [US4] Support shorthands `profile`, `credits`, and encoded full paths per contract in `lib/core/routing/auth_redirect.dart`

**Checkpoint**: QS-4 in `specs/001-login-only-app/quickstart.md` passes.

---

## Phase 7: User Story 3 — Sign out returns to login gate (Priority: P2)

**Goal**: Sign-out ends session; user cannot access app without re-authenticating.

**Independent Test**: Sign in → sign out → only sign-in reachable.

### Tests for User Story 3

- [x] T027 [P] [US3] Add unit test that signed-out state redirects all protected routes in `test/core/routing/auth_redirect_test.dart`

### Implementation for User Story 3

- [x] T028 [US3] Verify `authCtrlProvider` sign-out triggers router refresh via `lib/core/routing/auth_router_tick.dart`
- [x] T029 [US3] Confirm sign-out from `lib/features/auth/presentation/profile_screen.dart` leaves user on gated sign-in (no home fallback)

**Checkpoint**: QS-5 in quickstart passes; back/deep link while signed out stays on sign-in.

---

## Phase 8: Guest Migration Removal (FR-008)

**Purpose**: Remove legacy guest migration UI and providers (pre-production; out of scope per spec).

- [x] T030 [P] Delete `lib/features/auth/presentation/guest_migration_banner.dart`
- [x] T031 [P] Delete `lib/features/auth/application/guest_migration_providers.dart` and `lib/features/auth/application/guest_migration_providers.g.dart`
- [x] T032 Remove `GuestMigrationBanner` import and widget from `lib/features/library/presentation/home_screen.dart`
- [x] T033 Remove guest migration section and imports from `lib/features/settings/presentation/settings_screen.dart`
- [x] T034 Delete `test/features/auth/guest_migration_discover_test.dart`
- [x] T035 [P] Remove unused migration l10n keys from `lib/l10n/app_en.arb` and `lib/l10n/app_zh.arb`
- [x] T036 Run `flutter gen-l10n` after migration key removal
- [x] T037 Run `dart run build_runner build` after deleting `@Riverpod` guest migration providers

**Checkpoint**: No guest migration banner on home or settings; FR-008 satisfied.

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Documentation, verification, and quality gates.

- [x] T038 [P] Write ADR in `docs/decisions/0031-login-only-access.md`
- [x] T039 [P] Update login-only behavior in `docs/features/auth.md`
- [x] T040 [P] Remove guest/migration references in `docs/features/settings.md`
- [x] T041 [P] Add ADR-0031 row to `docs/decisions/README.md`
- [x] T042 Run `flutter analyze`
- [x] T043 Run `flutter test`
- [x] T044 Execute manual scenarios QS-1 through QS-9 in `specs/001-login-only-app/quickstart.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies
- **Foundational (Phase 2)**: Depends on Setup — **blocks all user stories**
- **US1 (Phase 3)**: Depends on Foundational — **MVP**
- **US2 (Phase 4)**: Depends on Foundational; best after US1 redirect wiring
- **US5 (Phase 5)**: Depends on US1 (sign-in route outside shell); can parallel with US2 after US1
- **US4 (Phase 6)**: Depends on US1 redirect + sign-in screen
- **US3 (Phase 7)**: Depends on US1 global gate
- **Guest removal (Phase 8)**: Independent after inventory (T002); can parallel with US5/US4
- **Polish (Phase 9)**: Depends on all desired phases complete

### User Story Dependencies

| Story | Depends on | Notes |
|-------|------------|-------|
| US1 | Foundational | Core gate — MVP |
| US2 | Foundational, US1 | Signed-in path through same redirect helper |
| US5 | US1 | Sign-in screen must be gate entry |
| US4 | US1, US5 | Post-sign-in navigation on sign-in screen |
| US3 | US1 | Sign-out verified against global gate |

### Within Each User Story

- Tests before or alongside implementation (redirect tests can precede wiring)
- Router changes before sign-in UI polish
- Story checkpoint before moving to next priority

### Parallel Opportunities

**After Phase 2 completes:**

```text
Stream A (gate):     T006 → T007 → T008 → T009 → T010
Stream B (welcome):  T017 → T018 → (wait T009) → T020 → T021
Stream C (migration): T030 → T031 → T032 → T033 → T034  (independent)
```

**Within US5:**

```text
T015 ∥ T016 ∥ T017 ∥ T018  (tests + ARB in parallel)
```

---

## Parallel Example: User Story 1

```bash
# Tests first (parallel):
T006: signed-out redirect tests in test/core/routing/auth_redirect_test.dart
T007: auth-loading redirect tests in test/core/routing/auth_redirect_test.dart

# Then sequential wiring:
T008 → T009 → T010 → T011
```

---

## Implementation Strategy

### MVP First (User Story 1 only)

1. Complete Phase 1–2 (Setup + Foundational)
2. Complete Phase 3 (US1 — auth gate)
3. **STOP and VALIDATE**: QS-1 and QS-3 from quickstart
4. Demo login-only gate

### Incremental Delivery

1. Setup + Foundational → redirect helper ready
2. **US1** → signed-out gate works (MVP)
3. **US2** → signed-in cold start unchanged
4. **US5** → friendly welcome, no escape hatches
5. **US4** → deep link `from` restoration
6. **US3** → sign-out gate verified
7. **Phase 8** → guest migration removed
8. **Phase 9** → docs + full verification

### Suggested MVP Scope

**Phases 1–3 only (T001–T011)** deliver the core product change: login-only gate with redirect tests.

Add **Phase 5 (US5)** before any external demo for welcome UX polish.

---

## Notes

- Keep `guestAppDatabaseProvider` in `lib/data/db/app_database_provider.dart` — device-global settings only (ADR-0012); not user-facing guest mode
- YouTube login (`/youtube/login`) is gated like other protected routes; playback flow unchanged (FR-009)
- Deferred (non-blocking): simplify `local-pending-rekey` in `lib/features/library/data/library_repository.dart`
- Total tasks: **44** (T001–T044)
