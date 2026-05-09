/// Shared MediaCard primitive — replaces the ad-hoc tiles in Home and Library.
///
/// Supports two layouts:
///   [MediaCard.tile] — vertical card for grids (video/home).
///   [MediaCard.row]  — horizontal row card for list views (audio).
library;

import 'dart:io';

import 'package:flutter/material.dart';

import '../enjoy_tokens.dart';

// ── Tile (vertical, for grids) ──────────────────────────────────────────────

class MediaCardTile extends StatefulWidget {
  const MediaCardTile({
    super.key,
    required this.title,
    required this.onTap,
    this.thumbnailFile,
    this.subtitle,
    this.isVideo = false,
    this.aspectRatio = 16 / 10,
    this.accentColor,
  });

  final String title;
  final VoidCallback onTap;
  final File? thumbnailFile;
  final String? subtitle;
  final bool isVideo;
  final double aspectRatio;
  final Color? accentColor;

  @override
  State<MediaCardTile> createState() => _MediaCardTileState();
}

class _MediaCardTileState extends State<MediaCardTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = EnjoyThemeTokens.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final accent = widget.accentColor ?? cs.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: t.motionFast,
          curve: Curves.easeOutCubic,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(t.radiusXl),
            color: _hover
                ? accent.withValues(alpha: 0.08)
                : cs.surfaceContainerLow,
            border: Border.all(
              color: _hover
                  ? accent.withValues(alpha: 0.6)
                  : cs.outlineVariant.withValues(alpha: 0.25),
              width: _hover ? 1.5 : 1,
            ),
            boxShadow: _hover
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              AspectRatio(
                aspectRatio: widget.aspectRatio,
                child: _Thumbnail(
                  file: widget.thumbnailFile,
                  isVideo: widget.isVideo,
                  cs: cs,
                ),
              ),
              // Meta
              Padding(
                padding: EdgeInsets.fromLTRB(
                  t.space12,
                  t.space8,
                  t.space12,
                  t.space12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Row (horizontal, for lists) ─────────────────────────────────────────────

class MediaCardRow extends StatefulWidget {
  const MediaCardRow({
    super.key,
    required this.title,
    required this.onTap,
    this.thumbnailFile,
    this.subtitle,
    this.badge,
    this.isVideo = false,
    this.accentColor,
    this.trailing,
  });

  final String title;
  final VoidCallback onTap;
  final File? thumbnailFile;
  final String? subtitle;
  final String? badge;
  final bool isVideo;
  final Color? accentColor;
  final Widget? trailing;

  @override
  State<MediaCardRow> createState() => _MediaCardRowState();
}

class _MediaCardRowState extends State<MediaCardRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = EnjoyThemeTokens.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final accent = widget.accentColor ?? cs.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: t.motionFast,
          curve: Curves.easeOutCubic,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(t.radiusLg),
            color: _hover
                ? accent.withValues(alpha: 0.06)
                : cs.surfaceContainerLow,
            border: Border.all(
              color: _hover
                  ? accent.withValues(alpha: 0.45)
                  : cs.outlineVariant.withValues(alpha: 0.2),
              width: _hover ? 1.5 : 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: t.space16,
              vertical: t.space12,
            ),
            child: Row(
              children: [
                // Thumbnail square
                ClipRRect(
                  borderRadius: BorderRadius.circular(t.radiusMd),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: _Thumbnail(
                      file: widget.thumbnailFile,
                      isVideo: widget.isVideo,
                      cs: cs,
                    ),
                  ),
                ),
                SizedBox(width: t.space16),
                // Title + meta
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (widget.subtitle != null || widget.badge != null) ...[
                        SizedBox(height: t.space4),
                        Row(
                          children: [
                            if (widget.badge != null) ...[
                              _Badge(label: widget.badge!, cs: cs),
                              SizedBox(width: t.space8),
                            ],
                            if (widget.subtitle != null)
                              Text(
                                widget.subtitle!,
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // Trailing
                widget.trailing ??
                    Icon(
                      Icons.chevron_right_rounded,
                      color: cs.onSurfaceVariant,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Shared helpers ───────────────────────────────────────────────────────────

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.file,
    required this.isVideo,
    required this.cs,
  });

  final File? file;
  final bool isVideo;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    if (file != null) {
      return Image.file(
        file!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.surfaceContainerHighest, cs.surfaceContainerHigh],
        ),
      ),
      child: Center(
        child: Icon(
          isVideo ? Icons.movie_outlined : Icons.audiotrack_rounded,
          size: 28,
          color: cs.onSurfaceVariant.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.cs});

  final String label;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}
