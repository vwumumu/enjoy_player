# App UI (premium shell & theming)

## Overview

- **Entry**: `MaterialApp.router` in `lib/app.dart` with dark `ThemeData` from `lib/core/theme/app_theme.dart` (violet seed on deep plum surfaces).
- **Navigation**: `go_router` `ShellRoute` → `RootShell` wraps **Home** (`/`), **Library** (`/library`), **ExpandedPlayerScreen** (`/player/:id`), **Settings** (`/settings`).
- **Persistent chrome**: [`GlobalTransportBar`](../../lib/features/player/presentation/widgets/global_transport_bar.dart) when a session exists (full-width glass transport + progress). Extended **sidebar** (brand, search, nav) at widths ≥ `EnjoyThemeTokens.breakpointRail`; compact **NavigationBar** (Home / Library / Settings) below that. Sidebar and nav chrome are hidden on `/player/*` for focus.

## Design tokens

- **Spacing / radii / breakpoints**: `EnjoyThemeTokens` (`lib/core/theme/enjoy_tokens.dart`).
- **Background**: radial gradient via [`AppBackground`](../../lib/core/theme/widgets/app_background.dart).
- **Glass panels**: [`GlassSurface`](../../lib/core/theme/widgets/glass_surface.dart) for sidebar and transport.

## Behavior

- **Breakpoints**: transcript side-by-side vs stacked (`breakpointTranscriptSideBySide`); sidebar vs bottom nav (`breakpointRail`).
- **Wide video + transcript**: Transcript width is draggable (min ~240px, max 50% of width). Video uses `BoxFit.contain` with native aspect ratio from the player.
- **Theme mode**: `ThemeMode.dark` in `EnjoyApp` for the premium shell.
- **Motion**: Short fade on expanded player route transitions in `app_router.dart`.

## Verification (after UI changes)

- `dart run build_runner build --delete-conflicting-outputs` (if `@Riverpod` / Drift touched)
- `flutter gen-l10n`
- `flutter analyze`
- `flutter test`
- Manual: Home grid + Library tabs + Settings; open player; transport ring + collapse/expand; narrow vs wide window.
