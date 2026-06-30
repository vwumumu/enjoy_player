import 'dart:convert';
import 'dart:typed_data';

import 'package:enjoy_player/core/validation/byok_url_guard.dart';
import 'package:enjoy_player/data/api/api_exception.dart';
import 'package:enjoy_player/features/ai/data/byok/byok_llm_model_factory.dart';
import 'package:http/http.dart' as http;

/// OpenAI-compatible `POST /audio/speech` with user credentials.
Future<Uint8List> postOpenAiSpeech({
  required String baseUrl,
  required String apiKey,
  required String model,
  required String input,
  String voice = 'alloy',
  http.Client? client,
}) async {
  if (!isByokBaseUrlAllowed(baseUrl)) {
    throw const ApiException(
      message: 'Invalid base URL for OpenAI speech synthesis',
      statusCode: 400,
    );
  }

  final root = normalizeByokBaseUrl(baseUrl);
  final uri = Uri.parse('$root/audio/speech');
  final httpClient = client ?? http.Client();

  try {
    final response = await httpClient.post(
      uri,
      headers: {
        'Authorization': 'Bearer ${apiKey.trim()}',
        'Content-Type': 'application/json',
        'Accept': 'audio/mpeg',
      },
      body: jsonEncode(<String, Object>{
        'model': model,
        'input': input,
        'voice': voice,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Uint8List.fromList(response.bodyBytes);
    }

    Object? parsed;
    try {
      parsed = jsonDecode(response.body);
    } catch (_) {
      parsed = response.body;
    }
    throw ApiException(
      message: 'Speech synthesis failed (${response.statusCode})',
      statusCode: response.statusCode,
      body: parsed,
    );
  } finally {
    if (client == null) {
      httpClient.close();
    }
  }
}
