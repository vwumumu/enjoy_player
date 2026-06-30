// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'secure_token_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(secureTokenStore)
final secureTokenStoreProvider = SecureTokenStoreProvider._();

final class SecureTokenStoreProvider
    extends
        $FunctionalProvider<
          SecureTokenStore,
          SecureTokenStore,
          SecureTokenStore
        >
    with $Provider<SecureTokenStore> {
  SecureTokenStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secureTokenStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secureTokenStoreHash();

  @$internal
  @override
  $ProviderElement<SecureTokenStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SecureTokenStore create(Ref ref) {
    return secureTokenStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SecureTokenStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SecureTokenStore>(value),
    );
  }
}

String _$secureTokenStoreHash() => r'9f99fbed56753b9fa04d0b8f632124afd2395e16';
