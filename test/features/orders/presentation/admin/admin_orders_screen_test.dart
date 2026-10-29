import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moven/features/admin/presentation/providers/dashboard_providers.dart';
import 'package:moven/features/orders/domain/models/order_status.dart';
import 'package:moven/features/orders/presentation/admin/admin_orders_screen.dart';
import 'package:moven/features/orders/presentation/providers/orders_providers.dart';

void main() {
  Widget createTestWidget() {
    return const ProviderScope(
      child: MaterialApp(
        home: AdminOrdersScreen(),
      ),
    );
  }

  testWidgets('AdminOrdersScreen renders admin header, search, and orders table', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Verify admin page title
    expect(find.text('Quản lý Đơn hàng & Giao vận'), findsOneWidget);

    // Verify search input
    expect(find.byType(TextField), findsOneWidget);

    // Verify table headers
    expect(find.text('Mã đơn'), findsOneWidget);
    expect(find.text('Khách hàng'), findsOneWidget);
    expect(find.text('Ngày đặt'), findsOneWidget);
    expect(find.text('Tổng thu COD'), findsOneWidget);
    expect(find.text('Trạng thái'), findsOneWidget);
    expect(find.text('Tiền COD'), findsOneWidget);
    expect(find.text('Hành động nhanh'), findsOneWidget);

    // Verify orders are listed
    expect(find.text('MVN-8A9F1B2C'), findsOneWidget);
    expect(find.text('Nguyễn Văn An'), findsWidgets);
  });

  test('Updating order status to delivered automatically invalidates and updates dashboard metrics', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Initial metrics
    final initialMetrics = await container.read(dashboardMetricsProvider.future);
    final initialRevenue = initialMetrics.deliveredRevenue;

    // Admin updates order MVN-8A9F1B2C (which is pending_confirmation with total 818000) to delivered
    final success = await container
        .read(orderActionControllerProvider.notifier)
        .adminUpdateStatus(
          orderId: 'ord-mock-001',
          orderCode: 'MVN-8A9F1B2C',
          newStatus: OrderStatus.delivered,
        );

    expect(success, isTrue);

    // Read updated dashboard metrics
    final updatedMetrics = await container.read(dashboardMetricsProvider.future);

    // Delivered revenue should now include the 818000 of ord-mock-001
    expect(updatedMetrics.deliveredRevenue, initialRevenue + 818000);

    // Recent orders in dashboard should now show MVN-8A9F1B2C as delivered and paid
    final recentOrder = updatedMetrics.recentOrders.firstWhere(
      (o) => o.orderCode == 'MVN-8A9F1B2C',
    );
    expect(recentOrder.status, 'delivered');
    expect(recentOrder.paymentStatus, 'paid');
  });
}
