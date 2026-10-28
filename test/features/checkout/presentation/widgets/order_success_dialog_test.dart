import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moven/core/router/route_names.dart';
import 'package:moven/features/checkout/domain/models/checkout_result.dart';
import 'package:moven/features/checkout/presentation/widgets/order_success_view.dart';

void main() {
  const sampleResult = CheckoutResult(
    success: true,
    orderId: 'ord-999',
    orderCode: 'MVN-ORDER-888',
    subtotal: 350000,
    shippingFee: 20000,
    totalAmount: 370000,
  );

  Widget buildDialogTestWidget({
    VoidCallback? onOpen,
    Size surfaceSize = const Size(1280, 800),
  }) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: surfaceSize),
        child: Scaffold(
          body: Builder(
            builder: (context) {
              return Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final destination = await OrderSuccessDialog.show(
                      context: context,
                      result: sampleResult,
                      recipientName: 'Trần Văn B',
                      recipientPhone: '0987654321',
                      shippingAddressText: 'Số 45 Lê Lợi, Quận 1, TP. Hồ Chí Minh',
                    );
                    if (destination != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Navigated to: $destination')),
                      );
                    }
                  },
                  child: const Text('Mở Dialog'),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  group('OrderSuccessDialog Widget Tests', () {
    testWidgets('Hiển thị đầy đủ thông tin đơn hàng và giá trị tiền tệ hợp lệ', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildDialogTestWidget());
      await tester.pumpAndSettle();

      // Mở dialog
      await tester.tap(find.text('Mở Dialog'));
      await tester.pumpAndSettle();

      // Kiểm tra các thành phần tiêu đề và icon thành công
      expect(find.byType(OrderSuccessDialog), findsOneWidget);
      expect(find.text('Đặt hàng thành công!'), findsOneWidget);
      expect(find.text('Mã đơn hàng:'), findsOneWidget);
      expect(find.text('MVN-ORDER-888'), findsOneWidget);
      expect(find.text('Trần Văn B (0987654321)'), findsOneWidget);
      expect(find.text('Số 45 Lê Lợi, Quận 1, TP. Hồ Chí Minh'), findsOneWidget);
      expect(find.text('Thanh toán COD khi nhận hàng'), findsOneWidget);
      expect(find.text('370.000\u00A0₫'), findsOneWidget);
      expect(find.text('Tiếp tục mua sắm'), findsOneWidget);
      expect(find.text('Xem danh sách đơn hàng'), findsOneWidget);
    });

    testWidgets('Bấm Tiếp tục mua sắm đóng dialog và trả về đường dẫn catalog', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildDialogTestWidget());
      await tester.pumpAndSettle();

      // Mở dialog
      await tester.tap(find.text('Mở Dialog'));
      await tester.pumpAndSettle();

      // Bấm nút "Tiếp tục mua sắm"
      await tester.tap(find.text('Tiếp tục mua sắm'));
      await tester.pumpAndSettle();

      // Dialog đã được đóng hoàn toàn
      expect(find.byType(OrderSuccessDialog), findsNothing);
      expect(find.text('Navigated to: ${RouteNames.catalogPath}'), findsOneWidget);
    });

    testWidgets('Bấm Xem danh sách đơn hàng đóng dialog và trả về đường dẫn orders', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildDialogTestWidget());
      await tester.pumpAndSettle();

      // Mở dialog
      await tester.tap(find.text('Mở Dialog'));
      await tester.pumpAndSettle();

      // Bấm nút "Xem danh sách đơn hàng"
      final viewOrdersBtn = find.text('Xem danh sách đơn hàng');
      await tester.ensureVisible(viewOrdersBtn);
      await tester.tap(viewOrdersBtn);
      await tester.pumpAndSettle();

      // Dialog đã được đóng hoàn toàn
      expect(find.byType(OrderSuccessDialog), findsNothing);
      expect(find.text('Navigated to: ${RouteNames.ordersPath}'), findsOneWidget);
    });

    testWidgets('Hoạt động mượt mà không bị RenderFlex overflow trên màn hình nhỏ/hẹp', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(360, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        buildDialogTestWidget(surfaceSize: const Size(360, 480)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mở Dialog'));
      await tester.pumpAndSettle();

      // Dialog hiển thị đầy đủ và có thể cuộn nhờ SingleChildScrollView
      expect(find.byType(OrderSuccessDialog), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
