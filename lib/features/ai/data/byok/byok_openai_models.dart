import 'dart:convert';

import 'package:enjoy_player/core/validation/byok_url_guard.dart';
import 'package:enjoy_player/data/api/api_exception.dart';
import 'package:enjoy_player/features/ai/data/byok/byok_llm_model_factory.dart';
import 'package:http/http.dart' as http;

/// Lists models from an OpenAI-compatible `GET /models` endpoint.
Future<List<String>> fetchOpenAiCompatibleModels({
  required String baseUrl,
  required String apiKey,
}) async {
  if (!isByokBaseUrlAllowed(baseUrl)) {
    throw const ApiException(
      message: 'Invalid base URL for model fetch',
      statusCode: 400,
    );
  }

  final root = normalizeByokBaseUrl(baseUrl);
  final response = await http.get(
    Uri.parse('$root/models'),
    headers: {
      'Authorization': 'Bearer ${apiKey.trim()}',
      'Accept': 'application/json',
    },
  );

  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw ApiException(
      message: 'Failed to fetch models (${response.statusCode})',
      statusCode: response.statusCode,
    );
  }

  final decoded = jsonDecode(response.body) as Map<String, dynamic>;
  final data = decoded['data'];
  if (data is! List) return const [];

  final ids = data
      .map((row) => (row as Map)['id']?.toString())
      .whereType<String>()
      .where((id) => id.isNotEmpty)
      .toList()
    ..sort();
  return ids;
}
