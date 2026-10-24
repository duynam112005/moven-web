import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:moven/app/app.dart';
import 'package:moven/core/constants/app_colors.dart';
import 'package:moven/core/router/route_names.dart';
import 'package:moven/features/home/presentation/widgets/storefront_shell.dart';

void main() {
  /// Helper kiểm tra trạng thái hiển thị của một mục Nav trên Header:
  /// - Nếu active: Nền AppColors.primary, chữ AppColors.onPrimary (trắng)
  /// - Nếu inactive: Nền Colors.transparent, chữ AppColors.textPrimary
  void verifyNavItemState(
    WidgetTester tester, {
    required String label,
    required bool isActive,
  }) {
    final navTextFinder = find.descendant(
      of: find.byType(PreferredSize),
      matching: find.text(label),
    );
    expect(navTextFinder, findsOneWidget);

    final textWidget = tester.widget<Text>(navTextFinder);
    expect(
      textWidget.style?.color,
      isActive ? AppColors.onPrimary : AppColors.textPrimary,
      reason: 'Text color of "$label" must match active state ($isActive)',
    );

    final containerFinder = find.ancestor(
      of: navTextFinder,
      matching: find.byType(AnimatedContainer),
    );
    expect(containerFinder, findsOneWidget);

    final containerWidget = tester.widget<AnimatedContainer>(containerFinder);
    final decoration = containerWidget.decoration as BoxDecoration?;
    expect(
      decoration?.color,
      isActive ? AppColors.primary : Colors.transparent,
      reason: 'Container color of "$label" must match active state ($isActive)',
    );
  }

  group('Storefront Navbar Active State Tests', () {
    testWidgets('1. "/" -> Trang chủ active, các mục khác inactive', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const ProviderScope(child: MovenApp()));
      await tester.pumpAndSettle();

      verifyNavItemState(tester, label: 'Trang chủ', isActive: true);
      verifyNavItemState(tester, label: 'Sản phẩm', isActive: false);
      verifyNavItemState(
        tester,
        label: 'Chính sách giao hàng',
        isActive: false,
      );
      verifyNavItemState(tester, label: 'Liên hệ', isActive: false);
    });

    testWidgets(
      '2. Chuyển trang qua click navbar -> cập nhật active chính xác',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(const ProviderScope(child: MovenApp()));
        await tester.pumpAndSettle();

        // Click "Sản phẩm" (/catalog)
        await tester.tap(
          find.descendant(
            of: find.byType(PreferredSize),
            matching: find.text('Sản phẩm'),
          ),
        );
        await tester.pumpAndSettle();

        verifyNavItemState(tester, label: 'Trang chủ', isActive: false);
        verifyNavItemState(tester, label: 'Sản phẩm', isActive: true);
        verifyNavItemState(
          tester,
          label: 'Chính sách giao hàng',
          isActive: false,
        );
        verifyNavItemState(tester, label: 'Liên hệ', isActive: false);

        // Click "Chính sách giao hàng" (/shipping-policy)
        await tester.tap(
          find.descendant(
            of: find.byType(PreferredSize),
            matching: find.text('Chính sách giao hàng'),
          ),
        );
        await tester.pumpAndSettle();

        verifyNavItemState(tester, label: 'Trang chủ', isActive: false);
        verifyNavItemState(tester, label: 'Sản phẩm', isActive: false);
        verifyNavItemState(
          tester,
          label: 'Chính sách giao hàng',
          isActive: true,
        );
        verifyNavItemState(tester, label: 'Liên hệ', isActive: false);

        // Click "Liên hệ" (/contact)
        await tester.tap(
          find.descendant(
            of: find.byType(PreferredSize),
            matching: find.text('Liên hệ'),
          ),
        );
        await tester.pumpAndSettle();

        verifyNavItemState(tester, label: 'Trang chủ', isActive: false);
        verifyNavItemState(tester, label: 'Sản phẩm', isActive: false);
        verifyNavItemState(
          tester,
          label: 'Chính sách giao hàng',
          isActive: false,
        );
        verifyNavItemState(tester, label: 'Liên hệ', isActive: true);

        // Click lại "Trang chủ" (/)
        await tester.tap(
          find.descendant(
            of: find.byType(PreferredSize),
            matching: find.text('Trang chủ'),
          ),
        );
        await tester.pumpAndSettle();

        verifyNavItemState(tester, label: 'Trang chủ', isActive: true);
        verifyNavItemState(tester, label: 'Sản phẩm', isActive: false);
        verifyNavItemState(
          tester,
          label: 'Chính sách giao hàng',
          isActive: false,
        );
        verifyNavItemState(tester, label: 'Liên hệ', isActive: false);
      },
    );

    testWidgets('3. Truy cập trực tiếp URL và reload -> active chính xác', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Tạo test router mô phỏng người dùng nhập trực tiếp URL '/shipping-policy'
      final testRouter = GoRouter(
        initialLocation: RouteNames.shippingPolicyPath,
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
                path: RouteNames.catalogPath,
                name: RouteNames.catalog,
                builder: (context, state) => const SizedBox(),
              ),
              GoRoute(
                path: RouteNames.shippingPolicyPath,
                name: RouteNames.shippingPolicy,
                builder: (context, state) => const SizedBox(),
              ),
              GoRoute(
                path: RouteNames.contactPath,
                name: RouteNames.contact,
                builder: (context, state) => const SizedBox(),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: testRouter)),
      );
      await tester.pumpAndSettle();

      // Kiểm tra ngay khi khởi động trực tiếp vào '/shipping-policy'
      verifyNavItemState(tester, label: 'Trang chủ', isActive: false);
      verifyNavItemState(tester, label: 'Sản phẩm', isActive: false);
      verifyNavItemState(tester, label: 'Chính sách giao hàng', isActive: true);
      verifyNavItemState(tester, label: 'Liên hệ', isActive: false);
    });

    testWidgets(
      '4. Route con của sản phẩm (/product/:slug hoặc /catalog/sub) -> Sản phẩm vẫn active',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final testRouter = GoRouter(
          initialLocation: '/product/ao-thun-cotton-compact',
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
                  path: RouteNames.catalogPath,
                  name: RouteNames.catalog,
                  builder: (context, state) => const SizedBox(),
                ),
                GoRoute(
                  path: '/product/:slug',
                  builder: (context, state) => const SizedBox(),
                ),
                GoRoute(
                  path: RouteNames.shippingPolicyPath,
                  name: RouteNames.shippingPolicy,
                  builder: (context, state) => const SizedBox(),
                ),
                GoRoute(
                  path: RouteNames.contactPath,
                  name: RouteNames.contact,
                  builder: (context, state) => const SizedBox(),
                ),
              ],
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(child: MaterialApp.router(routerConfig: testRouter)),
        );
        await tester.pumpAndSettle();

        // Sản phẩm phải active khi ở trang chi tiết sản phẩm /product/:slug
        verifyNavItemState(tester, label: 'Trang chủ', isActive: false);
        verifyNavItemState(tester, label: 'Sản phẩm', isActive: true);
        verifyNavItemState(
          tester,
          label: 'Chính sách giao hàng',
          isActive: false,
        );
        verifyNavItemState(tester, label: 'Liên hệ', isActive: false);
      },
    );

    testWidgets(
      '5. Trang khác ngoài 4 tab chính (vd: /cart) -> không tab nào active',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(const ProviderScope(child: MovenApp()));
        await tester.pumpAndSettle();

        // Click vào giỏ hàng (/cart)
        await tester.tap(find.byIcon(Icons.shopping_bag_outlined));
        await tester.pumpAndSettle();

        verifyNavItemState(tester, label: 'Trang chủ', isActive: false);
        verifyNavItemState(tester, label: 'Sản phẩm', isActive: false);
        verifyNavItemState(
          tester,
          label: 'Chính sách giao hàng',
          isActive: false,
        );
        verifyNavItemState(tester, label: 'Liên hệ', isActive: false);
      },
    );

    testWidgets(
      '6. Giữ nguyên responsive layout, logo, giỏ hàng, nút đăng nhập',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(const ProviderScope(child: MovenApp()));
        await tester.pumpAndSettle();

        // Logo MOVEN
        expect(find.text('MOVEN'), findsWidgets);

        // Giỏ hàng và badge số lượng
        expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
        expect(find.text('0'), findsOneWidget);

        // Nút Đăng nhập
        expect(find.text('Đăng nhập'), findsOneWidget);
        expect(find.byIcon(Icons.login), findsOneWidget);
      },
    );
  });
}
