import 'package:ai_sdk_dart/ai_sdk_dart.dart' as ai_sdk;
import 'package:ai_sdk_provider/ai_sdk_provider.dart';

import 'package:enjoy_player/core/logging/log.dart';
import 'package:enjoy_player/data/api/api_exception.dart';
import 'package:enjoy_player/data/api/byok_secret_store.dart';
import 'package:enjoy_player/features/ai/data/byok/byok_llm_model_factory.dart';
import 'package:enjoy_player/features/ai/domain/byok_not_configured_failure.dart';
import 'package:enjoy_player/features/ai/domain/capabilities/llm_capability.dart';
import 'package:enjoy_player/features/ai/domain/chat_message.dart';
import 'package:enjoy_player/features/ai/domain/modality_byok_config.dart';
import 'package:enjoy_player/features/ai/domain/modality_kind.dart';

typedef ByokGenerateTextRunner =
    Future<ai_sdk.GenerateTextResult<String>> Function({
      required LanguageModelV3 model,
      String? system,
      List<ai_sdk.ModelMessage>? messages,
      int? maxOutputTokens,
      double? temperature,
    });

/// LLM inference via user-supplied protocol-compatible endpoint ([ai_sdk_dart]).
final class ByokLlmCapability implements LlmCapability {
  ByokLlmCapability(
    this._config,
    this._secrets, {
    ByokGenerateTextRunner? generateTextRunner,
  }) : _generateText = generateTextRunner ?? _defaultGenerateText;

  static final _log = logNamed('ByokLlmCapability');

  final LlmByokConfig _config;
  final ByokSecretStoreBase _secrets;
  final ByokGenerateTextRunner _generateText;

  static Future<ai_sdk.GenerateTextResult<String>> _defaultGenerateText({
    required LanguageModelV3 model,
    String? system,
    List<ai_sdk.ModelMessage>? messages,
    int? maxOutputTokens,
    double? temperature,
  }) {
    return ai_sdk.generateText<String>(
      model: model,
      system: system,
      messages: messages,
      maxOutputTokens: maxOutputTokens,
      temperature: temperature,
    );
  }

  Future<String> _run({
    String? systemPrompt,
    required List<ChatMessage> messages,
    double? temperature,
    int? maxTokens,
  }) async {
    final apiKey = await _secrets.readApiKey(ModalityKind.llm);
    if (apiKey == null || apiKey.trim().isEmpty) {
      throw const ByokNotConfiguredFailure(ModalityKind.llm);
    }

    final model = createByokLanguageModel(
      config: _config,
      apiKey: apiKey.trim(),
    );

    try {
      final result = await _generateText(
        model: model,
        system: systemPrompt,
        messages: _toSdkMessages(messages),
        maxOutputTokens: maxTokens ?? 2048,
        temperature: temperature ?? 0.7,
      );
      final text = result.text.trim();
      if (text.isEmpty) {
        throw const ApiException(
          message: 'Empty completion content',
          statusCode: 502,
        );
      }
      return text;
    } catch (e, st) {
      _log.warning('BYOK LLM call failed (${_config.apiSpec.name})', e, st);
      rethrow;
    }
  }

  @override
  Future<String> generateText({
    String? systemPrompt,
    required String userPrompt,
    double? temperature,
    int? maxTokens,
  }) {
    return _run(
      systemPrompt: systemPrompt,
      messages: [ChatMessage(role: ChatMessage.roleUser, content: userPrompt)],
      temperature: temperature,
      maxTokens: maxTokens,
    );
  }

  @override
  Future<String> generateChatCompletion({
    required List<ChatMessage> messages,
    double? temperature,
    int? maxTokens,
    Map<String, dynamic>? responseFormat,
  }) {
    if (responseFormat != null) {
      _log.fine('BYOK LLM ignores responseFormat (not yet mapped to ai_sdk)');
    }
    return _run(
      messages: messages,
      temperature: temperature,
      maxTokens: maxTokens,
    );
  }

  List<ai_sdk.ModelMessage> _toSdkMessages(List<ChatMessage> messages) {
    return messages.map((message) {
      final role = switch (message.role) {
        ChatMessage.roleSystem => ai_sdk.ModelMessageRole.system,
        ChatMessage.roleAssistant => ai_sdk.ModelMessageRole.assistant,
        _ => ai_sdk.ModelMessageRole.user,
      };
      return ai_sdk.ModelMessage(role: role, content: message.content);
    }).toList();
  }
}
