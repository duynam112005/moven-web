import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/router/route_names.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../core/network/supabase_client.dart';
import '../../cart/data/cart_providers.dart';
import '../../catalog/data/catalog_providers.dart';
import '../../catalog/data/storage_repository.dart';
import '../../catalog/domain/models/product.dart';
import '../../catalog/domain/models/product_image.dart';
import '../../catalog/domain/models/product_variant.dart';
import '../../reviews/presentation/providers/reviews_providers.dart';
import '../../reviews/presentation/widgets/product_reviews_section.dart';
import '../../reviews/presentation/widgets/rating_stars.dart';

/// Màn hình chi tiết sản phẩm dành cho khách hàng (Storefront Product Detail)
class ProductDetailScreen extends ConsumerStatefulWidget {
  final String slug;

  const ProductDetailScreen({
    super.key,
    required this.slug,
  });

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  ProductVariant? _selectedVariant;
  ProductImage? _selectedImage;
  int _quantity = 1;
  bool _isInitialized = false;

  void _initializeSelection(Product product) {
    if (_isInitialized) return;
    final active = product.activeVariants;
    if (active.isNotEmpty) {
      // Ưu tiên chọn biến thể còn hàng đầu tiên
      _selectedVariant = active.firstWhere(
        (v) => v.inStock,
        orElse: () => active.first,
      );
    }
    _selectedImage = product.imageForVariant(_selectedVariant?.id);
    _isInitialized = true;
  }

  void _onVariantSelected(Product product, ProductVariant variant) {
    setState(() {
      _selectedVariant = variant;
      _quantity = 1;

      // Tự động chuyển ảnh nếu biến thể có ảnh riêng
      final variantImg = product.imageForVariant(variant.id);
      if (variantImg != null) {
        _selectedImage = variantImg;
      }
    });
  }

  void _onImageSelected(ProductImage image) {
    setState(() {
      _selectedImage = image;
    });
  }

