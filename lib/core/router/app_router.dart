import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/admin/presentation/admin_shell_screen.dart';
import '../../features/admin/presentation/banners/admin_banner_screen.dart';
import '../../features/admin/presentation/catalog/admin_catalog_screen.dart';
import '../../features/admin/presentation/catalog/admin_category_form_screen.dart';
import '../../features/admin/presentation/catalog/admin_product_form_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/cart/presentation/cart_screen.dart';
import '../../features/checkout/presentation/checkout_screen.dart';
import '../../features/catalog/presentation/catalog_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/widgets/storefront_shell.dart';
import '../../features/orders/presentation/admin/admin_orders_screen.dart';
import '../../features/orders/presentation/customer/order_detail_screen.dart';
import '../../features/orders/presentation/customer/orders_screen.dart';
import '../../features/admin/presentation/reviews/admin_reviews_screen.dart';
import '../../features/product_detail/presentation/product_detail_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/static_pages/presentation/static_page_screen.dart';
import '../network/supabase_client.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/not_found_screen.dart';
import 'route_names.dart';
import 'router_notifier.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'rootNav');
final storefrontNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'storefrontNav');
final adminNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'adminNav');

/// Provider cung cấp GoRouter toàn cục
final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RouteNames.homePath,
    refreshListenable: notifier,
    debugLogDiagnostics: false,
    errorBuilder: (context, state) => NotFoundScreen(path: state.uri.toString()),
    redirect: (context, state) {
      final isAuthenticated = ref.read(isAuthenticatedProvider);
      final isAdmin = ref.read(isAdminProvider);
      final location = state.matchedLocation;

      final isAdminRoute = location.startsWith('/admin');
      final isCustomerProtectedRoute = location == RouteNames.checkoutPath ||
          location.startsWith(RouteNames.ordersPath) ||
          location == RouteNames.profilePath ||
          location == RouteNames.addressesPath;

      // Bảo vệ Admin routes: nếu không phải Admin, chuyển hướng về Login
      if (isAdminRoute && !isAdmin) {
        return '${RouteNames.loginPath}?redirect=${Uri.encodeComponent(location)}';
      }

      // Bảo vệ Customer routes: nếu chưa đăng nhập, chuyển hướng về Login
      if (isCustomerProtectedRoute && !isAuthenticated) {
        return '${RouteNames.loginPath}?redirect=${Uri.encodeComponent(location)}';
      }

      return null;
    },
    routes: [
      // 1. Customer Storefront Shell Route
      ShellRoute(
        navigatorKey: storefrontNavigatorKey,
        builder: (context, state, child) => StorefrontShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.homePath,
            name: RouteNames.home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.catalogPath,
            name: RouteNames.catalog,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CatalogScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.productDetailPath,
            name: RouteNames.productDetail,
            pageBuilder: (context, state) {
              final slug = state.pathParameters['slug'] ?? '';
              return NoTransitionPage(
                child: ProductDetailScreen(slug: slug),
              );
            },
          ),
          GoRoute(
            path: RouteNames.contactPath,
            name: RouteNames.contact,
            pageBuilder: (context, state) => NoTransitionPage(
              child: StaticPageScreen.contact(),
            ),
          ),
          GoRoute(
            path: RouteNames.shippingPolicyPath,
            name: RouteNames.shippingPolicy,
            pageBuilder: (context, state) => NoTransitionPage(
              child: StaticPageScreen.shippingPolicy(),
            ),
          ),
          GoRoute(
            path: RouteNames.returnPolicyPath,
            name: RouteNames.returnPolicy,
            pageBuilder: (context, state) => NoTransitionPage(
              child: StaticPageScreen.returnPolicy(),
            ),
          ),
          GoRoute(
            path: RouteNames.cartPath,
            name: RouteNames.cart,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CartScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.checkoutPath,
            name: RouteNames.checkout,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CheckoutScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.ordersPath,
            name: RouteNames.orders,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: OrdersScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.orderDetailPath,
            name: RouteNames.orderDetail,
            pageBuilder: (context, state) {
              final code = state.pathParameters['code'] ?? '';
              return NoTransitionPage(
                child: OrderDetailScreen(orderCode: code),
              );
            },
          ),
          GoRoute(
            path: RouteNames.profilePath,
            name: RouteNames.profile,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.addressesPath,
            name: RouteNames.addresses,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),

      // 2. Auth Routes
      GoRoute(
        path: RouteNames.loginPath,
        name: RouteNames.login,
        pageBuilder: (context, state) {
          final redirect = state.uri.queryParameters['redirect'];
          return NoTransitionPage(
            child: Scaffold(
              body: LoginScreen(redirectPath: redirect),
            ),
          );
        },
      ),
      GoRoute(
        path: RouteNames.registerPath,
        name: RouteNames.register,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: Scaffold(
            body: RegisterScreen(),
          ),
        ),
      ),
      GoRoute(
        path: RouteNames.forgotPasswordPath,
        name: RouteNames.forgotPassword,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: Scaffold(
            body: ForgotPasswordScreen(),
          ),
        ),
      ),
      GoRoute(
        path: RouteNames.resetPasswordPath,
        name: RouteNames.resetPassword,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: Scaffold(
            body: ResetPasswordScreen(),
          ),
        ),
      ),

      // 3. Admin Dashboard Shell Route
      ShellRoute(
        navigatorKey: adminNavigatorKey,
        builder: (context, state, child) => AdminShellScreen(child: child),
        routes: [
          GoRoute(
            path: RouteNames.adminDashboardPath,
            name: RouteNames.adminDashboard,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AdminDashboardScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.adminCatalogPath,
            name: RouteNames.adminCatalog,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AdminCatalogScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.adminInventoryPath,
            name: RouteNames.adminInventory,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: EmptyStateView(
                icon: Icons.inventory_2_outlined,
                title: 'Quản lý Tồn kho & Biến động',
                description: 'Điều chỉnh tồn kho và audit inventory_movements.',
              ),
            ),
          ),
          GoRoute(
            path: RouteNames.adminOrdersPath,
            name: RouteNames.adminOrders,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AdminOrdersScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.adminBannersPath,
            name: RouteNames.adminBanners,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AdminBannerScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.adminReviewsPath,
            name: RouteNames.adminReviews,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AdminReviewsScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.adminSettingsPath,
            name: RouteNames.adminSettings,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: EmptyStateView(
                icon: Icons.settings_outlined,
                title: 'Cài đặt Cửa hàng',
                description: 'Cấu hình phí ship mặc định và ngưỡng cảnh báo low-stock.',
              ),
            ),
          ),
        ],
      ),

      // 4. Admin catalog sub-routes (top-level, full-screen, no admin shell)
      GoRoute(
        path: RouteNames.adminCategoryCreatePath,
        name: RouteNames.adminCategoryCreate,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: AdminCategoryFormScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.adminCategoryEditPath,
        name: RouteNames.adminCategoryEdit,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return NoTransitionPage(
            child: AdminCategoryFormScreen(categoryId: id),
          );
        },
      ),
      GoRoute(
        path: RouteNames.adminProductCreatePath,
        name: RouteNames.adminProductCreate,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: AdminProductFormScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.adminProductEditPath,
        name: RouteNames.adminProductEdit,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return NoTransitionPage(
            child: AdminProductFormScreen(productId: id),
          );
        },
      ),
    ],
  );
});
