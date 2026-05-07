// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_ui_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlayerUi)
const playerUiProvider = PlayerUiProvider._();

final class PlayerUiProvider
    extends $NotifierProvider<PlayerUi, PlayerUiState> {
  const PlayerUiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerUiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerUiHash();

  @$internal
  @override
  PlayerUi create() => PlayerUi();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlayerUiState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlayerUiState>(value),
    );
  }
}

String _$playerUiHash() => r'0c8da397bc7c2e13bd281340b8eadf600c4a2ac7';

abstract class _$PlayerUi extends $Notifier<PlayerUiState> {
  PlayerUiState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<PlayerUiState, PlayerUiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PlayerUiState, PlayerUiState>,
              PlayerUiState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
