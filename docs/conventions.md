# Conventions

## Layout

- `lib/features/<feature>/{application,data,domain,presentation}/`
- Shared code: `lib/core`, `lib/data`
- Generated files: `*.g.dart` (never hand-edit)

## Naming

- Files: `snake_case.dart`
- Widgets / classes: `UpperCamelCase`
- Providers: generated `*Provider` from `@Riverpod` names

## Imports

Prefer `package:enjoy_player/...` for cross-layer imports in presentation code to avoid fragile relative paths.

## Code quality

- Keep production code in `lib/features/<feature>/{application,data,domain,presentation}/`, `lib/core`, or `lib/data`.
- Domain models stay UI-free. Presentation widgets delegate state orchestration to Riverpod providers/notifiers.
- SQLite access goes through Drift DAOs backed by `AppDatabase`; do not add raw SQL in UI or feature widgets.
- Use `package:logging` through project logging helpers; do not call `print()`.
- Do not construct `media_kit` `Player()` outside `MediaKitPlayerEngine` / `PlayerController`.

## UI interaction

- Prefer **`EnjoyTappableSurface` / `EnjoyTappableIcon`** (or **`EnjoyButton`**) for new tappable UI instead of ad-hoc `InkWell` + `GestureDetector` combinations — see [ADR-0018](decisions/0018-shared-interactive-primitives.md).
- Route light user feedback through **`Haptics`** (`selection`, `impactMedium`, `success`, `warning`) rather than calling `HapticFeedback` directly; it honors reduced motion / platform.
- Icon-only controls should still expose **`Tooltip`** (and keyboard hints via `kbd_chip` / hotkey helpers where applicable).
- User-visible strings live in ARB localization files under `lib/l10n/`.

## Logging

```dart
import 'package:enjoy_player/core/logging/log.dart';

final log = logNamed('MyFeature');
log.info('hello');
```

## Riverpod

- Long-lived globals: `@Riverpod(keepAlive: true)`
- Prefer `Notifier` / generated providers over mutable singletons.
- Avoid circular dependencies: UI sync widgets listen to `Player` streams instead of `PlayerController` calling `PlayerUi` directly.

## Database

- No SQL strings outside Drift-generated / DAO code.
- Use `NativeDatabase.memory()` in tests (see `test/data/db/app_database_test.dart`).

## Testing

- Unit tests for pure logic (`echo_window`, subtitle parsers, repositories), DAOs, and Riverpod notifiers.
- Widget or integration tests for changed navigation, input, localization, platform chrome, and shared UI behavior.
- Every behavior change needs automated coverage or a documented manual verification reason (see [testing.md](testing.md)).

## Performance

- Keep expensive file, image, transcript, database, and audio work out of `build` methods and list/grid item builders.
- Cache, stream, page, debounce, or move heavy work off the main isolate when it can block frames.
- Include a performance goal or verification note for playback, startup, scrolling, transcript rendering, sync, and media import changes.
