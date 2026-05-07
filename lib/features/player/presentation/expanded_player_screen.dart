/// Full-screen player: docked top toolbar + video/transcript (no overlap).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:enjoy_player/core/theme/enjoy_tokens.dart';
import 'package:enjoy_player/l10n/app_localizations.dart';

import '../application/embedded_tracks_notifier.dart';
import '../application/player_controller.dart';
import '../application/player_ui_provider.dart';
import '../../transcript/presentation/subtitle_track_picker_sheet.dart';
import '../../transcript/presentation/transcript_panel.dart';
import 'layouts/audio_player_layout.dart';
import 'layouts/video_player_layout.dart';

class ExpandedPlayerScreen extends ConsumerStatefulWidget {
  const ExpandedPlayerScreen({required this.mediaId, super.key});

  final String mediaId;

  @override
  ConsumerState<ExpandedPlayerScreen> createState() =>
      _ExpandedPlayerScreenState();
}

class _ExpandedPlayerScreenState extends ConsumerState<ExpandedPlayerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final current = ref.read(playerControllerProvider);
      if (current?.mediaId != widget.mediaId) {
        await ref
            .read(playerControllerProvider.notifier)
            .openMedia(widget.mediaId);
      }
      ref.read(playerUiProvider.notifier).expand();
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(playerControllerProvider);
    final l10n = AppLocalizations.of(context)!;

    ref.listen(embeddedTracksProvider, (_, event) {
      if (event == null) return;
      if (event.mediaId != widget.mediaId) return;
      ref.read(embeddedTracksProvider.notifier).consume();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.subtitlesDetected),
          action: SnackBarAction(
            label: l10n.subtitlesChoose,
            onPressed:
                () => showSubtitleTrackPicker(context, ref, widget.mediaId),
          ),
        ),
      );
    });

    if (session == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: EnjoyThemeTokens.of(context).space16),
              Text(l10n.loading),
            ],
          ),
        ),
      );
    }

    final isVideo = session.mediaType == 'video';
    final videoController =
        ref.read(playerControllerProvider.notifier).videoController;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SafeArea(
            bottom: false,
            child: _ExpandedTopBar(
              title: session.mediaTitle,
              onCollapse: () {
                ref.read(playerUiProvider.notifier).collapse();
                context.pop();
              },
            ),
          ),
          Expanded(
            child:
                isVideo
                    ? VideoPlayerLayout(
                      controller: videoController,
                      transcript: TranscriptPanel(mediaId: widget.mediaId),
                    )
                    : AudioPlayerLayout(
                      transcript: TranscriptPanel(mediaId: widget.mediaId),
                    ),
          ),
        ],
      ),
    );
  }
}

/// Full-width docked toolbar — does not overlay the video; lives in layout flow.
class _ExpandedTopBar extends StatelessWidget {
  const _ExpandedTopBar({
    required this.title,
    required this.onCollapse,
  });

  final String title;
  final VoidCallback onCollapse;

  @override
  Widget build(BuildContext context) {
    final t = EnjoyThemeTokens.of(context);
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surfaceContainerHigh.withValues(alpha: 0.96),
      elevation: 0,
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: cs.outlineVariant.withValues(alpha: 0.45),
              ),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: t.space8),
            child: Row(
              children: [
                IconButton(
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  icon: const Icon(Icons.expand_more_rounded),
                  onPressed: onCollapse,
                ),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: AppLocalizations.of(context)!.transportMore,
                  icon: Icon(Icons.more_horiz_rounded, color: cs.onSurfaceVariant),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
