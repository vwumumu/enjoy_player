// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_interactions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlayerInteractions)
const playerInteractionsProvider = PlayerInteractionsProvider._();

final class PlayerInteractionsProvider
    extends $NotifierProvider<PlayerInteractions, int> {
  const PlayerInteractionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerInteractionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerInteractionsHash();

  @$internal
  @override
  PlayerInteractions create() => PlayerInteractions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$playerInteractionsHash() =>
    r'f36adec998288dcc8560f2bd88584639eeaed663';

abstract class _$PlayerInteractions extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
