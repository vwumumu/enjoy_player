import 'package:enjoy_player/core/validation/byok_url_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isByokBaseUrlAllowed', () {
    test('accepts public HTTPS endpoints', () {
      expect(isByokBaseUrlAllowed('https://api.openai.com/v1'), isTrue);
      expect(isByokBaseUrlAllowed('https://api.deepseek.com/v1'), isTrue);
      expect(
        isByokBaseUrlAllowed(
          'https://my-resource.openai.azure.com/openai/deployments/foo',
        ),
        isTrue,
      );
    });

    test('rejects non-HTTPS schemes', () {
      expect(isByokBaseUrlAllowed('http://api.openai.com/v1'), isFalse);
    });

    test('rejects localhost and loopback', () {
      expect(isByokBaseUrlAllowed('https://localhost:8080/v1'), isFalse);
      expect(isByokBaseUrlAllowed('https://127.0.0.1/v1'), isFalse);
    });

    test('rejects private IPv4 ranges', () {
      expect(isByokBaseUrlAllowed('https://10.0.0.1/v1'), isFalse);
      expect(isByokBaseUrlAllowed('https://172.16.0.1/v1'), isFalse);
      expect(isByokBaseUrlAllowed('https://192.168.1.5/v1'), isFalse);
    });

    test('rejects empty and unparseable URLs', () {
      expect(isByokBaseUrlAllowed(''), isFalse);
      expect(isByokBaseUrlAllowed('not-a-url'), isFalse);
    });
  });
}
