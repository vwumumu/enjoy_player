import 'package:enjoy_player/features/auth/domain/auth_platform_support.dart';
import 'package:enjoy_player/features/auth/domain/google_auth_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GoogleSignInService Apple guard', () {
    tearDown(() => debugDefaultTargetPlatformOverride = null);

    test('nativeGoogleSignInSupported is true on Apple targets once '
        'kGoogleNativeSignInConfiguredOnApple is true, so sign-in UI and service '
        'may call into the native SDK', () {
      expect(kGoogleNativeSignInConfiguredOnApple, isTrue);

      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(nativeGoogleSignInSupported, isTrue);

      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      expect(nativeGoogleSignInSupported, isTrue);
    });
  });
}
