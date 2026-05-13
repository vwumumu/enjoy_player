/// Async data for dictionary lookup sheet sections (cached by Riverpod family).
library;

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:enjoy_player/features/ai/application/ai_services.dart';
import 'package:enjoy_player/features/ai/domain/models/contextual_translation_result.dart';
import 'package:enjoy_player/features/ai/domain/models/dictionary_result.dart';
import 'package:enjoy_player/features/ai/domain/models/translation_result.dart';

part 'lookup_section_providers.g.dart';

@immutable
final class LookupTranslationParams {
  const LookupTranslationParams({
    required this.text,
    required this.sourceLanguage,
    required this.targetLanguage,
  });

  final String text;
  final String sourceLanguage;
  final String targetLanguage;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LookupTranslationParams &&
          text == other.text &&
          sourceLanguage == other.sourceLanguage &&
          targetLanguage == other.targetLanguage;

  @override
  int get hashCode => Object.hash(text, sourceLanguage, targetLanguage);
}

@immutable
final class LookupContextualParams {
  const LookupContextualParams({
    required this.text,
    required this.sourceLanguage,
    required this.targetLanguage,
    this.context,
  });

  final String text;
  final String sourceLanguage;
  final String targetLanguage;
  final String? context;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LookupContextualParams &&
          text == other.text &&
          sourceLanguage == other.sourceLanguage &&
          targetLanguage == other.targetLanguage &&
          context == other.context;

  @override
  int get hashCode =>
      Object.hash(text, sourceLanguage, targetLanguage, context);
}

@immutable
final class LookupDictionaryParams {
  const LookupDictionaryParams({
    required this.word,
    required this.sourceLanguage,
    required this.targetLanguage,
  });

  final String word;
  final String sourceLanguage;
  final String targetLanguage;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LookupDictionaryParams &&
          word == other.word &&
          sourceLanguage == other.sourceLanguage &&
          targetLanguage == other.targetLanguage;

  @override
  int get hashCode => Object.hash(word, sourceLanguage, targetLanguage);
}

@riverpod
Future<TranslationResult> lookupSheetTranslation(
  Ref ref,
  LookupTranslationParams params,
) async {
  return ref.read(translationServiceProvider).translate(
        text: params.text,
        sourceLanguage: params.sourceLanguage,
        targetLanguage: params.targetLanguage,
      );
}

@riverpod
Future<ContextualTranslationResult> lookupSheetContextual(
  Ref ref,
  LookupContextualParams params,
) async {
  return ref.read(contextualTranslationServiceProvider).translate(
        text: params.text,
        sourceLanguage: params.sourceLanguage,
        targetLanguage: params.targetLanguage,
        context: params.context,
      );
}

@riverpod
Future<DictionaryResult> lookupSheetDictionary(
  Ref ref,
  LookupDictionaryParams params,
) async {
  return ref.read(dictionaryServiceProvider).lookup(
        word: params.word,
        sourceLanguage: params.sourceLanguage,
        targetLanguage: params.targetLanguage,
      );
}
