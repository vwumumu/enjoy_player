# ADR-0031: Login-only application access

## Status

Accepted

## Context

Enjoy Player previously allowed signed-out (guest) usage of home, library, discover, and settings, with optional sign-in for profile, sync, and cloud features. Guest local data could be migrated into an account after sign-in. The native auth flow (ADR-0027) is now smooth enough to require authentication up front. The app is pre-production with no legacy users requiring guest migration.

## Decision

1. **Login-only gate**: All primary app routes require a valid Enjoy account session. Unsigned users may only reach `/sign-in` and `/sign-in/email`.
2. **Router enforcement**: Auth redirects are centralized in `lib/core/routing/auth_redirect.dart` and applied from `app_router.dart`. Auth loading redirects protected routes to sign-in to avoid flashing main app content.
3. **Welcome sign-in hub**: The existing single-screen sign-in hub is the welcome experience — no separate onboarding funnel and no cancel/skip-to-home affordances.
4. **Post-sign-in navigation**: Protected-route redirects preserve intent via a `from` query parameter resolved after successful sign-in.
5. **Guest migration removed**: Guest-to-account migration UI and providers are deleted. `deviceGlobalAppDatabaseProvider` remains for device-global settings only (ADR-0012).
6. **YouTube login unchanged**: YouTube WebView sign-in remains separate and is reachable only after Enjoy account sign-in (ADR-0015).

## Consequences

- **Pros**: Every session is account-backed; simpler mental model; sync/profile/cloud always available after entry; less guest-mode test matrix.
- **Cons**: First launch requires network to sign in at least once; signed-in cold start may briefly show sign-in skeleton while auth resolves.
- **Follow-up**: Signed-out import re-key paths (`local-pending-rekey`, pending-rekey UI) removed — guest library usage is no longer possible.

## Related

- [ADR-0012](0012-per-user-sqlite-isolation.md) — per-user Drift files; device-global DB file retained for device-global settings
- [ADR-0027](0027-native-auth-v2.md) — native sign-in hub
- [docs/features/auth.md](../features/auth.md)
