/// Full-width bottom transport: progress, times, artwork, play ring, tools.
library;

import 'dart:io' show File, Platform;

import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'package:enjoy_player/core/logging/log.dart';
import 'package:enjoy_player/core/theme/enjoy_tokens.dart';
import 'package:enjoy_player/core/theme/widgets/glass_surface.dart';
import 'package:enjoy_player/l10n/app_localizations.dart';

import '../../../transcript/application/all_transcripts_provider.dart';
import '../../../transcript/presentation/subtitle_track_picker_sheet.dart';
import '../../application/display_position_provider.dart';
import '../../application/echo_mode_provider.dart';
import '../../application/player_controller.dart';
import '../../application/player_interactions.dart';
import '../../application/player_preferences_provider.dart';
import '../../application/player_ui_provider.dart';
import '../../domain/playback_session.dart';
import '../../domain/player_settings.dart';

final _log = logNamed('GlobalTransportBar');

class GlobalTransportBar extends ConsumerStatefulWidget {
  const GlobalTransportBar({super.key});

  @override
  ConsumerState<GlobalTransportBar> createState() => _GlobalTransportBarState();
}

class _GlobalTransportBarState extends ConsumerState<GlobalTransportBar> {
  bool _sliderHovered = false;
  bool _volumeHovered = false;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(playerControllerProvider);
    final ui = ref.watch(playerUiProvider);
    final prefs = ref.watch(playerPreferencesCtrlProvider);
    final echo = ref.watch(echoModeProvider);
    final l10n = AppLocalizations.of(context)!;
    final t = EnjoyThemeTokens.of(context);
    final cs = Theme.of(context).colorScheme;
    final path = GoRouterState.of(context).uri.path;
    final onPlayer = path.startsWith('/player/');

    if (session == null) return const SizedBox.shrink();

    final durationSec =
        session.durationSeconds > 0 ? session.durationSeconds : 1.0;

    final posAsync = ref.watch(displayPositionProvider);
    final pos = switch (posAsync) {
      AsyncData(:final value) => value,
      _ => Duration.zero,
    };

    final value =
        durationSec > 0 ? pos.inMilliseconds / 1000 / durationSec : 0.0;

