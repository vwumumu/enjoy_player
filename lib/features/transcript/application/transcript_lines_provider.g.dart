// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transcript_lines_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(transcriptLinesForMedia)
final transcriptLinesForMediaProvider = TranscriptLinesForMediaFamily._();

final class TranscriptLinesForMediaProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TranscriptLine>>,
          List<TranscriptLine>,
          Stream<List<TranscriptLine>>
        >
    with
        $FutureModifier<List<TranscriptLine>>,
        $StreamProvider<List<TranscriptLine>> {
  TranscriptLinesForMediaProvider._({
    required TranscriptLinesForMediaFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'transcriptLinesForMediaProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$transcriptLinesForMediaHash();

  @override
  String toString() {
    return r'transcriptLinesForMediaProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<TranscriptLine>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TranscriptLine>> create(Ref ref) {
    final argument = this.argument as String;
    return transcriptLinesForMedia(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TranscriptLinesForMediaProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$transcriptLinesForMediaHash() =>
    r'71d952bc18a5870356504921ad2d263f0b0b7ff7';

final class TranscriptLinesForMediaFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<TranscriptLine>>, String> {
  TranscriptLinesForMediaFamily._()
    : super(
        retry: null,
        name: r'transcriptLinesForMediaProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TranscriptLinesForMediaProvider call(String mediaId) =>
      TranscriptLinesForMediaProvider._(argument: mediaId, from: this);

  @override
  String toString() => r'transcriptLinesForMediaProvider';
}
