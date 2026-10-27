import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moven/features/admin/presentation/settings/admin_settings_screen.dart';

void main() {
  Widget createTestWidget() {
    return const ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: AdminSettingsScreen(),
        ),
      ),
    );
  }

  testWidgets('AdminSettingsScreen renders fields and save button', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Verify header title
    expect(find.text('Cài đặt Cửa hàng'), findsOneWidget);

    // Verify section titles
    expect(find.text('1. Vận chuyển & Thanh toán COD'), findsOneWidget);
    expect(find.text('2. Quản lý Kho & Cảnh báo Tồn kho'), findsOneWidget);
    expect(find.text('3. Thông tin Liên hệ Cửa hàng'), findsOneWidget);

    // Verify form input labels
    expect(find.text('Phí giao hàng mặc định (VND)'), findsOneWidget);
    expect(find.text('Ngưỡng cảnh báo sắp hết hàng (Low Stock Threshold)'), findsOneWidget);
    expect(find.text('Tên cửa hàng'), findsOneWidget);

    // Verify save button exists
    expect(find.text('Lưu thay đổi cài đặt'), findsOneWidget);
  });
}
