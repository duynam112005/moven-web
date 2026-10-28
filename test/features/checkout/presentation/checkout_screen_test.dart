import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:moven/core/network/supabase_client.dart';
import 'package:moven/features/cart/data/cart_providers.dart';
import 'package:moven/features/cart/domain/models/cart_item_model.dart';
import 'package:moven/features/checkout/data/checkout_providers.dart';
import 'package:moven/features/checkout/data/checkout_repository.dart';
import 'package:moven/features/checkout/domain/models/checkout_result.dart';
import 'package:moven/features/checkout/presentation/checkout_screen.dart';
import 'package:moven/features/checkout/presentation/widgets/order_success_view.dart';
import 'package:moven/features/profile/data/address_repository.dart';
import 'package:moven/features/profile/domain/models/address.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  final mockUser = User(
    id: 'user-123',
    appMetadata: {},
    userMetadata: {'full_name': 'Nguyễn Văn A'},
    aud: 'authenticated',
    createdAt: DateTime.now().toIso8601String(),
  );

  final sampleItem = CartItemModel(
    id: 'item-1',
    cartId: 'cart-1',
    variantId: 'var-1',
    quantity: 1,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    productName: 'Áo Thun Nam Cotton Compact MOVEN',
    productSlug: 'ao-thun-nam-cotton-compact-moven',
    sku: 'MVN-TSH-BLK-M',
    size: 'M',
    colorName: 'Đen',
    price: 199000,
    stockQuantity: 10,
    isActive: true,
  );

  final sampleAddress = Address(
    id: 'addr-1',
    userId: 'user-123',
    recipientName: 'Nguyễn Văn A',
    phone: '0901234567',
    province: 'Hà Nội',
    district: 'Hoàn Kiếm',
    ward: 'Hàng Bạc',
    addressLine: '123 Phố Cổ',
    isDefault: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  Widget createTestWidget({
    required List<Override> overrides,
    Size surfaceSize = const Size(1280, 800),
  }) {
    final router = GoRouter(
      initialLocation: '/checkout',
      routes: [
        GoRoute(
          path: '/checkout',
          builder: (context, state) => MediaQuery(
            data: MediaQueryData(size: surfaceSize),
            child: const Scaffold(body: CheckoutScreen()),
          ),
        ),
        GoRoute(
          path: '/catalog',
          builder: (context, state) => const Scaffold(body: Text('Catalog Page')),
        ),
        GoRoute(
          path: '/orders',
          builder: (context, state) => const Scaffold(body: Text('Orders Page')),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const Scaffold(body: Text('Login Page')),
        ),
      ],
    );

    return ProviderScope(
      overrides: overrides,
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  group('CheckoutScreen Widget Tests', () {
    testWidgets('Hiển thị yêu cầu đăng nhập nếu chưa xác thực', (
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

      expect(find.text('Yêu cầu đăng nhập'), findsOneWidget);
      expect(find.text('Đăng nhập'), findsOneWidget);
    });

    testWidgets('Hiển thị các khối địa chỉ, COD và nút xác nhận đặt hàng', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        createTestWidget(
          overrides: [
            isAuthenticatedProvider.overrideWithValue(true),
            currentUserProvider.overrideWithValue(mockUser),
            cartNotifierProvider.overrideWith(
              (ref) => _MockCartNotifier(AsyncValue.data([sampleItem])),
            ),
            addressRepositoryProvider.overrideWithValue(
              _MockAddressRepository([sampleAddress]),
            ),
            defaultShippingFeeProvider.overrideWith((ref) => Future.value(20000)),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // Kiểm tra tiêu đề màn hình
      expect(find.text('Thanh toán COD'), findsWidgets);

      // Kiểm tra phần địa chỉ giao hàng
      expect(find.text('Địa chỉ giao hàng'), findsOneWidget);
      expect(find.text('Nguyễn Văn A'), findsOneWidget);

      // Kiểm tra phương thức thanh toán COD
      expect(find.text('Phương thức thanh toán'), findsOneWidget);
      expect(find.text('Thanh toán khi nhận hàng (COD)'), findsOneWidget);

      // Kiểm tra phần kiểm tra đơn hàng và nút xác nhận
      expect(find.text('Kiểm tra đơn hàng'), findsOneWidget);
      expect(find.text('Xác nhận đặt hàng COD'), findsOneWidget);
    });

    testWidgets('Xác nhận đặt hàng COD thành công hiển thị OrderSuccessDialog và chuyển trang mượt mà', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockRepo = _MockCheckoutRepository();

      await tester.pumpWidget(
        createTestWidget(
          overrides: [
            isAuthenticatedProvider.overrideWithValue(true),
            currentUserProvider.overrideWithValue(mockUser),
            cartNotifierProvider.overrideWith(
              (ref) => _MockCartNotifier(AsyncValue.data([sampleItem])),
            ),
            addressRepositoryProvider.overrideWithValue(
              _MockAddressRepository([sampleAddress]),
            ),
            checkoutRepositoryProvider.overrideWithValue(mockRepo),
            defaultShippingFeeProvider.overrideWith((ref) => Future.value(20000)),
          ],
        ),
      );

      await tester.pumpAndSettle();

      final confirmBtn = find.text('Xác nhận đặt hàng COD');
      expect(confirmBtn, findsOneWidget);
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      // Kiểm tra modal dialog thông tin đơn hàng hiển thị
      expect(find.byType(OrderSuccessDialog), findsOneWidget);
      expect(find.text('Đặt hàng thành công!'), findsOneWidget);
      expect(find.text('MVN-TEST1234'), findsOneWidget);
      expect(find.text('Nguyễn Văn A (0901234567)'), findsOneWidget);
      expect(find.text('Thanh toán COD khi nhận hàng'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(OrderSuccessDialog),
          matching: find.text('219.000\u00A0₫'),
        ),
        findsOneWidget,
      );

      // Nhấn Tiếp tục mua sắm
      final continueShoppingBtn = find.text('Tiếp tục mua sắm');
      expect(continueShoppingBtn, findsOneWidget);
      await tester.tap(continueShoppingBtn);
      await tester.pumpAndSettle();

      // Kiểm tra dialog đã đóng và chuyển sang trang Catalog thành công
      expect(find.byType(OrderSuccessDialog), findsNothing);
      expect(find.text('Catalog Page'), findsOneWidget);
    });

    testWidgets('Bấm Xem danh sách đơn hàng trên OrderSuccessDialog chuyển đến trang Orders', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockRepo = _MockCheckoutRepository();

      await tester.pumpWidget(
        createTestWidget(
          overrides: [
            isAuthenticatedProvider.overrideWithValue(true),
            currentUserProvider.overrideWithValue(mockUser),
            cartNotifierProvider.overrideWith(
              (ref) => _MockCartNotifier(AsyncValue.data([sampleItem])),
            ),
            addressRepositoryProvider.overrideWithValue(
              _MockAddressRepository([sampleAddress]),
            ),
            checkoutRepositoryProvider.overrideWithValue(mockRepo),
            defaultShippingFeeProvider.overrideWith((ref) => Future.value(20000)),
          ],
        ),
      );

      await tester.pumpAndSettle();

      final confirmBtn = find.text('Xác nhận đặt hàng COD');
      expect(confirmBtn, findsOneWidget);
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      // Kiểm tra modal dialog thông tin đơn hàng hiển thị
      expect(find.byType(OrderSuccessDialog), findsOneWidget);

      // Nhấn Xem danh sách đơn hàng
      final viewOrdersBtn = find.text('Xem danh sách đơn hàng');
      expect(viewOrdersBtn, findsOneWidget);
      await tester.tap(viewOrdersBtn);
      await tester.pumpAndSettle();

      // Kiểm tra dialog đã đóng và chuyển sang trang Orders thành công
      expect(find.byType(OrderSuccessDialog), findsNothing);
      expect(find.text('Orders Page'), findsOneWidget);
    });
  });
}

class _MockCartNotifier extends StateNotifier<AsyncValue<List<CartItemModel>>>
    implements CartNotifier {
  _MockCartNotifier(super.state);

  @override
  Future<void> loadCart() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockCheckoutRepository implements CheckoutRepository {
  @override
  Future<CheckoutResult> createOrderCheckout({
    required Map<String, dynamic> shippingAddress,
    required List<Map<String, dynamic>> items,
    String? customerNote,
  }) async {
    return const CheckoutResult(
      success: true,
      orderId: 'order-123',
      orderCode: 'MVN-TEST1234',
      subtotal: 199000,
      shippingFee: 20000,
      totalAmount: 219000,
    );
  }

  @override
  Future<int> getDefaultShippingFee() async => 20000;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockAddressRepository implements AddressRepository {
  final List<Address> addresses;
  _MockAddressRepository(this.addresses);

  @override
  Future<List<Address>> getAddresses(String userId) async => addresses;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
