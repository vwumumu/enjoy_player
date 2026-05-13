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

const List<String> kSupportedNativeLanguageTags = <String>[
  'en-US',
  'zh-CN',
];

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
