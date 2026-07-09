/// Worker `POST /youtube/transcripts` (sync poll; may return `generating` with HTTP 202).
library;

import 'package:enjoy_player/data/api/rest_api.dart';

/// Contract for YouTube transcript polling on the Enjoy Worker.
abstract class YoutubeTranscriptsClient {
  Future<Map<String, dynamic>> pollTranscript({
    required String videoId,
    required String language,
    String? captionFetch,
    bool? forceRefresh,
    int? waitMs,
  });

  /// Multi-language path: the first entry of [languages] is the source language
  /// (the original caption); the remaining entries are translation targets.
  Future<Map<String, dynamic>> pollTranscripts({
    required String videoId,
    required List<String> languages,
    String? captionFetch,
    bool? forceRefresh,
    int? waitMs,
  });
}

class YoutubeTranscriptsApi extends RestApi
    implements YoutubeTranscriptsClient {
  YoutubeTranscriptsApi(super.client);

  static const _path = '/youtube/transcripts';

  @override
  Future<Map<String, dynamic>> pollTranscript({
    required String videoId,
    required String language,
    String? captionFetch,
    bool? forceRefresh,
    int? waitMs,
  }) {
    return client.postJson(
      _path,
      body: {
        'videoId': videoId,
        'language': language,
        'captionFetch': ?captionFetch,
        'forceRefresh': ?forceRefresh,
        'waitMs': ?waitMs,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> pollTranscripts({
    required String videoId,
    required List<String> languages,
    String? captionFetch,
    bool? forceRefresh,
    int? waitMs,
  }) {
    return client.postJson(
      _path,
      body: {
        'videoId': videoId,
        'languages': languages,
        'captionFetch': ?captionFetch,
        'forceRefresh': ?forceRefresh,
        'waitMs': ?waitMs,
      },
    );
  }
}
