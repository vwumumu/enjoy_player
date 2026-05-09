/// Artwork color extraction via palette_generator.
/// Results are cached in-process by thumbnail-path hash.
library;

import 'dart:io';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

/// Extracted colors from a piece of media artwork.
class ArtworkPalette {
  const ArtworkPalette({
    required this.dominant,
    required this.accent,
    required this.onAccent,
    required this.vibrant,
  });

  /// Dominant (most common) color — used for backdrop tint.
  final Color dominant;

  /// Vibrant accent — used for ring glow and active-line rail.
  final Color accent;

  /// High-contrast text color readable on [accent].
  final Color onAccent;

  /// Raw vibrant swatch (may equal accent).
  final Color vibrant;

  static ArtworkPalette fromScheme(ColorScheme scheme) => ArtworkPalette(
    dominant: scheme.primaryContainer,
    accent: scheme.primary,
    onAccent: scheme.onPrimary,
    vibrant: scheme.primary,
  );
}

/// LRU-bounded in-process cache so repeated navigations are free.
final _cache = LinkedHashMap<String, ArtworkPalette>(equals: (a, b) => a == b);
const _kCacheMax = 32;

/// Extracts [ArtworkPalette] from a local file path.
/// Returns null if the file is absent or extraction fails.
Future<ArtworkPalette?> extractArtworkPalette(String? thumbnailPath) async {
  if (thumbnailPath == null || thumbnailPath.isEmpty) return null;

  if (_cache.containsKey(thumbnailPath)) return _cache[thumbnailPath];

  final file = File(thumbnailPath);
  if (!file.existsSync()) return null;

  try {
    final generator = await PaletteGenerator.fromImageProvider(
      FileImage(file),
      size: const Size(200, 200),
      maximumColorCount: 16,
    );

    final dominant =
        generator.dominantColor?.color ??
        generator.mutedColor?.color ??
        const Color(0xFF1A1A22);

    final vibrant =
        generator.vibrantColor?.color ??
        generator.lightVibrantColor?.color ??
        generator.dominantColor?.color ??
        dominant;

    // Compute a readable on-color for the accent.
    final luminance = vibrant.computeLuminance();
    final onAccent = luminance > 0.4 ? const Color(0xFF0B0B10) : Colors.white;

    final palette = ArtworkPalette(
      dominant: dominant,
      accent: vibrant,
      onAccent: onAccent,
      vibrant: vibrant,
    );

    // Maintain LRU max size.
    if (_cache.length >= _kCacheMax) {
      _cache.remove(_cache.keys.first);
    }
    _cache[thumbnailPath] = palette;
    return palette;
  } catch (_) {
    return null;
  }
}
