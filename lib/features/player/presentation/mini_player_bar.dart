/// Compact player bar when expanded mode is collapsed.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../application/player_controller.dart';
import '../application/player_ui_provider.dart';

class MiniPlayerBar extends ConsumerWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(playerControllerProvider);
    final ui = ref.watch(playerUiProvider);
    if (session == null) return const SizedBox.shrink();

    final player = ref.read(playerControllerProvider.notifier).player;
    final l10n = AppLocalizations.of(context)!;

    if (ui.mode == PlayerChromeMode.expanded) {
      return const SizedBox.shrink();
    }

    return Material(
      elevation: 8,
      child: InkWell(
        onTap: () => context.push('/player/${session.mediaId}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(session.mediaType == 'video' ? Icons.movie : Icons.audiotrack),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      session.mediaTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      l10n.miniPlayerOpen,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              StreamBuilder<bool>(
                stream: player.stream.playing,
                builder: (context, snap) {
                  final playing = snap.data ?? false;
                  return IconButton(
                    tooltip: playing ? l10n.pause : l10n.play,
                    icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                    onPressed: () =>
                        ref.read(playerControllerProvider.notifier).togglePlay(),
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
