import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moven/features/orders/presentation/admin/admin_orders_screen.dart';

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
}
