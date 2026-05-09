# ADR-0009 — Platform-adaptive shell nuances

**Status**: Accepted  
**Date**: 2026-05-09

## Context

Enjoy Player targets iOS, Android, Windows, and macOS. A single Material 3 shell works functionally but feels generic. Premium apps on each platform follow platform-specific navigation idioms.

## Decision

Apply platform nuances without full platform forks:

- **iOS / macOS**: `CupertinoPageTransitionsBuilder` for route transitions; swipe-back gesture preserved (go_router `popGestureEnabled`); bottom `NavigationBar` on iOS uses standard bottom tab placement.
- **Android**: `ZoomPageTransitionsBuilder` (Material 3 predictive-back ready).
- **Windows / macOS desktop**: Extended sidebar at ≥ 900px stays; macOS gets an additional `SafeArea` top inset to respect the traffic-light region; Windows keeps current density.
- **All platforms**: `VisualDensity.adaptivePlatformDensity` (already in place).

## Consequences

- No per-platform widget trees — a single widget tree with `Theme.of(context).platform` guards where needed.
- `pageTransitionsTheme` is the primary divergence point (already implemented in `app_theme.dart`).
- Future ADR needed if a full platform fork becomes necessary (e.g., macOS toolbar/menu-bar integration).
