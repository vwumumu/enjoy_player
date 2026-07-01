import 'package:enjoy_player/features/auth/domain/auth_platform_support.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('authPkceRedirectUri uses the custom scheme on mobile-like targets', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    expect(authPkceRedirectUri(), 'enjoyplayer://auth/callback');
  });

  test('authPkceRedirectUri uses the custom scheme on windows', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    expect(authPkceRedirectUri(), 'enjoyplayer://auth/callback');
  });

  test('nativeAppleSignInSupported only on Apple platforms', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    expect(nativeAppleSignInSupported, isTrue);

    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    expect(nativeAppleSignInSupported, isFalse);
  });
}
