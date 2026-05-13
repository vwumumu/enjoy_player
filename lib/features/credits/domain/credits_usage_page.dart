/// Paginated slice from Worker credits usage API.
library;

import 'package:enjoy_player/features/credits/domain/credits_usage_log.dart';

class CreditsUsagePage {
  const CreditsUsagePage({required this.logs, required this.hasMore});

  final List<CreditsUsageLog> logs;
  final bool hasMore;
}
