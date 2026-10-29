import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/router/route_names.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../catalog/data/catalog_providers.dart';
import '../../catalog/domain/models/catalog_filter.dart';
import '../../catalog/presentation/widgets/product_card.dart';
import 'widgets/banner_carousel.dart';

/// Màn hình Trang chủ (Storefront Home Screen)
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppDimensions.maxContentWidth,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space20,
            vertical: AppDimensions.space24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Carousel động từ Supabase (fallback hero banner nếu rỗng)
              const BannerCarousel(),

              const SizedBox(height: AppDimensions.space48),

              // Giá trị thương hiệu (COD, Đổi trả, Chất lượng)
              _buildValueProps(),

              const SizedBox(height: AppDimensions.space48),

              // Danh mục nổi bật (nạp từ DB)
              _buildCategorySection(context, ref),

              const SizedBox(height: AppDimensions.space48),

              // Sản phẩm nổi bật (nạp từ DB)
              _buildFeaturedProductsSection(context, ref),
            ],
          ),
        ),
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
              subtitle: 'Kiểm tra hàng trước khi thanh toán',
            ),
          ),
          SizedBox(width: AppDimensions.space16),
          Expanded(
            child: _ValuePropItem(
              icon: Icons.verified_outlined,
              title: 'Cam kết chất lượng',
              subtitle: 'Chất liệu thoáng mát, bền đẹp',
            ),
          ),
          SizedBox(width: AppDimensions.space16),
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

  Widget _buildCategorySection(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(activeCategoriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Danh mục sản phẩm', style: AppTypography.headlineLarge),
            TextButton(
              onPressed: () {
                ref.read(catalogFilterProvider.notifier).state =
                    const CatalogFilter();
                context.goNamed(RouteNames.catalog);
              },
              child: const Text('Xem tất cả →'),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.space16),
        categoriesAsync.when(
          loading: () => const SizedBox(
            height: 100,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          error: (error, stack) => _buildFallbackCategoryList(context, ref),
          data: (categories) {
            if (categories.isEmpty) {
              return _buildFallbackCategoryList(context, ref);
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 600;
                final displayCategories = categories.take(4).toList();

                if (isNarrow) {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppDimensions.space12,
                      mainAxisSpacing: AppDimensions.space12,
                      childAspectRatio: 1.4,
                    ),
                    itemCount: displayCategories.length,
                    itemBuilder: (context, index) {
                      final cat = displayCategories[index];
                      return _buildCategoryCard(
                        context,
                        ref,
                        name: cat.name,
                        categoryId: cat.id,
                        icon: Icons.checkroom_outlined,
                      );
                    },
                  );
                }

                return Row(
                  children: displayCategories.map((cat) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.space6,
                        ),
                        child: _buildCategoryCard(
                          context,
                          ref,
                          name: cat.name,
                          categoryId: cat.id,
                          icon: Icons.checkroom_outlined,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    WidgetRef ref, {
    required String name,
    String? categoryId,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () {
        ref.read(catalogFilterProvider.notifier).state =
            CatalogFilter(categoryId: categoryId);
        ref.read(catalogPageProvider.notifier).state = 1;
        context.goNamed(RouteNames.catalog);
      },
      borderRadius: BorderRadius.circular(AppDimensions.radius8),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.space20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radius8),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppDimensions.space12),
            Text(
              name,
              style: AppTypography.titleMedium.copyWith(fontSize: 14),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackCategoryList(BuildContext context, WidgetRef ref) {
    final defaultCategories = [
      {'name': 'Áo Thun & Polo', 'icon': Icons.checkroom},
      {'name': 'Quần Short', 'icon': Icons.dry_cleaning},
      {'name': 'Áo Sơ Mi', 'icon': Icons.style_outlined},
      {'name': 'Quần Dài & Kaki', 'icon': Icons.layers_outlined},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        if (isNarrow) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppDimensions.space12,
              mainAxisSpacing: AppDimensions.space12,
              childAspectRatio: 1.4,
            ),
            itemCount: defaultCategories.length,
            itemBuilder: (context, index) {
              final cat = defaultCategories[index];
              return _buildCategoryCard(
                context,
                ref,
                name: cat['name'] as String,
                icon: cat['icon'] as IconData,
              );
            },
          );
        }

        return Row(
          children: defaultCategories.map((cat) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space6,
                ),
                child: _buildCategoryCard(
                  context,
                  ref,
                  name: cat['name'] as String,
                  icon: cat['icon'] as IconData,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildFeaturedProductsSection(BuildContext context, WidgetRef ref) {
    final featuredAsync = ref.watch(featuredProductsProvider);
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;

    int crossAxisCount = 4;
    if (!isDesktop) {
      crossAxisCount = isTablet ? 3 : 2;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sản phẩm nổi bật', style: AppTypography.headlineLarge),
                  SizedBox(height: AppDimensions.space8),
                  Text(
                    'Những mẫu trang phục được yêu thích nhất tại MOVEN',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.space16),
            TextButton(
              onPressed: () {
                ref.read(catalogFilterProvider.notifier).state =
                    const CatalogFilter(isFeaturedOnly: true);
                context.goNamed(RouteNames.catalog);
              },
              child: const Text('Xem tất cả →'),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.space24),
        featuredAsync.when(
          loading: () => const SizedBox(
            height: 300,
            child: AppLoading(message: 'Đang tải sản phẩm nổi bật...'),
          ),
          error: (error, stack) => ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 240),
            child: ErrorStateView(
              title: 'Không thể tải sản phẩm nổi bật',
              message: error.toString(),
              onRetry: () => ref.refresh(featuredProductsProvider),
            ),
          ),
          data: (products) {
            if (products.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.space32),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radius8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.checkroom_outlined,
                        size: 48,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(height: AppDimensions.space12),
                      const Text(
                        'Bộ sưu tập mới đang được chuẩn bị',
                        style: AppTypography.titleMedium,
                      ),
                      const SizedBox(height: AppDimensions.space8),
                      const Text(
                        'Các sản phẩm nổi bật sẽ được cập nhật sớm nhất tại đây.',
                        style: AppTypography.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.space20),
                      AppButton(
                        label: 'Xem tất cả sản phẩm',
                        variant: AppButtonVariant.outlined,
                        onPressed: () => context.goNamed(RouteNames.catalog),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: AppDimensions.space16,
                    mainAxisSpacing: AppDimensions.space20,
                    childAspectRatio: isDesktop ? 0.60 : 0.58,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return ProductCard(product: products[index]);
                  },
                ),
                const SizedBox(height: AppDimensions.space32),
                Center(
                  child: AppButton(
                    label: 'Xem toàn bộ sản phẩm',
                    variant: AppButtonVariant.outlined,
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    onPressed: () => context.goNamed(RouteNames.catalog),
                  ),
                ),
              ],
            );
          },
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
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.space12),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppDimensions.radius8),
          ),
          child: Icon(icon, size: 28, color: AppColors.primary),
        ),
        const SizedBox(height: AppDimensions.space12),
        Text(
          title,
          style: AppTypography.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.space4),
        Text(
          subtitle,
          style: AppTypography.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
