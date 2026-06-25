/// Fixed 9:16 branded practice poster layout for export and preview.
library;

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:enjoy_player/core/theme/colors.dart';
import 'package:enjoy_player/core/theme/generative_media_cover.dart';
import 'package:enjoy_player/core/theme/widgets/enjoy_logo.dart';
import 'package:enjoy_player/core/utils/time_format.dart';
import 'package:enjoy_player/features/share_poster/domain/practice_poster_data.dart';

/// User-visible poster strings (from l10n).
class PracticePosterLabels {
  const PracticePosterLabels({
    required this.tagline,
    required this.takesLabel,
    required this.sentencesLabel,
    required this.spokenLabel,
    required this.qrHint,
  });

  final String tagline;
  final String takesLabel;
  final String sentencesLabel;
  final String spokenLabel;
  final String qrHint;
}

class PracticePosterWidget extends StatelessWidget {
  const PracticePosterWidget({
    super.key,
    required this.data,
    required this.labels,
    this.onCoverReady,
  });

  final PracticePosterData data;
  final PracticePosterLabels labels;
  final VoidCallback? onCoverReady;

  @override
  Widget build(BuildContext context) {
    final accent = generativeAccentForSeed(data.coverSeed);
    final hasQuote = data.quote != null && !data.quote!.isEmpty;
    final denseContent = hasQuote && data.quote!.hasMultiple;

    return SizedBox(
      width: practicePosterLogicalWidth,
      height: practicePosterLogicalHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.gradientStartDark,
              AppColors.gradientEndDark,
              accent.withValues(alpha: 0.08),
            ],
            stops: const [0.0, 0.72, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const EnjoyLogo(size: 28),
                  const Spacer(),
                  Text(
                    labels.tagline,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brandOnDark.withValues(alpha: 0.85),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              SizedBox(height: denseContent ? 14 : 18),
              AspectRatio(
                aspectRatio: denseContent ? 2.12 : 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.32),
                          blurRadius: 22,
                          spreadRadius: -6,
                        ),
                      ],
                    ),
                    child: PracticePosterCover(
                      data: data,
                      onCoverReady: onCoverReady,
                    ),
                  ),
                ),
              ),
              SizedBox(height: denseContent ? 12 : 14),
              Text(
                data.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.28,
                  color: Colors.white,
                ),
              ),
              if (hasQuote) ...[
                SizedBox(height: denseContent ? 12 : 14),
                _PracticePosterQuoteBlock(
                  quote: data.quote!,
                  accent: accent,
                ),
              ],
              SizedBox(height: denseContent ? 22 : 20),
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      value: '${data.takes}',
                      label: labels.takesLabel,
                      accent: accent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatTile(
                      value: '${data.sentencesPracticed}',
                      label: labels.sentencesLabel,
                      accent: accent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatTile(
                      value: formatPracticeDurationMs(data.spokenDurationMs),
                      label: labels.spokenLabel,
                      accent: accent,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Divider(
                height: 24,
                thickness: 1,
                color: accent.withValues(alpha: 0.18),
              ),
              _PracticePosterFooter(labels: labels, accent: accent),
            ],
          ),
        ),
      ),
    );
  }
}

class _PracticePosterQuoteBlock extends StatelessWidget {
  const _PracticePosterQuoteBlock({
    required this.quote,
    required this.accent,
  });

  final PracticePosterQuote quote;
  final Color accent;

  static const _maxQuoteLines = 2;

  static TextStyle _quoteTextStyle({
    required double opacity,
    double fontSize = 15,
  }) {
    return GoogleFonts.playfairDisplay(
      fontSize: fontSize,
      height: 1.42,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.italic,
      color: Colors.white.withValues(alpha: opacity),
      letterSpacing: 0.15,
    );
  }

  @override
  Widget build(BuildContext context) {
    final lines = quote.lines.take(_maxQuoteLines).toList(growable: false);
    final perLineMax = lines.length > 1 ? 1 : _maxQuoteLines;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Text(
            '“',
            style: GoogleFonts.playfairDisplay(
              fontSize: 34,
              height: 0.85,
              fontWeight: FontWeight.w700,
              color: accent.withValues(alpha: 0.45),
            ),
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < lines.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                Text(
                  lines[i].displayText,
                  maxLines: perLineMax,
                  overflow: TextOverflow.ellipsis,
                  style: _quoteTextStyle(
                    opacity: i == 0 ? 0.96 : 0.72,
                    fontSize: i == 0 ? 15 : 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PracticePosterFooter extends StatelessWidget {
  const _PracticePosterFooter({
    required this.labels,
    required this.accent,
  });

  final PracticePosterLabels labels;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.18),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: QrImageView(
              data: practicePosterDownloadUrl,
              size: 68,
              backgroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            labels.qrHint,
            style: TextStyle(
              fontSize: 11.5,
              height: 1.35,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
        ),
      ],
    );
  }
}

class PracticePosterCover extends StatefulWidget {
  const PracticePosterCover({
    super.key,
    required this.data,
    this.onCoverReady,
  });

  final PracticePosterData data;
  final VoidCallback? onCoverReady;

  @override
  State<PracticePosterCover> createState() => _PracticePosterCoverState();
}

class _PracticePosterCoverState extends State<PracticePosterCover> {
  var _readyNotified = false;

  void _notifyReadyOnce() {
    if (_readyNotified) return;
    _readyNotified = true;
    widget.onCoverReady?.call();
  }

  @override
  Widget build(BuildContext context) {
    final localPath = widget.data.localThumbnailPath;
    if (localPath != null && localPath.isNotEmpty) {
      final file = File(localPath);
      if (file.existsSync()) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _notifyReadyOnce();
        });
        return Image.file(file, fit: BoxFit.cover);
      }
    }

    final url = widget.data.networkThumbnailUrl;
    if (url != null && url.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, _) => GenerativeMediaCover(
          seed: widget.data.coverSeed,
          isVideo: widget.data.isVideo,
        ),
        errorWidget: (_, _, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _notifyReadyOnce();
          });
          return GenerativeMediaCover(
            seed: widget.data.coverSeed,
            isVideo: widget.data.isVideo,
          );
        },
        imageBuilder: (context, imageProvider) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _notifyReadyOnce();
          });
          return DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            ),
          );
        },
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyReadyOnce();
    });
    return GenerativeMediaCover(
      seed: widget.data.coverSeed,
      isVideo: widget.data.isVideo,
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.accent,
  });

  final String value;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
        child: Column(
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 1.1,
                color: Colors.white,
                letterSpacing: 0.15,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                height: 1.2,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.62),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
