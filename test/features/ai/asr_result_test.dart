import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:enjoy_player/features/ai/domain/models/asr_result.dart';

void main() {
  test(
    'AsrResult.fromJson parses transcriptionInfo when nested map is Map<dynamic, dynamic>',
    () {
      final nested = <dynamic, dynamic>{
        'language': 'en',
        'duration': 1.25,
      };
      final json = <String, dynamic>{
        'text': 'hello',
        'transcriptionInfo': nested,
      };
      final r = AsrResult.fromJson(json);
      expect(r.text, 'hello');
      expect(r.language, 'en');
      expect(r.duration, 1.25);
    },
  );

  test(
    'AsrResult.fromJson parses transcriptionInfo from jsonDecode nested maps',
    () {
      final decoded = jsonDecode(
        '{"text":"hello","transcriptionInfo":{"language":"en","duration":1.25}}',
      );
      final top = Map<String, dynamic>.from(decoded as Map);
      final r = AsrResult.fromJson(top);
      expect(r.text, 'hello');
      expect(r.language, 'en');
      expect(r.duration, 1.25);
    },
  );
}
