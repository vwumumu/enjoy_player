# Feature: Settings

## Summary

The Settings hub is reached at `/settings` and groups every preference surface in one editorial screen. It also hosts two **sub-screens** — `/settings/hotkeys` (keyboard shortcuts) and `/settings/sync` (cloud metadata sync status) — and the **About / update** entry. The screen mixes a single `SliverList` composition with **14 private widgets**, **2 `ConsumerStatefulWidget` editors**, and a dialog builder, all currently living in `lib/features/settings/presentation/settings_screen.dart` (≈1566 LOC; see [Issue #45](https://github.com/baizhiheizi/enjoy_player/issues/45) for the deferred split plan).

## Routes

| Path | Purpose |
|------|---------|
| `/settings` | Hub screen |
| `/settings/hotkeys` | Keyboard shortcuts editor (sub-screen) |
| `/settings/sync` | Cloud metadata sync status (sub-screen) |

## Sections

- **Account hero** — `_AccountHeroCard` shows the signed-in profile (avatar, name, email) or a guest chip; `_AccountHeroSkeleton` is the loading state. Sign-out lives in the account hero's overflow menu with a confirmation dialog.
- **Guest data migration** — visible only when signed out; explains that locally stored media will be claimed on sign-in.
- **Cloud sync** — links to `/settings/sync` and surfaces a `_SyncQueueStatusPill` (synced / queued / error) read from the sync status provider.
- **Appearance & language** — display + native language pickers (`language_choice_sheet.dart`). Selection persists via `SettingsKeys.prefsDisplayLanguage` / `prefsNativeLanguage`.
- **Focus learning language** — editable in Settings and Profile (English, Japanese, Korean, Spanish, French, plus Chinese variants). Drives Discover recommendation filtering, import defaults, and dictionary lookup fallbacks. Persisted locally and synced to the cloud profile when signed in. Azure pronunciation assessment and some AI features are **capability-gated** by locale — unsupported media languages show disabled controls with an explanation rather than silently assessing as English.
- **Recording** — microphone picker (auto + every input device returned by `AudioRecorder.listInputDevices()`; see [`echo-mode.md`](echo-mode.md) for the virtual-device skip list).
- **Keyboard shortcuts** — link to `/settings/hotkeys` (full editor).
- **Developer** — API base URL editors for the **Worker** and the **AI gateway** (`_ApiBaseUrlEditor`, `_AiApiBaseUrlEditor`); visible only in debug builds. Also links to the AI playground (see [`ai.md`](ai.md)).
- **About / update** — gradient About card (`about_section_card.dart`) and a link into the update prompt flow (see [`update.md`](update.md)).

## Sub-screens

### `/settings/hotkeys`

Full keyboard shortcut editor. Backed by `HotkeysService` (see [`hotkeys.md`](hotkeys.md)); the screen shows current bindings, surfaces conflicts, and offers a confirmation dialog on save.

### `/settings/sync`

Cloud metadata sync status (see [`sync.md`](sync.md)). Shows the queue, last sync time, per-target progress, and a manual sync button. Read-only; the user cannot change sync configuration from this screen (that's in the [ADR-0010](../decisions/0010-cloud-sync-mvp.md) cloud-sync MVP scope).

## Account hero states

- **Signed in** → avatar + display name + email, plus overflow menu with **Sign out** (with confirmation dialog that warns about cloud data).
- **Loading** → `_AccountHeroSkeleton` shimmer.
- **Signed out** → guest chip with **Sign in** CTA pointing at `/sign-in?from=/settings`.

## Sign-out flow

Confirmation dialog explains cloud-side consequences (per-target recordings will remain on the server, scoped to the account). On confirm: `authCtrlProvider.signOut()` clears the secure token store, closes the per-user SQLite, and routes back to `/sign-in`.

## Code map

| Area | Path |
|------|------|
| Hub screen | [`lib/features/settings/presentation/settings_screen.dart`](../../lib/features/settings/presentation/settings_screen.dart) |
| Language picker sheet | [`lib/features/settings/presentation/widgets/language_choice_sheet.dart`](../../lib/features/settings/presentation/widgets/language_choice_sheet.dart) |
| About card | [`lib/features/settings/presentation/widgets/about_section_card.dart`](../../lib/features/settings/presentation/widgets/about_section_card.dart) |
| Hotkeys sub-screen | [`lib/features/settings/presentation/hotkeys_settings_screen.dart`](../../lib/features/settings/presentation/hotkeys_settings_screen.dart) |
| Sync sub-screen | [`lib/features/settings/presentation/sync_status_screen.dart`](../../lib/features/settings/presentation/sync_status_screen.dart) |

## Related

- Auth: [`docs/features/auth.md`](auth.md)
- Hotkeys: [`docs/features/hotkeys.md`](hotkeys.md)
- Sync: [`docs/features/sync.md`](sync.md)
- App updates: [`docs/features/update.md`](update.md)
- Production diagnostics: [`docs/features/diagnostics.md`](diagnostics.md)