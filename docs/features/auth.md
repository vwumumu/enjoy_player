# Auth & profile (Enjoy account)

## Behavior

- Optional sign-in: `POST /api/v1/sessions/start_auth`, then the user completes auth in an **in-app WebView** (`flutter_inappwebview`) loading `verificationUrl`; the app polls `GET /api/v1/sessions/poll` until `approved` or timeout (~5 minutes). **Open in system browser** is available from the overflow menu if an IdP blocks embedded WebViews or the user prefers the OS browser (polling unchanged).
- **Sign-in screen**: After approval the shell navigates **home** automatically; while polling, the user can **reload the sign-in page**, open the system browser, or **cancel**; failed loads show **network error** UI with **retry**.
- **Bearer token** is stored in **flutter_secure_storage** (not in Drift). macOS requires **Keychain Sharing** in [`DebugProfile.entitlements`](../macos/Runner/DebugProfile.entitlements) / [`Release.entitlements`](../macos/Runner/Release.entitlements) (`keychain-access-groups`); without it sign-in fails with `errSecMissingEntitlement` (-34018).
- Last **profile snapshot** is cached in **flutter_secure_storage** (JSON) for fast cold start when a token exists — avoids coupling auth init to the session-scoped Drift DB ([ADR-0012](../decisions/0012-per-user-sqlite-isolation.md)).
- **Profile** screen calls `GET/PATCH /api/v1/profile` with camelCase JSON; the HTTP client maps camelCase ↔ snake_case like the web `@enjoy/api` client.
- **Credits usage** (Worker audit log): from Profile, **Credits usage** opens `/credits` and calls Worker `GET /credits/usages` via the AI API base URL ([features/credits-usage.md](credits-usage.md)).
- **Locale / learning / native language** from the server profile are applied to app preferences (Drift `prefs.*`) on login and profile refresh. **Settings** (guest or signed-in) and **Profile** (signed-in) offer pickers: UI **en-US / zh-CN**, learning fixed **en-US**, native **en-US / zh-CN** minus the learning tag (MVP: native **zh-CN** only while learning is English). Native must not equal learning; invalid server pairs are coerced locally and corrected with `PATCH` when the server sends conflicting values.
- **API base URL** is configurable under Settings → Advanced (`api.base_url` in the **guest** Drift DB `enjoy_player`); default `https://enjoy.bot`. Session-scoped data (library, prefs, sync cursors) lives in `appDatabaseProvider` (guest DB when signed out, per-user file when signed in).
- **Guest → account migration**: If the guest DB still has library or practice data after sign-in, a **Home** banner offers to copy it into the signed-in user's DB and clear those tables on the guest DB (API base URL and other guest settings stay). **Not now** hides the banner (stored in user DB as `migration.guest_dismissed`); **Settings → Local data** repeats the action while guest data exists.

## REST clients

Typed list/object helpers live under `lib/data/api/services/` for audios, videos, transcripts, and recordings. **Metadata sync** uses the mine endpoints for audios/videos/recordings when signed in ([features/sync.md](sync.md)).

## Related ADR

- [ADR-0006](../decisions/0006-auth-and-profile-sync.md)
- [ADR-0012](../decisions/0012-per-user-sqlite-isolation.md) — per-user SQLite + profile cache
- [ADR-0016](../decisions/0016-enjoy-account-webview-sign-in.md) — in-app WebView for Enjoy account verification URL (partial supersession of 0006 delivery)
