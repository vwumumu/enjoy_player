// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'window_fullscreen_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tracks and controls the OS fullscreen state of the application window.
///
/// Listens to [WindowListener] callbacks so that the UI stays in sync even
/// when the user toggles fullscreen via OS mechanisms (e.g. F11 at OS level,
/// title-bar buttons on macOS, Windows keyboard shortcuts).

@ProviderFor(WindowFullscreen)
final windowFullscreenProvider = WindowFullscreenProvider._();

/// Tracks and controls the OS fullscreen state of the application window.
///
/// Listens to [WindowListener] callbacks so that the UI stays in sync even
/// when the user toggles fullscreen via OS mechanisms (e.g. F11 at OS level,
/// title-bar buttons on macOS, Windows keyboard shortcuts).
final class WindowFullscreenProvider
    extends $NotifierProvider<WindowFullscreen, bool> {
  /// Tracks and controls the OS fullscreen state of the application window.
  ///
  /// Listens to [WindowListener] callbacks so that the UI stays in sync even
  /// when the user toggles fullscreen via OS mechanisms (e.g. F11 at OS level,
  /// title-bar buttons on macOS, Windows keyboard shortcuts).
  WindowFullscreenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'windowFullscreenProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$windowFullscreenHash();

  @$internal
  @override
  WindowFullscreen create() => WindowFullscreen();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$windowFullscreenHash() => r'b6cb02231852532111b4bea14c0ce1001542272e';

/// Tracks and controls the OS fullscreen state of the application window.
///
/// Listens to [WindowListener] callbacks so that the UI stays in sync even
/// when the user toggles fullscreen via OS mechanisms (e.g. F11 at OS level,
/// title-bar buttons on macOS, Windows keyboard shortcuts).

abstract class _$WindowFullscreen extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
