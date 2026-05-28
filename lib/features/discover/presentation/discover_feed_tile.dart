/// Single Discover feed row with add / in-library / play actions.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:enjoy_player/core/ids/enjoy_ids.dart';
import 'package:enjoy_player/core/notices/app_notice.dart';
import 'package:enjoy_player/core/routing/player_navigation.dart';
import 'package:enjoy_player/core/theme/enjoy_tokens.dart';
import 'package:enjoy_player/core/utils/remote_thumbnail_url.dart';
import 'package:enjoy_player/features/discover/application/discover_providers.dart';
import 'package:enjoy_player/features/discover/domain/feed_entry.dart';
import 'package:enjoy_player/features/library/application/library_media_provider.dart';
import 'package:enjoy_player/l10n/app_localizations.dart';

class DiscoverFeedTile extends ConsumerStatefulWidget {
  const DiscoverFeedTile({required this.entry, super.key});

  final FeedEntry entry;

  @override
  ConsumerState<DiscoverFeedTile> createState() => _DiscoverFeedTileState();
}

class _DiscoverFeedTileState extends ConsumerState<DiscoverFeedTile> {
  bool? _inLibrary;
  bool _adding = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadLibraryState());
  }

  @override
  void didUpdateWidget(covariant DiscoverFeedTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.videoId != widget.entry.videoId) {
      unawaited(_loadLibraryState());
    }
  }

  Future<void> _loadLibraryState() async {
    final inLib = await discoverVideoInLibrary(ref, widget.entry.videoId);
    if (!mounted) return;
    setState(() => _inLibrary = inLib);
  }

  /// Returns `true` when the video is in the library after this call.
  Future<bool> _addToLibrary() async {
    if (_adding) return _inLibrary ?? false;
    setState(() => _adding = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      await addDiscoverFeedEntryToLibrary(ref, widget.entry);
      ref.invalidate(libraryMediaProvider);
      if (!mounted) return false;
      setState(() => _inLibrary = true);
      AppNotice.success(context, l10n.discoverAddedToLibrary);
      return true;
    } catch (_) {
      if (mounted) {
        AppNotice.error(context, l10n.discoverAddFailed);
      }
      return false;
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  Future<void> _play() async {
    var inLib = await discoverVideoInLibrary(ref, widget.entry.videoId);
    if (!inLib) {
      inLib = await _addToLibrary();
    }
    if (!inLib || !mounted) return;
    if (mounted) setState(() => _inLibrary = true);
    final mediaId = enjoyVideoId(provider: 'youtube', vid: widget.entry.videoId);
    openPlayerRoute(context, mediaId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = EnjoyThemeTokens.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final entry = widget.entry;
    final thumb = remoteThumbnailForCard(entry.thumbnailUrl);

    final inLibrary = _inLibrary ?? false;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: inLibrary ? () => unawaited(_play()) : null,
        child: Padding(
          padding: EdgeInsets.all(t.space12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(t.radiusSm),
                child: thumb != null
                    ? Image.network(
                        thumb,
                        width: 120,
                        height: 68,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _thumbFallback(context),
                      )
                    : _thumbFallback(context),
              ),
              SizedBox(width: t.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: t.space4),
                    Text(
                      _formatPublishedDate(entry.publishedAt),
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    SizedBox(height: t.space8),
                    Wrap(
                      spacing: t.space8,
                      children: [
                        if (inLibrary)
                          FilledButton.tonalIcon(
                            onPressed: () => unawaited(_play()),
                            icon: const Icon(Icons.play_arrow_rounded, size: 18),
                            label: Text(l10n.discoverPlay),
                          )
                        else
                          FilledButton.icon(
                            onPressed: _adding ? null : () => unawaited(_addToLibrary()),
                            icon: _adding
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: cs.onPrimary,
                                    ),
                                  )
                                : const Icon(Icons.add_rounded, size: 18),
                            label: Text(l10n.discoverAddToLibrary),
                          ),
                        if (inLibrary)
                          Text(
                            l10n.discoverInLibrary,
                            style: tt.labelMedium?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _thumbFallback(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 120,
      height: 68,
      color: cs.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(Icons.play_circle_outline_rounded, color: cs.onSurfaceVariant),
    );
  }

  static String _formatPublishedDate(DateTime dt) {
    final local = dt.toLocal();
    final y = local.year;
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
