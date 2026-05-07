/// Scrollable transcript with tap-to-seek and echo-aware highlighting.
library;

import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/subtitle/transcript_line.dart';
import '../../../l10n/app_localizations.dart';
import '../../player/application/display_position_provider.dart';
import '../../player/application/echo_mode_provider.dart';
import '../../player/application/player_interactions.dart';
import '../application/transcript_lines_provider.dart';
import '../application/transcript_repository_provider.dart';

class TranscriptPanel extends ConsumerWidget {
  const TranscriptPanel({required this.mediaId, super.key});

  final String mediaId;

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final pick = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['srt', 'vtt'],
    );
    if (pick == null || pick.files.isEmpty) return;
    final f = pick.files.single;
    final path = f.path;
    if (path == null) return;

    await ref.read(transcriptRepositoryProvider).importSubtitle(
          mediaId: mediaId,
          file: XFile(path),
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.transcript)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final linesAsync = ref.watch(transcriptLinesForMediaProvider(mediaId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Text(l10n.transcript, style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _import(context, ref),
                icon: const Icon(Icons.upload_file),
                label: Text(l10n.importSubtitle),
              ),
            ],
          ),
        ),
        Expanded(
          child: linesAsync.when(
            data: (lines) {
              if (lines.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.noTranscript,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(l10n.importSrtOrVtt, textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                );
              }
              return _TranscriptBody(lines: lines);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('${l10n.error}: $e')),
          ),
        ),
      ],
    );
  }
}

class _TranscriptBody extends ConsumerWidget {
  const _TranscriptBody({required this.lines});

  final List<TranscriptLine> lines;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final echo = ref.watch(echoModeProvider);
    final posAsync = ref.watch(displayPositionProvider);

    final t = switch (posAsync) {
      AsyncData(:final value) => value.inMilliseconds / 1000.0,
      _ => 0.0,
    };
    final active = _activeIndex(lines, t);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: lines.length,
      itemBuilder: (context, index) {
        final line = lines[index];
        final isActive = index == active;
        final inEcho = echo.active &&
            index >= echo.startLineIndex &&
            index <= echo.endLineIndex;
        final bg = inEcho
            ? Theme.of(context)
                .colorScheme
                .primaryContainer
                .withValues(alpha: 0.35)
            : isActive
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : null;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => ref
                  .read(playerInteractionsProvider.notifier)
                  .seekToLine(line, index),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  line.text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.normal,
                      ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  int _activeIndex(List<TranscriptLine> lines, double t) {
    for (var i = 0; i < lines.length; i++) {
      if (t >= lines[i].startSeconds && t < lines[i].endSeconds) return i;
    }
    for (var i = lines.length - 1; i >= 0; i--) {
      if (t >= lines[i].startSeconds) return i;
    }
    return -1;
  }
}
