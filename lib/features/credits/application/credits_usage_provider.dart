/// Riverpod: credits usage query + fetch from Worker.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:enjoy_player/data/api/services/ai/ai_api_providers.dart';
import 'package:enjoy_player/features/credits/domain/credits_usage_filters.dart';
import 'package:enjoy_player/features/credits/domain/credits_usage_page.dart';

part 'credits_usage_provider.g.dart';

@Riverpod(keepAlive: true)
class CreditsUsageFiltersCtrl extends _$CreditsUsageFiltersCtrl {
  @override
  CreditsUsageFilters build() => CreditsUsageFilters.initial;

  void setStartDate(String? ymd) {
    final s = state;
    state = CreditsUsageFilters(
      startDate: ymd,
      endDate: s.endDate,
      serviceType: s.serviceType,
      offset: 0,
      limit: s.limit,
    );
  }

  void setEndDate(String? ymd) {
    final s = state;
    state = CreditsUsageFilters(
      startDate: s.startDate,
      endDate: ymd,
      serviceType: s.serviceType,
      offset: 0,
      limit: s.limit,
    );
  }

  /// `null` means all service types.
  void setServiceType(String? type) {
    final s = state;
    state = CreditsUsageFilters(
      startDate: s.startDate,
      endDate: s.endDate,
      serviceType: type,
      offset: 0,
      limit: s.limit,
    );
  }

  void clearFilters() {
    state = CreditsUsageFilters(
      startDate: null,
      endDate: null,
      serviceType: null,
      offset: 0,
      limit: state.limit,
    );
  }

  void goToPreviousPage() {
    final s = state;
    final nextOffset = (s.offset - s.limit).clamp(0, 1 << 30);
    if (nextOffset == s.offset) return;
    state = CreditsUsageFilters(
      startDate: s.startDate,
      endDate: s.endDate,
      serviceType: s.serviceType,
      offset: nextOffset,
      limit: s.limit,
    );
  }

  void goToNextPage() {
    final s = state;
    state = CreditsUsageFilters(
      startDate: s.startDate,
      endDate: s.endDate,
      serviceType: s.serviceType,
      offset: s.offset + s.limit,
      limit: s.limit,
    );
  }
}

@Riverpod(keepAlive: true)
Future<CreditsUsagePage> creditsUsagePage(Ref ref) async {
  final f = ref.watch(creditsUsageFiltersCtrlProvider);
  final api = ref.watch(creditsApiProvider);
  return api.getUsages(
    startDate: f.startDate,
    endDate: f.endDate,
    serviceType: f.serviceType,
    limit: f.limit,
    offset: f.offset,
  );
}
