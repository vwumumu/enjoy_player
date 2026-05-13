/// Filter + pagination state for Worker `GET /credits/usages`.
library;

class CreditsUsageFilters {
  const CreditsUsageFilters({
    this.startDate,
    this.endDate,
    this.serviceType,
    this.offset = 0,
    this.limit = 50,
  });

  static const initial = CreditsUsageFilters();

  final String? startDate;
  final String? endDate;
  final String? serviceType;
  final int offset;
  final int limit;
}