  void _incrementQuantity(int maxStock) {
    if (_quantity < maxStock) {
      setState(() => _quantity++);
    }
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() => _quantity--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.slug));
    final storageRepo = ref.watch(storageRepositoryProvider);
    final isDesktop = context.isDesktop;

    return productAsync.when(
      loading: () => const SizedBox(
        height: 500,
        child: AppLoading(message: 'Đang tải thông tin sản phẩm...'),
      ),
      error: (error, stack) => SizedBox(
        height: 500,
        child: ErrorStateView(
          title: 'Không thể tải sản phẩm',
          message: error.toString(),
          onRetry: () => ref.refresh(productDetailProvider(widget.slug)),
        ),
      ),
      data: (product) {
        if (product == null) {
          return SizedBox(
            height: 500,
            child: EmptyStateView(
              icon: Icons.search_off_outlined,
              title: 'Không tìm thấy sản phẩm',
              description:
                  'Sản phẩm bạn đang tìm kiếm có thể đã ngừng kinh doanh hoặc đường dẫn không đúng.',
              actionLabel: 'Xem tất cả sản phẩm',
              onAction: () => context.goNamed(RouteNames.catalog),
            ),
          );
        }

        _initializeSelection(product);

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
                  // Breadcrumbs
                  _buildBreadcrumbs(context, product),

                  const SizedBox(height: AppDimensions.space24),

                  // Nội dung chi tiết (2 cột trên Desktop, 1 cột trên Mobile)
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cột trái: Bộ sưu tập ảnh
                        Expanded(
                          flex: 6,
                          child: _buildGallery(product, storageRepo),
                        ),
                        const SizedBox(width: AppDimensions.space48),
                        // Cột phải: Thông tin sản phẩm & Mua hàng
                        Expanded(
                          flex: 5,
                          child: _buildProductInfo(product),
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGallery(product, storageRepo),
                        const SizedBox(height: AppDimensions.space24),
                        _buildProductInfo(product),
                      ],
                    ),

                  const SizedBox(height: AppDimensions.space48),

                  // Khối Đánh giá & Nhận xét sản phẩm (Phase 7)
                  ProductReviewsSection(
                    productId: product.id,
                    productName: product.name,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBreadcrumbs(BuildContext context, Product product) {
    return Row(
      children: [
        InkWell(
          onTap: () => context.goNamed(RouteNames.home),
          child: Text(
            'Trang chủ',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.space8),
          child: Text('/', style: TextStyle(color: AppColors.textMuted)),
        ),
        InkWell(
          onTap: () => context.goNamed(RouteNames.catalog),
          child: Text(
            'Sản phẩm',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
          ),
        ),
        if (product.category != null) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDimensions.space8),
            child: Text('/', style: TextStyle(color: AppColors.textMuted)),
          ),
          Text(
            product.category!.name,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
          ),
        ],
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.space8),
          child: Text('/', style: TextStyle(color: AppColors.textMuted)),
        ),
        Expanded(
          child: Text(
            product.name,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildGallery(Product product, StorageRepository storageRepo) {
    final images = product.images;
    final currentImage = _selectedImage ?? product.primaryImage;
    final mainImageUrl = currentImage != null
        ? storageRepo.getProductImageUrl(currentImage.imagePath)
        : '';

    return Column(
      children: [
        // Ảnh lớn chính
        Container(
          width: double.infinity,
          height: 480,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppDimensions.radius12),
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: mainImageUrl.isNotEmpty
              ? Image.network(
                  mainImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const _DetailPlaceholder(),
                )
              : const _DetailPlaceholder(),
        ),

        // Hàng ảnh thumbnails thu nhỏ (nếu có nhiều ảnh)
        if (images.length > 1) ...[
          const SizedBox(height: AppDimensions.space12),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: AppDimensions.space12),
              itemBuilder: (context, index) {
                final img = images[index];
                final isSelected = currentImage?.id == img.id;
                final thumbUrl =
                    storageRepo.getProductImageUrl(img.imagePath);

                return InkWell(
                  onTap: () => _onImageSelected(img),
                  borderRadius: BorderRadius.circular(AppDimensions.radius8),
                  child: Container(
                    width: 70,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radius8),
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primary : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: thumbUrl.isNotEmpty
                        ? Image.network(thumbUrl, fit: BoxFit.cover)
                        : const Icon(Icons.image, color: AppColors.textMuted),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProductInfo(Product product) {
    final activeVariants = product.activeVariants;
    final selected = _selectedVariant;

    // Tính giá hiển thị dựa trên biến thể được chọn
    final int displayPrice = selected?.price ?? product.minPrice ?? 0;
    final int? comparePrice =
        selected?.compareAtPrice ?? product.minCompareAtPrice;
    final bool hasDiscount =
        comparePrice != null && comparePrice > displayPrice;
    final int discountPercent = hasDiscount && comparePrice > 0
        ? (((comparePrice - displayPrice) / comparePrice) * 100).round()
        : 0;

    final inStock = selected?.inStock ?? product.inStock;
    final maxStock = selected?.stockQuantity ?? 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thẻ phân loại và danh mục
        Row(
          children: [
            if (product.category != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space12,
                  vertical: AppDimensions.space4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppDimensions.radius4),
                ),
                child: Text(
                  product.category!.name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            const SizedBox(width: AppDimensions.space8),
            Text(
              'Dành cho: ${_formatAudience(product.targetAudience)}',
              style: AppTypography.bodySmall,
            ),
          ],
        ),

        const SizedBox(height: AppDimensions.space12),

        // Tên sản phẩm
        Text(
          product.name,
          style: AppTypography.displayMedium.copyWith(fontSize: 26),
        ),

        // Rating quick info (Phase 7)
        Consumer(
          builder: (context, ref, _) {
            final summaryAsync =
                ref.watch(productRatingSummaryProvider(product.id));
            final summary = summaryAsync.valueOrNull;
            if (summary == null || summary.totalReviews == 0) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: AppDimensions.space6),
              child: Row(
                children: [
                  RatingStars.small(rating: summary.averageRating),
                  const SizedBox(width: AppDimensions.space6),
                  Text(
                    summary.averageRating.toStringAsFixed(1),
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space4),
                  Text(
                    '(${summary.totalReviews} đánh giá)',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: AppDimensions.space16),

        // Giá bán VND (Nguồn giá duy nhất từ ProductVariant)
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              CurrencyFormatter.format(displayPrice),
              style: AppTypography.displayLarge.copyWith(
                fontSize: 28,
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (hasDiscount) ...[
              const SizedBox(width: AppDimensions.space12),
              Text(
                CurrencyFormatter.format(comparePrice),
                style: AppTypography.titleLarge.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(width: AppDimensions.space8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space8,
                  vertical: AppDimensions.space2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(AppDimensions.radius4),
                ),
                child: Text(
                  '-$discountPercent%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onError,
                  ),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: AppDimensions.space8),

        // Tình trạng kho hàng
        Row(
          children: [
            Icon(
              inStock ? Icons.check_circle_outline : Icons.cancel_outlined,
              size: 16,
              color: inStock ? AppColors.success : AppColors.error,
            ),
            const SizedBox(width: AppDimensions.space6),
            Text(
              inStock
                  ? (selected != null
                      ? 'Còn ${selected.stockQuantity} sản phẩm trong kho'
                      : 'Còn hàng')
                  : 'Hết hàng',
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: inStock ? AppColors.success : AppColors.error,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppDimensions.space24),
        const Divider(color: AppColors.border),
        const SizedBox(height: AppDimensions.space16),

        // Bộ chọn biến thể (Variants Selector)
        if (activeVariants.isNotEmpty) ...[
          const Text(
            'Chọn kích thước & màu sắc:',
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: AppDimensions.space12),
          Wrap(
            spacing: AppDimensions.space8,
            runSpacing: AppDimensions.space8,
            children: activeVariants.map((variant) {
              final isSelected = selected?.id == variant.id;
              final isVariantInStock = variant.inStock;

              return InkWell(
                onTap: isVariantInStock
                    ? () => _onVariantSelected(product, variant)
                    : null,
                borderRadius: BorderRadius.circular(AppDimensions.radius8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space16,
                    vertical: AppDimensions.space12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : (isVariantInStock
                            ? AppColors.surface
                            : AppColors.surfaceVariant),
                    borderRadius: BorderRadius.circular(AppDimensions.radius8),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : (isVariantInStock
                              ? AppColors.border
                              : AppColors.border),
                    ),
                  ),
                  child: Text(
                    variant.displayLabel +
                        (!isVariantInStock ? ' (Hết)' : ''),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.onPrimary
                          : (isVariantInStock
                              ? AppColors.textPrimary
                              : AppColors.textMuted),
                      decoration: isVariantInStock
                          ? TextDecoration.none
                          : TextDecoration.lineThrough,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppDimensions.space24),
        ],

        // Bộ chọn số lượng
        Row(
          children: [
            const Text('Số lượng:', style: AppTypography.titleMedium),
            const SizedBox(width: AppDimensions.space16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppDimensions.radius8),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 16),
                    onPressed: inStock && _quantity > 1
                        ? _decrementQuantity
                        : null,
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '$_quantity',
                      textAlign: TextAlign.center,
                      style: AppTypography.titleMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 16),
                    onPressed: inStock && _quantity < maxStock
                        ? () => _incrementQuantity(maxStock)
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: AppDimensions.space24),

        // Nút thêm vào giỏ hàng
        AppButton(
          label: inStock ? 'Thêm vào giỏ hàng' : 'Tạm hết hàng',
          icon: const Icon(Icons.shopping_bag_outlined, size: 20),
          isFullWidth: true,
          height: AppDimensions.buttonHeightLg,
          onPressed: (inStock && selected != null)
              ? () async {
                  final isAuth = ref.read(isAuthenticatedProvider);
                  if (!isAuth) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Vui lòng đăng nhập để thêm sản phẩm vào giỏ hàng.',
                        ),
                        action: SnackBarAction(
                          label: 'Đăng nhập',
                          textColor: AppColors.onPrimary,
                          onPressed: () =>
                              context.push(RouteNames.loginPath),
                        ),
                      ),
                    );
                    return;
                  }

                  try {
                    await ref
                        .read(cartNotifierProvider.notifier)
                        .addToCart(
                          variantId: selected.id,
                          quantity: _quantity,
                        );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.primary,
                          content: Text(
                            'Đã thêm "${product.name} (${selected.displayLabel})" x $_quantity vào giỏ hàng!',
                          ),
                          action: SnackBarAction(
                            label: 'Xem giỏ hàng',
                            textColor: AppColors.onPrimary,
                            onPressed: () =>
                                context.push(RouteNames.cartPath),
                          ),
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.error,
                          content: Text('Lỗi: $e'),
                        ),
                      );
                    }
                  }
                }
              : null,
        ),

        const SizedBox(height: AppDimensions.space24),

        // Thông tin bảo đảm / giá trị gia tăng
        Container(
          padding: const EdgeInsets.all(AppDimensions.space16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radius8),
            border: Border.all(color: AppColors.border),
          ),
          child: const Column(
            children: [
              _FeatureRow(
                icon: Icons.local_shipping_outlined,
                title: 'Thanh toán COD toàn quốc',
                subtitle: 'Kiểm tra hàng trước khi thanh toán tận nơi',
              ),
              SizedBox(height: AppDimensions.space12),
              _FeatureRow(
                icon: Icons.published_with_changes_outlined,
                title: 'Hỗ trợ đổi size',
                subtitle: 'Đổi hàng nhanh chóng khi liên hệ cửa hàng',
              ),
            ],
          ),
        ),

        const SizedBox(height: AppDimensions.space24),

        // Thông tin mô tả & chất liệu
        if (product.description != null &&
            product.description!.isNotEmpty) ...[
          const Text('Mô tả sản phẩm', style: AppTypography.titleLarge),
          const SizedBox(height: AppDimensions.space8),
          Text(
            product.description!,
            style: AppTypography.bodyMedium.copyWith(height: 1.6),
          ),
          const SizedBox(height: AppDimensions.space16),
        ],

        if (product.material != null && product.material!.isNotEmpty) ...[
          const Text('Chất liệu & bảo quản', style: AppTypography.titleLarge),
          const SizedBox(height: AppDimensions.space8),
          Text(
            product.material!,
            style: AppTypography.bodyMedium.copyWith(height: 1.6),
          ),
          const SizedBox(height: AppDimensions.space16),
        ],

        if (selected != null)
          Text(
            'Mã SKU: ${selected.sku}',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
          ),
      ],
    );
  }

  String _formatAudience(String audience) {
    switch (audience) {
      case 'men':
        return 'Nam';
      case 'women':
        return 'Nữ';
      default:
        return 'Unisex';
    }
  }
}

class _DetailPlaceholder extends StatelessWidget {
  const _DetailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.checkroom_outlined,
              size: 64, color: AppColors.textMuted),
          SizedBox(height: 8),
          Text(
            'MOVEN CLOTHING',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 24, color: AppColors.primary),
        const SizedBox(width: AppDimensions.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: AppTypography.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
