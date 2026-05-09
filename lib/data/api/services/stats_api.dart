/// `/api/v1/mine/stats` (today/week/month learning statistics).
library;

import 'package:enjoy_player/data/api/api_client.dart';

class StatsApi {
  StatsApi(this._client);

  final ApiClient _client;

  static const _path = '/api/v1/mine/stats';

  Future<Map<String, dynamic>> learningStatistics({String? timezone}) {
    final q = timezone == null || timezone.isEmpty
        ? null
        : <String, String>{'timezone': timezone};
    return _client.getJson(_path, queryParameters: q);
  }
}
