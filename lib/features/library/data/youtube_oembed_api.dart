/// Best-effort YouTube oEmbed metadata (title + thumbnail).
library;

import 'dart:convert';

import 'package:enjoy_player/core/utils/youtube_video_identity.dart';
import 'package:http/http.dart' as http;

typedef YoutubeOembedMetadata = ({String title, String? thumbnailUrl});

Future<YoutubeOembedMetadata?> fetchYoutubeOembed(
  String videoId, {
  http.Client? client,
}) async {
  final watch =
      'https://www.youtube.com/watch?v=${Uri.encodeComponent(videoId)}';
  final uri = Uri.parse(
    'https://www.youtube.com/oembed?format=json&url=${Uri.encodeComponent(watch)}',
  );
  try {
    final r = client == null ? await http.get(uri) : await client.get(uri);
    if (r.statusCode != 200) return null;
    final j = jsonDecode(r.body) as Map<String, dynamic>;
    final title = j['title'] as String?;
    final thumb = j['thumbnail_url'] as String?;
    final resolvedTitle = (title != null && title.trim().isNotEmpty)
        ? title.trim()
        : youtubeImportPlaceholderTitle(videoId);
    if (isYoutubeImportPlaceholderTitle(resolvedTitle, videoId)) {
      return null;
    }
    return (title: resolvedTitle, thumbnailUrl: thumb);
  } on Object {
    return null;
  }
}
