/// Cached RSS feed item (not a library row until imported).
library;

class FeedEntry {
  const FeedEntry({
    required this.videoId,
    required this.channelId,
    required this.title,
    this.thumbnailUrl,
    required this.publishedAt,
  });

  final String videoId;
  final String channelId;
  final String title;
  final String? thumbnailUrl;
  final DateTime publishedAt;
}
