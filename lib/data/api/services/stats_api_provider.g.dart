// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_api_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(statsApi)
final statsApiProvider = StatsApiProvider._();

final class StatsApiProvider
    extends $FunctionalProvider<StatsApi, StatsApi, StatsApi>
    with $Provider<StatsApi> {
  StatsApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'statsApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$statsApiHash();

  @$internal
  @override
  $ProviderElement<StatsApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StatsApi create(Ref ref) {
    return statsApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StatsApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StatsApi>(value),
    );
  }
}

String _$statsApiHash() => r'33e4658443f75bd4daaabc5b221b3d51a1ee2ebe';
