/// Compact player bar shown at the bottom of every non-player route.
///
/// Layout (Windows Media Player inspired):
///
///   ─────── progress slider (full-bleed) ───────
///   [frame]  Title                  ⏮  ⏯  ⏭  ⤢
///            mm:ss / mm:ss
library;

import 'dart:io' show File, Platform;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'package:enjoy_player/core/theme/enjoy_tokens.dart';
import 'package:enjoy_player/l10n/app_localizations.dart';

import '../application/display_position_provider.dart';
import '../application/player_controller.dart';
import '../application/player_interactions.dart';
import '../application/player_ui_provider.dart';
import '../domain/playback_session.dart';

class MiniPlayerBar extends ConsumerWidget {
  const MiniPlayerBar({super.key});

  /// Height of the small media frame on the leading edge.
  static const double _frameWidth = 64;
  static const double _frameHeight = 40;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(playerControllerProvider);
    final ui = ref.watch(playerUiProvider);
    if (session == null) return const SizedBox.shrink();
    if (ui.mode == PlayerChromeMode.expanded) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final t = EnjoyThemeTokens.of(context);
    final l10n = AppLocalizations.of(context)!;

    final inner = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _MiniProgressBar(),
        Padding(
          padding: EdgeInsets.fromLTRB(
            t.space12,
            t.space4,
            t.space8,
            t.space8,
          ),
          child: Row(
            children: [
              _MiniMediaFrame(
                session: session,
                width: _frameWidth,
                height: _frameHeight,
                onTap: () => context.push('/player/${session.mediaId}'),
              ),
              SizedBox(width: t.space12),
              Expanded(
                child: InkWell(
                  onTap: () => context.push('/player/${session.mediaId}'),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: t.space4,
                      horizontal: t.space4,
                    ),
                    child: _MiniMeta(session: session),
                  ),
                ),
              ),
              const _MiniTransportControls(),
              IconButton(
                tooltip: l10n.miniPlayerOpen,
                onPressed: () => context.push('/player/${session.mediaId}'),
                icon: const Icon(Icons.open_in_full_rounded),
              ),
            ],
          ),
        ),
      ],
    );

    final surfaceColor = cs.surfaceContainerHigh.withValues(
      alpha: Theme.of(context).brightness == Brightness.dark ? 0.58 : 0.86,
    );

    if (t.miniBarBlurSigma <= 0) {
      return Material(
        elevation: t.elevationBar,
        color: cs.surfaceContainerHigh,
        child: inner,
      );
    }

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: t.miniBarBlurSigma,
          sigmaY: t.miniBarBlurSigma,
        ),
        child: Material(
          elevation: t.elevationBar,
          color: surfaceColor,
          surfaceTintColor: cs.surfaceTint.withValues(alpha: 0.12),
          shadowColor: Colors.black26,
          child: inner,
        ),
      ),
    );
  }
}

/// Full-bleed thin progress slider rendered along the top edge of the bar.
class _MiniProgressBar extends ConsumerWidget {
  const _MiniProgressBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(playerControllerProvider);
    final posAsync = ref.watch(displayPositionProvider);
    final cs = Theme.of(context).colorScheme;

    final pos = switch (posAsync) {
      AsyncData(:final value) => value,
      _ => Duration.zero,
    };
    final durationSec = (session?.durationSeconds ?? 0) > 0
        ? session!.durationSeconds
        : 1.0;
    final fraction = (pos.inMilliseconds / 1000 / durationSec).clamp(0.0, 1.0);

    return SizedBox(
      height: 16,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 3,
          activeTrackColor: cs.primary,
          inactiveTrackColor: cs.surfaceContainerHighest,
          overlayShape: SliderComponentShape.noOverlay,
          thumbShape: const RoundSliderThumbShape(
            enabledThumbRadius: 5,
            elevation: 1,
            pressedElevation: 2,
          ),
        ),
        child: Slider(
          value: fraction,
          onChanged: session == null
              ? null
              : (v) => ref
                    .read(playerInteractionsProvider.notifier)
                    .seekToProgressFraction(v),
        ),
      ),
    );
  }
}

/// Title + position/duration text block.
class _MiniMeta extends ConsumerWidget {
  const _MiniMeta({required this.session});

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
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          session.mediaTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Text(
          '${_fmtDuration(pos)} / ${_fmtDuration(Duration(milliseconds: (session.durationSeconds * 1000).round()))}',
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

/// Prev / play-pause / next controls.
class _MiniTransportControls extends ConsumerWidget {
  const _MiniTransportControls();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ui = ref.watch(playerUiProvider);
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: l10n.previousLine,
          iconSize: 22,
          onPressed: ui.isBuffering
              ? null
              : () => ref
                    .read(playerInteractionsProvider.notifier)
                    .prevLine(),
          icon: const Icon(Icons.skip_previous_rounded),
        ),
        IconButton.filled(
          tooltip: ui.isPlaying ? l10n.pause : l10n.play,
          iconSize: 26,
          style: IconButton.styleFrom(
            foregroundColor: cs.onPrimary,
            backgroundColor: cs.primary,
            disabledForegroundColor: cs.onSurface.withValues(alpha: 0.38),
            disabledBackgroundColor: cs.onSurface.withValues(alpha: 0.12),
          ),
          onPressed: ui.isBuffering
              ? null
              : () =>
                    ref.read(playerControllerProvider.notifier).togglePlay(),
          icon: Icon(
            ui.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          ),
        ),
        IconButton(
          tooltip: l10n.nextLine,
          iconSize: 22,
          onPressed: ui.isBuffering
              ? null
              : () => ref
                    .read(playerInteractionsProvider.notifier)
                    .nextLine(),
          icon: const Icon(Icons.skip_next_rounded),
        ),
      ],
    );
  }
}

/// Small video / artwork frame rendered on the leading edge.
///
/// For video sessions the live [VideoController] texture is rendered at a
/// reduced size — clicking it opens the expanded player. For audio (or video
/// without a frame) we fall back to a thumbnail image, then a media-type icon.
class _MiniMediaFrame extends ConsumerWidget {
  const _MiniMediaFrame({
    required this.session,
    required this.width,
    required this.height,
    required this.onTap,
  });

  final PlaybackSession session;
  final double width;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isVideo = session.mediaType == 'video';

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
      button: true,
      child: SizedBox(
        width: width,
        height: height,
        child: Material(
          color: Colors.transparent,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.4)),
          ),
          child: InkWell(
            onTap: onTap,
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
    // Defensive: only attempt file IO on host platforms with a real filesystem.
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
