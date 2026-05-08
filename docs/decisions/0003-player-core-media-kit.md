# ADR-0003: media_kit as sole player engine

## Status

Accepted

## Context

We need reliable cross-platform A/V playback (Android, iOS, Windows, macOS) with a single API surface and good codec coverage.

## Decision

Use **media_kit** + **media_kit_video** + **media_kit_libs_video**. Instantiate **one** `Player` inside `PlayerController` and expose `VideoController` to widgets.

## Scope

The single-`Player` rule applies to **lesson playback** (`PlayerController` / `PlayerEngine`). A **second** `media_kit` `Player` used only for **shadow-reading take previews** is allowed — see `lib/core/audio/recording_preview_player.dart` — so previews never replace the loaded lesson media.

## Consequences

- YouTube and other web-only sources are **out of scope** for this engine (handled later with `flutter_inappwebview`, separate ADR).
- Volume is mapped from 0–1 app settings to 0–100 `media_kit` API.
