# ADR-0012: Per-user SQLite files + secure profile cache

## Status

Accepted

## Context

The app used a single Drift database (`enjoy_player`) for all local data. Switching Enjoy accounts would mix libraries, echo sessions, recordings, and sync state. `AuthRepository` also cached the last profile JSON in Drift (`auth.last_profile`), which would block making the session database depend on auth state (Riverpod cycle: `appDatabase` → `auth` → `apiClient` → `apiBaseUrl` → `appDatabase`).

## Decision

1. **Per-user database files**: `AppDatabase` uses `driftDatabase(name: …)` where the name is `enjoy_player_<sanitizedUserId>` for the signed-in library session. The `enjoy_player` file (see [`deviceGlobalAppDatabaseProvider`](../../lib/data/db/app_database_provider.dart) / `deviceGlobalDatabaseName`) holds **device-global** settings only (e.g. `api.base_url`) — not a guest library ([ADR-0031](0031-login-only-access.md)).
2. **Profile cache in secure storage**: Last `UserProfile` JSON is stored in `flutter_secure_storage` (not Drift) so auth initialization does not require the session-scoped database.
3. **`appDatabaseProvider`** watches `authCtrlProvider` and opens the per-user `AppDatabase` when signed in; it throws when unsigned. Device-global settings use `deviceGlobalAppDatabaseProvider`.

## Consequences

- **Pros**: Strong isolation between accounts; no schema migration to add `userId` everywhere; no cross-account sync bleed.
- **Cons**: Two SQLite files per device (device-global + per-user).
- **Docs**: Supersedes ADR-0006’s “profile cache in Drift” detail for the Flutter app; API base URL remains in Drift on the **device-global** file only.

## Supersedes (partial)

- [ADR-0006](0006-auth-and-profile-sync.md) — profile cold-start cache location (Drift → secure storage) for Enjoy Player.
