import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/admin/presentation/admin_shell_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/widgets/storefront_shell.dart';
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
          location == RouteNames.profilePath;

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
              child: EmptyStateView(
                icon: Icons.checkroom_outlined,
                title: 'Danh mục sản phẩm',
                description: 'Danh sách sản phẩm sẽ sẵn sàng khi hoàn thiện Giai đoạn 4.',
              ),
            ),
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
              child: EmptyStateView(
                icon: Icons.shopping_bag_outlined,
                title: 'Giỏ hàng của bạn đang trống',
                description: 'Hãy chọn những trang phục yêu thích để thêm vào giỏ.',
                actionLabel: 'Mua sắm ngay',
              ),
            ),
          ),
          GoRoute(
            path: RouteNames.checkoutPath,
            name: RouteNames.checkout,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: EmptyStateView(
                icon: Icons.local_shipping_outlined,
                title: 'Thanh toán COD',
                description: 'Màn hình checkout COD sẽ kết nối tại Giai đoạn 5.',
              ),
            ),
          ),
          GoRoute(
            path: RouteNames.ordersPath,
            name: RouteNames.orders,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: EmptyStateView(
                icon: Icons.receipt_long_outlined,
                title: 'Đơn hàng của bạn',
                description: 'Theo dõi đơn hàng COD tại đây.',
              ),
            ),
          ),
          GoRoute(
            path: RouteNames.profilePath,
            name: RouteNames.profile,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: EmptyStateView(
                icon: Icons.person_outline,
                title: 'Hồ sơ cá nhân',
                description: 'Quản lý thông tin và sổ địa chỉ.',
              ),
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
            body: Center(
              child: EmptyStateView(
                icon: Icons.person_add_outlined,
                title: 'Đăng ký tài khoản',
                description: 'Chức năng đăng ký tài khoản sẽ kết nối tại Giai đoạn 3.',
              ),
            ),
          ),
        ),
      ),
      GoRoute(
        path: RouteNames.forgotPasswordPath,
        name: RouteNames.forgotPassword,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: Scaffold(
            body: Center(
              child: EmptyStateView(
                icon: Icons.lock_reset_outlined,
                title: 'Khôi phục mật khẩu',
                description: 'Vui lòng nhập email để nhận liên kết đặt lại mật khẩu.',
              ),
            ),
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
              child: EmptyStateView(
                icon: Icons.category_outlined,
                title: 'Quản lý Catalog & Sản phẩm',
                description: 'CRUD sản phẩm, danh mục và ảnh Storage (Giai đoạn 4).',
              ),
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
              child: EmptyStateView(
                icon: Icons.receipt_long_outlined,
                title: 'Quản lý Đơn hàng & Vận chuyển',
                description: 'Cập nhật trạng thái thủ công: shipping, delivery_failed, delivered, returned.',
              ),
            ),
          ),
          GoRoute(
            path: RouteNames.adminBannersPath,
            name: RouteNames.adminBanners,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: EmptyStateView(
                icon: Icons.view_carousel_outlined,
                title: 'Quản lý Banner',
                description: 'Tải lên và cấu hình lịch hiển thị banner trang chủ.',
              ),
            ),
          ),
          GoRoute(
            path: RouteNames.adminReviewsPath,
            name: RouteNames.adminReviews,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: EmptyStateView(
                icon: Icons.rate_review_outlined,
                title: 'Kiểm duyệt Đánh giá & Báo cáo',
                description: 'Xử lý báo cáo và ẩn/khôi phục đánh giá sản phẩm.',
              ),
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
    ],
  );
});
