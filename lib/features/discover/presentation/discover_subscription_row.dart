/// Single row in the Discover subscriptions management list.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:enjoy_player/core/interaction/haptics.dart';
import 'package:enjoy_player/core/riverpod/async_value_x.dart';
import 'package:enjoy_player/core/theme/enjoy_tokens.dart';
import 'package:enjoy_player/core/theme/generative_media_cover.dart';
import 'package:enjoy_player/core/utils/remote_thumbnail_url.dart';
import 'package:enjoy_player/features/discover/application/discover_providers.dart';
import 'package:enjoy_player/features/discover/domain/discover_channel.dart';
import 'package:enjoy_player/l10n/app_localizations.dart';

class DiscoverSubscriptionRow extends ConsumerWidget {
  const DiscoverSubscriptionRow({
    required this.channel,
    required this.onUnsubscribe,
    super.key,
  });

  static const avatarSize = 44.0;

  final DiscoverChannel channel;
  final VoidCallback onUnsubscribe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final t = EnjoyThemeTokens.of(context);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final avatarAsync = ref.watch(
      recommendedChannelAvatarProvider(channel.channelId),
    );
    final avatarUrl = remoteThumbnailForCard(
      avatarAsync.valueOrNull ?? channel.thumbnailUrl,
    );

    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: BorderRadius.circular(t.radiusMd),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Haptics.selection(context);
          context.push('/discover/channel/${channel.channelId}');
        },
        child: Padding(
          padding: EdgeInsets.only(
            left: t.space12,
            top: t.space4,
            bottom: t.space4,
          ),
          child: Row(
            children: [
              _SubscriptionAvatar(
                url: avatarUrl,
                displayName: channel.displayName,
                seed: channel.channelId,
              ),
              SizedBox(width: t.space12),
              Expanded(
                child: Text(
                  channel.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: () {
                  Haptics.selection(context);
                  onUnsubscribe();
                },
                style: TextButton.styleFrom(
                  foregroundColor: cs.onSurfaceVariant,
                  textStyle: tt.labelMedium,
                ),
                child: Text(l10n.discoverUnsubscribeAction),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubscriptionAvatar extends StatelessWidget {
  const _SubscriptionAvatar({
    required this.displayName,
    required this.seed,
    this.url,
  });

  final String? url;
  final String displayName;
  final String seed;

  @override
  Widget build(BuildContext context) {
    final accent = generativeAccentForSeed(seed);
    final initial = displayName.trim().isNotEmpty
        ? displayName.trim()[0].toUpperCase()
        : '?';

    Widget fallback() {
      return ColoredBox(
        color: accent.withValues(alpha: 0.22),
        child: Center(
          child: Text(
            initial,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    return ClipOval(
      child: SizedBox(
        width: DiscoverSubscriptionRow.avatarSize,
        height: DiscoverSubscriptionRow.avatarSize,
        child: url != null
            ? Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => fallback(),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return fallback();
                },
              )
            : fallback(),
      ),
    );
  }
}
