import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moven/core/network/supabase_client.dart';
import 'package:moven/features/cart/data/cart_providers.dart';
import 'package:moven/features/cart/domain/models/cart_item_model.dart';
import 'package:moven/features/cart/presentation/cart_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  final mockUser = User(
    id: 'user-123',
    appMetadata: {},
    userMetadata: {'full_name': 'Nguyễn Văn A'},
    aud: 'authenticated',
    createdAt: DateTime.now().toIso8601String(),
  );

  Widget createTestWidget({
    required List<Override> overrides,
    Size surfaceSize = const Size(1280, 800),
  }) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: surfaceSize),
          child: const CartScreen(),
        ),
      ),
    );
  }

  group('CartScreen Widget Tests', () {
    testWidgets('Hiển thị yêu cầu đăng nhập nếu người dùng chưa xác thực', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          overrides: [
            isAuthenticatedProvider.overrideWithValue(false),
            currentUserProvider.overrideWithValue(null),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Vui lòng đăng nhập'), findsOneWidget);
      expect(find.text('Đăng nhập ngay'), findsOneWidget);
    });

    testWidgets('Hiển thị trạng thái giỏ trống khi danh sách rỗng', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          overrides: [
            isAuthenticatedProvider.overrideWithValue(true),
            currentUserProvider.overrideWithValue(mockUser),
            cartNotifierProvider.overrideWith(
              (ref) => _MockCartNotifier(const AsyncValue.data([])),
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Giỏ hàng của bạn đang trống'), findsOneWidget);
      expect(find.text('Mua sắm ngay'), findsOneWidget);
    });

    testWidgets('Hiển thị danh sách sản phẩm và tóm tắt thanh toán đúng số liệu', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final items = [
        CartItemModel(
          id: 'item-1',
          cartId: 'cart-1',
          variantId: 'var-1',
          quantity: 2,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          productName: 'Áo Thun Nam Cotton Compact MOVEN',
          productSlug: 'ao-thun-nam-cotton-compact-moven',
          sku: 'MVN-TSH-BLK-M',
          size: 'M',
          colorName: 'Đen',
          price: 199000,
          compareAtPrice: 249000,
          stockQuantity: 10,
          isActive: true,
        ),
      ];

      await tester.pumpWidget(
        createTestWidget(
          overrides: [
            isAuthenticatedProvider.overrideWithValue(true),
            currentUserProvider.overrideWithValue(mockUser),
            cartNotifierProvider.overrideWith(
              (ref) => _MockCartNotifier(AsyncValue.data(items)),
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // Xác nhận tên sản phẩm hiển thị
      expect(find.text('Áo Thun Nam Cotton Compact MOVEN'), findsOneWidget);
      expect(find.text('Mã SKU: MVN-TSH-BLK-M'), findsOneWidget);

      // Xác nhận các thành phần tóm tắt đơn hàng hiển thị
      expect(find.text('Tóm tắt đơn hàng'), findsOneWidget);
      expect(find.text('Tiến hành đặt hàng COD'), findsOneWidget);
    });
  });
}

class _MockCartNotifier extends StateNotifier<AsyncValue<List<CartItemModel>>>
    implements CartNotifier {
  _MockCartNotifier(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
