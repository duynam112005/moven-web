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
      expect(find.textContaining('Tiến hành đặt hàng COD'), findsOneWidget);
      expect(find.textContaining('Chọn tất cả'), findsOneWidget);
    });

    testWidgets(
        'Cho phép chọn tất cả, bỏ chọn tất cả và cập nhật trạng thái nút đặt hàng',
        (WidgetTester tester) async {
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
          quantity: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          productName: 'Áo Thun 1',
          productSlug: 'ao-thun-1',
          sku: 'MVN-1',
          size: 'M',
          colorName: 'Đen',
          price: 100000,
          stockQuantity: 10,
          isActive: true,
        ),
        CartItemModel(
          id: 'item-2',
          cartId: 'cart-1',
          variantId: 'var-2',
          quantity: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          productName: 'Áo Polo 2',
          productSlug: 'ao-polo-2',
          sku: 'MVN-2',
          size: 'L',
          colorName: 'Trắng',
          price: 150000,
          stockQuantity: 5,
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

      // Ban đầu mặc định cả 2 sản phẩm còn hàng đều được chọn (Shopee style)
      expect(find.textContaining('Đã chọn: 2'), findsOneWidget);
      expect(find.text('Tiến hành đặt hàng COD (2)'), findsOneWidget);

      // Nhấn "Bỏ chọn tất cả"
      final deselectAllBtn = find.text('Bỏ chọn tất cả');
      expect(deselectAllBtn, findsOneWidget);
      await tester.tap(deselectAllBtn);
      await tester.pumpAndSettle();

      // Sau khi bỏ chọn tất cả: số lượng chọn = 0, thông báo nhắc nhở xuất hiện, nút bị disabled
      expect(find.textContaining('Đã chọn: 0'), findsOneWidget);
      expect(
        find.text(
            'Vui lòng tick chọn ít nhất 1 sản phẩm để tiến hành đặt hàng.'),
        findsOneWidget,
      );
      expect(find.text('Tiến hành đặt hàng COD'), findsOneWidget);

      // Nhấn checkbox "Chọn tất cả" để chọn lại
      final selectAllCheckbox = find.byType(Checkbox).first;
      await tester.tap(selectAllCheckbox);
      await tester.pumpAndSettle();

      // Sau khi chọn lại tất cả: cả 2 món được chọn trở lại
      expect(find.textContaining('Đã chọn: 2'), findsOneWidget);
      expect(find.text('Tiến hành đặt hàng COD (2)'), findsOneWidget);
    });

    testWidgets('Sản phẩm hết hàng bị vô hiệu hóa checkbox không cho phép chọn',
        (WidgetTester tester) async {
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
          quantity: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          productName: 'Áo Còn Hàng',
          productSlug: 'ao-con-hang',
          sku: 'MVN-IN-STOCK',
          size: 'M',
          colorName: 'Đen',
          price: 200000,
          stockQuantity: 10,
          isActive: true,
        ),
        CartItemModel(
          id: 'item-2',
          cartId: 'cart-1',
          variantId: 'var-2',
          quantity: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          productName: 'Áo Hết Hàng',
          productSlug: 'ao-het-hang',
          sku: 'MVN-OUT-OF-STOCK',
          size: 'L',
          colorName: 'Trắng',
          price: 300000,
          stockQuantity: 0,
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

      // Chỉ có 1 sản phẩm còn hàng được chọn
      expect(find.textContaining('Chọn tất cả (1)'), findsOneWidget);
      expect(find.textContaining('Đã chọn: 1'), findsOneWidget);
      expect(find.text('Tiến hành đặt hàng COD (1)'), findsOneWidget);

      // Checkbox của sản phẩm hết hàng bị disable (onChanged == null)
      final checkboxes = tester.widgetList<Checkbox>(find.byType(Checkbox)).toList();
      // Checkbox đầu là "Chọn tất cả", checkbox 2 là món còn hàng, checkbox 3 là món hết hàng
      expect(checkboxes.length, 3);
      expect(checkboxes[1].onChanged, isNotNull);
      expect(checkboxes[2].onChanged, isNull);
    });
  });
}

class _MockCartNotifier extends StateNotifier<AsyncValue<List<CartItemModel>>>
    implements CartNotifier {
  _MockCartNotifier(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
