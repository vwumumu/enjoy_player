import 'package:enjoy_player/features/player/presentation/widgets/global_transport_bar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveNarrowTransportBudget', () {
    test('player route at 320px keeps prev/next, omits volume', () {
      const innerWidth = 296.0; // 320 minus transport horizontal padding
      final budget = resolveNarrowTransportBudget(
        innerWidth,
        hasTranscriptLines: true,
        onPlayer: true,
        showFullscreenTransport: false,
      );

      expect(budget.showPrevNext, isTrue);
      expect(budget.showEcho, isTrue);
      expect(budget.showCc, isTrue);
      expect(budget.showSpeed, isTrue);
      expect(budget.showVolume, isFalse);
      expect(budget.showExpand, isFalse);
    });

    test('player route at 375px keeps prev/next and volume', () {
      const innerWidth = 351.0;
      final budget = resolveNarrowTransportBudget(
        innerWidth,
        hasTranscriptLines: true,
        onPlayer: true,
        showFullscreenTransport: false,
      );

      expect(budget.showPrevNext, isTrue);
      expect(budget.showVolume, isTrue);
    });

    test('mini at 320px keeps prev/next, defers expand and volume', () {
      const innerWidth = 296.0;
      final budget = resolveNarrowTransportBudget(
        innerWidth,
        hasTranscriptLines: true,
        onPlayer: false,
        showFullscreenTransport: false,
      );

      expect(budget.showPrevNext, isTrue);
      expect(budget.showExpand, isFalse);
      expect(budget.showVolume, isFalse);
      expect(budget.showEcho, isTrue);
    });

    test('no transcript hides prev/next', () {
      final budget = resolveNarrowTransportBudget(
        400,
        hasTranscriptLines: false,
        onPlayer: true,
        showFullscreenTransport: false,
      );

      expect(budget.showPrevNext, isFalse);
    });
  });
}
