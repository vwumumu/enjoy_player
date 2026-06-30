# Contract: Sign-In Welcome UI

**Feature**: `001-login-only-app` | **Screen**: `SignInScreen` / `_SignInHub` | **Version**: 1.0

## Purpose

Single-screen welcome + sign-in hub shown when the auth gate is active. Must feel approachable and offer no guest bypass.

## Layout (single screen)

Vertical stack, centered, max width 400px (existing):

| Zone | Content | Required |
|------|---------|----------|
| Brand | App logo in rounded container | Yes |
| Welcome | `authSignInTitle` — headline | Yes |
| Value prop | `authSignInSubtitle` — 1–2 sentences on sync, library, learning | Yes |
| Primary actions | Google / Apple / Email (platform-filtered) | Yes |
| Secondary | "Other sign-in options" (PKCE) | Yes |
| Escape | ~~Close / Cancel to home~~ | **No** — removed |

## Platform action visibility

Unchanged from `auth_platform_support.dart`:

| Platform | Google | Apple | Email | PKCE fallback |
|----------|--------|-------|-------|---------------|
| Android | Yes | No | Yes | Yes |
| iOS | Yes | Yes | Yes | Yes |
| macOS | Yes | Yes | Yes | Yes |
| Windows | No | No | Yes | Yes |

## States

| Auth state | UI |
|------------|-----|
| `AsyncLoading` | `SkeletonAppBootstrap` centered |
| `AuthSignedOut` | Full welcome hub |
| `AuthAwaitingOtp` | OTP resume pane (existing) |
| `AuthSigningInWebPkce` | Web PKCE waiting pane (existing) |
| `AuthSignedIn` | Brief success OR immediate navigation to `from` target |

## Interaction rules

1. **No dismiss to app**: No AppBar close button; no `authCancel` ghost button on hub.
2. **Email flow**: `/sign-in/email` retains back → hub (not home).
3. **Provider cancel**: Silent return to hub; no error snackbar (existing auth controller behavior).
4. **Provider failure**: Show `AppNotice.error` with message (existing).
5. **Success**: Navigate to resolved `from` path or `/`.

## Copy guidelines (localization)

Update ARB strings; regenerate l10n.

**English direction** (final copy in ARB):

- Title: welcoming, product-named (e.g. "Welcome to Enjoy")
- Subtitle: mention learning, library, sync — not punitive ("you must sign in")

**Chinese**: equivalent tone in `app_zh.arb`.

## Accessibility

- All buttons use `EnjoyButton` with full-width tap targets
- Headline/subtitle meet contrast on `AppBackground`
- Provider buttons have icons + text labels

## Scenarios

### W1 — Welcome visible

- **WHEN** unsigned user lands on `/sign-in`
- **THEN** headline, subtitle, and ≥1 sign-in action visible on one screen

### W2 — No guest bypass

- **WHEN** unsigned user inspects hub
- **THEN** no control navigates to `/` or any protected route without auth

### W3 — OTP sub-route

- **WHEN** user taps Continue with Email
- **THEN** navigate to `/sign-in/email`; back returns to hub

### W4 — Success navigation

- **WHEN** user completes sign-in with `?from=profile`
- **THEN** navigate to `/profile`

## Non-goals

- New onboarding illustrations or multi-step carousel
- Guest migration banner or copy
- YouTube sign-in on this screen
