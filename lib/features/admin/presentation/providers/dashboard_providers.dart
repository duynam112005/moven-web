import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moven/core/network/supabase_client.dart';
import 'package:moven/features/admin/data/dashboard_repository.dart';
import 'package:moven/features/admin/domain/models/dashboard_metrics.dart';

/// Các tùy chọn khoảng thời gian báo cáo trên Dashboard
enum DashboardDateRange {
  today('Hôm nay'),
  last7Days('7 ngày qua'),
  last30Days('30 ngày qua'),
  allTime('Toàn thời gian');

  final String label;
  const DashboardDateRange(this.label);

  DateTime? get startDate {
    final now = DateTime.now();
    switch (this) {
      case DashboardDateRange.today:
        return DateTime(now.year, now.month, now.day);
      case DashboardDateRange.last7Days:
        return now.subtract(const Duration(days: 7));
      case DashboardDateRange.last30Days:
        return now.subtract(const Duration(days: 30));
      case DashboardDateRange.allTime:
        return null;
    }
  }

  DateTime? get endDate => null; // To now
}

/// Provider cung cấp DashboardRepository
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  try {
    final client = ref.watch(supabaseClientProvider);
    return DashboardRepository(client);
  } catch (_) {
    return DashboardRepository();
  }
});

/// Provider lưu khoảng thời gian báo cáo hiện tại
final dashboardDateRangeProvider =
    StateProvider<DashboardDateRange>((ref) => DashboardDateRange.last30Days);

/// Provider truy vấn số liệu Dashboard theo khoảng thời gian
final dashboardMetricsProvider = FutureProvider<DashboardMetrics>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  final range = ref.watch(dashboardDateRangeProvider);

  return repo.getDashboardMetrics(
    startDate: range.startDate,
    endDate: range.endDate,
  );
});
