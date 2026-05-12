/// Tiered score coloring (mirrors web `getScoreLevel` thresholds).
library;

import 'package:flutter/material.dart';

enum AssessmentScoreLevel { excellent, good, fair, poor }

AssessmentScoreLevel assessmentScoreLevel(num score) {
  if (score >= 91) return AssessmentScoreLevel.excellent;
  if (score >= 81) return AssessmentScoreLevel.good;
  if (score >= 61) return AssessmentScoreLevel.fair;
  return AssessmentScoreLevel.poor;
}

Color assessmentScoreColor(ColorScheme scheme, AssessmentScoreLevel level) {
  return switch (level) {
    AssessmentScoreLevel.excellent => scheme.primary,
    AssessmentScoreLevel.good => scheme.secondary,
    AssessmentScoreLevel.fair => scheme.tertiary,
    AssessmentScoreLevel.poor => scheme.error,
  };
}

Color assessmentScoreBackground(ColorScheme scheme, AssessmentScoreLevel level) {
  return assessmentScoreColor(scheme, level).withValues(alpha: 0.16);
}
