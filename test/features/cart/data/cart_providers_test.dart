import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:moven/core/network/supabase_client.dart';
import 'package:moven/core/router/route_names.dart';
import 'package:moven/features/auth/data/auth_repository.dart';
import 'package:moven/features/auth/domain/models/user_profile.dart';
import 'package:moven/features/cart/data/cart_providers.dart';
import 'package:moven/features/cart/data/cart_repository.dart';
import 'package:moven/features/cart/domain/models/cart_item_model.dart';
import 'package:moven/features/home/presentation/widgets/storefront_shell.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeCartRepository implements CartRepository {
  final List<CartItemModel> items;
  _FakeCartRepository(this.items);

  @override
  Future<List<CartItemModel>> getCartItems(String userId) async {
    return items;
  }

  @override
  Future<void> addToCart({
    required String userId,
    required String variantId,
    required int quantity,
  }) async {}

  @override
  Future<void> updateQuantity({
    required String itemId,
    required int quantity,
  }) async {}

  @override
  Future<void> removeItem(String itemId) async {}

  @override
  Future<void> clearCart(String userId) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuthRepository implements AuthRepository {
  bool signedOutCalled = false;
  final VoidCallback? onSignOut;

  _FakeAuthRepository({this.onSignOut});

  @override
  Future<void> signOut() async {
    signedOutCalled = true;
    onSignOut?.call();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final mockUser = User(
    id: 'user-cart-test',
    appMetadata: const {},
    userMetadata: const {'full_name': 'Nguyễn Văn Test'},
    aud: 'authenticated',
    createdAt: DateTime.now().toIso8601String(),
  );

  final sampleItems = [
    CartItemModel(
      id: 'cart-item-1',
      cartId: 'cart-1',
      variantId: 'var-1',
      quantity: 2,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      productName: 'Áo Thun Cotton',
      productSlug: 'ao-thun-cotton',
      sku: 'MVN-TSH-01',
      size: 'L',
      colorName: 'Đen',
      price: 200000,
      compareAtPrice: 250000,
      stockQuantity: 10,
      isActive: true,
      imageUrl: null,
    ),
    CartItemModel(
      id: 'cart-item-2',
      cartId: 'cart-1',
      variantId: 'var-2',
      quantity: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      productName: 'Quần Kaki',
      productSlug: 'quan-kaki',
      sku: 'MVN-PNT-01',
      size: '32',
      colorName: 'Be',
      price: 350000,
      compareAtPrice: 400000,
      stockQuantity: 5,
      isActive: true,
      imageUrl: null,
    ),
  ];

  group('Cart Providers Auth Lifecycle Tests', () {
    test('Khách chưa đăng nhập: Giỏ hàng rỗng và cartItemCountProvider = 0', () {
      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWithValue(null),
          cartRepositoryProvider.overrideWithValue(_FakeCartRepository(sampleItems)),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(cartItemCountProvider), 0);
      expect(container.read(cartNotifierProvider).value, isEmpty);
      expect(container.read(selectedCartItemIdsProvider), isEmpty);
    });

    test('Đăng xuất: cartNotifierProvider và cartItemCountProvider tự động reset về 0', () async {
      final authUserProvider = StateProvider<User?>((ref) => mockUser);

      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWith((ref) => ref.watch(authUserProvider)),
          cartRepositoryProvider.overrideWithValue(_FakeCartRepository(sampleItems)),
        ],
      );
      addTearDown(container.dispose);

      // Chờ nạp dữ liệu giỏ hàng của user
      await container.read(cartNotifierProvider.notifier).loadCart();
      expect(container.read(cartItemCountProvider), 3);
      expect(container.read(cartNotifierProvider).value?.length, 2);

      // Giả lập thao tác đăng xuất: authUserProvider đổi sang null
      container.read(authUserProvider.notifier).state = null;

      // Sau khi đăng xuất: Số lượng giỏ hàng phải về 0 và danh sách rỗng
      expect(container.read(cartItemCountProvider), 0);
      expect(container.read(cartNotifierProvider).value, isEmpty);
      expect(container.read(selectedCartItemIdsProvider), isEmpty);
    });

    testWidgets('Header StorefrontShell: Icon giỏ hàng về 0 sau khi người dùng đăng xuất', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final authUserProvider = StateProvider<User?>((ref) => mockUser);

      final fakeAuthRepo = _FakeAuthRepository(
        onSignOut: () {
          // Khi signOut được gọi, cập nhật currentUser thành null
          // Giống như behavior thật của Supabase Auth listener
        },
      );

      final testRouter = GoRouter(
        initialLocation: RouteNames.homePath,
        routes: [
          ShellRoute(
            builder: (context, state, child) => StorefrontShell(child: child),
            routes: [
              GoRoute(
                path: RouteNames.homePath,
                name: RouteNames.home,
                builder: (context, state) => const SizedBox(),
              ),
              GoRoute(
                path: RouteNames.ordersPath,
                name: RouteNames.orders,
                builder: (context, state) => const SizedBox(),
              ),
              GoRoute(
                path: RouteNames.profilePath,
                name: RouteNames.profile,
                builder: (context, state) => const SizedBox(),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) => ref.watch(authUserProvider)),
            isAuthenticatedProvider.overrideWith((ref) => ref.watch(authUserProvider) != null),
            userProfileProvider.overrideWith((ref) async {
              final user = ref.watch(authUserProvider);
              if (user == null) return null;
              return UserProfile(
                id: user.id,
                fullName: 'Nguyễn Văn Test',
                phone: '0901234567',
                role: 'customer',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
            }),
            authRepositoryProvider.overrideWithValue(fakeAuthRepo),
            cartRepositoryProvider.overrideWithValue(_FakeCartRepository(sampleItems)),
          ],
          child: MaterialApp.router(
            routerConfig: testRouter,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Khi đã đăng nhập và có 2 mặt hàng (tổng số lượng = 3)
      // Icon giỏ hàng trên Header phải hiển thị badge số 3
      expect(find.text('3'), findsOneWidget);

      // Mở menu tài khoản
      await tester.tap(find.byTooltip('Tài khoản'));
      await tester.pumpAndSettle();

      // Nhấn Đăng xuất
      await tester.tap(find.text('Đăng xuất'));

      // Giả lập authStateChange sau signOut
      fakeAuthRepo.signedOutCalled = true;
      final element = tester.element(find.byType(StorefrontShell));
      final container = ProviderScope.containerOf(element);
      container.read(authUserProvider.notifier).state = null;

      await tester.pumpAndSettle();

      // Sau khi đăng xuất: Badge giỏ hàng trên icon phải về 0
      expect(find.text('0'), findsOneWidget);
      expect(find.text('3'), findsNothing);
      expect(find.text('Đăng nhập'), findsOneWidget);
    });
  });
}
