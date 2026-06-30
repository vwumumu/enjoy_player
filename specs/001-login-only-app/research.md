# Research: Login-Only Application Access

**Feature**: `001-login-only-app` | **Date**: 2026-06-30

## 1. Global auth gate mechanism

**Decision**: Extend `go_router` `redirect` with a pure helper `resolveAuthRedirect` in `lib/core/routing/auth_redirect.dart`.

**Rationale**: The app already gates `/profile` and `/credits` when signed out and refreshes redirects via `authRouterTickProvider`. Centralizing rules avoids scattered `AuthSignedOut` checks in widgets and matches go_router best practice for auth flows.

**Alternatives considered**:

| Alternative | Rejected because |
|-------------|------------------|
| `AuthGate` widget wrapping `MaterialApp.router` | Duplicates route knowledge; harder to test; deep links still hit shell first |
| Per-screen `ConsumerWidget` guards | Easy to miss routes; violates DRY; flash before guard runs |
| Navigator 1.0 `onGenerateRoute` | Project standard is go_router |

## 2. Auth loading flash (FR-010)

**Decision**: While `authCtrlProvider` is `AsyncLoading`, redirect any non-sign-in matched location to `/sign-in`.

**Rationale**: Current code returns `null` during loading, which renders `/` (home) briefly before auth resolves — violates SC-001. `SignInScreen` already renders `SkeletonAppBootstrap` in loading state.

**Alternatives considered**:

| Alternative | Rejected because |
|-------------|------------------|
| Dedicated `/auth/loading` route | Extra route + copy; sign-in loading UI already exists |
| Block entire app with overlay in `RootShell` | Shell still mounts sync/player listeners; overlay fights shell chrome |

## 3. Sign-in route placement vs app shell

**Decision**: Register `/sign-in` and `/sign-in/email` as **top-level** `GoRoute`s outside `ShellRoute`.

**Rationale**: Login-only makes sign-in the first impression. Keeping it inside `RootShell` shows sidebar/bottom nav and starts `syncCtrlProvider` / discover schedulers for unsigned users. Top-level routes give a focused welcome surface.

**Alternatives considered**:

| Alternative | Rejected because |
|-------------|------------------|
| Hide chrome in `RootShell` when path starts with `/sign-in` | Side-effect providers still run; partial fix |
| Modal sign-in overlay on home | Home still mounts behind overlay; worse for security perception and tests |

## 4. Post-sign-in destination (`from` query)

**Decision**: Reuse and extend existing `?from=profile` / `?from=credits` pattern to accept encoded full paths (e.g. `from=%2Flibrary`, `from=%2Fplayer%2Fabc`).

**Rationale**: Partial allowlist already exists in router redirects. Generalizing `from` satisfies User Story 4 without new state storage.

**Alternatives considered**:

| Alternative | Rejected because |
|-------------|------------------|
| Riverpod `pendingRouteProvider` | Extra mutable state; lost on process death |
| Always land on `/` | Violates FR-004 / SC-004 |

## 5. Guest migration removal

**Decision**: Delete `GuestMigrationBanner`, `guest_migration_providers.dart`, and related tests. Do **not** delete `guestAppDatabaseProvider`.

**Rationale**: Spec clarification: pre-production, no legacy users. `guestAppDatabaseProvider` holds device-global Drift settings (`api.base_url`) per ADR-0012 — internal naming, not user-facing guest mode.

**Alternatives considered**:

| Alternative | Rejected because |
|-------------|------------------|
| Keep migration UI dormant | Dead code; contradicts FR-008 |
| Remove guest DB file entirely | Breaks API base URL storage and ADR-0012 layout |

## 6. Sign-in escape hatches

**Decision**: Remove close AppBar action and `authCancel` button that call `_close` → `context.go('/')`.

**Rationale**: `_close` is the primary guest bypass today. Email OTP back navigation stays (returns to hub, not home).

**Alternatives considered**:

| Alternative | Rejected because |
|-------------|------------------|
| Keep cancel on desktop only | Inconsistent; still allows guest access on desktop |
| Disable cancel only when `from` absent | Complex; login-only is universal |

## 7. YouTube login route

**Decision**: `/youtube/login` remains reachable only when signed in (protected like other shell routes).

**Rationale**: Spec FR-009 — YouTube auth is separate from Enjoy account but does not replace it. Users need Enjoy session first; YouTube WebView flow unchanged.

## 8. Welcome copy

**Decision**: Polish existing `authSignInTitle` and `authSignInSubtitle` ARB strings; no new screens.

**Rationale**: Clarification chose single-screen hub. Current hub already has logo, title, subtitle, and provider buttons — meets FR-011 with copy refresh only.

**Alternatives considered**:

| Alternative | Rejected because |
|-------------|------------------|
| New illustration / animation | Out of scope; increases implementation time |
| Separate marketing onboarding | Rejected in clarify session (Option A) |

## 9. Session expiry handling

**Decision**: Rely on existing `AuthRepository` refresh-on-401 → sign-out path; router redirect sends user to `/sign-in`.

**Rationale**: No new token logic required. Verify redirect fires when `authCtrlProvider` transitions to `AuthSignedOut`.

## 10. ADR

**Decision**: Add ADR-0028 documenting login-only product scope and guest-mode removal.

**Rationale**: Constitution V — product-scope decisions that are costly to reverse require ADRs.
