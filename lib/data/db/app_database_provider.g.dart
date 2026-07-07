// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Device-global Drift DB (`enjoy_player`) — API base URL, diagnostics, and
/// other settings that must be readable before sign-in (ADR-0012, ADR-0031).
///
/// Kept separate from [appDatabaseProvider] so [ApiBaseUrl] does not depend on
/// auth-scoped DB (avoids Riverpod cycles with [authCtrlProvider]).

@ProviderFor(deviceGlobalAppDatabase)
final deviceGlobalAppDatabaseProvider = DeviceGlobalAppDatabaseProvider._();

/// Device-global Drift DB (`enjoy_player`) — API base URL, diagnostics, and
/// other settings that must be readable before sign-in (ADR-0012, ADR-0031).
///
/// Kept separate from [appDatabaseProvider] so [ApiBaseUrl] does not depend on
/// auth-scoped DB (avoids Riverpod cycles with [authCtrlProvider]).

final class DeviceGlobalAppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  /// Device-global Drift DB (`enjoy_player`) — API base URL, diagnostics, and
  /// other settings that must be readable before sign-in (ADR-0012, ADR-0031).
  ///
  /// Kept separate from [appDatabaseProvider] so [ApiBaseUrl] does not depend on
  /// auth-scoped DB (avoids Riverpod cycles with [authCtrlProvider]).
  DeviceGlobalAppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceGlobalAppDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceGlobalAppDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return deviceGlobalAppDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$deviceGlobalAppDatabaseHash() =>
    r'86a373429642aeb371e25fd31d82629a0bef6491';

/// Per-user library + prefs (`enjoy_player_<userId>`). Requires sign-in
/// (ADR-0031 login-only access); use [deviceGlobalAppDatabaseProvider] for
/// device-global settings.

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

/// Per-user library + prefs (`enjoy_player_<userId>`). Requires sign-in
/// (ADR-0031 login-only access); use [deviceGlobalAppDatabaseProvider] for
/// device-global settings.

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  /// Per-user library + prefs (`enjoy_player_<userId>`). Requires sign-in
  /// (ADR-0031 login-only access); use [deviceGlobalAppDatabaseProvider] for
  /// device-global settings.
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'798886c51a483a4cf3d0a80d1bbbc5a9a764439f';
