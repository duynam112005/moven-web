import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moven/features/admin/presentation/admin_dashboard_screen.dart';

void main() {
  Widget createTestWidget() {
    return const ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: AdminDashboardScreen(),
        ),
      ),
    );
  }

  testWidgets('AdminDashboardScreen renders header, range chips, KPIs, and data tables', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Verify header title and refresh button
    expect(find.text('Tổng quan kinh doanh'), findsOneWidget);
    expect(find.byTooltip('Làm mới số liệu'), findsOneWidget);

    // Verify time range filter chips
    expect(find.text('Hôm nay'), findsOneWidget);
    expect(find.text('7 ngày qua'), findsOneWidget);
    expect(find.text('30 ngày qua'), findsOneWidget);
    expect(find.text('Toàn thời gian'), findsOneWidget);

    // Verify KPI summary card titles
    expect(find.text('Doanh thu giao thành công'), findsOneWidget);
    expect(find.text('Đơn chờ duyệt'), findsOneWidget);
    expect(find.text('Đang vận chuyển'), findsWidgets);
    expect(find.text('Cảnh báo tồn kho'), findsOneWidget);

    // Verify section titles
    expect(find.text('Phân bổ đơn hàng'), findsOneWidget);
    expect(find.text('Top sản phẩm bán chạy'), findsOneWidget);
    expect(find.textContaining('Cảnh báo tồn kho thấp'), findsOneWidget);
    expect(find.text('Đơn hàng gần đây'), findsOneWidget);

    // Verify recent orders link
    expect(find.text('Xem tất cả đơn hàng →'), findsOneWidget);
  });
}
