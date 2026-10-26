import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moven/features/orders/presentation/customer/orders_screen.dart';

void main() {
  Widget createTestWidget() {
    return const ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: OrdersScreen(),
        ),
      ),
    );
  }

  testWidgets('OrdersScreen renders header, filter tabs and order cards', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Verify page header
    expect(find.text('Đơn hàng của bạn'), findsOneWidget);
    expect(find.textContaining('Theo dõi tình trạng vận chuyển'), findsOneWidget);

    // Verify filter tabs
    expect(find.text('Tất cả'), findsOneWidget);
    expect(find.text('Chờ xác nhận'), findsWidgets);
    expect(find.text('Đang giao'), findsWidgets);
    expect(find.text('Đã giao'), findsWidgets);
    expect(find.text('Đã hủy'), findsOneWidget);

    // Verify mock orders rendered
    expect(find.text('MVN-8A9F1B2C'), findsOneWidget);
    expect(find.text('MVN-5E2D3C4B'), findsOneWidget);
  });
}
