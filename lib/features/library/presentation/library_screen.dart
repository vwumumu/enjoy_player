/// Library: Music / Video tabs, search filter, WMP-style tiles & lists.
library;

import 'dart:io' show File, Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:enjoy_player/core/theme/enjoy_tokens.dart';
import 'package:enjoy_player/data/db/app_database.dart';
import 'package:enjoy_player/l10n/app_localizations.dart';

import '../application/library_media_provider.dart';
import '../application/library_search_provider.dart';
import 'library_actions.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<MediaRow> _filter(List<MediaRow> items, String query) {
    if (query.isEmpty) return items;
    final lower = query.toLowerCase();
    return items
        .where((m) => m.title.toLowerCase().contains(lower))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final mediaAsync = ref.watch(libraryMediaProvider);
    final query = ref.watch(librarySearchProvider);
    final l10n = AppLocalizations.of(context)!;
    final t = EnjoyThemeTokens.of(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: mediaAsync.when(
        data: (items) {
          final filtered = _filter(items, query);
          final audioItems =
              filtered.where((m) => m.kind == 'audio').toList()
                ..sort((a, b) => a.title.compareTo(b.title));
          final videoItems =
              filtered.where((m) => m.kind == 'video').toList()
                ..sort((a, b) => a.title.compareTo(b.title));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  t.space24,
                  t.space24,
                  t.space24,
                  t.space16,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        l10n.libraryTitle,
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: t.space24),
                child: Material(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(t.radiusFull),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(t.radiusFull),
                      color: cs.primaryContainer.withValues(alpha: 0.55),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: cs.onPrimaryContainer,
                    unselectedLabelColor: cs.onSurfaceVariant,
                    dividerColor: Colors.transparent,
                    tabs: [
                      Tab(text: l10n.libraryTabMusic),
                      Tab(text: l10n.libraryTabVideo),
                    ],
                  ),
                ),
              ),
              SizedBox(height: t.space8),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _MusicLibraryBody(items: audioItems),
                    _VideoLibraryBody(items: videoItems),
                  ],
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

class _MusicLibraryBody extends StatelessWidget {
  const _MusicLibraryBody({required this.items});

  final List<MediaRow> items;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = EnjoyThemeTokens.of(context);

    if (items.isEmpty) {
      return _LibraryEmptyHero(
        icon: Icons.music_note_rounded,
        title: l10n.libraryEmptyMusicTitle,
        subtitle: l10n.libraryEmptyMusicHint,
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(t.space24, t.space16, t.space24, t.space24),
      itemCount: items.length,
      separatorBuilder: (context, _) => SizedBox(height: t.space8),
      itemBuilder: (context, index) {
        final m = items[index];
        return _MusicRowCard(media: m);
      },
    );
  }
}

class _VideoLibraryBody extends StatelessWidget {
  const _VideoLibraryBody({required this.items});

  final List<MediaRow> items;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = EnjoyThemeTokens.of(context);

    if (items.isEmpty) {
      return _LibraryEmptyHero(
        icon: Icons.movie_outlined,
        title: l10n.libraryEmptyVideoTitle,
        subtitle: l10n.libraryEmptyVideoHint,
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(t.space24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 280,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 16 / 11,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _VideoTile(media: items[index]),
    );
  }
}

class _LibraryEmptyHero extends StatelessWidget {
  const _LibraryEmptyHero({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final t = EnjoyThemeTokens.of(context);
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: t.contentMaxWidth),
        child: Padding(
          padding: EdgeInsets.all(t.space24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [cs.primary, cs.tertiary],
                ).createShader(bounds),
                child: Icon(icon, size: 120, color: Colors.white),
              ),
              SizedBox(height: t.space24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: t.space8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              SizedBox(height: t.space24),
              Consumer(
                builder: (context, ref, _) {
                  final l10n = AppLocalizations.of(context)!;
                  return FilledButton.icon(
                    onPressed: () => importMediaFromPicker(context, ref),
                    icon: const Icon(Icons.folder_open_rounded),
                    label: Text(l10n.actionOpenFiles),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MusicRowCard extends StatefulWidget {
  const _MusicRowCard({required this.media});

  final MediaRow media;

  @override
  State<_MusicRowCard> createState() => _MusicRowCardState();
}

class _MusicRowCardState extends State<_MusicRowCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = EnjoyThemeTokens.of(context);
    final cs = Theme.of(context).colorScheme;
    final thumb = _thumbFile(widget.media.thumbnailPath);
    final dur = _fmtDuration(Duration(milliseconds: widget.media.durationMs));

    return Card(
      clipBehavior: Clip.antiAlias,
      child: AnimatedContainer(
        duration: t.motionFast,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(t.radiusLg),
          border: Border.all(
            color:
                _hover
                    ? cs.primary.withValues(alpha: 0.5)
                    : cs.outlineVariant.withValues(alpha: 0.18),
          ),
        ),
        child: InkWell(
          onTap: () => context.push('/player/${widget.media.id}'),
          child: MouseRegion(
            onEnter: (_) => setState(() => _hover = true),
            onExit: (_) => setState(() => _hover = false),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: t.space16,
                vertical: t.space12,
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(t.radiusSm),
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child:
                          thumb != null
                              ? Image.file(
                                thumb,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, _, _) => _musicPlaceholder(cs),
                              )
                              : _musicPlaceholder(cs),
                    ),
                  ),
                  SizedBox(width: t.space16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.media.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: t.space4),
                        Wrap(
                          spacing: t.space8,
                          runSpacing: t.space4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Chip(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              label: Text(widget.media.language),
                              labelStyle: Theme.of(context).textTheme.labelSmall,
                            ),
                            Text(
                              dur,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: cs.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _musicPlaceholder(ColorScheme cs) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
      ),
      child: Icon(Icons.audiotrack_rounded, color: cs.primary, size: 30),
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

class _VideoTile extends StatefulWidget {
  const _VideoTile({required this.media});

  final MediaRow media;

  @override
  State<_VideoTile> createState() => _VideoTileState();
}

class _VideoTileState extends State<_VideoTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = EnjoyThemeTokens.of(context);
    final cs = Theme.of(context).colorScheme;
    final thumb = _thumbFile(widget.media.thumbnailPath);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(t.radiusMd),
          onTap: () => context.push('/player/${widget.media.id}'),
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
                            errorBuilder: (_, _, _) => _videoPlaceholder(cs),
                          )
                          : _videoPlaceholder(cs),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _videoPlaceholder(ColorScheme cs) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.surfaceContainerHighest, cs.surfaceContainer],
        ),
      ),
      child: Center(
        child: Icon(Icons.movie_outlined, size: 48, color: cs.onSurfaceVariant),
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
