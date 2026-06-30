/// Shared subscribe / unsubscribe actions for Discover UI.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:enjoy_player/core/application/app_language_catalog.dart';
import 'package:enjoy_player/core/notices/app_notice.dart';
import 'package:enjoy_player/features/discover/application/discover_providers.dart';
import 'package:enjoy_player/features/discover/domain/discover_channel.dart';
import 'package:enjoy_player/features/discover/domain/recommended_channel.dart';
import 'package:enjoy_player/features/library/presentation/widgets/content_language_picker.dart';
import 'package:enjoy_player/l10n/app_localizations.dart';

Future<void> subscribeRecommendedChannel(
  BuildContext context,
  WidgetRef ref,
  RecommendedChannel channel,
) async {
  final l10n = AppLocalizations.of(context)!;
  try {
    await ref.read(discoverRepositoryProvider).subscribeRecommended(channel);
  } catch (_) {
    if (context.mounted) {
      AppNotice.error(context, l10n.discoverSubscribeFailed);
    }
    return;
  }

  await waitForDiscoverSubscription(ref, channel.channelId);
  if (!context.mounted) return;

  try {
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

Future<void> unsubscribeDiscoverChannel(
  BuildContext context,
  WidgetRef ref,
  String channelId,
) async {
  final l10n = AppLocalizations.of(context)!;
  await ref.read(discoverRepositoryProvider).unsubscribe(channelId);
  if (context.mounted) {
    AppNotice.success(context, l10n.discoverUnsubscribed);
  }
}

Future<void> editDiscoverChannelLanguage(
  BuildContext context,
  WidgetRef ref,
  DiscoverChannel channel,
) async {
  final l10n = AppLocalizations.of(context)!;
  final picked = await showContentLanguagePicker(
    context: context,
    ref: ref,
    selectedValue: channel.language,
    title: l10n.mediaEditLanguage,
  );
  if (picked == null || !context.mounted) return;
  if (tagsEqual(picked, channel.language)) return;

  try {
    await ref
        .read(discoverRepositoryProvider)
        .updateSubscriptionLanguage(channel.channelId, picked);
    if (context.mounted) {
      AppNotice.success(context, l10n.mediaLanguageUpdated);
    }
  } catch (_) {
    if (context.mounted) {
      AppNotice.error(context, l10n.mediaLanguageUpdateFailed);
    }
  }
}
