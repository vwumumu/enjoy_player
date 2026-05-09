# ADR-0008 — Light mode parity

**Status**: Accepted  
**Date**: 2026-05-09

## Context

The app was dark-only (hard-coded `ThemeMode.dark`). Users on bright environments, particularly desktop and tablet users, prefer system-adaptive or light themes. The premium repositioning also requires a professional light theme to compete with tools like Apple Podcasts and Spotify on desktop.

## Decision

Build a full `Brightness.light` `ThemeData` alongside dark, using a warm off-white surface ramp (`#FAFAF7` base) and the same amber brand accent with a darker, higher-contrast primary for text legibility.

The default `ThemeMode` changes from `ThemeMode.dark` to `ThemeMode.system` — new installs follow the OS preference. Existing users who had no stored preference also migrate to system (the DB key `prefsThemeMode` falls back to `'system'` when absent).

The Settings screen exposes a System / Light / Dark toggle (implemented in Phase 6).

## Consequences

- All widgets must use `colorScheme.*` tokens (not hardcoded colors or `Colors.white/black`) — audit each screen as part of the phase rollout.
- Glass blur tints need light-mode tuning (lighter tint, same blur).
- The ambient artwork backdrop on the player must respect light mode (lighter overlay, not opaque).
