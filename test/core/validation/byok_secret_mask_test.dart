import 'package:enjoy_player/core/validation/byok_secret_mask.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maskByokApiKey shows prefix and suffix only', () {
    expect(maskByokApiKey('sk-1234567890'), 'sk-1•••••7890');
    expect(maskByokApiKey('short'), '••••••••');
    expect(maskByokApiKey(''), '');
  });
}
