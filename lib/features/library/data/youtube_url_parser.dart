/// Parses YouTube URLs and bare 11-character ids from user paste.
library;

final RegExp _bareId = RegExp(r'^[A-Za-z0-9_-]{11}$');

/// Returns canonical YouTube video id or null.
String? parseYoutubeVideoId(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return null;
  if (_bareId.hasMatch(s)) return s;

  var uri = Uri.tryParse(s);
  if (uri == null || uri.host.isEmpty) return null;
  final host = uri.host.toLowerCase();

  if (host.contains('youtu.be')) {
    final parts = uri.pathSegments.where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return null;
    final seg = parts.first;
    if (_bareId.hasMatch(seg)) return seg;
    return null;
  }

  if (host.contains('youtube.com')) {
    final v = uri.queryParameters['v'];
    if (v != null && _bareId.hasMatch(v)) return v;

    final parts = uri.pathSegments.where((e) => e.isNotEmpty).toList();
    // /embed/ID /shorts/ID /live/ID
    for (final key in ['embed', 'shorts', 'live']) {
      final i = parts.indexOf(key);
      if (i >= 0 && i + 1 < parts.length) {
        final id = parts[i + 1];
        if (_bareId.hasMatch(id)) return id;
      }
    }
  }

  return null;
}
