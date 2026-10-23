import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/responsive_layout.dart';

/// Khung giao diện chuẩn dành cho Khách hàng (Customer Storefront Shell)
/// Bao gồm Header (Logo, Điều hướng, Giỏ hàng, Tài khoản), nội dung chính và Footer.
class StorefrontShell extends ConsumerWidget {
  final Widget child;

  const StorefrontShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final isDesktop = context.isDesktop;

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
                        borderRadius: BorderRadius.circular(AppDimensions.radius4),
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
                          onTap: () => context.goNamed(RouteNames.home),
                        ),
                        _buildNavLink(
                          context,
                          label: 'Sản phẩm',
                          onTap: () => context.goNamed(RouteNames.catalog),
                        ),
                        _buildNavLink(
                          context,
                          label: 'Chính sách giao hàng',
                          onTap: () => context.goNamed(RouteNames.shippingPolicy),
                        ),
                        _buildNavLink(
                          context,
                          label: 'Liên hệ',
                          onTap: () => context.goNamed(RouteNames.contact),
                        ),
                      ],

                      const Spacer(),

                      // Cart Icon
                      IconButton(
                        tooltip: 'Giỏ hàng',
                        icon: const Badge(
                          label: Text('0'),
                          child: Icon(Icons.shopping_bag_outlined, size: 22),
                        ),
                        onPressed: () => context.goNamed(RouteNames.cart),
                      ),

                      const SizedBox(width: AppDimensions.space8),

                      // Auth / Profile Button
                      if (isAuthenticated)
                        IconButton(
                          tooltip: 'Tài khoản',
                          icon: const Icon(Icons.person_outline, size: 22),
                          onPressed: () => context.goNamed(RouteNames.profile),
                        )
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
              constraints: const BoxConstraints(
                minHeight: 500,
              ),
              child: child,
            ),

            // Storefront Footer
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildNavLink(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radius4),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space8,
            vertical: AppDimensions.space4,
          ),
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
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
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
