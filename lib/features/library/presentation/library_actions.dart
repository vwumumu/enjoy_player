/// Shared import flow for Home / Library.
library;

import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:enjoy_player/features/library/application/library_repository_provider.dart';

Future<void> importMediaFromPicker(BuildContext context, WidgetRef ref) async {
  final pick = await FilePicker.pickFiles(type: FileType.media);
  if (pick == null || pick.files.isEmpty) return;
  final path = pick.files.single.path;
  if (path == null) return;
  final id = await ref.read(mediaLibraryRepositoryProvider).importMedia(XFile(path));
  if (context.mounted) {
    context.push('/player/$id');
  }
}
