/// Echo segment as one card with controls and optional shadow-reading panel.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:enjoy_player/core/theme/enjoy_tokens.dart';
import 'package:enjoy_player/data/subtitle/transcript_line.dart';
import 'package:enjoy_player/features/player/application/display_position_provider.dart';
import 'package:enjoy_player/features/player/application/echo_mode_provider.dart';
import 'package:enjoy_player/features/player/application/player_controller.dart';
import 'package:enjoy_player/features/player/application/player_interactions.dart';
import 'package:enjoy_player/features/player/domain/playback_session.dart';
import 'package:enjoy_player/features/shadow_reading/presentation/shadow_reading_panel.dart';
import 'package:enjoy_player/features/transcript/application/transcript_line_alignment.dart';
import 'package:enjoy_player/features/transcript/presentation/echo_region_controls_bar.dart';
import 'package:enjoy_player/features/transcript/presentation/transcript_line_tile.dart';

class EchoRegionMergedCard extends ConsumerWidget {
  const EchoRegionMergedCard({
    required this.mediaId,
    required this.lines,
    required this.echo,
    required this.activeCueIndex,
    required this.secondaryLines,
    super.key,
  });

  final String mediaId;
  final List<TranscriptLine> lines;
  final EchoState echo;
  final int activeCueIndex;
  final List<TranscriptLine> secondaryLines;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final tok = EnjoyThemeTokens.of(context);
    final chrome = ref.watch(playerControllerProvider.select(playbackChromeOf));
    final posAsync = ref.watch(displayPositionProvider);
    final currentTimeSec = switch (posAsync) {
      AsyncData(:final value) => value.inMilliseconds / 1000.0,
      _ => 0.0,
    };

    // Neutral surface — no colored background; left rail carries the echo accent.
    final shell = scheme.surfaceContainerLow;

    final showShadow = echo.startTimeSeconds >= 0 && echo.endTimeSeconds >= 0;

    final lineWidgets = <Widget>[];
    for (var i = echo.startLineIndex; i <= echo.endLineIndex; i++) {
      if (i > echo.startLineIndex) {
        lineWidgets.add(
          Divider(
            height: 1,
            thickness: 1,
            indent: tok.space12,
            endIndent: tok.space12,
            color: scheme.outlineVariant.withValues(alpha: 0.2),
          ),
        );
      }

      final line = lines[i];
      final isActive = i == activeCueIndex;
      final secondaryText = transcriptMatchSecondary(
        line,
        secondaryLines,
      )?.text;

      final tile = TranscriptLineTile(
        line: line,
        secondaryText: secondaryText,
        isActive: isActive,
        inEcho: true,
        groupedInEcho: true,
        onTap: () =>
            ref.read(playerInteractionsProvider.notifier).seekToLine(line, i),
      );

      lineWidgets.add(tile);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        EchoRegionControlsBar(
          position: EchoRegionBarPosition.top,
          expandDisabled: echo.startLineIndex <= 0,
          shrinkDisabled: echo.startLineIndex >= echo.endLineIndex,
          dense: true,
          onExpand: () =>
              ref.read(echoModeProvider.notifier).expandEchoBackward(lines),
          onShrink: () =>
              ref.read(echoModeProvider.notifier).shrinkEchoBackward(lines),
        ),
        SizedBox(height: tok.space8),
        // Neutral card with 8px warm orange left rail
        ClipRRect(
          borderRadius: BorderRadius.circular(tok.radiusMd),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Orange rail
                Container(
                  width: 8,
                  decoration: BoxDecoration(color: tok.echoActive),
                ),
                // Content
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: shell,
                      border: Border(
                        top: BorderSide(
                          color: scheme.outlineVariant.withValues(alpha: 0.18),
                        ),
                        right: BorderSide(
                          color: scheme.outlineVariant.withValues(alpha: 0.18),
                        ),
                        bottom: BorderSide(
                          color: scheme.outlineVariant.withValues(alpha: 0.18),
                        ),
                      ),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: lineWidgets,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: tok.space8),
        EchoRegionControlsBar(
          position: EchoRegionBarPosition.bottom,
          expandDisabled: echo.endLineIndex >= lines.length - 1,
          shrinkDisabled: echo.endLineIndex <= echo.startLineIndex,
          dense: true,
          onExpand: () =>
              ref.read(echoModeProvider.notifier).expandEchoForward(lines),
          onShrink: () =>
              ref.read(echoModeProvider.notifier).shrinkEchoForward(lines),
        ),
        if (showShadow) ...[
          SizedBox(height: tok.space16),
          ShadowReadingPanel(
            mediaId: mediaId,
            targetType: chrome?.dexieTargetType ?? 'Audio',
            language: chrome?.language ?? 'en',
            startSec: echo.startTimeSeconds,
            endSec: echo.endTimeSeconds,
            referenceText: echoReferencePlainText(lines, echo),
            echoActive: echo.active,
            currentTimeSec: currentTimeSec,
          ),
        ],
      ],
    );
  }
}
