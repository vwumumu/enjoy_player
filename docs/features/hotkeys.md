# Hotkeys

Keyboard shortcuts mirror the Enjoy web app defaults (`stores/hotkeys.ts`). Custom bindings are stored in Drift settings KV under key `hotkeys_custom_bindings` as JSON `{ "actionId": "ctrl+k", ... }`.

## Behavior

- **Global** shortcuts are evaluated whenever no editable field has focus (`EditableText`).
- **Modal**: `Escape` pops the top GoRouter route when possible; if the router stack is empty, the root `Navigator` is popped so overlays such as the shortcuts cheatsheet close.
- **Help / cheatsheet**: `global.help` (default `Shift+/` → `?`) opens `HotkeysHelpDialog`; pressing the same chord again closes it. Open state is tracked via `hotkeysCheatsheetOpen` (`lib/features/hotkeys/presentation/hotkeys_cheatsheet_open.dart`) so the hotkey and Settings “Open shortcuts cheatsheet” stay in sync. The cheatsheet handles `Escape` itself as well.
- **Library** `/`: focuses the sidebar search field when the wide layout with sidebar is visible. Narrow layouts without the sidebar have no search focus target yet.
- **Player** shortcuts apply when a playback session exists (`playerControllerProvider`).
- **Echo brackets**: expand/shrink apply only when Echo mode is active (handled inside `PlayerInteractions`).
- **Shadow reading**: `R` / `G` / `P` / `V` pulse a Riverpod bus consumed by `ShadowReadingPanel` / `PitchContourSection`. Assessment (`V`) runs the same flow as the shadow-reading **assess** control (view result if already assessed, otherwise run). Dictation (`H`) is reserved (no UI yet).

## Customization

Settings → **Keyboard shortcuts**: filter list, tap a row or **Change shortcut** to capture a new chord; conflicts show an error snackbar. Reset per row or reset all restores defaults. From the cheatsheet, **Customize in Settings** navigates to `/settings?section=keyboard` and scrolls the keyboard section into view.

## Implementation entry points

- Definitions: `lib/features/hotkeys/domain/hotkey_definitions.dart`
- Persistence: `lib/features/hotkeys/application/hotkeys_ctrl.dart`
- Dispatch: `lib/features/hotkeys/presentation/app_hotkeys_keyboard_listener.dart` (`HardwareKeyboard.addHandler`). Mounted via **`MaterialApp.router`'s `builder`** so the listener sits **under** `MaterialApp` / GoRouter (valid overlay + `ref.read(appRouterProvider)` for path/navigation — avoids `GoRouterState.of(context)` when context was above the router).
- Cheatsheet UI: `lib/features/hotkeys/presentation/hotkeys_help_dialog.dart` (`showHotkeysHelpDialog`)
