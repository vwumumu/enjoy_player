// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lookup_section_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(lookupSheetTranslation)
final lookupSheetTranslationProvider = LookupSheetTranslationFamily._();

final class LookupSheetTranslationProvider
    extends
        $FunctionalProvider<
          AsyncValue<TranslationResult>,
          TranslationResult,
          FutureOr<TranslationResult>
        >
    with
        $FutureModifier<TranslationResult>,
        $FutureProvider<TranslationResult> {
  LookupSheetTranslationProvider._({
    required LookupSheetTranslationFamily super.from,
    required LookupTranslationParams super.argument,
  }) : super(
         retry: null,
         name: r'lookupSheetTranslationProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$lookupSheetTranslationHash();

  @override
  String toString() {
    return r'lookupSheetTranslationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<TranslationResult> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TranslationResult> create(Ref ref) {
    final argument = this.argument as LookupTranslationParams;
    return lookupSheetTranslation(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LookupSheetTranslationProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lookupSheetTranslationHash() =>
    r'0be0954bf48bb3991c83b5422726d7fcdd8eca18';

final class LookupSheetTranslationFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<TranslationResult>,
          LookupTranslationParams
        > {
  LookupSheetTranslationFamily._()
    : super(
        retry: null,
        name: r'lookupSheetTranslationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LookupSheetTranslationProvider call(LookupTranslationParams params) =>
      LookupSheetTranslationProvider._(argument: params, from: this);

  @override
  String toString() => r'lookupSheetTranslationProvider';
}

@ProviderFor(lookupSheetContextual)
final lookupSheetContextualProvider = LookupSheetContextualFamily._();

final class LookupSheetContextualProvider
    extends
        $FunctionalProvider<
          AsyncValue<ContextualTranslationResult>,
          ContextualTranslationResult,
          FutureOr<ContextualTranslationResult>
        >
    with
        $FutureModifier<ContextualTranslationResult>,
        $FutureProvider<ContextualTranslationResult> {
  LookupSheetContextualProvider._({
    required LookupSheetContextualFamily super.from,
    required LookupContextualParams super.argument,
  }) : super(
         retry: null,
         name: r'lookupSheetContextualProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$lookupSheetContextualHash();

  @override
  String toString() {
    return r'lookupSheetContextualProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ContextualTranslationResult> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ContextualTranslationResult> create(Ref ref) {
    final argument = this.argument as LookupContextualParams;
    return lookupSheetContextual(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LookupSheetContextualProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lookupSheetContextualHash() =>
    r'd71db9f753c1d36df33806e93cc3b9cb31b85069';

final class LookupSheetContextualFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<ContextualTranslationResult>,
          LookupContextualParams
        > {
  LookupSheetContextualFamily._()
    : super(
        retry: null,
        name: r'lookupSheetContextualProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LookupSheetContextualProvider call(LookupContextualParams params) =>
      LookupSheetContextualProvider._(argument: params, from: this);

  @override
  String toString() => r'lookupSheetContextualProvider';
}

@ProviderFor(lookupSheetDictionary)
final lookupSheetDictionaryProvider = LookupSheetDictionaryFamily._();

final class LookupSheetDictionaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<DictionaryResult>,
          DictionaryResult,
          FutureOr<DictionaryResult>
        >
    with $FutureModifier<DictionaryResult>, $FutureProvider<DictionaryResult> {
  LookupSheetDictionaryProvider._({
    required LookupSheetDictionaryFamily super.from,
    required LookupDictionaryParams super.argument,
  }) : super(
         retry: null,
         name: r'lookupSheetDictionaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$lookupSheetDictionaryHash();

  @override
  String toString() {
    return r'lookupSheetDictionaryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<DictionaryResult> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DictionaryResult> create(Ref ref) {
    final argument = this.argument as LookupDictionaryParams;
    return lookupSheetDictionary(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LookupSheetDictionaryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lookupSheetDictionaryHash() =>
    r'a154874e74c68f877d87f9e0308246c406b51b5c';

final class LookupSheetDictionaryFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<DictionaryResult>,
          LookupDictionaryParams
        > {
  LookupSheetDictionaryFamily._()
    : super(
        retry: null,
        name: r'lookupSheetDictionaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LookupSheetDictionaryProvider call(LookupDictionaryParams params) =>
      LookupSheetDictionaryProvider._(argument: params, from: this);

  @override
  String toString() => r'lookupSheetDictionaryProvider';
}
