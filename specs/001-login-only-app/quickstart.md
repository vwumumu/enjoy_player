# Quickstart: Login-Only Application Access

**Feature**: `001-login-only-app` | **Date**: 2026-06-30

Validation guide for manual and automated verification after implementation. See [contracts/auth-gate-routing.md](./contracts/auth-gate-routing.md) and [contracts/sign-in-welcome-ui.md](./contracts/sign-in-welcome-ui.md) for behavioral contracts.

## Prerequisites

- Flutter SDK matching `pubspec.yaml` (`sdk: ^3.12.0`)
- Device or emulator (Windows desktop and one mobile target recommended)
- Enjoy API reachable (or configured `api.base_url` in settings DB)
- Test Enjoy account credentials (email OTP or Google/Apple as available on platform)

## Setup

```bash
cd c:/Users/me/dev/enjoy_player
flutter pub get
dart run build_runner build   # only if Riverpod providers changed
flutter gen-l10n              # after ARB copy updates
```

## Automated verification

```bash
flutter analyze
flutter test test/core/routing/auth_redirect_test.dart
flutter test test/features/auth/presentation/sign_in_screen_test.dart
flutter test
```

**Expected**: All tests pass; no analyzer errors in touched files.

## Manual scenarios

### QS-1 — Signed-out cold start (SC-001)

1. Sign out from profile/settings (or clear secure storage + restart).
2. Force-quit and relaunch the app.

**Expected**:

- Lands on `/sign-in` welcome hub
- No flash of home/library/discover
- No bottom nav or sidebar chrome
- Welcome headline + subtitle visible

### QS-2 — Signed-in cold start (SC-002, SC-003)

1. Sign in successfully.
2. Force-quit and relaunch.

**Expected**:

- Lands on `/` (home) directly
- No sign-in screen
- Cold start feels comparable to pre-change signed-in launch

### QS-3 — Protected route redirect (FR-001)

While signed out, attempt navigation to each:

- `/library`
- `/discover`
- `/settings`
- `/profile`
- `/credits`

**Expected**: Each redirects to `/sign-in` with appropriate `from` parameter.

### QS-4 — Post-sign-in destination (SC-004)

1. While signed out, navigate to `/profile` (via URL bar / deep link tool).
2. Complete sign-in.

**Expected**: Arrives at `/profile` without manual re-navigation.

Repeat with `/library` if `from` encoding supports full paths.

### QS-5 — Sign out gate (User Story 3)

1. Sign in, use app briefly.
2. Sign out from account menu.

**Expected**:

- Returns to welcome sign-in screen
- Cannot access home via back gesture or nav

### QS-6 — No guest bypass (FR-003)

On sign-in hub, confirm:

- No "Continue as guest" or similar
- No cancel/close control that opens home

### QS-7 — Provider cancel (SC-006)

1. Tap Google or Apple sign-in.
2. Cancel the system picker.

**Expected**: Returns to welcome hub; no error snackbar.

### QS-8 — Guest migration absent (FR-008)

1. Sign in with an account.
2. Open home.

**Expected**: No guest migration banner.

### QS-9 — YouTube login still separate (FR-009)

1. Sign in to Enjoy account.
2. Open content requiring YouTube auth.
3. Complete YouTube login flow if prompted.

**Expected**: YouTube WebView login works; distinct from Enjoy sign-in hub.

## Platform matrix (spot-check)

| Check | Windows | Android or iOS |
|-------|---------|----------------|
| QS-1 cold start gate | Required | Required |
| QS-2 signed-in return | Required | Optional |
| Platform sign-in buttons | Email + PKCE only | Native providers per platform |

## Failure triage

| Symptom | Likely cause |
|---------|--------------|
| Flash of home on launch | Auth loading returns `null` redirect — fix loading branch |
| Nav bar on sign-in | Sign-in still inside `ShellRoute` — move route or hide chrome |
| Cancel opens home | `_close` still wired — remove escape hatch |
| Stuck after sign-in | `from` decode failure — check navigation listener |

## Done criteria

- [ ] QS-1 through QS-8 pass on primary dev platform
- [ ] Automated routing + sign-in widget tests green
- [ ] `docs/features/auth.md` updated
- [ ] ADR-0028 added to `docs/decisions/`
