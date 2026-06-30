import 'dart:convert';

import 'package:enjoy_player/core/validation/byok_url_guard.dart';
import 'package:enjoy_player/data/api/api_exception.dart';
import 'package:enjoy_player/features/ai/data/byok/byok_llm_model_factory.dart';
import 'package:http/http.dart' as http;

/// OpenAI-compatible Whisper `POST /audio/transcriptions` with user credentials.
Future<Map<String, dynamic>> postWhisperTranscription({
  required String baseUrl,
  required String apiKey,
  required List<int> audioBytes,
  required String filename,
  String? model,
  String? language,
  String? prompt,
  String responseFormat = 'json',
  http.Client? client,
}) async {
  if (!isByokBaseUrlAllowed(baseUrl)) {
    throw const ApiException(
      message: 'Invalid base URL for Whisper transcription',
      statusCode: 400,
    );
  }

  final root = normalizeByokBaseUrl(baseUrl);
  final uri = Uri.parse('$root/audio/transcriptions');

  final request = http.MultipartRequest('POST', uri);
  request.headers['Accept'] = 'application/json';
  request.headers['Authorization'] = 'Bearer ${apiKey.trim()}';
  request.files.add(
    http.MultipartFile.fromBytes('file', audioBytes, filename: filename),
  );

  final fields = <String, String>{
    'response_format': responseFormat,
    if (model != null && model.isNotEmpty) 'model': model,
    if (language != null && language.isNotEmpty) 'language': language,
    if (prompt != null && prompt.isNotEmpty) 'prompt': prompt,
  };
  request.fields.addAll(fields);

  final httpClient = client ?? http.Client();
  try {
    final streamed = await httpClient.send(request);
    final bodyBytes = await streamed.stream.toBytes();
    final body = utf8.decode(bodyBytes);

    if (streamed.statusCode >= 200 && streamed.statusCode < 300) {
      if (responseFormat == 'text') {
        return {'text': body.trim()};
      }
      final decoded = jsonDecode(body);
      if (decoded is! Map) {
        throw ApiException(
          message: 'Expected JSON object from Whisper',
          statusCode: streamed.statusCode,
        );
      }
      return Map<String, dynamic>.from(
        decoded.map((k, v) => MapEntry(k.toString(), v)),
      );
    }

    Object? parsed;
    try {
      parsed = jsonDecode(body);
    } catch (_) {
      parsed = body;
    }
    throw ApiException(
      message: 'Whisper transcription failed (${streamed.statusCode})',
      statusCode: streamed.statusCode,
      body: parsed,
    );
  } finally {
    if (client == null) {
      httpClient.close();
    }
  }
}
