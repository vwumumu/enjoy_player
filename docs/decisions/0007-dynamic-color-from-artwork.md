# ADR-0007 — Dynamic color from media artwork

**Status**: Accepted  
**Date**: 2026-05-09

## Context

The "Cinematic Editorial" design direction requires the player chrome, transport ring, transcript active-line, and ambient backdrop to reflect the dominant hue of the currently playing media's artwork. This creates an immersive, content-driven experience akin to Apple Music and Spotify.

## Decision

Use `package:palette_generator` to extract a dominant swatch and a vibrant accent from the local thumbnail file on demand. Results are cached in memory keyed by a hash of the thumbnail path so repeated extractions are free. The palette is exposed as an `@riverpod` provider `artworkPaletteProvider(mediaId)` that returns a nullable `ArtworkPalette` record.

Consumers apply the palette as an overlay/tint (never as a hard surface replacement) so that the app remains coherent when no artwork is available (falls back to theme primary).

## Consequences

- Adds `palette_generator` dependency.
- Extraction runs on an `Isolate` via the package — does not block the UI thread.
- Discontinued package notice accepted (no maintained alternative with equivalent API in 2026; can be replaced with custom FFI extraction later).
- Dynamic color only applies to player surfaces; library/home/settings always use the static brand amber.
