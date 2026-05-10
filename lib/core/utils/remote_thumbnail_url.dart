/// Whether [url] is an http(s) artwork URL suitable for API sync payloads.
library;

bool isRemoteThumbnailUrl(String? url) {
  if (url == null || url.isEmpty) return false;
  final u = Uri.tryParse(url);
  return u != null &&
      u.hasScheme &&
      (u.isScheme('http') || u.isScheme('https'));
}

/// When set, library/home cards should use [Image.network] instead of a local file.
String? remoteThumbnailForCard(String? thumbnailPath) {
  return isRemoteThumbnailUrl(thumbnailPath) ? thumbnailPath : null;
}
