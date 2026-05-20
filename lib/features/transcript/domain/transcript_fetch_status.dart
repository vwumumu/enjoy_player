/// UI and persistence status for transcript resolution on media open.
library;

enum TranscriptFetchStatus { idle, loading, success, empty, error }

/// Observed fetch lifecycle for a single media item.
class TranscriptFetchUiState {
  const TranscriptFetchUiState({
    this.status = TranscriptFetchStatus.idle,
    this.errorMessage,
  });

  final TranscriptFetchStatus status;
  final String? errorMessage;

  bool get isLoading => status == TranscriptFetchStatus.loading;

  TranscriptFetchUiState copyWith({
    TranscriptFetchStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TranscriptFetchUiState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  static TranscriptFetchStatus fromPersisted(String? raw) {
    switch (raw) {
      case 'success':
        return TranscriptFetchStatus.success;
      case 'empty':
        return TranscriptFetchStatus.empty;
      case 'error':
        return TranscriptFetchStatus.error;
      default:
        return TranscriptFetchStatus.idle;
    }
  }

  static String toPersisted(TranscriptFetchStatus status) {
    switch (status) {
      case TranscriptFetchStatus.success:
        return 'success';
      case TranscriptFetchStatus.empty:
        return 'empty';
      case TranscriptFetchStatus.error:
        return 'error';
      case TranscriptFetchStatus.idle:
      case TranscriptFetchStatus.loading:
        return 'success';
    }
  }
}

enum TranscriptCloudFetchStatus { skipped, success, empty, error }

/// Result of the cloud / Worker transcript fetch step.
class TranscriptCloudFetchResult {
  const TranscriptCloudFetchResult({
    required this.status,
    this.storedCount = 0,
    this.errorMessage,
  });

  final TranscriptCloudFetchStatus status;
  final int storedCount;
  final String? errorMessage;
}

/// Combined result of [TranscriptRepository.resolveOnOpen].
class TranscriptResolveResult {
  const TranscriptResolveResult({
    required this.hasTracks,
    this.cloud = const TranscriptCloudFetchResult(
      status: TranscriptCloudFetchStatus.skipped,
    ),
    this.errorMessage,
  });

  final bool hasTracks;
  final TranscriptCloudFetchResult cloud;
  final String? errorMessage;

  TranscriptFetchStatus get uiStatus {
    if (errorMessage != null) return TranscriptFetchStatus.error;
    switch (cloud.status) {
      case TranscriptCloudFetchStatus.error:
        return TranscriptFetchStatus.error;
      case TranscriptCloudFetchStatus.skipped:
        return hasTracks
            ? TranscriptFetchStatus.success
            : TranscriptFetchStatus.empty;
      case TranscriptCloudFetchStatus.success:
        return TranscriptFetchStatus.success;
      case TranscriptCloudFetchStatus.empty:
        return hasTracks
            ? TranscriptFetchStatus.success
            : TranscriptFetchStatus.empty;
    }
  }
}
