# Data Model: Login-Only Application Access

**Feature**: `001-login-only-app` | **Date**: 2026-06-30

This feature does not introduce new Drift tables or API payloads. It constrains **session state** and **routing** behavior. Entities below are logical — not new database schemas.

## Entities

### Enjoy account session

| Attribute | Description |
|-----------|-------------|
| `state` | `AuthSignedIn`, `AuthSignedOut`, `AuthAwaitingOtp`, `AuthSigningInWebPkce` (existing enum/classes in `auth_state.dart`) |
| `profile` | `UserProfile` when signed in (id, email, display fields) |
| `tokens` | Access + refresh in `flutter_secure_storage` (existing) |

**Validation rules**:

- Primary app routes require `state == AuthSignedIn` with non-empty profile id.
- `AuthAwaitingOtp` and `AuthSigningInWebPkce` are allowed on sign-in sub-routes only.

**Lifecycle**:

```text
[cold start] → AsyncLoading → AuthSignedIn | AuthSignedOut
AuthSignedOut → (sign-in flow) → AuthSigningInWebPkce | AuthAwaitingOtp → AuthSignedIn
AuthSignedIn → (sign out | refresh failure) → AuthSignedOut
```

### Sign-in gate

| Attribute | Description |
|-----------|-------------|
| `allowedPaths` | `/sign-in`, `/sign-in/email` when unsigned |
| `blockedPaths` | All other app routes including `/`, `/library`, `/discover`, `/player/*`, `/settings`, `/profile`, `/credits`, `/youtube/login` |
| `loadingBehavior` | Unresolved auth → treat as gate active (redirect to `/sign-in`) |

Not persisted — derived from `authCtrlProvider` + current route.

### Welcome sign-in experience

| Attribute | Description |
|-----------|-------------|
| `headline` | Localized (`authSignInTitle`) |
| `valueProposition` | Localized (`authSignInSubtitle`) |
| `actions` | Platform-filtered provider buttons (existing `auth_platform_support.dart`) |
| `escapeHatches` | None (no cancel-to-home, no guest) |

Presentation-only; no persistence.

### Intended destination

| Attribute | Description |
|-----------|-------------|
| `from` | Query parameter on `/sign-in` — shorthand (`profile`, `credits`) or URL-encoded path |
| `resolvedPath` | Post-sign-in navigation target; defaults to `/` |

Ephemeral — lives in router URI until sign-in completes.

## Relationships

```text
Enjoy account session ──determines──► Sign-in gate (open | closed)
Intended destination ──consumed by──► Sign-in success navigation
Welcome sign-in experience ──shown when──► Sign-in gate closed for user (unsigned)
```

## Removed concepts (this feature)

| Concept | Action |
|---------|--------|
| Guest migration banner | Delete UI + providers |
| Guest migratable local data (user-facing) | Out of scope — no UI or flows |
| `local-pending-rekey` guest import path | Optional deferred cleanup in `library_repository.dart` |

## Unchanged persistence

| Store | Role after change |
|-------|-------------------|
| `guestAppDatabaseProvider` (`enjoy_player` file) | Device-global settings only (e.g. API base URL) |
| `appDatabaseProvider` | Per-user Drift when signed in; unused for library while unsigned |
| Secure storage | Session tokens + profile snapshot (ADR-0012) |
