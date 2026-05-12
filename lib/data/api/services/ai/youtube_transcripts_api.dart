/// Worker `POST /youtube/transcripts` (sync poll; may return `generating` with HTTP 202).
library;

import 'package:enjoy_player/data/api/api_client.dart';

/// Contract for YouTube transcript polling on the Enjoy Worker.
abstract class YoutubeTranscriptsClient {
  Future<Map<String, dynamic>> pollTranscript({
    required String videoId,
    required String language,
    String? captionFetch,
    bool? forceRefresh,
  });
}

class YoutubeTranscriptsApi implements YoutubeTranscriptsClient {
  YoutubeTranscriptsApi(this._client);

  final ApiClient _client;

  static const _path = '/youtube/transcripts';

  @override
  Future<Map<String, dynamic>> pollTranscript({
    required String videoId,
    required String language,
    String? captionFetch,
    bool? forceRefresh,
  }) {
    return _client.postJson(
      _path,
      body: {
        'videoId': videoId,
        'language': language,
        'captionFetch': ?captionFetch,
        'forceRefresh': ?forceRefresh,
      },
    );
  }
}
