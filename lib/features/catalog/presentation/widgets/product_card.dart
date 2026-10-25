import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/storage_repository.dart';
import '../../domain/models/product.dart';

/// Thẻ hiển thị sản phẩm trên danh mục và trang chủ (Storefront Product Card)
class ProductCard extends ConsumerWidget {
  final Product product;

  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storageRepo = ref.watch(storageRepositoryProvider);
    final primaryImg = product.primaryImage;
    final imageUrl = primaryImg != null
        ? storageRepo.getProductImageUrl(primaryImg.imagePath)
        : '';

    final minPrice = product.minPrice;
    final maxPrice = product.maxPrice;
    final comparePrice = product.minCompareAtPrice;
    final hasDiscount = comparePrice != null &&
        minPrice != null &&
        comparePrice > minPrice;

    int discountPercent = 0;
    if (hasDiscount && comparePrice > 0) {
      discountPercent =
          (((comparePrice - minPrice) / comparePrice) * 100).round();
    }

    return InkWell(
      onTap: () {
        context.go('/product/${product.slug}');
      },
      borderRadius: BorderRadius.circular(AppDimensions.radius8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radius8),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vùng ảnh sản phẩm và badges
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: AppColors.surfaceVariant,
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const _ImagePlaceholder(),
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                          )
                        : const _ImagePlaceholder(),
                  ),

                  // Huy hiệu nổi bật hoặc giảm giá (Góc trên trái)
                  Positioned(
                    top: AppDimensions.space8,
                    left: AppDimensions.space8,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (product.isFeatured)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.space8,
                              vertical: AppDimensions.space4,
                            ),
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.radius4),
                            ),
                            child: const Text(
                              'HOT',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onPrimary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        if (hasDiscount)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.space8,
                              vertical: AppDimensions.space4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.radius4),
                            ),
                            child: Text(
                              '-$discountPercent%',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onError,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Huy hiệu hết hàng (nếu không còn tồn khả dụng)
                  if (!product.inStock)
                    Container(
                      color: Colors.black.withValues(alpha: 0.45),
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.space12,
                          vertical: AppDimensions.space6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radius4),
                        ),
                        child: Text(
                          'HẾT HÀNG',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Thông tin chi tiết sản phẩm
            Padding(
              padding: const EdgeInsets.all(AppDimensions.space12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên danh mục (nếu có)
                  if (product.category != null)
                    Text(
                      product.category!.name.toUpperCase(),
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 11,
                        letterSpacing: 0.8,
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: AppDimensions.space4),

                  // Tên sản phẩm
                  Text(
                    product.name,
                    style: AppTypography.titleMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: AppDimensions.space8),

                  // Giá hiển thị tính động từ các biến thể
                  if (minPrice != null) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          minPrice == maxPrice
                              ? CurrencyFormatter.format(minPrice)
                              : CurrencyFormatter.formatRange(
                                  minPrice, maxPrice ?? minPrice),
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        if (hasDiscount) ...[
                          const SizedBox(width: AppDimensions.space6),
                          Text(
                            CurrencyFormatter.format(comparePrice),
                            style: AppTypography.bodySmall.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ] else ...[
                    Text(
                      'Đang cập nhật giá',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.checkroom_outlined,
            size: 36,
            color: AppColors.textMuted,
          ),
          SizedBox(height: 4),
          Text(
            'MOVEN',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
