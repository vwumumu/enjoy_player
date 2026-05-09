/// Learning statistics from `GET /api/v1/mine/stats` (camelCase JSON).
library;

class PeriodStats {
  const PeriodStats({
    required this.recordingDurationMs,
    required this.recordingCount,
  });

  final int recordingDurationMs;
  final int recordingCount;

  static PeriodStats zero() =>
      const PeriodStats(recordingDurationMs: 0, recordingCount: 0);

  static PeriodStats fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return PeriodStats.zero();
    final dur = json['recordingDuration'];
    final durMs = dur is num ? dur.round() : int.tryParse('$dur') ?? 0;
    final cnt = json['recordingCount'];
    final count = cnt is num ? cnt.round() : int.tryParse('$cnt') ?? 0;
    return PeriodStats(recordingDurationMs: durMs, recordingCount: count);
  }
}

class LearningStatistics {
  const LearningStatistics({
    required this.today,
    required this.week,
    required this.month,
  });

  final PeriodStats today;
  final PeriodStats week;
  final PeriodStats month;

  static LearningStatistics empty() => LearningStatistics(
    today: PeriodStats.zero(),
    week: PeriodStats.zero(),
    month: PeriodStats.zero(),
  );

  factory LearningStatistics.fromJson(Map<String, dynamic> json) {
    final today = json['today'];
    final week = json['week'];
    final month = json['month'];
    return LearningStatistics(
      today: PeriodStats.fromJson(
        today is Map<String, dynamic> ? today : null,
      ),
      week: PeriodStats.fromJson(
        week is Map<String, dynamic> ? week : null,
      ),
      month: PeriodStats.fromJson(
        month is Map<String, dynamic> ? month : null,
      ),
    );
  }
}
