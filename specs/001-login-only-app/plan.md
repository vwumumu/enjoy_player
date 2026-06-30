# Implementation Plan: Login-Only Application Access

**Branch**: `001-login-only-app` | **Date**: 2026-06-30 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-login-only-app/spec.md`

## Summary

Require a valid Enjoy account session before any primary app surface is reachable. Extend the existing `go_router` auth redirect (already used for `/profile` and `/credits`) to gate all shell routes, fix auth-loading flash by treating unresolved auth as sign-in, remove guest escape hatches on `SignInScreen`, and delete guest-migration UI/providers. Polish the existing single-screen sign-in hub with friendlier welcome copy (localized ARB strings). YouTube login remains a separate in-app flow reachable only after Enjoy account sign-in.

## Technical Context

**Language/Version**: Dart ^3.12, Flutter stable (SDK constraint in `pubspec.yaml`)

**Primary Dependencies**: Riverpod 3 (`flutter_riverpod`, `@riverpod`), go_router, Drift, flutter_secure_storage, native auth SDKs (Google, Apple), existing `authCtrlProvider` / `AuthRepository`

**Storage**: Per-user Drift via `appDatabaseProvider`; device-global settings via `guestAppDatabaseProvider` (retained for `api.base_url` per ADR-0012 — not end-user guest mode); session tokens in secure storage

**Testing**: `flutter test`; new unit tests for redirect helper; widget tests for sign-in gate and welcome screen; manual cold-start verification on at least one desktop and one mobile target

**Target Platform**: Android, iOS, macOS, Windows (no Flutter web)

**Project Type**: Flutter native mobile/desktop app

**Performance Goals**: Signed-in cold start unchanged (<3s to interactive home); auth gate resolution <2s; no visible flash of protected routes during auth bootstrap (SC-001, SC-003)

**Constraints**: Single `media_kit` player ownership unchanged; no new auth methods; guest-to-account migration removed (pre-production); YouTube WebView login separate (ADR-0015)

**Scale/Scope**: Router redirect expansion, sign-in presentation tweaks, removal of ~3 guest-migration files + home banner, docs + ADR, ~5–8 test files touched/added

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### I. Architecture and Code Quality

- **Pass**: Changes stay in `lib/core/routing/` (gate), `lib/features/auth/presentation/` (welcome UX), removal of `lib/features/auth/application/guest_migration_providers.dart` and `guest_migration_banner.dart`, plus `docs/features/auth.md`.
- **Pass**: Domain auth models unchanged; no Drift schema migration required.
- **Pass**: Router logic extracted to testable pure function in `lib/core/routing/` (e.g. `auth_redirect.dart`).
- **Pass**: No new global singletons; `authRouterTickProvider` reused.

### II. Testing Defines the Contract

- **Required**: Unit tests for `resolveAuthRedirect` covering signed-in, signed-out, loading, error, sign-in routes, `from` preservation, and YouTube login exception path.
- **Required**: Widget test — signed-out user on sign-in hub shows welcome copy, no cancel-to-home control.
- **Required**: Widget or integration smoke — signed-in cold start reaches `/` without sign-in screen.
- **Manual**: Session expiry mid-use → sign-in gate (if hard to automate refresh failure).
- **Codegen**: Run `dart run build_runner build` only if `@Riverpod` providers are added/removed.

### III. User Experience Consistency

- **Pass**: Welcome copy via ARB (`lib/l10n/app_en.arb`, `app_zh.arb`); run `flutter gen-l10n`.
- **Pass**: Sign-in actions use existing `EnjoyButton` patterns.
- **Pass**: Remove close/cancel affordances that imply optional guest access.
- **Docs**: Update `docs/features/auth.md`; trim guest references in `docs/features/settings.md`.

### IV. Performance Is a Requirement

- **Pass**: Redirect runs synchronously in go_router; no extra async in redirect callback.
- **Pass**: Auth loading shows existing `SkeletonAppBootstrap` on sign-in route — no new heavy work on critical path.
- **Evidence**: Compare cold-start timeline signed-in before/after on Windows or Android emulator.

### V. Documentation and Traceability

- **Required**: New ADR `docs/decisions/0028-login-only-access.md` (product-scope, supersedes guest-mode UX in docs).
- **Required**: Update `docs/features/auth.md` and ADR index in `docs/decisions/README.md`.
- **No exception** needed.

**Post-design re-check**: All gates still pass. No complexity tracking entries required.

## Project Structure

### Documentation (this feature)

```text
specs/001-login-only-app/
├── plan.md              # This file
├── research.md          # Phase 0
├── data-model.md        # Phase 1
├── quickstart.md        # Phase 1 validation guide
├── contracts/           # Phase 1 UI/routing contracts
│   ├── auth-gate-routing.md
│   └── sign-in-welcome-ui.md
└── tasks.md             # Phase 2 (/speckit-tasks — not created here)
```

### Source Code (repository root)

```text
lib/
├── core/routing/
│   ├── app_router.dart           # Global auth redirect
│   └── auth_redirect.dart        # NEW — pure redirect resolver + tests
├── features/auth/
│   ├── presentation/
│   │   ├── sign_in_screen.dart   # Welcome UX, remove guest escape
│   │   └── guest_migration_banner.dart  # DELETE
│   └── application/
│       └── guest_migration_providers.dart  # DELETE
├── features/library/presentation/
│   └── home_screen.dart          # Remove GuestMigrationBanner
└── l10n/
    ├── app_en.arb                # Welcome copy polish
    └── app_zh.arb

