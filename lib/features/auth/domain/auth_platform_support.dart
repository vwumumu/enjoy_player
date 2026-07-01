/// Which native auth providers are offered on the current platform.
library;

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

/// Google native SDK is unreliable on Windows desktop.
bool get nativeGoogleSignInSupported =>
    defaultTargetPlatform != TargetPlatform.windows;

/// Sign in with Apple is available on Apple platforms only.
bool get nativeAppleSignInSupported =>
    defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.macOS;

/// OAuth PKCE redirect URI for the current platform.
///
/// Always the custom URL scheme: the backend's client registry
/// (`config/native_auth_clients.yml` in enjoy_web) only whitelists
/// `enjoyplayer://auth/callback` (plus loopback URLs for dev). A universal
/// link (`https://enjoy.bot/app/auth/callback`) would also require the
/// backend to host `apple-app-site-association` / `assetlinks.json`, which
/// it does not.
String authPkceRedirectUri() => 'enjoyplayer://auth/callback';

/// Platform string sent to `POST /api/v1/auth/google`.
String? authGooglePlatformParam() {
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => 'android',
    TargetPlatform.iOS => 'ios',
    TargetPlatform.macOS => 'macos',
    _ => null,
  };
}
