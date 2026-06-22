// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnostics_verbose_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DiagnosticsVerbose)
final diagnosticsVerboseProvider = DiagnosticsVerboseProvider._();

final class DiagnosticsVerboseProvider
    extends $AsyncNotifierProvider<DiagnosticsVerbose, bool> {
  DiagnosticsVerboseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'diagnosticsVerboseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$diagnosticsVerboseHash();

  @$internal
  @override
  DiagnosticsVerbose create() => DiagnosticsVerbose();
}

String _$diagnosticsVerboseHash() =>
    r'adee79bb3afb55c187a93b720f79b613f391c5ff';

abstract class _$DiagnosticsVerbose extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
