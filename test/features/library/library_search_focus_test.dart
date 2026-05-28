import 'package:enjoy_player/features/library/application/library_search_focus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('librarySearchHotkeyEnabledForPath', () {
    test('enabled on shell browse routes', () {
      expect(librarySearchHotkeyEnabledForPath('/'), isTrue);
      expect(librarySearchHotkeyEnabledForPath('/library'), isTrue);
      expect(librarySearchHotkeyEnabledForPath('/cloud'), isTrue);
      expect(librarySearchHotkeyEnabledForPath('/settings'), isTrue);
      expect(
        librarySearchHotkeyEnabledForPath('/settings/keyboard'),
        isTrue,
      );
      expect(librarySearchHotkeyEnabledForPath('/profile'), isTrue);
    });

    test('disabled on player and auth-only routes', () {
      expect(librarySearchHotkeyEnabledForPath('/player/abc'), isFalse);
      expect(librarySearchHotkeyEnabledForPath('/sign-in'), isFalse);
      expect(
        librarySearchHotkeyEnabledForPath('/sign-in?from=profile'),
        isFalse,
      );
      expect(librarySearchHotkeyEnabledForPath('/youtube/login'), isFalse);
    });
  });
}
