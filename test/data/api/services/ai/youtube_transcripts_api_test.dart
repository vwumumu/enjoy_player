import 'dart:convert';

import 'package:enjoy_player/data/api/api_client.dart';
import 'package:enjoy_player/data/api/services/ai/youtube_transcripts_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('YoutubeTranscriptsApi', () {
    ApiClient apiClient(http.Client client) => ApiClient(
          httpClient: client,
          getBaseUrl: () async => 'https://worker.example.com',
          getAccessToken: () async => 'tok',
        );

    test('pollTranscript posts single-language body as snake_case', () async {
      http.Request? captured;
      final mock = MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({'status': 'ready'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final api = YoutubeTranscriptsApi(apiClient(mock));
      await api.pollTranscript(
        videoId: 'dQw4w9WgXcQ',
        language: 'en',
        captionFetch: 'auto',
        forceRefresh: true,
        waitMs: 20000,
      );

      expect(captured, isNotNull);
      final req = captured!;
      expect(req.url.path, '/youtube/transcripts');
      expect(req.method, 'POST');

      final body = jsonDecode(req.body) as Map<String, dynamic>;
      expect(body['video_id'], 'dQw4w9WgXcQ');
      expect(body['language'], 'en');
      expect(body['caption_fetch'], 'auto');
      expect(body['force_refresh'], true);
      expect(body['wait_ms'], 20000);
      // Multi-language key must not be sent on the single-language path.
      expect(body.containsKey('languages'), isFalse);
    });

    test('pollTranscripts posts multi-language body as snake_case', () async {
      http.Request? captured;
      final mock = MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'status': 'ready',
            'transcripts': <Map<String, dynamic>>[],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final api = YoutubeTranscriptsApi(apiClient(mock));
      await api.pollTranscripts(
        videoId: 'dQw4w9WgXcQ',
        languages: const ['en', 'zh'],
        captionFetch: 'auto',
        forceRefresh: false,
        waitMs: 20000,
      );

      expect(captured, isNotNull);
      final req = captured!;
      expect(req.url.path, '/youtube/transcripts');

      final body = jsonDecode(req.body) as Map<String, dynamic>;
      expect(body['video_id'], 'dQw4w9WgXcQ');
      expect(body['languages'], ['en', 'zh']);
      expect(body['caption_fetch'], 'auto');
      expect(body['force_refresh'], false);
      expect(body['wait_ms'], 20000);
      // Single-language key must not be sent on the multi-language path.
      expect(body.containsKey('language'), isFalse);
    });

    test('pollTranscripts omits nullable fields when not supplied', () async {
      http.Request? captured;
      final mock = MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({'status': 'ready'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final api = YoutubeTranscriptsApi(apiClient(mock));
      await api.pollTranscripts(
        videoId: 'dQw4w9WgXcQ',
        languages: const ['en'],
      );

      final body =
          jsonDecode(captured!.body) as Map<String, dynamic>;
      expect(body['video_id'], 'dQw4w9WgXcQ');
      expect(body['languages'], ['en']);
      expect(body.containsKey('caption_fetch'), isFalse);
      expect(body.containsKey('force_refresh'), isFalse);
      expect(body.containsKey('wait_ms'), isFalse);
    });
  });
}
