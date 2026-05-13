/// Opens the transcript dictionary / translation bottom sheet.
library;

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:enjoy_player/core/logging/log.dart';
import 'package:enjoy_player/features/lookup/domain/lookup_request.dart';
import 'package:enjoy_player/features/lookup/presentation/dictionary_lookup_sheet.dart';

part 'lookup_coordinator.g.dart';

final Logger _log = logNamed('lookup');

@Riverpod(keepAlive: true)
class LookupCoordinator extends _$LookupCoordinator {
  @override
  int build() => 0;

  Future<void> open(BuildContext context, LookupRequest request) async {
    if (!context.mounted) return;
    _log.fine('lookup sheet: "${request.selectedText}"');
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      useSafeArea: true,
      builder: (sheetContext) => DictionaryLookupSheet(request: request),
    );
  }
}
