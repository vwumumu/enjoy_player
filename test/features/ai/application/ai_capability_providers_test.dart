import 'package:enjoy_player/data/api/api_client.dart';
import 'package:enjoy_player/data/api/services/ai/ai_api_providers.dart';
import 'package:enjoy_player/data/api/services/ai/chat_api.dart';
import 'package:enjoy_player/features/ai/application/ai_capability_providers.dart';
import 'package:enjoy_player/features/ai/application/ai_modality_configs.dart';
import 'package:enjoy_player/features/ai/data/enjoy/enjoy_llm_capability.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

class _NullApiClient extends ApiClient {
  _NullApiClient()
      : super(
          httpClient: _NullHttpClient(),
          getBaseUrl: () async => 'https://test.invalid',
          getAccessToken: () async => null,
        );
}

class _NullHttpClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    throw UnsupportedError('Not used in capability routing test');
  }
}

void main() {
  test('llmCapabilityProvider returns EnjoyLlmCapability for default config', () {
    final container = ProviderContainer(
      overrides: [
        aiModalityConfigsProvider.overrideWithValue(AiModalityConfigs.defaults),
        chatApiProvider.overrideWithValue(ChatApi(_NullApiClient())),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(llmCapabilityProvider), isA<EnjoyLlmCapability>());
  });
}
