/// Today's practice goal card (signed-in home dashboard).
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:enjoy_player/core/theme/enjoy_tokens.dart';
import 'package:enjoy_player/features/auth/application/auth_controller.dart';
import 'package:enjoy_player/features/auth/domain/auth_state.dart';
import 'package:enjoy_player/features/library/application/learning_statistics_provider.dart';
import 'package:enjoy_player/l10n/app_localizations.dart';

String _formatDurationMs(int ms) {
  final seconds = ms ~/ 1000;
  final minutes = seconds ~/ 60;
  final hours = minutes ~/ 60;
  if (hours > 0) {
    return '${hours}h ${minutes % 60}m';
  }
  if (minutes > 0) {
    return '${minutes}m ${seconds % 60}s';
  }
  return '${seconds}s';
}

int _completedMinutes(int recordingDurationMs) =>
    recordingDurationMs ~/ (60 * 1000);

int _progressPercent(int completedMinutes, int goalMinutes) {
  if (goalMinutes <= 0) return 0;
  return math.min(100, ((completedMinutes / goalMinutes) * 100).round());
}

String _encouragement(AppLocalizations l10n, int percentage) {
  if (percentage >= 100) return l10n.homeGoalCompleted;
  if (percentage >= 75) return l10n.homeGoalAlmostThere;
  if (percentage >= 50) return l10n.homeGoalHalfway;
  if (percentage >= 25) return l10n.homeGoalGoodStart;
  if (percentage > 0) return l10n.homeGoalJustStarted;
  return l10n.homeGoalStartNow;
}

/// Circular ring matching web SVG dash-offset semantics.
class _GoalRingPainter extends CustomPainter {
  _GoalRingPainter({
    required this.percentage,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  final int percentage;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final sweep = 2 * math.pi * (percentage.clamp(0, 100) / 100);
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(rect, -math.pi / 2, sweep, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _GoalRingPainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class TodaysGoalCard extends ConsumerWidget {
  const TodaysGoalCard({super.key});

  static const double _ringSize = 140;
  static const double _strokeWidth = 10;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = EnjoyThemeTokens.of(context);
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final statsAsync = ref.watch(learningStatisticsProvider);
    final authAsync = ref.watch(authCtrlProvider);

    final goalMinutes = authAsync.maybeWhen(
      data: (auth) => auth is AuthSignedIn
          ? (auth.profile.goal ?? 30).clamp(1, 24 * 60)
          : 30,
      orElse: () => 30,
    );

    return statsAsync.when(
      skipLoadingOnReload: true,
      data: (stats) {
        if (stats == null) return const SizedBox.shrink();

        final completedMin = _completedMinutes(stats.today.recordingDurationMs);
        final pct = _progressPercent(completedMin, goalMinutes);
        final encouragement = _encouragement(l10n, pct);
        final progressColor = pct >= 100 ? Colors.green : cs.primary;
        final msgColor = pct >= 100 ? Colors.green : cs.onSurfaceVariant;

        return Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: EdgeInsets.all(t.space16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.track_changes_rounded,
                      size: 20,
                      color: cs.primary,
                    ),
                    SizedBox(width: t.space8),
                    Expanded(
                      child: Text(
                        l10n.homeTodaysGoal,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: t.space16),
                Center(
                  child: SizedBox(
                    width: _ringSize,
                    height: _ringSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(_ringSize, _ringSize),
                          painter: _GoalRingPainter(
                            percentage: pct,
                            trackColor: cs.surfaceContainerHighest,
                            progressColor: progressColor,
                            strokeWidth: _strokeWidth,
                          ),
                        ),
                        Text(
                          '$pct%',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: t.space16),
                Text(
                  '$completedMin / $goalMinutes ${l10n.homeMinutes}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: t.space4),
                Text(
                  '${stats.today.recordingDurationMs > 0 ? _formatDurationMs(stats.today.recordingDurationMs) : '0m'} ${l10n.homeCompleted}',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                SizedBox(height: t.space12),
                Text(
                  encouragement,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: msgColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => _TodaysGoalLoadingCard(t: t, cs: cs),
      error: (e, _) => _TodaysGoalErrorCard(
        t: t,
        cs: cs,
        onRetry: () => ref.invalidate(learningStatisticsProvider),
      ),
    );
  }
}

class _TodaysGoalLoadingCard extends StatelessWidget {
  const _TodaysGoalLoadingCard({required this.t, required this.cs});

  final EnjoyThemeTokens t;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final base = cs.surfaceContainerHighest.withValues(alpha: 0.6);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(t.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.track_changes_rounded, size: 20, color: cs.primary),
                SizedBox(width: t.space8),
                Container(
                  height: 22,
                  width: 140,
                  decoration: BoxDecoration(
                    color: base,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            SizedBox(height: t.space24),
            Center(
              child: Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(color: base, shape: BoxShape.circle),
              ),
            ),
            SizedBox(height: t.space24),
            Center(
              child: Container(
                height: 28,
                width: 180,
                decoration: BoxDecoration(
                  color: base,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            SizedBox(height: t.space8),
            Center(
              child: Container(
                height: 16,
                width: 120,
                decoration: BoxDecoration(
                  color: base,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodaysGoalErrorCard extends StatelessWidget {
  const _TodaysGoalErrorCard({
    required this.t,
    required this.cs,
    required this.onRetry,
  });

  final EnjoyThemeTokens t;
  final ColorScheme cs;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(t.space16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: cs.error, size: 22),
            SizedBox(width: t.space12),
            Expanded(
              child: Text(
                l10n.errorNetwork,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            TextButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}
