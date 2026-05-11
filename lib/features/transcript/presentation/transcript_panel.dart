/// Scrollable transcript with tap-to-seek and echo-aware highlighting.
library;

import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:enjoy_player/l10n/app_localizations.dart';
import 'package:enjoy_player/features/transcript/application/transcript_lines_provider.dart';
import 'package:enjoy_player/features/transcript/application/transcript_repository_provider.dart';
import 'package:enjoy_player/features/transcript/presentation/import_subtitle_language_dialog.dart';
import 'package:enjoy_player/features/transcript/presentation/transcript_empty_state.dart';
import 'package:enjoy_player/features/transcript/presentation/transcript_scrollable_list.dart';

class TranscriptPanel extends ConsumerWidget {
  const TranscriptPanel({required this.mediaId, super.key});

  final String mediaId;

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final pick = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['srt', 'vtt'],
    );
    if (pick == null || pick.files.isEmpty) return;
    final f = pick.files.single;
    final path = f.path;
    if (path == null) return;
    if (!context.mounted) return;

    final hint = languageHintFromSubtitleFileName(f.name);
    final lang = await showImportSubtitleLanguageDialog(
      context,
      initialLanguage: hint,
    );
    if (lang == null) return;
    final trimmed = lang.trim();
    if (trimmed.isEmpty) return;

    await ref.read(transcriptRepositoryProvider).importSubtitle(
          mediaId: mediaId,
          file: XFile(path),
          language: trimmed,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.importSubtitleSuccess),
        ),
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
        Expanded(
          child: linesAsync.when(
            data: (lines) {
              if (lines.isEmpty) {
                return TranscriptEmptyState(
                  onImport: () => _import(context, ref),
                );
              }
              return TranscriptScrollableList(mediaId: mediaId, lines: lines);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('${l10n.error}: $e')),
          ),
        ),
      ],
    );
  }
}