test/
├── core/routing/
│   └── auth_redirect_test.dart   # NEW
└── features/auth/presentation/
    └── sign_in_screen_test.dart  # NEW or extend

docs/
├── features/auth.md
└── decisions/0028-login-only-access.md
```

**Structure Decision**: Primary touchpoints are routing (`core`) and auth presentation. Guest migration deletion is confined to the auth feature. Device-global `guestAppDatabaseProvider` remains in `lib/data/db/` unchanged (internal name; not user-facing guest mode).

## Complexity Tracking

> No constitution violations.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| — | — | — |

## Implementation Phases (for `/speckit-tasks`)

### Phase A — Auth gate (P1 stories 1, 2, 4)

1. Add `auth_redirect.dart` with `AuthRedirectResult resolveAuthRedirect(...)`.
2. Update `app_router.dart`:
   - Allowlist unsigned routes: `/sign-in`, `/sign-in/email` only.
   - When `auth.isLoading`, redirect non-sign-in routes to `/sign-in` (prevents home flash).
   - When signed out, redirect protected routes to `/sign-in?from=<encoded-path>`.
   - Preserve existing signed-in redirect away from `/sign-in`.
3. Move sign-in routes **outside** `ShellRoute` (or hide shell chrome on sign-in paths) so bottom nav / sidebar / sync side-effects do not appear on the gate screen.
4. Unit-test redirect matrix.

### Phase B — Sign-in welcome UX (P1 story 5)

1. Remove AppBar close button and `authCancel` ghost button from hub when gate is mandatory.
2. Update `authSignInTitle` / `authSignInSubtitle` ARB strings for warmer welcome + value prop.
3. On `AuthSignedIn`, navigate to `from` query target (map `profile`/`credits` shorthands + raw paths) instead of always `/`.
4. Widget tests for copy visibility and absent cancel-to-home.

### Phase C — Remove guest migration (FR-008)

1. Delete `guest_migration_banner.dart`, `guest_migration_providers.dart`, generated `.g.dart`.
2. Remove banner from `home_screen.dart` and related tests.
3. Remove unused l10n keys for migration banner (optional cleanup pass).
4. Update settings account hero copy if it references guest chip as primary path.

### Phase D — Docs & validation

1. ADR-0028 + `docs/features/auth.md`.
2. Run `flutter analyze`, `flutter test`, manual quickstart scenarios.

### Deferred cleanup (non-blocking)

- Simplify `local-pending-rekey` import path in `library_repository.dart` (guest imports no longer possible).
- Rename `guestAppDatabaseProvider` → device-global naming (cosmetic; separate refactor).

## Risk Notes

| Risk | Mitigation |
|------|------------|
| Auth loading redirect loops | Allowlist `/sign-in` during loading; sign-in screen already handles loading UI |
| Deep link `from` open redirect | Encode full path in `from`; test `/player/:id` and `/discover/channel/:id` |
| RootShell sync/player watchers on sign-in | Prefer sign-in routes outside shell |
| Dev machines with old guest DB files | Pre-production; no migration UI; devs can clear app data |
