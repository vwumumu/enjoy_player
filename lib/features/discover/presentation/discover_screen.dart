/// Discover: recommended channels, subscriptions, merged RSS timeline.
library;

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:enjoy_player/core/notices/app_notice.dart';
import 'package:enjoy_player/core/theme/enjoy_tokens.dart';
import 'package:enjoy_player/core/theme/widgets/editorial_header.dart';
import 'package:enjoy_player/core/theme/widgets/empty_state.dart';
import 'package:enjoy_player/core/theme/widgets/skeleton.dart';
import 'package:enjoy_player/features/discover/application/discover_providers.dart';
import 'package:enjoy_player/features/discover/domain/discover_channel.dart';
import 'package:enjoy_player/features/discover/domain/recommended_channel.dart';
import 'package:enjoy_player/features/discover/presentation/discover_feed_tile.dart';
import 'package:enjoy_player/features/discover/presentation/discover_recommended_channel_card.dart';
import 'package:enjoy_player/features/discover/presentation/discover_subscribe_sheet.dart';
import 'package:enjoy_player/l10n/app_localizations.dart';

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final t = EnjoyThemeTokens.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final refreshing = ref.watch(discoverRefreshStateProvider);
    final recommendedAsync = ref.watch(recommendedChannelsProvider);
    final subscriptionsAsync = ref.watch(discoverSubscriptionsProvider);
    final timelineAsync = ref.watch(discoverTimelineProvider);

    Future<void> onRefresh() async {
      final result = await ref
          .read(discoverRefreshStateProvider.notifier)
          .refresh(force: true);
      if (!context.mounted) return;
      if (result.hasFailures) {
        AppNotice.error(context, l10n.discoverRefreshPartialFailed);
      }
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: EditorialHeader(
                title: l10n.discoverTitle,
                trailing: FilledButton.icon(
                  onPressed: refreshing
                      ? null
                      : () => unawaited(showDiscoverSubscribeSheet(context, ref)),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(l10n.discoverSubscribeAction),
                ),
              ),
            ),
            if (refreshing)
              const SliverToBoxAdapter(
                child: LinearProgressIndicator(minHeight: 2),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(t.space24, 0, t.space24, t.space8),
                child: Text(
                  l10n.discoverRecommendedHeading,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            recommendedAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: SkeletonMediaList(itemCount: 3),
                ),
              ),
              error: (_, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(t.space24),
                  child: Text(l10n.discoverRecommendedLoadFailed),
                ),
              ),
              data: (recommended) => subscriptionsAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: SkeletonMediaList(itemCount: 3),
                  ),
                ),
                error: (_, _) => SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(t.space24),
                    child: Text(l10n.discoverSubscriptionsLoadFailed),
                  ),
                ),
                data: (subs) => SliverToBoxAdapter(
                  child: _RecommendedRow(
                    recommended: recommended,
                    subscriptions: subs,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(t.space24, t.space16, t.space24, t.space8),
                child: Text(
                  l10n.discoverSubscriptionsHeading,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            subscriptionsAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: SkeletonMediaList(itemCount: 2),
                ),
              ),
              error: (_, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(t.space24),
                  child: Text(l10n.discoverSubscriptionsLoadFailed),
                ),
              ),
              data: (subs) {
                if (subs.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: t.space24),
                      child: Text(
                        l10n.discoverNoSubscriptionsHint,
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                }
                return SliverToBoxAdapter(
                  child: SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: t.space24),
                      itemCount: subs.length,
                      separatorBuilder: (_, _) => SizedBox(width: t.space8),
                      itemBuilder: (context, index) {
                        final sub = subs[index];
                        return ActionChip(
                          label: Text(sub.displayName),
                          onPressed: () => context.push(
                            '/discover/channel/${sub.channelId}',
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(t.space24, t.space24, t.space24, t.space8),
                child: Text(
                  l10n.discoverTimelineHeading,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            timelineAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: SkeletonMediaList(itemCount: 5),
                ),
              ),
              error: (_, _) => SliverToBoxAdapter(
                child: EmptyState(
                  icon: Icons.cloud_off_rounded,
                  title: l10n.discoverFeedErrorTitle,
                  subtitle: l10n.discoverFeedErrorHint,
                  action: () => unawaited(onRefresh()),
                  actionLabel: l10n.discoverRetry,
                ),
              ),
              data: (entries) {
                if (entries.isEmpty) {
                  return SliverToBoxAdapter(
                    child: EmptyState(
                      icon: Icons.rss_feed_rounded,
                      title: l10n.discoverFeedEmptyTitle,
                      subtitle: l10n.discoverFeedEmptyHint,
                      action: () => unawaited(onRefresh()),
                      actionLabel: l10n.discoverRetry,
                    ),
                  );
                }
                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(t.space24, 0, t.space24, t.space32),
                  sliver: SliverLayoutBuilder(
                    builder: (context, constraints) {
                      const minTileWidth = 320.0;
                      final crossAxisCount = (constraints.crossAxisExtent / minTileWidth)
                          .floor()
                          .clamp(1, 4);

                      if (crossAxisCount == 1) {
                        return SliverList.separated(
                          itemCount: entries.length,
                          separatorBuilder: (_, _) => SizedBox(height: t.space24),
                          itemBuilder: (context, index) =>
                              DiscoverFeedTile(entry: entries[index]),
                        );
                      }

                      return SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: t.space24,
                          crossAxisSpacing: t.space16,
                          childAspectRatio: discoverFeedTileGridAspectRatio,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Align(
                            alignment: Alignment.topCenter,
                            child: DiscoverFeedTile(entry: entries[index]),
                          ),
                          childCount: entries.length,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendedRow extends ConsumerStatefulWidget {
  const _RecommendedRow({
    required this.recommended,
    required this.subscriptions,
  });

  final List<RecommendedChannel> recommended;
  final List<DiscoverChannel> subscriptions;

  @override
  ConsumerState<_RecommendedRow> createState() => _RecommendedRowState();
}

class _RecommendedRowState extends ConsumerState<_RecommendedRow> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = EnjoyThemeTokens.of(context);
    final subscribedIds = widget.subscriptions.map((s) => s.channelId).toSet();

    return SizedBox(
      height: DiscoverRecommendedChannelCard.rowHeight(t),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
            PointerDeviceKind.stylus,
          },
        ),
        child: Scrollbar(
          controller: _scrollController,
          interactive: true,
          notificationPredicate: (notification) =>
              notification.metrics.axis == Axis.horizontal,
          child: ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            primary: false,
            padding: EdgeInsets.fromLTRB(
              t.space24,
              0,
              t.space24,
              t.space16,
            ),
            itemCount: widget.recommended.length,
            separatorBuilder: (_, _) => SizedBox(width: t.space16),
            itemBuilder: (context, index) {
              final channel = widget.recommended[index];
              final subscribed = subscribedIds.contains(channel.channelId);
              return Align(
                alignment: Alignment.topCenter,
                child: DiscoverRecommendedChannelCard(
                  channel: channel,
                  subscribed: subscribed,
                  onSubscribe: () => unawaited(
                    _subscribeRecommended(context, ref, channel),
                  ),
                  onViewFeed: () => context.push(
                    '/discover/channel/${channel.channelId}',
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _subscribeRecommended(
    BuildContext context,
    WidgetRef ref,
    RecommendedChannel channel,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref
          .read(discoverRepositoryProvider)
          .subscribeRecommended(channel);
      await ref.read(discoverRefreshStateProvider.notifier).refresh(force: true);
      if (context.mounted) {
        AppNotice.success(context, l10n.discoverSubscribed);
      }
    } catch (_) {
      if (context.mounted) {
        AppNotice.error(context, l10n.discoverSubscribeFailed);
      }
    }
  }
}
