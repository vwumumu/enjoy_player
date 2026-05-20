/// Observable transcript fetch lifecycle for a media item.
library;

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/db/app_database_provider.dart';
import '../../../data/db/media_target_resolver.dart';
import '../domain/transcript_fetch_status.dart';
import 'transcript_repository_provider.dart';

part 'transcript_fetch_controller.g.dart';

@Riverpod(keepAlive: true)
class TranscriptFetchCtrl extends _$TranscriptFetchCtrl {
  Future<void>? _inFlight;

  @override
  TranscriptFetchUiState build(String mediaId) {
    unawaited(_hydrateFromPersisted());
    return const TranscriptFetchUiState();
  }

  Future<void> _hydrateFromPersisted() async {
    final db = ref.read(appDatabaseProvider);
    final tt = await dexieTargetTypeForId(db, mediaId);
    if (tt == null) return;

    final row = await db.transcriptFetchStateDao.getForTarget(tt, mediaId);
    if (row == null || row.lastStatus == null) return;

    if (!ref.mounted) return;
    state = TranscriptFetchUiState(
      status: TranscriptFetchUiState.fromPersisted(row.lastStatus),
      errorMessage: row.lastError,
    );
  }

  Future<bool> _alreadyCloudFetched() async {
    final db = ref.read(appDatabaseProvider);
    final tt = await dexieTargetTypeForId(db, mediaId);
    if (tt == null) return false;
    final row = await db.transcriptFetchStateDao.getForTarget(tt, mediaId);
    if (row == null) return false;
    // Allow automatic retry on next open after a failed fetch.
    return row.lastStatus != 'error';
  }

  /// Resolves transcripts on media open (primary, sidecar, optional cloud).
  Future<void> resolveOnOpen({required bool signedIn}) async {
    if (_inFlight != null) {
      await _inFlight;
      return;
    }

    final shouldShowLoading = signedIn && !await _alreadyCloudFetched();
    if (shouldShowLoading && ref.mounted) {
      state = state.copyWith(
        status: TranscriptFetchStatus.loading,
        clearError: true,
      );
    }

    _inFlight = _runResolve(signedIn: signedIn, forceCloud: false);
    try {
      await _inFlight;
    } finally {
      _inFlight = null;
    }
  }

  /// Forces a cloud refresh from the subtitle picker or error retry.
  Future<void> refreshFromCloud({required bool signedIn}) async {
    if (_inFlight != null) {
      await _inFlight;
      return;
    }

    if (signedIn && ref.mounted) {
      state = state.copyWith(
        status: TranscriptFetchStatus.loading,
        clearError: true,
      );
    }

    _inFlight = _runResolve(signedIn: signedIn, forceCloud: true);
    try {
      await _inFlight;
    } finally {
      _inFlight = null;
    }
  }

  Future<void> _runResolve({
    required bool signedIn,
    required bool forceCloud,
  }) async {
    final repo = ref.read(transcriptRepositoryProvider);
    try {
      final result = await repo.resolveOnOpen(
        mediaId,
        forceCloud: forceCloud,
        fetchCloud: signedIn,
      );

      if (!ref.mounted) return;
      state = TranscriptFetchUiState(
        status: result.uiStatus,
        errorMessage: result.errorMessage,
      );
    } on Object catch (e) {
      if (!ref.mounted) return;
      state = TranscriptFetchUiState(
        status: TranscriptFetchStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}

/// Read-only alias for widgets that only need fetch status.
@riverpod
TranscriptFetchUiState transcriptFetchStatus(Ref ref, String mediaId) {
  return ref.watch(transcriptFetchCtrlProvider(mediaId));
}
