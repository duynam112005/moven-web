import 'package:flutter_test/flutter_test.dart';
import 'package:moven/features/admin/data/dashboard_repository.dart';

void main() {
  group('DashboardRepository Tests (Mock Mode)', () {
    late DashboardRepository repo;

    setUp(() {
      repo = DashboardRepository();
    });

    test('getDashboardMetrics returns metrics adhering to ADR-0005', () async {
      final metrics = await repo.getDashboardMetrics();

      expect(metrics.deliveredRevenue, greaterThan(0));
      expect(metrics.lowStockThreshold, 5);
      expect(metrics.statusCounts, isNotEmpty);
      expect(metrics.deliveredCount, greaterThan(0));
      expect(metrics.bestSellers, isNotEmpty);
      expect(metrics.lowStockVariants, isNotEmpty);
      expect(metrics.recentOrders, isNotEmpty);

      // Verify all lowStockVariants have stock <= threshold
      for (final item in metrics.lowStockVariants) {
        expect(item.stockQuantity, lessThanOrEqualTo(metrics.lowStockThreshold));
      }
    });
  });
}
