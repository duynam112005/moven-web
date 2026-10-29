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
    'OrderDetailScreen shows transit info card on shipping order without customer self-confirm button',
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

      // Verify transit banner is visible informing customer about courier transit and COD cash payment
      expect(find.textContaining('Kiện hàng đang trên đường giao tới bạn'), findsOneWidget);
      expect(find.textContaining('Nhân viên giao vận sẽ liên hệ với bạn'), findsOneWidget);

      // Verify customer self-confirm delivery button is NOT present (strictly adheres to ADR-0001 & COD flow)
      expect(find.byKey(const ValueKey('customer_confirm_delivery_button')), findsNothing);

      // Verify review buttons are NOT visible while in shipping
      expect(find.text('Đánh giá sản phẩm'), findsNothing);
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