    final inner = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TransportProgressStrip(
          session: session,
          position: pos,
          fraction: value.clamp(0, 1),
          hovered: _sliderHovered,
          onHoverChanged: (v) => setState(() => _sliderHovered = v),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(t.space12, t.space4, t.space12, t.space12),
          child: SizedBox(
            height: 56,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _TransportArtwork(session: session),
                        SizedBox(width: t.space12),
                        Flexible(
                          child: InkWell(
                            onTap: () => context.push('/player/${session.mediaId}'),
                            borderRadius: BorderRadius.circular(t.radiusSm),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: t.space4,
                                horizontal: t.space4,
                              ),
                              child: _TransportMeta(session: session),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: l10n.previousLine,
                      iconSize: 22,
                      onPressed:
                          ui.isBuffering
                              ? null
                              : () => ref
                                  .read(playerInteractionsProvider.notifier)
                                  .prevLine(),
                      icon: const Icon(Icons.skip_previous_rounded),
                    ),
                    _PlayRingButton(
                      playing: ui.isPlaying,
                      buffering: ui.isBuffering,
                      onPressed:
                          ui.isBuffering
                              ? null
                              : () => ref
                                  .read(playerControllerProvider.notifier)
                                  .togglePlay(),
                    ),
                    IconButton(
                      tooltip: l10n.nextLine,
                      iconSize: 22,
                      onPressed:
                          ui.isBuffering
                              ? null
                              : () => ref
                                  .read(playerInteractionsProvider.notifier)
                                  .nextLine(),
                      icon: const Icon(Icons.skip_next_rounded),
                    ),
                    _RepeatButton(
                      mode: prefs.repeatMode,
                      tooltip: l10n.transportRepeat,
                      onPressed: () {
                        final next = switch (prefs.repeatMode) {
                          RepeatMode.none => RepeatMode.single,
                          RepeatMode.single => RepeatMode.segment,
                          RepeatMode.segment => RepeatMode.none,
                        };
                        ref.read(playerPreferencesCtrlProvider.notifier).setRepeatMode(next);
                      },
                    ),
                  ],
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: l10n.echoMode,
                            color: echo.active ? t.echoActive : null,
                            style:
                                echo.active
                                    ? IconButton.styleFrom(
                                      backgroundColor: t.echoActive.withValues(alpha: 0.18),
                                    )
                                    : null,
                            onPressed:
                                () => ref
                                    .read(playerInteractionsProvider.notifier)
                                    .toggleEcho(),
                            icon: const Icon(Icons.mic_none_rounded),
                          ),
                          _CcButton(mediaId: session.mediaId),
                          PopupMenuButton<double>(
                            tooltip: l10n.speed,
                            onSelected: (rate) => ref
                                .read(playerPreferencesCtrlProvider.notifier)
                                .setPlaybackRate(rate),
                            itemBuilder:
                                (ctx) => [
                                  for (final r in [0.5, 0.75, 1.0, 1.25, 1.5, 2.0])
                                    PopupMenuItem(value: r, child: Text('${r}x')),
                                ],
                            child: Padding(
                              padding: EdgeInsets.all(t.space8),
                              child: Icon(Icons.speed_rounded, color: cs.onSurfaceVariant),
                            ),
                          ),
                          MouseRegion(
                            onEnter: (_) => setState(() => _volumeHovered = true),
                            onExit: (_) => setState(() => _volumeHovered = false),
                            child: AnimatedCrossFade(
                              duration: t.motionFast,
                              crossFadeState:
                                  _volumeHovered
                                      ? CrossFadeState.showSecond
                                      : CrossFadeState.showFirst,
                              firstChild: IconButton(
                                tooltip: l10n.volume,
                                icon: Icon(
                                  prefs.volume <= 0.01
                                      ? Icons.volume_off_rounded
                                      : Icons.volume_up_rounded,
                                ),
                                onPressed: () {},
                              ),
                              secondChild: SizedBox(
                                width: 132,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.volume_down_rounded,
                                      size: 18,
                                      color: cs.onSurfaceVariant,
                                    ),
                                    Expanded(
                                      child: SliderTheme(
                                        data: SliderTheme.of(context).copyWith(
                                          trackHeight: 3,
                                          thumbShape: const RoundSliderThumbShape(
                                            enabledThumbRadius: 6,
                                          ),
                                          overlayShape: const RoundSliderOverlayShape(
                                            overlayRadius: 12,
                                          ),
                                        ),
                                        child: Slider(
                                          value: prefs.volume,
                                          onChanged:
                                              (v) => ref
                                                  .read(
                                                    playerPreferencesCtrlProvider.notifier,
                                                  )
                                                  .setVolume(v),
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.volume_up_rounded,
                                      size: 18,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: l10n.transportFullscreen,
                            icon: const Icon(Icons.fullscreen_rounded),
                            onPressed: () => _log.fine('fullscreen toggled (stub)'),
                          ),
                          IconButton(
                            tooltip:
                                onPlayer ? l10n.transportCollapse : l10n.transportExpand,
                            icon: Icon(
                              onPlayer ? Icons.expand_more_rounded : Icons.open_in_full_rounded,
                            ),
                            onPressed: () {
                              if (onPlayer) {
                                ref.read(playerUiProvider.notifier).collapse();
                                context.pop();
                              } else {
                                context.push('/player/${session.mediaId}');
                              }
                            },
                          ),
                          PopupMenuButton<String>(
                            tooltip: l10n.transportMore,
                            itemBuilder:
                                (ctx) => [
                                  PopupMenuItem(
                                    value: 'replay',
                                    child: Text(l10n.replayLine),
                                  ),
                                ],
                            onSelected: (v) {
                              if (v == 'replay') {
                                ref.read(playerInteractionsProvider.notifier).replayLine();
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.all(t.space8),
                              child: Icon(Icons.more_horiz_rounded, color: cs.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    return GlassSurface(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: inner,
      ),
    );
  }
}

class _TransportProgressStrip extends ConsumerWidget {
  const _TransportProgressStrip({
    required this.session,
    required this.position,
    required this.fraction,
    required this.hovered,
    required this.onHoverChanged,
  });

  final PlaybackSession session;
  final Duration position;
  final double fraction;
  final bool hovered;
  final ValueChanged<bool> onHoverChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final durationSec =
        session.durationSeconds > 0 ? session.durationSeconds : 1.0;

    return MouseRegion(
      onEnter: (_) => onHoverChanged(true),
      onExit: (_) => onHoverChanged(false),
      child: SizedBox(
        height: 26,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.centerLeft,
          children: [
            Positioned(
              left: 10,
              right: 10,
              bottom: 2,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  thumbShape: RoundSliderThumbShape(
                    enabledThumbRadius: hovered ? 6 : 0,
                  ),
                  overlayShape: SliderComponentShape.noOverlay,
                  activeTrackColor: cs.primary,
                  inactiveTrackColor: cs.onSurface.withValues(alpha: 0.12),
                  thumbColor: cs.primary,
                ),
                child: Slider(
                  value: fraction.clamp(0, 1),
                  onChanged:
                      (v) => ref
                          .read(playerInteractionsProvider.notifier)
                          .seekToProgressFraction(v),
                ),
              ),
            ),
            Positioned(
              left: 12,
              top: 2,
              child: Text(
                _fmtDurationFull(position),
                style: tt.labelSmall?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
            Positioned(
              right: 12,
              top: 2,
              child: Text(
                _fmtDurationFull(
                  Duration(milliseconds: (durationSec * 1000).round()),
                ),
                style: tt.labelSmall?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransportMeta extends ConsumerWidget {
  const _TransportMeta({required this.session});

  final PlaybackSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final posAsync = ref.watch(displayPositionProvider);
    final pos = switch (posAsync) {
      AsyncData(:final value) => value,
      _ => Duration.zero,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          session.mediaTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(
          '${_fmtDurationFull(pos)} / ${_fmtDurationFull(Duration(milliseconds: (session.durationSeconds * 1000).round()))}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: tt.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _TransportArtwork extends ConsumerWidget {
  const _TransportArtwork({required this.session});

  final PlaybackSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isVideo = session.mediaType == 'video';
    const width = 64.0;
    const height = 40.0;

    Widget content;
    if (isVideo) {
      final controller = ref.read(playerControllerProvider.notifier).videoController;
      content = ColoredBox(
        color: Colors.black,
        child: ExcludeSemantics(
          child: Video(
            controller: controller,
            controls: NoVideoControls,
            width: width,
            height: height,
            fit: BoxFit.cover,
            fill: Colors.black,
            wakelock: false,
          ),
        ),
      );
    } else {
      final thumb = _thumbnailFile(session.thumbnailUrl);
      if (thumb != null) {
        content = Image.file(
          thumb,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _fallbackArt(cs, isVideo: false),
        );
      } else {
        content = _fallbackArt(cs, isVideo: false);
      }
    }

    return Semantics(
      label: isVideo ? l10n.miniPlayerMediaVideo : l10n.miniPlayerMediaAudio,
      child: SizedBox(
        width: width,
        height: height,
        child: Material(
          color: Colors.transparent,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.4)),
          ),
          child: InkWell(
            onTap: () => context.push('/player/${session.mediaId}'),
            child: content,
          ),
        ),
      ),
    );
  }

  Widget _fallbackArt(ColorScheme cs, {required bool isVideo}) {
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
          size: 22,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }

  File? _thumbnailFile(String? path) {
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

class _PlayRingButton extends StatelessWidget {
  const _PlayRingButton({
    required this.playing,
    required this.buffering,
    required this.onPressed,
  });

  final bool playing;
  final bool buffering;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Tooltip(
        message: playing ? l10n.pause : l10n.play,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: Ink(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: cs.primary, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.28),
                    blurRadius: 14,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Center(
                child:
                    buffering
                        ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cs.primary,
                          ),
                        )
                        : Icon(
                          playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: cs.onSurface,
                          size: 26,
                        ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RepeatButton extends StatelessWidget {
  const _RepeatButton({
    required this.mode,
    required this.tooltip,
    required this.onPressed,
  });

  final RepeatMode mode;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final icon = switch (mode) {
      RepeatMode.none => Icons.repeat_rounded,
      RepeatMode.single => Icons.repeat_one_rounded,
      RepeatMode.segment => Icons.repeat_rounded,
    };
    final active = mode != RepeatMode.none;
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon, color: active ? cs.primary : cs.onSurfaceVariant),
      style:
          active
              ? IconButton.styleFrom(
                backgroundColor: cs.primaryContainer.withValues(alpha: 0.45),
              )
              : null,
      onPressed: onPressed,
    );
  }
}

class _CcButton extends ConsumerWidget {
  const _CcButton({required this.mediaId});

  final String mediaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracksAsync = ref.watch(allTranscriptsForMediaProvider(mediaId));
    final hasTrack = (tracksAsync.value ?? []).isNotEmpty;
    final l10n = AppLocalizations.of(context)!;
    final t = EnjoyThemeTokens.of(context);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: l10n.subtitles,
          icon: const Icon(Icons.closed_caption_outlined),
          onPressed: () => showSubtitleTrackPicker(context, ref, mediaId),
        ),
        if (hasTrack)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: t.ccBadge,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

String _fmtDurationFull(Duration d) {
  String two(int n) => n.toString().padLeft(2, '0');
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60);
  if (h > 0) return '${two(h)}:${two(m)}:${two(s)}';
  return '${two(m)}:${two(s)}';
}
