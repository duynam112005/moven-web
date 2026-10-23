import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moven/app/app.dart';

void main() {
  testWidgets('MovenApp khởi động hiển thị Storefront và thương hiệu MOVEN', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MovenApp(),
      ),
    );

    // Chờ router nạp initial route '/'
    await tester.pumpAndSettle();

    // Xác nhận logo thương hiệu MOVEN hiển thị trên Header
    expect(find.text('MOVEN'), findsWidgets);

    // Xác nhận slogan và banner chính hiển thị
    expect(find.text('Thời trang tối giản,\ntrải nghiệm tối ưu.'), findsOneWidget);

    // Xác nhận cam kết thanh toán COD hiển thị
    expect(find.text('Thanh toán COD'), findsWidgets);
  });
}
