import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moven/features/admin/presentation/reviews/admin_reviews_screen.dart';

void main() {
  Widget createTestWidget() {
    return const ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: AdminReviewsScreen(),
        ),
      ),
    );
  }

  testWidgets('AdminReviewsScreen renders header, tab bar, and moderation elements', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Verify header title
    expect(find.text('Kiểm duyệt Đánh giá & Báo cáo'), findsOneWidget);

    // Verify tabs
    expect(find.text('Báo cáo vi phạm'), findsOneWidget);
    expect(find.text('Tất cả đánh giá'), findsOneWidget);

    // Verify report filter chips
    expect(find.text('Chờ xử lý'), findsWidgets);
    expect(find.text('Đã xử lý (Ẩn)'), findsOneWidget);
    expect(find.text('Đã bỏ qua'), findsOneWidget);
    expect(find.text('Tất cả báo cáo'), findsOneWidget);

    // Switch to "Tất cả đánh giá" tab
    await tester.tap(find.text('Tất cả đánh giá'));
    await tester.pumpAndSettle();

    // Verify search and table headers
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Khách hàng & Mã đơn'), findsOneWidget);
    expect(find.text('Biến thể đã mua'), findsOneWidget);
    expect(find.text('Nội dung nhận xét'), findsOneWidget);
  });
}
