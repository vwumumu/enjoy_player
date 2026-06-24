/// Navigation allow/deny rules for the YouTube player [InAppWebView].
///
/// See ADR-0025 — blocks Google sign-in hijacks during watch-page playback.
library;

/// True when [url] is YouTube/Google silent sign-in (observed on `m.youtube.com`
/// watch loads without existing session cookies).
bool isPassiveGoogleSignInUrl(String url) {
  if (!url.contains('accounts.google.com')) return false;
  if (url.contains('passive=true')) return true;
  if (url.contains('signin_passive')) return true;
  return false;
}

/// YouTube media and static asset hosts (not matched by `google.com` alone).
bool isYoutubePlaybackOrStaticAssetUrl(String url) {
  return url.contains('googlevideo.com') ||
      url.contains('ytimg.com') ||
      url.contains('ggpht.com') ||
      url.contains('googleusercontent.com');
}

/// Whether the player WebView may navigate to [url] while [videoId] is open.
///
/// Explicit YouTube login uses [`YoutubeLoginScreen`] — not the player WebView.
///
/// On Windows, [shouldOverrideUrlLoading] is invoked for subresource loads as
/// well as main-frame navigations — pass [isForMainFrame] from the callback.
bool shouldAllowYoutubeWatchNavigation({
  required String url,
  required String videoId,
  required bool isForMainFrame,
}) {
  // Never block CDN / static asset requests (e.g. googlevideo.com segments).
  if (!isForMainFrame) {
    return true;
  }

  if (url == 'about:blank' || url.startsWith('about:')) {
    return true;
  }
  if (videoId.isEmpty) {
    return false;
  }

  // Never leave the watch surface for Google account flows (passive or active).
  if (url.contains('accounts.google.com')) {
    return false;
  }

  if (url.contains('consent.youtube.com') ||
      url.contains('myaccount.google.com') ||
      url.contains('gstatic.com') ||
      url.contains('googleapis.com')) {
    return true;
  }

  if (isYoutubePlaybackOrStaticAssetUrl(url)) {
    return true;
  }

  if (url.contains('youtube.com') ||
      url.contains('youtu.be') ||
      url.contains('google.com')) {
    return true;
  }

  return false;
}
