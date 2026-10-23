import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/router/route_names.dart';
import '../../../core/widgets/app_button.dart';

/// Trang chủ của website thời trang MOVEN (Storefront Home)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppDimensions.maxContentWidth,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space20,
            vertical: AppDimensions.space32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner Area
              _buildHeroBanner(context),

              const SizedBox(height: AppDimensions.space48),

              // Value Propositions (Giao COD, Đổi trả, Chất lượng)
              _buildValueProps(),

              const SizedBox(height: AppDimensions.space48),

              // Danh mục nổi bật
              _buildCategorySection(context),

              const SizedBox(height: AppDimensions.space48),

              // Sản phẩm mới nhất / Nổi bật
              _buildFeaturedProductsHeader(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space32,
        vertical: AppDimensions.space64,
      ),
      decoration: BoxDecoration(
        color: AppColors.beige,
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space12,
              vertical: AppDimensions.space4,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppDimensions.radius4),
            ),
            child: const Text(
              'BỘ SƯU TẬP MỚI 2026',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppColors.onPrimary,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.space16),
          const Text(
            'Thời trang tối giản,\ntrải nghiệm tối ưu.',
            style: AppTypography.displayLarge,
          ),
          const SizedBox(height: AppDimensions.space16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Text(
              'Thiết kế tinh gọn, chất liệu cao cấp thoáng mát. Đặt hàng dễ dàng và thanh toán trực tiếp khi nhận hàng (COD).',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.space32),
          AppButton(
            label: 'Khám phá bộ sưu tập',
            icon: const Icon(Icons.arrow_forward, size: 18),
            onPressed: () => context.goNamed(RouteNames.catalog),
          ),
        ],
      ),
    );
  }

  Widget _buildValueProps() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius8),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          Expanded(
            child: _ValuePropItem(
              icon: Icons.local_shipping_outlined,
              title: 'Thanh toán COD',
              subtitle: 'Kiểm tra hàng rồi thanh toán tận nơi',
            ),
          ),
          _VerticalDivider(),
          Expanded(
            child: _ValuePropItem(
              icon: Icons.verified_outlined,
              title: 'Chất lượng cam kết',
              subtitle: 'Chất vải cao cấp, đường may tỉ mỉ',
            ),
          ),
          _VerticalDivider(),
          Expanded(
            child: _ValuePropItem(
              icon: Icons.support_agent_outlined,
              title: 'Hỗ trợ chu đáo',
              subtitle: 'Đổi hàng nhanh chóng khi liên hệ cửa hàng',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context) {
    final categories = [
      {'name': 'Áo Thun & Polo', 'icon': Icons.checkroom},
      {'name': 'Quần Short', 'icon': Icons.dry_cleaning},
      {'name': 'Áo Sơ Mi', 'icon': Icons.style_outlined},
      {'name': 'Quần Dài & Kaki', 'icon': Icons.layers_outlined},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Danh mục sản phẩm', style: AppTypography.headlineLarge),
            TextButton(
              onPressed: () => context.goNamed(RouteNames.catalog),
              child: const Text('Xem tất cả →'),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.space16),
        Row(
          children: categories.map((cat) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space6),
                child: InkWell(
                  onTap: () => context.goNamed(RouteNames.catalog),
                  borderRadius: BorderRadius.circular(AppDimensions.radius8),
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.space20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppDimensions.radius8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          cat['icon'] as IconData,
                          size: 36,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: AppDimensions.space12),
                        Text(
                          cat['name'] as String,
                          style: AppTypography.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFeaturedProductsHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sản phẩm nổi bật', style: AppTypography.headlineLarge),
        const SizedBox(height: AppDimensions.space8),
        Text(
          'Những mẫu trang phục được yêu thích nhất tại MOVEN',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppDimensions.space24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.space32),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radius8),
            border: Border.all(color: AppColors.border),
          ),
          child: const Center(
            child: Column(
              children: [
                Icon(
                  Icons.storefront_outlined,
                  size: 48,
                  color: AppColors.textMuted,
                ),
                SizedBox(height: AppDimensions.space12),
                Text(
                  'Catalog đang được nạp từ Supabase',
                  style: AppTypography.titleMedium,
                ),
                SizedBox(height: AppDimensions.space8),
                Text(
                  'Các sản phẩm sẽ hiển thị tại đây khi dữ liệu catalog được kết nối ở Giai đoạn 4.',
                  style: AppTypography.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ValuePropItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ValuePropItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 32, color: AppColors.primary),
        const SizedBox(width: AppDimensions.space16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.titleMedium),
              const SizedBox(height: AppDimensions.space2),
              Text(
                subtitle,
                style: AppTypography.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      color: AppColors.border,
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.space16),
    );
  }
}
