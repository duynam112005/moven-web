import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../auth/data/auth_repository.dart';
import '../../cart/data/cart_providers.dart';

/// Khung giao diện Quản trị viên (Admin Dashboard Shell)
/// Phân tách riêng biệt với Storefront khách hàng: có Sidebar quản trị, Header admin và vùng nội dung.
class AdminShellScreen extends ConsumerWidget {
  final Widget child;

  const AdminShellScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = context.isDesktop;
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Row(
        children: [
          // Admin Sidebar (Hiển thị cố định trên Desktop)
          if (isDesktop)
            Container(
              width: AppDimensions.adminSidebarWidth,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                border: Border(
                  right: BorderSide(color: Color(0xFF374151)),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // Sidebar Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.space24,
                      vertical: AppDimensions.space24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MOVEN',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                            color: AppColors.onPrimary,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.space4),
                        Text(
                          'Bảng điều khiển quản trị',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(color: Color(0xFF374151), height: 1),

                  // Navigation Items
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.space12,
                        horizontal: AppDimensions.space12,
                      ),
                      children: [
                        _buildAdminNavItem(
                          context,
                          icon: Icons.dashboard_outlined,
                          label: 'Tổng quan',
                          route: RouteNames.adminDashboard,
                        ),
                        _buildAdminNavItem(
                          context,
                          icon: Icons.category_outlined,
                          label: 'Sản phẩm & Danh mục',
                          route: RouteNames.adminCatalog,
                        ),
                        _buildAdminNavItem(
                          context,
                          icon: Icons.inventory_2_outlined,
                          label: 'Tồn kho & Biến động',
                          route: RouteNames.adminInventory,
                        ),
                        _buildAdminNavItem(
                          context,
                          icon: Icons.receipt_long_outlined,
                          label: 'Đơn hàng & Giao vận',
                          route: RouteNames.adminOrders,
                        ),
                        _buildAdminNavItem(
                          context,
                          icon: Icons.view_carousel_outlined,
                          label: 'Quản lý Banner',
                          route: RouteNames.adminBanners,
                        ),
                        _buildAdminNavItem(
                          context,
                          icon: Icons.rate_review_outlined,
                          label: 'Đánh giá & Báo cáo',
                          route: RouteNames.adminReviews,
                        ),
                        _buildAdminNavItem(
                          context,
                          icon: Icons.settings_outlined,
                          label: 'Cài đặt cửa hàng',
                          route: RouteNames.adminSettings,
                        ),
                      ],
                    ),
                  ),

                  // Bottom Action: Về Storefront
                  const Divider(color: Color(0xFF374151), height: 1),
                  Padding(
                    padding: const EdgeInsets.all(AppDimensions.space16),
                    child: InkWell(
                      onTap: () => context.goNamed(RouteNames.home),
                      borderRadius: BorderRadius.circular(AppDimensions.radius8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.space12,
                          vertical: AppDimensions.space12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F2937),
                          borderRadius: BorderRadius.circular(AppDimensions.radius8),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.storefront_outlined,
                              size: 18,
                              color: AppColors.onPrimary,
                            ),
                            SizedBox(width: AppDimensions.space12),
                            Expanded(
                              child: Text(
                                'Về trang bán hàng',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.onPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Admin Top Header
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space24,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      bottom: BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Quản trị MOVEN',
                        style: AppTypography.titleLarge.copyWith(
                          fontSize: 17,
                        ),
                      ),
                      const Spacer(),
                      if (user != null)
                        Chip(
                          avatar: const Icon(Icons.security, size: 16),
                          label: Text(user.email ?? 'Admin'),
                          backgroundColor: AppColors.surfaceVariant,
                        ),
                      const SizedBox(width: AppDimensions.space12),
                      IconButton(
                        tooltip: 'Đăng xuất',
                        icon: const Icon(Icons.logout, size: 20),
                        onPressed: () async {
                          // Điều hướng an toàn về Trang chủ trước khi xóa phiên đăng nhập
                          // Tránh việc GoRouter thấy route /admin chưa đăng nhập rồi tự động đẩy vào /login?redirect=/admin
                          if (context.mounted) {
                            context.go(RouteNames.homePath);
                          }
                          try {
                            await ref.read(authRepositoryProvider).signOut();
                          } catch (_) {}
                          ref.invalidate(userProfileProvider);
                          ref.invalidate(cartNotifierProvider);
                          ref.invalidate(selectedCartItemIdsProvider);
                        },
                      ),
                    ],
                  ),
                ),

                // Page Body
                Expanded(
                  child: child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
  }) {
    String currentRoute = '';
    try {
      currentRoute = GoRouterState.of(context).matchedLocation;
    } catch (_) {}
    final isSelected = currentRoute == route;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.space4),
      child: ListTile(
        leading: Icon(
          icon,
          size: 20,
          color: isSelected ? AppColors.onPrimary : AppColors.textMuted,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? AppColors.onPrimary : AppColors.textMuted,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius8),
        ),
        tileColor: isSelected ? const Color(0xFF1F2937) : Colors.transparent,
        dense: true,
        onTap: () {
          if (!isSelected) {
            context.goNamed(route);
          }
        },
      ),
    );
  }
}
