# Feature: App updates (direct distribution)

## Summary

Enjoy Player distributes **direct** updates (not via a store) on **Windows** and **macOS**, and falls back to **NoOp** on iOS / Android (the store handles updates there). The flow fetches a remote **version manifest**, compares against the running version, and either **silently logs up-to-date**, shows an **optional** prompt, or blocks on a **mandatory** update. Snooze is honored until a per-release deadline.

## Channel split

| Channel | Platforms | Strategy |
|---------|-----------|----------|
| Direct | Windows, macOS | `DirectUpdateStrategy` — fetches the remote `latest.json`, evaluates, prompts. |
| Store | iOS, Android | `NoOpUpdateStrategy` — store handles updates; we don't prompt. |

The channel is resolved by `DISTRIBUTION_CHANNEL` env / build flag (see [ADR-0023](../decisions/0023-app-update-distribution.md)).

## Manifest schema

`latest.json` is fetched from the project's CDN; the schema is parsed by `version_manifest_repository.dart` into a `ReleaseManifest`:

```json
{
  "version": "0.2.4",
  "build": 5,
  "minSupportedVersion": "0.2.0",
  "notes": "...",
  "assets": {
    "windows": { "url": "...", "sha256": "...", "file": "EnjoyPlayer-0.2.4.exe" },
    "macos":   { "url": "...", "sha256": "...", "file": "EnjoyPlayer-0.2.4.dmg" }
  }
}
```

`checksum_verifier.dart` validates `sha256` against the downloaded asset before install.

## Evaluator rules (`UpdateEvaluator.evaluateUpdate`)

- If `currentVersion >= manifest.version` → `upToDate`.
- Else if `currentVersion < manifest.minSupportedVersion` → `mandatoryUpdate`.
- Else if `snoozedVersion == manifest.version` and `clock < snoozeUntil` → `upToDate`.
- Else → `updateAvailable`.

`semver_compare.dart` provides `isVersionLessThan` (numeric component compare, ignoring pre-release tags; matches web `semverLessThan`).

## Prompt UX

`update_prompt_dialog.dart` is rendered by `update_prompt_host.dart` from inside the app shell (not a separate route), so it floats above whatever is on screen:

- **Optional**: **Update now** / **Later** / **Snooze until tomorrow**. The user's choice is persisted in `SettingsKeys.prefsSnoozedVersion` + `prefsSnoozeUntil`.
- **Mandatory**: **Update now** is the only available action; the dialog blocks interaction until the user accepts (or the install completes / fails). On Windows, the dialog drives the in-app installer handoff; on macOS, the dialog opens the downloaded `.dmg`.

## Failure modes

- **Manifest fetch fails** → swallow the error (logged). The user is not prompted; the next app launch retries.
- **Checksum mismatch** → the download is discarded and an error toast is shown.
- **Install handoff fails** (e.g. permission) → the prompt reappears on next launch.
- **Out-of-date without mandatory** → the prompt can be permanently dismissed by the user (snooze is the lighter-weight path; **dismiss** is reserved for the support contact path).

## Code map

| Area | Path |
|------|------|
| Manifest repository | [`lib/features/update/data/version_manifest_repository.dart`](../../lib/features/update/data/version_manifest_repository.dart) |
| Checksum verifier | [`lib/features/update/data/checksum_verifier.dart`](../../lib/features/update/data/checksum_verifier.dart) |
| Evaluator | [`lib/features/update/application/update_evaluator.dart`](../../lib/features/update/application/update_evaluator.dart) |
| Direct strategy | [`lib/features/update/application/direct_update_strategy.dart`](../../lib/features/update/application/direct_update_strategy.dart) |
| No-op strategy | [`lib/features/update/application/noop_update_strategy.dart`](../../lib/features/update/application/noop_update_strategy.dart) |
| Controller | [`lib/features/update/application/update_controller.dart`](../../lib/features/update/application/update_controller.dart) |
| Prompt UI | [`lib/features/update/presentation/update_prompt_dialog.dart`](../../lib/features/update/presentation/update_prompt_dialog.dart) |

## Related

- ADR: [`docs/decisions/0023-app-update-distribution.md`](../decisions/0023-app-update-distribution.md)
- Production diagnostics: [`docs/features/diagnostics.md`](diagnostics.md) (update failures feed diagnostic log)
- Packaging: [`docs/packaging.md`](../packaging.md)