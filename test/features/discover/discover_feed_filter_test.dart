import 'package:enjoy_player/features/discover/application/discover_providers.dart';
import 'package:enjoy_player/features/discover/domain/discover_channel.dart';
import 'package:enjoy_player/features/discover/domain/feed_entry.dart';
import 'package:enjoy_player/data/db/youtube_subscription_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('filterDiscoverFeedByFocusLanguage', () {
    final now = DateTime.utc(2024, 6, 1);
    final entries = [
      FeedEntry(
        videoId: 'enVideo123456',
        channelId: 'UCen',
        title: 'English',
        publishedAt: now,
      ),
      FeedEntry(
        videoId: 'jaVideo123456',
        channelId: 'UCja',
        title: 'Japanese',
        publishedAt: now,
      ),
    ];

    final subs = [
      DiscoverChannel(
        channelId: 'UCen',
        displayName: 'English Channel',
        source: YoutubeSubscriptionSource.recommended,
        subscribedAt: now,
        language: 'en',
      ),
      DiscoverChannel(
        channelId: 'UCja',
        displayName: 'Japanese Channel',
        source: YoutubeSubscriptionSource.recommended,
        subscribedAt: now,
        language: 'ja',
      ),
    ];

    test('returns all entries when showAllLanguages is true', () {
      final filtered = filterDiscoverFeedByFocusLanguage(
        entries: entries,
        subscriptions: subs,
        focusLanguage: 'ja',
        showAllLanguages: true,
      );
      expect(filtered, hasLength(2));
    });

    test('filters to focus language subscriptions', () {
      final filtered = filterDiscoverFeedByFocusLanguage(
        entries: entries,
        subscriptions: subs,
        focusLanguage: 'ja',
        showAllLanguages: false,
      );
      expect(filtered, hasLength(1));
      expect(filtered.single.videoId, 'jaVideo123456');
    });

    test('keeps unknown-language subscriptions visible', () {
      final unknownSubs = [
        DiscoverChannel(
          channelId: 'UCunk',
          displayName: 'Unknown',
          source: YoutubeSubscriptionSource.user,
          subscribedAt: now,
          language: 'und',
        ),
      ];
      final unknownEntries = [
        FeedEntry(
          videoId: 'unkVideo123456',
          channelId: 'UCunk',
          title: 'Unknown',
          publishedAt: now,
        ),
      ];

      final filtered = filterDiscoverFeedByFocusLanguage(
        entries: unknownEntries,
        subscriptions: unknownSubs,
        focusLanguage: 'ja',
        showAllLanguages: false,
      );
      expect(filtered, hasLength(1));
    });
  });
}
