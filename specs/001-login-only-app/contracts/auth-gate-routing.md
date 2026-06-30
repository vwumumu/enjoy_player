# Contract: Auth Gate Routing

**Feature**: `001-login-only-app` | **Consumer**: `appRouter` redirect | **Version**: 1.0

## Purpose

Define deterministic redirect behavior for Enjoy account authentication. Implement as pure function `resolveAuthRedirect` testable without widget tree.

## Inputs

| Input | Type | Description |
|-------|------|-------------|
| `matchedLocation` | `String` | go_router `state.matchedLocation` |
| `fullUri` | `Uri` | Includes query parameters |
| `auth` | `AsyncValue<AuthState>` | Current `authCtrlProvider` value |

## Output

| Output | Type | Description |
|--------|------|-------------|
| `redirectPath` | `String?` | `null` = no redirect; otherwise target location |

## Allowlists

### Unsigned allowed paths

Routes reachable without `AuthSignedIn`:

- `/sign-in`
- `/sign-in/email`

### Signed-in blocked paths

When `AuthSignedIn`, redirect away from:

- `/sign-in` → `/` (or `from` resolution handled in presentation after redirect to `/`)

## Redirect rules (priority order)

1. **Legacy path**: `/cloud` → library cloud route (existing; unchanged).
2. **Platform guards**: AI playground (release), keyboard settings (non-desktop) — existing; unchanged.
3. **Auth loading or error**: If `auth.isLoading || auth.hasError` and path not in unsigned allowlist → `/sign-in`.
4. **Signed in on sign-in route**: If path starts with `/sign-in` → `/`.
5. **Signed out on protected route**: If not `AuthSignedIn` and path not in unsigned allowlist → `/sign-in?from=<target>`.
6. **Otherwise**: `null`.

## `from` parameter encoding

When redirecting unsigned user to sign-in:

| Original target | `from` value |
|-----------------|--------------|
| `/profile` | `profile` (shorthand, backward compatible) |
| `/credits` | `credits` |
| Any other protected path | URL-encoded path without query (e.g. `%2Flibrary`) |

## Post-sign-in resolution (presentation contract)

On transition to `AuthSignedIn` while on sign-in flow:

| `from` | Navigate to |
|--------|-------------|
| absent / empty | `/` |
| `profile` | `/profile` |
| `credits` | `/credits` |
| encoded path | decoded path if valid app route; else `/` |

## Scenarios (acceptance)

### S1 — Signed-out cold start

- **WHEN** auth resolves to `AuthSignedOut` and location is `/`
- **THEN** redirect to `/sign-in`

### S2 — Signed-in cold start

- **WHEN** auth resolves to `AuthSignedIn` and location is `/`
- **THEN** no redirect

### S3 — Auth loading

- **WHEN** auth is loading and location is `/library`
- **THEN** redirect to `/sign-in` (shows bootstrap skeleton)

### S4 — Deep link while signed out

- **WHEN** auth is signed out and location is `/player/abc123`
- **THEN** redirect to `/sign-in?from=%2Fplayer%2Fabc123`

### S5 — Sign-in while signed in

- **WHEN** auth is signed in and location is `/sign-in`
- **THEN** redirect to `/`

### S6 — YouTube login gated

- **WHEN** auth is signed out and location is `/youtube/login`
- **THEN** redirect to `/sign-in?from=%2Fyoutube%2Flogin`

## Non-goals

- OAuth/PKCE token exchange (unchanged — auth feature)
- YouTube cookie auth mechanics (unchanged — player feature)
