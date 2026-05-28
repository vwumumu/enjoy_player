/// Domain model for a subscribed or recommended YouTube channel.
library;

class DiscoverChannel {
  const DiscoverChannel({
    required this.channelId,
    required this.displayName,
    this.thumbnailUrl,
    required this.source,
    required this.subscribedAt,
    this.lastFetchedAt,
  });

  final String channelId;
  final String displayName;
  final String? thumbnailUrl;

  /// `recommended` or `user`.
  final String source;
  final DateTime subscribedAt;
  final DateTime? lastFetchedAt;

  bool get isSubscribed => true;
}
