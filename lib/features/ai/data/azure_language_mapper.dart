/// Maps transcript / ISO-ish language codes to Azure Speech locale strings.
library;

import 'package:enjoy_player/core/logging/log.dart';
import 'package:logging/logging.dart';

final Logger _log = logNamed('ai.azure_language');

/// Maps YouTube-style or short language codes to Azure Speech locales (e.g. `en` → `en-US`).
String mapTranscriptLanguageToAzure(String? youtubeLanguageCode) {
  if (youtubeLanguageCode == null || youtubeLanguageCode.isEmpty) {
    return 'en-US';
  }

  final code = youtubeLanguageCode.toLowerCase();

  const languageMap = <String, String>{
    'en': 'en-US',
    'en-us': 'en-US',
    'en-gb': 'en-GB',
    'en-au': 'en-AU',
    'en-ca': 'en-CA',
    'en-in': 'en-IN',
    'zh': 'zh-CN',
    'zh-cn': 'zh-CN',
    'zh-hans': 'zh-CN',
    'zh-tw': 'zh-TW',
    'zh-hant': 'zh-TW',
    'zh-hk': 'zh-HK',
    'ja': 'ja-JP',
    'ja-jp': 'ja-JP',
    'ko': 'ko-KR',
    'ko-kr': 'ko-KR',
    'es': 'es-ES',
    'es-es': 'es-ES',
    'es-mx': 'es-MX',
    'es-ar': 'es-AR',
    'es-co': 'es-CO',
    'fr': 'fr-FR',
    'fr-fr': 'fr-FR',
    'fr-ca': 'fr-CA',
    'de': 'de-DE',
    'de-de': 'de-DE',
    'it': 'it-IT',
    'it-it': 'it-IT',
    'pt': 'pt-BR',
    'pt-br': 'pt-BR',
    'pt-pt': 'pt-PT',
    'ru': 'ru-RU',
    'ru-ru': 'ru-RU',
    'ar': 'ar-SA',
    'ar-sa': 'ar-SA',
    'hi': 'hi-IN',
    'hi-in': 'hi-IN',
    'nl': 'nl-NL',
    'nl-nl': 'nl-NL',
    'pl': 'pl-PL',
    'pl-pl': 'pl-PL',
    'sv': 'sv-SE',
    'sv-se': 'sv-SE',
    'tr': 'tr-TR',
    'tr-tr': 'tr-TR',
    'vi': 'vi-VN',
    'vi-vn': 'vi-VN',
    'th': 'th-TH',
    'th-th': 'th-TH',
  };

  final mapped = languageMap[code];
  if (mapped != null) {
    return mapped;
  }

  if (RegExp(r'^[a-z]{2}-[A-Z]{2}$').hasMatch(youtubeLanguageCode)) {
    return youtubeLanguageCode;
  }

  if (RegExp(r'^[a-z]{2}$').hasMatch(code)) {
    final upper = code.toUpperCase();
    _log.warning(
      "[LanguageMapper] Unmapped language code '$code', using fallback: $code-$upper",
    );
    return '$code-$upper';
  }

  _log.warning(
    "[LanguageMapper] Unsupported language code '$youtubeLanguageCode', defaulting to en-US",
  );
  return 'en-US';
}
