// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'youtube_auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(youtubeLoginState)
final youtubeLoginStateProvider = YoutubeLoginStateProvider._();

final class YoutubeLoginStateProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  YoutubeLoginStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'youtubeLoginStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$youtubeLoginStateHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return youtubeLoginState(ref);
  }
}

String _$youtubeLoginStateHash() => r'a49735614df411d0a2fda2c698eb677bf9d8822f';
