/// Parses YouTube channel Atom RSS into [FeedEntry] rows.
library;

import '../domain/feed_entry.dart';

class YoutubeRssParser {
  const YoutubeRssParser();

  /// True when [body] looks like a YouTube Atom feed document.
  static bool isValidFeedDocument(String body) {
    final trimmed = body.trimLeft();
    if (trimmed.startsWith('<!DOCTYPE html') || trimmed.startsWith('<html')) {
      return false;
    }
    if (looksLikeBotBlockPage(body)) return false;
    return trimmed.startsWith('<?xml') || trimmed.startsWith('<feed');
  }

  /// YouTube anti-automation / consent interstitials (often HTTP 200).
  static bool looksLikeBotBlockPage(String body) {
    final lower = body.toLowerCase();
    return lower.contains("can't process your request right now") ||
        lower.contains('unusual traffic') ||
        lower.contains('consent.youtube.com') ||
        lower.contains('before you continue to youtube');
  }

  static final _entrySplit = RegExp(r'<entry[\s>]');
  static final _videoId = RegExp(
    r'<yt:videoId>([^<]+)</yt:videoId>',
    caseSensitive: false,
  );
  static final _title = RegExp(
    r'<title(?:\s[^>]*)?>(?:<!\[CDATA\[)?([\s\S]*?)(?:\]\]>)?</title>',
    caseSensitive: false,
  );
  static final _published = RegExp(
    r'<published>([^<]+)</published>',
    caseSensitive: false,
  );
  static final _thumbnail = RegExp(
    r'<media:thumbnail[^>]+url="([^"]+)"',
    caseSensitive: false,
  );

  /// Feed-level channel title (before the first `<entry>`).
  String? parseFeedTitle(String xml) {
    final head = xml.split(_entrySplit).first;
    final titleMatch = _title.firstMatch(head);
    final raw = titleMatch?.group(1)?.trim();
    if (raw == null || raw.isEmpty) return null;
    final title = _decodeXml(raw);
    if (title.endsWith(' - YouTube')) {
      return title.substring(0, title.length - ' - YouTube'.length).trim();
    }
    return title.isEmpty ? null : title;
  }

  List<FeedEntry> parse(String xml, {required String channelId}) {
    final chunks = xml.split(_entrySplit);
    if (chunks.length <= 1) return const [];

    final entries = <FeedEntry>[];
    for (var i = 1; i < chunks.length; i++) {
      final block = chunks[i];
      final videoMatch = _videoId.firstMatch(block);
      if (videoMatch == null) continue;
      final videoId = videoMatch.group(1)!.trim();
      if (videoId.isEmpty) continue;

      final titleMatch = _title.firstMatch(block);
      final title = _decodeXml(titleMatch?.group(1)?.trim() ?? 'Untitled');

      final publishedMatch = _published.firstMatch(block);
      final publishedAt =
          DateTime.tryParse(publishedMatch?.group(1)?.trim() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

      final thumbMatch = _thumbnail.firstMatch(block);
      final thumb = thumbMatch?.group(1)?.trim();

      entries.add(
        FeedEntry(
          videoId: videoId,
          channelId: channelId,
          title: title,
          thumbnailUrl: thumb?.isNotEmpty == true ? thumb : null,
          publishedAt: publishedAt.toUtc(),
        ),
      );
    }
    return entries;
  }

  static String _decodeXml(String value) {
    return value
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
  }
}
