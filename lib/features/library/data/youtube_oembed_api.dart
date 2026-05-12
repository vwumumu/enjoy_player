/// Best-effort YouTube oEmbed metadata (title + thumbnail).
library;

import 'dart:convert';

import 'package:http/http.dart' as http;

typedef YoutubeOembedMetadata = ({String title, String? thumbnailUrl});

Future<YoutubeOembedMetadata?> fetchYoutubeOembed(String videoId) async {
  final watch =
      'https://www.youtube.com/watch?v=${Uri.encodeComponent(videoId)}';
  final uri = Uri.parse(
    'https://www.youtube.com/oembed?format=json&url=${Uri.encodeComponent(watch)}',
  );
  try {
    final r = await http.get(uri);
    if (r.statusCode != 200) return null;
    final j = jsonDecode(r.body) as Map<String, dynamic>;
    final title = j['title'] as String?;
    final thumb = j['thumbnail_url'] as String?;
    return (title: title ?? 'YouTube video $videoId', thumbnailUrl: thumb);
  } on Object {
    return null;
  }
}
