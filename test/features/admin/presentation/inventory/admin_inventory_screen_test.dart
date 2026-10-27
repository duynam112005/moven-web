import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moven/features/admin/presentation/inventory/admin_inventory_screen.dart';

void main() {
  Widget createTestWidget() {
    return const ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: AdminInventoryScreen(),
        ),
      ),
    );
  }

  testWidgets('AdminInventoryScreen renders header, KPI cards, and tabs', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Verify header title
    expect(find.text('Quản lý Tồn kho & Biến động'), findsOneWidget);

    // Verify KPI cards
    expect(find.text('Tổng biến thể'), findsOneWidget);
    expect(find.text('Sắp hết hàng (<= 5)'), findsOneWidget);
    expect(find.text('Đã hết hàng (0)'), findsOneWidget);

    // Verify tabs
    expect(find.text('Danh sách tồn kho biến thể'), findsOneWidget);
    expect(find.text('Lịch sử biến động kho (Audit Trail)'), findsOneWidget);

    // Verify refresh button
    expect(find.text('Làm mới'), findsOneWidget);
  });
}
