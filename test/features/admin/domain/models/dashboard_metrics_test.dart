import 'package:flutter_test/flutter_test.dart';
import 'package:moven/features/admin/domain/models/dashboard_metrics.dart';

void main() {
  group('DashboardMetrics Domain Model Tests', () {
    test('status counts and computed properties calculate correctly', () {
      const metrics = DashboardMetrics(
        deliveredRevenue: 10000000,
        lowStockThreshold: 5,
        statusCounts: {
          'pending_confirmation': 4,
          'confirmed': 2,
          'preparing': 3,
          'shipping': 5,
          'delivered': 20,
          'delivery_failed': 1,
          'cancelled': 2,
          'returned': 1,
        },
        lowStockVariants: [
          LowStockVariantItem(
            variantId: 'v-1',
            sku: 'SKU-1',
            size: 'M',
            colorName: 'Trắng',
            stockQuantity: 2,
            productName: 'Áo Phông Nam',
          ),
          LowStockVariantItem(
            variantId: 'v-2',
            sku: 'SKU-2',
            size: 'L',
            colorName: 'Đen',
            stockQuantity: 0,
            productName: 'Quần Khaki',
          ),
        ],
      );

      expect(metrics.deliveredRevenue, 10000000);
      expect(metrics.pendingConfirmationCount, 4);
      expect(metrics.confirmedCount, 2);
      expect(metrics.preparingCount, 3);
      expect(metrics.shippingCount, 5);
      expect(metrics.deliveredCount, 20);
      expect(metrics.deliveryFailedCount, 1);
      expect(metrics.cancelledCount, 2);
      expect(metrics.returnedCount, 1);

      expect(metrics.lowStockCount, 2);
    });

    test('default DashboardMetrics handles empty maps gracefully', () {
      const empty = DashboardMetrics();
      expect(empty.deliveredRevenue, 0);
      expect(empty.lowStockThreshold, 5);
      expect(empty.pendingConfirmationCount, 0);
      expect(empty.shippingCount, 0);
      expect(empty.deliveredCount, 0);
      expect(empty.lowStockCount, 0);
    });
  });
}
