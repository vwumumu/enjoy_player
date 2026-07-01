/// Google OAuth client IDs for native Google Sign-In.
///
/// These are public OAuth client identifiers (not secrets) issued by Google
/// Cloud Console for this app's project — safe to embed in client code, the
/// same way they ship in `google-services.json` / `GoogleService-Info.plist`.
library;

/// Web application OAuth client ID (matches `google.client_id` in enjoy_web's
/// Rails credentials). Passed as `serverClientId` on Android so the ID token
/// returned by the SDK carries this audience, which the backend already
/// verifies by default for requests without a `platform` (and as the
/// `android` platform fallback — see
/// `NativeAuth::GoogleIdTokenVerifier.audience_for` in enjoy_web).
const String kGoogleWebClientId =
    '93185289922-28sf8q3ekkoo6lu3nflc8cjtult1clbr.apps.googleusercontent.com';
