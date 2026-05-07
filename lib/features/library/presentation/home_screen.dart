/// Home: hero header + recent media grid (WMP-inspired).
library;

import 'dart:io' show File, Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:enjoy_player/core/theme/enjoy_tokens.dart';
import 'package:enjoy_player/data/db/app_database.dart';
import 'package:enjoy_player/l10n/app_localizations.dart';

import '../application/library_media_provider.dart';
import 'library_actions.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const int _kRecentLimit = 12;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaAsync = ref.watch(libraryMediaProvider);
    final l10n = AppLocalizations.of(context)!;
    final t = EnjoyThemeTokens.of(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: mediaAsync.when(
        data: (items) {
          final sorted = [...items]
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          final recent = sorted.take(_kRecentLimit).toList();

          if (recent.isEmpty) {
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: t.contentMaxWidth),
                child: Padding(
                  padding: EdgeInsets.all(t.space24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            cs.primary,
                            cs.tertiary,
                          ],
                        ).createShader(bounds),
                        child: const Icon(
                          Icons.library_music_rounded,
                          size: 96,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: t.space24),
                      Text(
                        l10n.homeEmptyTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      SizedBox(height: t.space8),
                      Text(
                        l10n.homeEmptyHint,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                      SizedBox(height: t.space24),
                      FilledButton.icon(
                        onPressed: () => importMediaFromPicker(context, ref),
                        icon: const Icon(Icons.folder_open_rounded),
                        label: Text(l10n.actionOpenFiles),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(t.space24, t.space24, t.space24, t.space16),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          l10n.homeTitle,
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: () => importMediaFromPicker(context, ref),
                        icon: const Icon(Icons.folder_open_rounded),
                        label: Text(l10n.actionOpenFiles),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: t.space24),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    l10n.homeRecentMedia,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.all(t.space24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 16 / 12.5,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final m = recent[index];
                      return _HomeMediaTile(media: m);
                    },
                    childCount: recent.length,
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: EdgeInsets.all(t.space24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded, size: 48, color: cs.error),
                SizedBox(height: t.space16),
                Text(
                  '${l10n.error}: $e',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(height: t.space16),
                FilledButton.tonal(
                  onPressed: () => ref.invalidate(libraryMediaProvider),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeMediaTile extends StatefulWidget {
  const _HomeMediaTile({required this.media});

  final MediaRow media;

  @override
  State<_HomeMediaTile> createState() => _HomeMediaTileState();
}

class _HomeMediaTileState extends State<_HomeMediaTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = EnjoyThemeTokens.of(context);
    final cs = Theme.of(context).colorScheme;
    final isVideo = widget.media.kind == 'video';
    final thumb = _thumbFile(widget.media.thumbnailPath);
    final dur = _fmtDuration(Duration(milliseconds: widget.media.durationMs));

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(t.radiusMd),
          onTap: () => context.push('/player/${widget.media.id}'),
          child: AnimatedOpacity(
            duration: t.motionFast,
            opacity: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: t.motionFast,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(t.radiusMd),
                      border: Border.all(
                        color:
                            _hover
                                ? cs.primary.withValues(alpha: 0.85)
                                : cs.outlineVariant.withValues(alpha: 0.35),
                        width: _hover ? 1.5 : 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child:
                        thumb != null
                            ? Image.file(
                              thumb,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder:
                                  (_, _, _) => _placeholder(cs, isVideo),
                            )
                            : _placeholder(cs, isVideo),
                  ),
                ),
                SizedBox(height: t.space8),
                Text(
                  widget.media.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: t.space4),
                Text(
                  '${isVideo ? l10n.miniPlayerMediaVideo : l10n.miniPlayerMediaAudio} · $dur',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholder(ColorScheme cs, bool isVideo) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.surfaceContainerHighest,
            cs.surfaceContainer,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          isVideo ? Icons.movie_outlined : Icons.audiotrack_rounded,
          size: 40,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }

  File? _thumbFile(String? path) {
    if (path == null || path.isEmpty) return null;
    if (!(Platform.isWindows ||
        Platform.isLinux ||
        Platform.isMacOS ||
        Platform.isAndroid ||
        Platform.isIOS)) {
      return null;
    }
    final f = File(path);
    return f.existsSync() ? f : null;
  }
}

String _fmtDuration(Duration d) {
  String two(int n) => n.toString().padLeft(2, '0');
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60);
  if (h > 0) return '${two(h)}:${two(m)}:${two(s)}';
  return '${two(m)}:${two(s)}';
}
