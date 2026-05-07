// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'echo_mode_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EchoMode)
const echoModeProvider = EchoModeProvider._();

final class EchoModeProvider extends $NotifierProvider<EchoMode, EchoState> {
  const EchoModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'echoModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$echoModeHash();

  @$internal
  @override
  EchoMode create() => EchoMode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EchoState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EchoState>(value),
    );
  }
}

String _$echoModeHash() => r'89f533e1c564c8ade6b2a8594ffe39925edda73a';

abstract class _$EchoMode extends $Notifier<EchoState> {
  EchoState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<EchoState, EchoState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<EchoState, EchoState>,
              EchoState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
