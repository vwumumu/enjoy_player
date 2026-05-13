/// Supported display / learning / native language tags (MVP).
library;

import 'package:flutter/material.dart';

/// Default UI locale when none is stored and not overridden by profile.
const Locale kAppDefaultDisplayLocale = Locale('zh', 'CN');

/// Selectable app UI locales (Material [Locale] → BCP-47 via [localeToBcp47]).
const List<Locale> kAppDisplayLocales = <Locale>[
  Locale('en', 'US'),
  Locale('zh', 'CN'),
];

const String kDefaultLearningLanguageTag = 'en-US';

const String kDefaultNativeLanguageTag = 'zh-CN';

const List<String> kSupportedNativeLanguageTags = <String>['en-US', 'zh-CN'];

/// ISO 639 / BCP-47 language subtags that must not be used for lookup or worker calls.
const Set<String> kInvalidLanguageTags = <String>{
  '',
  'und',
  'mul',
  'mis',
  'zxx',
};

/// Short UI labels for [kSupportedNativeLanguageTags] (lookup sheet pills / picker).
const Map<String, String> kLookupLanguageLabels = <String, String>{
  'en-US': 'English',
  'zh-CN': '中文',
};

/// True when [tag] has a non-empty primary subtag not in [kInvalidLanguageTags].
bool isValidLanguageTag(String? tag) {
  if (tag == null) return false;
  final trimmed = tag.trim();
  if (trimmed.isEmpty) return false;
  final primary = trimmed.split(RegExp(r'[-_]')).first.toLowerCase();
  if (primary.isEmpty) return false;
  return !kInvalidLanguageTags.contains(primary);
}

/// Maps a tag to a supported native tag (`en-US` / `zh-CN`), or `null` if unknown/invalid.
String? canonicalLookupTag(String? tag) {
  if (!isValidLanguageTag(tag)) return null;
  final trimmed = tag!.trim();
  final primary = trimmed.split(RegExp(r'[-_]')).first.toLowerCase();
  if (primary == 'en') return 'en-US';
  if (primary == 'zh') return 'zh-CN';
  final n = normalizeBcp47Tag(trimmed);
  for (final supported in kSupportedNativeLanguageTags) {
    if (tagsEqual(n, supported)) return supported;
  }
  return null;
}

/// Fallback when transcript language is missing or unsupported (learning language).
String coerceLookupSource(String? transcriptLanguage) =>
    canonicalLookupTag(transcriptLanguage) ?? kDefaultLearningLanguageTag;

/// Worker / web short language code: first subtag lowercased (`en-US` → `en`).
String workerLanguageBase(String tag) {
  final t = tag.trim();
  if (t.isEmpty) return 'en';
  return t.split(RegExp(r'[-_]')).first.toLowerCase();
}

String normalizeBcp47Tag(String tag) {
  final t = tag.trim();
  if (t.isEmpty) return t;
  final parts = t.split(RegExp(r'[-_]'));
  if (parts.length >= 2) {
    return '${parts[0].toLowerCase()}-${parts[1].toUpperCase()}';
  }
  return parts[0].toLowerCase();
}

bool tagsEqual(String a, String b) =>
    normalizeBcp47Tag(a) == normalizeBcp47Tag(b);

/// Native choices for the current learning language (native must ≠ learning).
List<String> allowedNativeTags(String learningTag) {
  final learn = normalizeBcp47Tag(learningTag);
  return kSupportedNativeLanguageTags
      .where((n) => !tagsEqual(n, learn))
      .toList(growable: false);
}

/// If [native] is null, empty, or equals [learning], pick a valid default.
String coerceNativeIfEqualsLearning(String? native, String learning) {
  final learn = normalizeBcp47Tag(learning);
  if (native == null || native.trim().isEmpty) {
    return _firstAllowedOrDefault(learn);
  }
  final n = normalizeBcp47Tag(native);
  if (tagsEqual(n, learn)) {
    return _firstAllowedOrDefault(learn);
  }
  if (!kSupportedNativeLanguageTags.any((t) => tagsEqual(t, n))) {
    return _firstAllowedOrDefault(learn);
  }
  return kSupportedNativeLanguageTags.firstWhere((t) => tagsEqual(t, n));
}

String _firstAllowedOrDefault(String normalizedLearning) {
  final allowed = allowedNativeTags(normalizedLearning);
  if (allowed.isNotEmpty) return allowed.first;
  return kDefaultNativeLanguageTag;
}

String localeToBcp47(Locale locale) => locale.toLanguageTag();

/// Maps [locale] to a supported display locale, or [kAppDefaultDisplayLocale].
Locale displayLocaleFromRawOrDefault(String? raw) {
  if (raw == null || raw.trim().isEmpty) return kAppDefaultDisplayLocale;
  final parts = raw.trim().split(RegExp(r'[-_]'));
  final Locale candidate = parts.length >= 2
      ? Locale(parts[0], parts[1])
      : Locale(parts[0]);
  for (final loc in kAppDisplayLocales) {
    if (loc.languageCode == candidate.languageCode &&
        (loc.countryCode ?? '') == (candidate.countryCode ?? '')) {
      return loc;
    }
  }
  for (final loc in kAppDisplayLocales) {
    if (loc.languageCode == candidate.languageCode) return loc;
  }
  return kAppDefaultDisplayLocale;
}
