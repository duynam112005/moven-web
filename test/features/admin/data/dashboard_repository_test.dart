import 'package:flutter_test/flutter_test.dart';
import 'package:moven/features/admin/data/dashboard_repository.dart';
import 'package:moven/features/orders/data/orders_repository.dart';
import 'package:moven/features/orders/domain/models/order_status.dart';

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

    test('getDashboardMetrics dynamically reflects newly delivered orders from OrdersRepository', () async {
      final ordersRepo = OrdersRepository(null);
      final dynamicDashboardRepo = DashboardRepository(null, ordersRepo);

      final initialMetrics = await dynamicDashboardRepo.getDashboardMetrics();
      final initialRevenue = initialMetrics.deliveredRevenue;
      final initialDeliveredCount = initialMetrics.deliveredCount;

      // Find an order that is currently pendingConfirmation or shipping
      final pendingOrder = ordersRepo.mockOrders.firstWhere(
        (o) => o.status == OrderStatus.pendingConfirmation || o.status == OrderStatus.shipping,
      );

      // Admin updates order to delivered
      await ordersRepo.adminUpdateOrderStatus(
        orderId: pendingOrder.id,
        newStatus: OrderStatus.delivered,
      );

      final updatedMetrics = await dynamicDashboardRepo.getDashboardMetrics();

      // Revenue must increase by pendingOrder.totalAmount
      expect(updatedMetrics.deliveredRevenue, initialRevenue + pendingOrder.totalAmount);
      expect(updatedMetrics.deliveredCount, initialDeliveredCount + 1);

      // Recent orders must show the updated status
      final recentDelivered = updatedMetrics.recentOrders.firstWhere(
        (o) => o.id == pendingOrder.id,
      );
      expect(recentDelivered.status, 'delivered');
      expect(recentDelivered.paymentStatus, 'paid');
    });
  });
}
