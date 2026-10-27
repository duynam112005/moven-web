import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moven/features/reviews/presentation/widgets/product_reviews_section.dart';

void main() {
  Widget createTestWidget() {
    return const ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProductReviewsSection(
              productId: 'prod-001',
              productName: 'Áo Phông Nam Basic Cotton',
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('ProductReviewsSection renders rating summary, filters, and review cards', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Verify section title
    expect(find.text('Đánh giá từ khách hàng'), findsOneWidget);

    // Verify star filters
    expect(find.text('Tất cả'), findsOneWidget);
    expect(find.text('5 sao'), findsWidgets);
    expect(find.text('4 sao'), findsWidgets);

    // Verify verified buyer badges exist
    expect(find.text('Đã mua hàng'), findsWidgets);

    // Verify write review button exists
    expect(find.text('Viết đánh giá'), findsOneWidget);
  });
}
