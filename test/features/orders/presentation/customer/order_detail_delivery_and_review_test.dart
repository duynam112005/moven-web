import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moven/features/orders/presentation/customer/order_detail_screen.dart';
import 'package:moven/features/reviews/presentation/widgets/submit_review_dialog.dart';

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

  testWidgets(
    'OrderDetailScreen shows confirm delivery button on shipping order and updates status on confirm',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // MVN-5E2D3C4B is a mock order with status: shipping
      await tester.pumpWidget(createTestWidget('MVN-5E2D3C4B'));
      await tester.pumpAndSettle();

      // Verify order header and status
      expect(find.text('Đơn hàng MVN-5E2D3C4B'), findsOneWidget);
      expect(find.text('Đang giao hàng'), findsWidgets);

      // Verify confirm delivery banner and button are visible
      expect(find.textContaining('Kiện hàng đang được giao tới bạn'), findsOneWidget);
      final confirmBtn = find.byKey(const ValueKey('customer_confirm_delivery_button'));
      expect(confirmBtn, findsOneWidget);

      // Verify review buttons are NOT visible while in shipping
      expect(find.text('Đánh giá sản phẩm'), findsNothing);

      // Tap "Đã nhận được hàng"
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      // Verify confirmation dialog appears
      expect(find.text('Xác nhận đã nhận hàng?'), findsOneWidget);
      expect(find.text('Chưa nhận'), findsOneWidget);
      expect(find.text('Đã nhận hàng'), findsOneWidget);

      // Tap confirm in dialog
      await tester.tap(find.text('Đã nhận hàng'));
      await tester.pumpAndSettle();

      // Verify snackbar appears
      expect(
        find.textContaining('Xác nhận nhận hàng thành công!'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'OrderDetailScreen shows review button on delivered order and opens SubmitReviewDialog',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // MVN-1A7F9D3E is a mock order with status: delivered
      await tester.pumpWidget(createTestWidget('MVN-1A7F9D3E'));
      await tester.pumpAndSettle();

      // Verify order header and status
      expect(find.text('Đơn hàng MVN-1A7F9D3E'), findsOneWidget);
      expect(find.text('Giao thành công'), findsWidgets);

      // Verify confirm delivery button is NOT visible
      expect(find.byKey(const ValueKey('customer_confirm_delivery_button')), findsNothing);

      // Verify "Đánh giá sản phẩm" button is visible
      final reviewBtn = find.text('Đánh giá sản phẩm');
      expect(reviewBtn, findsOneWidget);

      // Scroll if needed and tap review button
      await tester.ensureVisible(reviewBtn);
      await tester.tap(reviewBtn);
      await tester.pumpAndSettle();

      // Verify SubmitReviewDialog opened
      expect(find.byType(SubmitReviewDialog), findsOneWidget);
      expect(find.textContaining('Đánh giá sản phẩm'), findsWidgets);
      expect(find.text('Chọn số sao đánh giá'), findsOneWidget);
    },
  );
}
