// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transcript_line_recording_counts_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dexieTargetTypeForMedia)
final dexieTargetTypeForMediaProvider = DexieTargetTypeForMediaFamily._();

final class DexieTargetTypeForMediaProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  DexieTargetTypeForMediaProvider._({
    required DexieTargetTypeForMediaFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'dexieTargetTypeForMediaProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dexieTargetTypeForMediaHash();

  @override
  String toString() {
    return r'dexieTargetTypeForMediaProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as String;
    return dexieTargetTypeForMedia(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DexieTargetTypeForMediaProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dexieTargetTypeForMediaHash() =>
    r'545f88377972109adb99d70cdfabfaed3d4de93b';

final class DexieTargetTypeForMediaFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, String> {
  DexieTargetTypeForMediaFamily._()
    : super(
        retry: null,
        name: r'dexieTargetTypeForMediaProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DexieTargetTypeForMediaProvider call(String mediaId) =>
      DexieTargetTypeForMediaProvider._(argument: mediaId, from: this);

  @override
  String toString() => r'dexieTargetTypeForMediaProvider';
}

/// Map of transcript line index → overlapping recording count for [mediaId].

@ProviderFor(transcriptLineRecordingCounts)
final transcriptLineRecordingCountsProvider =
    TranscriptLineRecordingCountsFamily._();

/// Map of transcript line index → overlapping recording count for [mediaId].

final class TranscriptLineRecordingCountsProvider
    extends $FunctionalProvider<Map<int, int>, Map<int, int>, Map<int, int>>
    with $Provider<Map<int, int>> {
  /// Map of transcript line index → overlapping recording count for [mediaId].
  TranscriptLineRecordingCountsProvider._({
    required TranscriptLineRecordingCountsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'transcriptLineRecordingCountsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$transcriptLineRecordingCountsHash();

  @override
  String toString() {
    return r'transcriptLineRecordingCountsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Map<int, int>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Map<int, int> create(Ref ref) {
    final argument = this.argument as String;
    return transcriptLineRecordingCounts(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<int, int> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<int, int>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TranscriptLineRecordingCountsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$transcriptLineRecordingCountsHash() =>
    r'9fc949e6cf32db5f423a612e638001bea9114272';

/// Map of transcript line index → overlapping recording count for [mediaId].

final class TranscriptLineRecordingCountsFamily extends $Family
    with $FunctionalFamilyOverride<Map<int, int>, String> {
  TranscriptLineRecordingCountsFamily._()
    : super(
        retry: null,
        name: r'transcriptLineRecordingCountsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Map of transcript line index → overlapping recording count for [mediaId].

  TranscriptLineRecordingCountsProvider call(String mediaId) =>
      TranscriptLineRecordingCountsProvider._(argument: mediaId, from: this);

  @override
  String toString() => r'transcriptLineRecordingCountsProvider';
}
