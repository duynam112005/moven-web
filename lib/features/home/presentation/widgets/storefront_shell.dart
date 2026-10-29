import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../cart/data/cart_providers.dart';

/// Khung giao diện chuẩn dành cho Khách hàng (Customer Storefront Shell)
/// Bao gồm Header (Logo, Điều hướng, Giỏ hàng, Tài khoản), nội dung chính và Footer.
class StorefrontShell extends ConsumerWidget {
  final Widget child;

  const StorefrontShell({super.key, required this.child});

  String _getCurrentPath(BuildContext context) {
    try {
      final path = GoRouterState.of(context).uri.path;
      if (path.length > 1 && path.endsWith('/')) {
        return path.substring(0, path.length - 1);
      }
      return path;
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final isDesktop = context.isDesktop;
    final currentPath = _getCurrentPath(context);

    final isHomeActive = currentPath == RouteNames.homePath;
    final isCatalogActive =
        currentPath == RouteNames.catalogPath ||
        currentPath.startsWith('${RouteNames.catalogPath}/') ||
        currentPath == '/products' ||
        currentPath.startsWith('/products/') ||
        currentPath.startsWith('/product/');
    final isShippingPolicyActive =
        currentPath == RouteNames.shippingPolicyPath ||
        currentPath.startsWith('${RouteNames.shippingPolicyPath}/');
    final isContactActive =
        currentPath == RouteNames.contactPath ||
        currentPath.startsWith('${RouteNames.contactPath}/');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(AppDimensions.headerHeight),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppDimensions.maxContentWidth,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space20,
                  ),
                  child: Row(
                    children: [
                      // Logo MOVEN
                      InkWell(
                        onTap: () => context.goNamed(RouteNames.home),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radius4,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppDimensions.space8,
                            vertical: AppDimensions.space4,
                          ),
                          child: Text(
                            'MOVEN',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: AppDimensions.space32),

                      // Desktop Navigation Links
                      if (isDesktop) ...[
                        _buildNavLink(
                          context,
                          label: 'Trang chủ',
                          isActive: isHomeActive,
                          onTap: () => context.goNamed(RouteNames.home),
                        ),
                        _buildNavLink(
                          context,
                          label: 'Sản phẩm',
                          isActive: isCatalogActive,
                          onTap: () => context.goNamed(RouteNames.catalog),
                        ),
                        _buildNavLink(
                          context,
                          label: 'Chính sách giao hàng',
                          isActive: isShippingPolicyActive,
                          onTap: () =>
                              context.goNamed(RouteNames.shippingPolicy),
                        ),
                        _buildNavLink(
                          context,
                          label: 'Liên hệ',
                          isActive: isContactActive,
                          onTap: () => context.goNamed(RouteNames.contact),
                        ),
                      ],

                      const Spacer(),

                      // Nút truy cập nhanh Đơn hàng của tôi
                      IconButton(
                        tooltip: 'Đơn hàng của tôi',
                        icon: const Icon(Icons.receipt_long_outlined, size: 22),
                        onPressed: () => context.goNamed(RouteNames.orders),
                      ),
                      const SizedBox(width: AppDimensions.space4),

                      // Cart Icon with dynamic item count badge
                      Consumer(
                        builder: (context, ref, _) {
                          final cartCount = ref.watch(cartItemCountProvider);
                          return IconButton(
                            tooltip: 'Giỏ hàng',
                            icon: Badge(
                              label: Text('$cartCount'),
                              child: const Icon(Icons.shopping_bag_outlined, size: 22),
                            ),
                            onPressed: () => context.goNamed(RouteNames.cart),
                          );
                        },
                      ),
                      const SizedBox(width: AppDimensions.space8),
                      // Nút truy cập nhanh Trang quản trị cho Admin
                      if (isAuthenticated && isAdmin && isDesktop) ...[
                        OutlinedButton.icon(
                          onPressed: () => context.go(RouteNames.adminDashboardPath),
                          icon: const Icon(Icons.dashboard_outlined, size: 16),
                          label: const Text('Trang quản trị', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.space12,
                              vertical: AppDimensions.space8,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space8),
                      ],

                      // Auth / Profile Button
                      if (isAuthenticated)
                        _buildUserMenu(context, ref)
                      else
                        TextButton.icon(
                          onPressed: () => context.goNamed(RouteNames.login),
                          icon: const Icon(Icons.login, size: 18),
                          label: const Text('Đăng nhập'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Body Content
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 500),
              child: child,
            ),

            // Storefront Footer
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUserMenu(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final displayName = profileAsync.value?.fullName ?? '';
    final initial =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return PopupMenuButton<String>(
      tooltip: 'Tài khoản',
      offset: const Offset(0, 40),
      onSelected: (value) async {
        if (value == 'admin') {
          context.go(RouteNames.adminDashboardPath);
        } else if (value == 'orders') {
          context.goNamed(RouteNames.orders);
        } else if (value == 'profile') {
          context.goNamed(RouteNames.profile);
        } else if (value == 'logout') {
          if (context.mounted) context.go(RouteNames.homePath);
          try {
            await ref.read(authRepositoryProvider).signOut();
            ref.invalidate(userProfileProvider);
            ref.invalidate(cartNotifierProvider);
            ref.invalidate(selectedCartItemIdsProvider);
          } catch (_) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Đăng xuất không thành công.')),
              );
            }
          }
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          enabled: false,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  displayName.isNotEmpty ? displayName : 'Tài khoản',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isAdmin)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'ADMIN',
                    style: TextStyle(
                      color: AppColors.onPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        if (isAdmin) ...[
          const PopupMenuItem(
            value: 'admin',
            child: Row(
              children: [
                Icon(Icons.dashboard_outlined, size: 18, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Trang quản trị (Admin)',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const PopupMenuDivider(),
        ],
        const PopupMenuItem(
          value: 'orders',
          child: Row(
            children: [
              Icon(Icons.receipt_long_outlined, size: 18),
              SizedBox(width: 8),
              Text('Đơn hàng của tôi'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person_outline, size: 18),
              SizedBox(width: 8),
              Text('Hồ sơ cá nhân'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 18, color: AppColors.error),
              SizedBox(width: 8),
              Text('Đăng xuất',
                  style: TextStyle(color: AppColors.error)),
            ],
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space8),
        child: CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.primary,
          child: Text(
            initial,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavLink(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
    required bool isActive,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radius8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space12,
            vertical: AppDimensions.space8,
          ),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.radius8),
          ),
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive ? AppColors.onPrimary : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.space48,
        horizontal: AppDimensions.space24,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppDimensions.maxContentWidth,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
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
                        const SizedBox(height: AppDimensions.space12),
                        Text(
                          'Thương hiệu thời trang nam tối giản, hiện đại và tinh tế. Mua sắm tiện lợi với thanh toán khi nhận hàng (COD).',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space32),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chính sách',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.onPrimary,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.space12),
                        _buildFooterLink(
                          context,
                          'Chính sách giao hàng',
                          () => context.goNamed(RouteNames.shippingPolicy),
                        ),
                        _buildFooterLink(
                          context,
                          'Chính sách đổi trả',
                          () => context.goNamed(RouteNames.returnPolicy),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hỗ trợ',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.onPrimary,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.space12),
                        _buildFooterLink(
                          context,
                          'Đơn hàng của tôi',
                          () => context.goNamed(RouteNames.orders),
                        ),
                        _buildFooterLink(
                          context,
                          'Liên hệ chúng tôi',
                          () => context.goNamed(RouteNames.contact),
                        ),
                        Text(
                          'Hotline: 1900 xxxx\nEmail: contact@moven.vn',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textMuted,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space32),
              const Divider(color: Color(0xFF374151)),
              const SizedBox(height: AppDimensions.space16),
              Center(
                child: Text(
                  '© 2026 MOVEN. All rights reserved. Thanh toán COD toàn quốc.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterLink(
    BuildContext context,
    String label,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.space8),
      child: InkWell(
        onTap: onTap,
        child: Text(
          label,
          style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
        ),
      ),
    );
  }
}
