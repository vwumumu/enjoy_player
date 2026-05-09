/// Audio-only layout: hero artwork with rim-light + transcript reading view.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:enjoy_player/core/theme/dynamic_color/dynamic_color_provider.dart';
import 'package:enjoy_player/core/theme/enjoy_tokens.dart';
import 'package:enjoy_player/core/theme/widgets/hero_artwork.dart';
import 'package:enjoy_player/core/utils/local_thumbnail.dart';
import 'package:enjoy_player/l10n/app_localizations.dart';

import '../../application/player_controller.dart';
import '../../application/player_state_providers.dart';

class AudioPlayerLayout extends ConsumerWidget {
  const AudioPlayerLayout({
    required this.transcript,
    super.key,
  });

  final Widget transcript;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = EnjoyThemeTokens.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(playerControllerProvider);
    final isPlayingAsync = ref.watch(playerIsPlayingProvider);
    final isPlaying = isPlayingAsync.value ?? false;
    final paletteAsync = ref.watch(currentArtworkPaletteProvider);
    final accent = paletteAsync.value?.accent;

    final thumbFile = localThumbnailFile(session?.thumbnailUrl);

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 520;
        final artworkSize = wide ? 240.0 : 180.0;

        // Add top padding for extendBodyBehindAppBar
        final topPad = MediaQuery.of(context).padding.top + kToolbarHeight;

        return SingleChildScrollView(
          padding: EdgeInsets.only(top: topPad),
          child: Column(
            children: [
              SizedBox(height: t.space32),
              // Hero artwork with dynamic rim light
              Center(
                child: HeroArtwork(
                  size: artworkSize,
                  thumbnailFile: thumbFile,
                  isVideo: false,
                  accentColor: accent,
                  isPlaying: isPlaying,
                ),
              ),
              SizedBox(height: t.space8),
              // "Now Reading" label
              if (session != null) ...[
                SizedBox(height: t.space24),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: t.space24),
                  child: Row(
                    children: [
                      Text(
                        l10n.transcriptNowReading.toUpperCase(),
                        style: tt.labelSmall?.copyWith(
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w600,
                          color: accent ?? cs.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: t.space8),
              ],
              // Transcript
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: t.contentMaxWidth),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: t.space12),
                  child: transcript,
                ),
              ),
              SizedBox(height: t.space40),
            ],
          ),
        );
      },
    );
  }
}
