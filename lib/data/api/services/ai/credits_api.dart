/// `GET /credits/usages` — authenticated Worker credits audit log.
library;

import 'package:enjoy_player/data/api/api_client.dart';
import 'package:enjoy_player/features/credits/domain/credits_usage_log.dart';
import 'package:enjoy_player/features/credits/domain/credits_usage_page.dart';

class CreditsApi {
  CreditsApi(this._client);

  final ApiClient _client;

  static const _path = '/credits/usages';

  /// [limit] is clamped server-side to \[1, 100\]; default 50 matches Worker.
  Future<CreditsUsagePage> getUsages({
    String? startDate,
    String? endDate,
    String? serviceType,
    int limit = 50,
    int offset = 0,
  }) async {
    final query = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
      if (startDate != null && startDate.isNotEmpty) 'startDate': startDate,
      if (endDate != null && endDate.isNotEmpty) 'endDate': endDate,
      if (serviceType != null && serviceType.isNotEmpty)
        'serviceType': serviceType,
    };

    final map = await _client.getJson(_path, queryParameters: query);
    final raw = map['logs'];
    final logs = <CreditsUsageLog>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          logs.add(CreditsUsageLog.fromJson(e));
        } else if (e is Map) {
          logs.add(
            CreditsUsageLog.fromJson(
              Map<String, dynamic>.from(
                e.map((k, v) => MapEntry(k.toString(), v)),
              ),
            ),
          );
        }
      }
    }

    return CreditsUsagePage(logs: logs, hasMore: logs.length >= limit);
  }
}
