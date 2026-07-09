import 'package:enjoy_player/features/player/presentation/widgets/global_transport_bar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveNarrowTransportBudget always-on invariant (C1)', () {
    // The five practice controls (echo/blur/cc/speed) + play must never drop
    // on any supported width, on either route. Play is rendered outside this
    // struct; echo/blur/cc/speed are the always-on flags checked here.
    for (final onPlayer in [true, false]) {
      for (final width in [
        150.0,
        234.0,
        254.0,
        274.0,
        296.0,
        318.0,
        340.0,
        362.0,
        384.0,
        402.0,
        424.0,
        500.0,
      ]) {
        test('always-on flags true at ${width}px (onPlayer=$onPlayer)', () {
          final budget = resolveNarrowTransportBudget(
            width,
            hasTranscriptLines: true,
            onPlayer: onPlayer,
            showFullscreenTransport: false,
          );
          expect(budget.showEcho, isTrue, reason: 'echo always-on');
          expect(budget.showBlur, isTrue, reason: 'blur always-on');
          expect(budget.showCc, isTrue, reason: 'cc always-on');
          expect(budget.showSpeed, isTrue, reason: 'speed always-on');
        });
      }
    }
  });

  group('resolveNarrowTransportBudget eligibility gating (C2)', () {
    test('no transcript hides previous and next', () {
      final budget = resolveNarrowTransportBudget(
        500,
        hasTranscriptLines: false,
        onPlayer: false,
        showFullscreenTransport: false,
      );
      expect(budget.showPrevious, isFalse);
      expect(budget.showNext, isFalse);
    });

    test('on player hides expand', () {
      final budget = resolveNarrowTransportBudget(
        500,
        hasTranscriptLines: true,
        onPlayer: true,
        showFullscreenTransport: false,
      );
      expect(budget.showExpand, isFalse);
    });

    test('no fullscreen transport hides fullscreen', () {
      final budget = resolveNarrowTransportBudget(
        500,
        hasTranscriptLines: true,
        onPlayer: true,
        showFullscreenTransport: false,
      );
      expect(budget.showFullscreen, isFalse);
    });
  });

  group('resolveNarrowTransportBudget drop order (C3)', () {
    // Phone profile: transcript loaded, collapsed mini, no desktop fullscreen.
    NarrowTransportBudget at(double width) => resolveNarrowTransportBudget(
          width,
          hasTranscriptLines: true,
          onPlayer: false,
          showFullscreenTransport: false,
        );

    test('widest shows every droppable', () {
      final b = at(424);
      expect(b.showVolume, isTrue);
      expect(b.showNext, isTrue);
      expect(b.showPrevious, isTrue);
      expect(b.showExpand, isTrue);
    });

    test('expand drops first (before previous)', () {
      // base(234) + volume(40) + next(44) + prev(44) = 362; expand needs +40.
      final b = at(392); // 362 <= 392 < 402
      expect(b.showVolume, isTrue);
      expect(b.showNext, isTrue);
      expect(b.showPrevious, isTrue);
      expect(b.showExpand, isFalse, reason: 'expand is the first to drop');
    });

    test('previous drops before next', () {
      final b = at(340); // 318 <= 340 < 362
      expect(b.showVolume, isTrue);
      expect(b.showNext, isTrue);
      expect(b.showPrevious, isFalse, reason: 'previous drops before next');
    });

    test('next drops before volume', () {
      final b = at(296); // 274 <= 296 < 318
      expect(b.showVolume, isTrue);
      expect(b.showNext, isFalse, reason: 'next drops before volume');
      expect(b.showPrevious, isFalse);
    });

    test('volume drops last among the droppables', () {
      final b = at(254); // < 274
      expect(b.showVolume, isFalse);
      expect(b.showNext, isFalse);
      expect(b.showPrevious, isFalse);
      expect(b.showExpand, isFalse);
      // Only the always-on set remains.
      expect(b.showEcho, isTrue);
      expect(b.showBlur, isTrue);
      expect(b.showCc, isTrue);
      expect(b.showSpeed, isTrue);
    });
  });

  group('resolveNarrowTransportBudget strict priority (C4)', () {
    // No lower-priority droppable may survive while a higher-priority one is
    // dropped. Implications (phone profile): expand => previous => next =>
    // volume. Swept across many widths.
    for (var width = 200.0; width <= 500; width += 7) {
      test('no priority inversion at ${width.toInt()}px', () {
        final b = resolveNarrowTransportBudget(
          width,
          hasTranscriptLines: true,
          onPlayer: false,
          showFullscreenTransport: false,
        );
        if (b.showExpand) {
          expect(b.showPrevious, isTrue, reason: 'expand => previous');
        }
        if (b.showPrevious) {
          expect(b.showNext, isTrue, reason: 'previous => next');
        }
        if (b.showNext) {
          expect(b.showVolume, isTrue, reason: 'next => volume');
        }
      });
    }

    test('previous-only never occurs', () {
      for (var w = 200.0; w <= 500; w += 5) {
        final b = resolveNarrowTransportBudget(
          w,
          hasTranscriptLines: true,
          onPlayer: false,
          showFullscreenTransport: false,
        );
        expect(
          b.showPrevious && !b.showNext,
          isFalse,
          reason: 'previous shown without next at $w',
        );
      }
    });
  });

  group('resolveNarrowTransportBudget determinism (C6)', () {
    test('same inputs yield same output', () {
      for (var w = 200.0; w <= 500; w += 23) {
        final a = resolveNarrowTransportBudget(
          w,
          hasTranscriptLines: true,
          onPlayer: false,
          showFullscreenTransport: false,
        );
        final b = resolveNarrowTransportBudget(
          w,
          hasTranscriptLines: true,
          onPlayer: false,
          showFullscreenTransport: false,
        );
        expect(a.showPrevious, b.showPrevious);
        expect(a.showNext, b.showNext);
        expect(a.showVolume, b.showVolume);
        expect(a.showExpand, b.showExpand);
      }
    });

    test('does not throw for tiny widths', () {
      expect(
        () => resolveNarrowTransportBudget(
          0,
          hasTranscriptLines: true,
          onPlayer: false,
          showFullscreenTransport: false,
        ),
        returnsNormally,
      );
    });
  });

  group('resolveNarrowTransportBudget fullscreen priority (desktop video)', () {
    test('fullscreen is highest priority (last to drop)', () {
      // With showFullscreenTransport, fullscreen packs first. At a width where
      // nothing else fits, fullscreen still shows before volume would.
      final b = resolveNarrowTransportBudget(
        278, // base(234) + fullscreen(40) = 274 <= 278; volume(40) won't fit
        hasTranscriptLines: true,
        onPlayer: false,
        showFullscreenTransport: true,
      );
      expect(b.showFullscreen, isTrue);
      expect(b.showVolume, isFalse, reason: 'volume drops before fullscreen');
    });
  });
}
