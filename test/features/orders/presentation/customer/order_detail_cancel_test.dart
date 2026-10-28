import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moven/features/orders/domain/models/order_status.dart';
import 'package:moven/features/orders/presentation/customer/order_detail_screen.dart';
import 'package:moven/features/orders/presentation/customer/widgets/cancel_order_dialog.dart';

void main() {
  Widget createTestWidget(String orderCode) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: OrderDetailScreen(orderCode: orderCode),
        ),
      ),
    );
  }

  group('OrderDetailScreen - Customer Order Cancellation Flow', () {
    testWidgets(
      'Opening CancelOrderDialog and dismissing keeps order in pendingConfirmation state',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        // MVN-8A9F1B2C is a mock order with status: pendingConfirmation
        await tester.pumpWidget(createTestWidget('MVN-8A9F1B2C'));
        await tester.pumpAndSettle();

        // 1. Verify initial status and presence of cancel button
        expect(find.text('Đơn hàng MVN-8A9F1B2C'), findsOneWidget);
        expect(find.text('Chờ xác nhận'), findsWidgets);

        final cancelBtn = find.byKey(const ValueKey('customer_cancel_order_button'));
        expect(cancelBtn, findsOneWidget);

        // 2. Tap "Hủy đơn hàng"
        await tester.ensureVisible(cancelBtn);
        await tester.tap(cancelBtn);
        await tester.pumpAndSettle();

        // 3. Verify CancelOrderDialog is shown
        expect(find.byType(CancelOrderDialog), findsOneWidget);
        expect(find.text('Xác nhận hủy đơn hàng?'), findsOneWidget);

        // 4. Tap "Giữ đơn hàng" to dismiss dialog
        final dismissBtn = find.byKey(const ValueKey('dismiss_cancel_order_button'));
        expect(dismissBtn, findsOneWidget);
        await tester.tap(dismissBtn);
        await tester.pumpAndSettle();

        // 5. Verify dialog is dismissed and status remains pendingConfirmation
        expect(find.byType(CancelOrderDialog), findsNothing);
        expect(find.text('Chờ xác nhận'), findsWidgets);
        expect(find.byKey(const ValueKey('customer_cancel_order_button')), findsOneWidget);
      },
    );

    testWidgets(
      'Confirming cancellation in CancelOrderDialog successfully updates order to cancelled without crashing',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        // MVN-8A9F1B2C is a mock order with status: pendingConfirmation
        await tester.pumpWidget(createTestWidget('MVN-8A9F1B2C'));
        await tester.pumpAndSettle();

        // 1. Initial checks
        expect(find.text('Đơn hàng MVN-8A9F1B2C'), findsOneWidget);
        expect(find.text('Chờ xác nhận'), findsWidgets);

        final cancelBtn = find.byKey(const ValueKey('customer_cancel_order_button'));
        expect(cancelBtn, findsOneWidget);

        // 2. Tap "Hủy đơn hàng" button
        await tester.ensureVisible(cancelBtn);
        await tester.tap(cancelBtn);
        await tester.pumpAndSettle();

        // 3. Verify dialog appeared
        expect(find.byType(CancelOrderDialog), findsOneWidget);
        expect(find.text('Xác nhận hủy đơn hàng?'), findsOneWidget);

        // 4. Tap "Xác nhận hủy"
        final confirmBtn = find.byKey(const ValueKey('confirm_cancel_order_button'));
        expect(confirmBtn, findsOneWidget);
        await tester.tap(confirmBtn);
        await tester.pumpAndSettle();

        // 5. Verify dialog closed
        expect(find.byType(CancelOrderDialog), findsNothing);

        // 6. Verify success snackbar is shown
        expect(find.text('Đã hủy đơn hàng thành công.'), findsOneWidget);

        // 7. Verify status updated to "Đã hủy" (cancelled)
        expect(find.text(OrderStatus.cancelled.displayName), findsWidgets);

        // 8. Verify cancellation reason banner is visible
        expect(find.text('Lý do hủy đơn hàng'), findsOneWidget);
        expect(
          find.text('Muốn thay đổi sản phẩm / kích cỡ / màu sắc'),
          findsWidgets,
        );

        // 9. Verify "Hủy đơn hàng" action button is no longer visible
        expect(find.byKey(const ValueKey('customer_cancel_order_button')), findsNothing);
      },
    );
  });
}
