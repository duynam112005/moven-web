import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/network/supabase_client.dart';
import '../../../core/router/route_names.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_state_view.dart';
import '../data/cart_providers.dart';
import '../domain/models/cart_item_model.dart';

/// Màn hình giỏ hàng của khách hàng (Storefront Cart Screen)
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    // Nếu chưa đăng nhập, hiển thị yêu cầu đăng nhập để xem giỏ
    if (!isAuthenticated) {
      return Material(
        color: AppColors.background,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.space64),
            child: EmptyStateView(
              icon: Icons.lock_outline,
              title: 'Vui lòng đăng nhập',
              description: 'Đăng nhập tài khoản để xem và quản lý giỏ hàng của bạn.',
              actionLabel: 'Đăng nhập ngay',
              onAction: () => context.push(RouteNames.loginPath),
            ),
          ),
        ),
      );
    }

    final cartAsync = ref.watch(cartNotifierProvider);

    return Material(
      color: AppColors.background,
      child: cartAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: AppDimensions.space64),
          child: Center(child: AppLoading()),
        ),
        error: (err, _) => Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.space64),
          child: Center(
            child: ErrorStateView(
              message: err.toString(),
              onRetry: () => ref.read(cartNotifierProvider.notifier).loadCart(),
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.space64),
                child: EmptyStateView(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Giỏ hàng của bạn đang trống',
                  description: 'Hãy chọn những trang phục yêu thích để thêm vào giỏ.',
                  actionLabel: 'Mua sắm ngay',
                  onAction: () => context.go(RouteNames.catalogPath),
                ),
              ),
            );
          }

          final selectedSubtotal = ref.watch(selectedCartSubtotalProvider);
          final selectedCount = ref.watch(selectedCartItemCountProvider);
          final estimatedShippingFee = selectedCount > 0 ? 20000 : 0;
          final total = selectedSubtotal + estimatedShippingFee;
          final hasOutOfStockInCart = items.any((item) => !item.inStock);

          return ResponsiveLayout(
            mobile: _buildMobileLayout(
              context,
              ref,
              items,
              selectedSubtotal,
              estimatedShippingFee,
              total,
              selectedCount,
              hasOutOfStockInCart,
            ),
            desktop: _buildDesktopLayout(
              context,
              ref,
              items,
              selectedSubtotal,
              estimatedShippingFee,
              total,
              selectedCount,
              hasOutOfStockInCart,
            ),
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    WidgetRef ref,
    List<CartItemModel> items,
    int subtotal,
    int shippingFee,
    int total,
    int selectedCount,
    bool hasOutOfStockInCart,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space32,
        vertical: AppDimensions.space32,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Giỏ hàng của bạn (${items.length} mặt hàng)',
                style: AppTypography.headlineMedium,
              ),
              const SizedBox(height: AppDimensions.space24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Danh sách sản phẩm (Bên trái)
                  Expanded(
                    flex: 3,
                    child: _buildItemList(context, ref, items),
                  ),
                  const SizedBox(width: AppDimensions.space32),
                  // Tóm tắt đơn hàng (Bên phải)
                  Expanded(
                    flex: 2,
                    child: _buildSummaryCard(
                      context,
                      subtotal,
                      shippingFee,
                      total,
                      selectedCount,
                      hasOutOfStockInCart,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    WidgetRef ref,
    List<CartItemModel> items,
    int subtotal,
    int shippingFee,
    int total,
    int selectedCount,
    bool hasOutOfStockInCart,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Giỏ hàng (${items.length})',
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: AppDimensions.space16),
          _buildItemList(context, ref, items),
          const SizedBox(height: AppDimensions.space24),
          _buildSummaryCard(
            context,
            subtotal,
            shippingFee,
            total,
            selectedCount,
            hasOutOfStockInCart,
          ),
        ],
      ),
    );
  }

  Widget _buildItemList(
    BuildContext context,
    WidgetRef ref,
    List<CartItemModel> items,
  ) {
    final isAllSelected = ref.watch(isAllCartItemsSelectedProvider);
    final inStockCount = items.where((i) => i.inStock).length;
    final selectedCount = ref.watch(selectedCartItemCountProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSelectionHeaderBar(
          context,
          ref,
          items,
          isAllSelected,
          inStockCount,
          selectedCount,
        ),
        const SizedBox(height: AppDimensions.space16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, _) => const Divider(height: AppDimensions.space24),
          itemBuilder: (context, index) {
            final item = items[index];
            return _CartItemTile(item: item);
          },
        ),
      ],
    );
  }

  Widget _buildSelectionHeaderBar(
    BuildContext context,
    WidgetRef ref,
    List<CartItemModel> items,
    bool isAllSelected,
    int inStockCount,
    int selectedCount,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space16,
        vertical: AppDimensions.space12,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Checkbox(
            value: isAllSelected,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: inStockCount == 0
                ? null
                : (bool? val) {
                    if (isAllSelected) {
                      ref
                          .read(selectedCartItemIdsProvider.notifier)
                          .deselectAll();
                    } else {
                      ref
                          .read(selectedCartItemIdsProvider.notifier)
                          .selectAll(items);
                    }
                  },
          ),
          const SizedBox(width: AppDimensions.space8),
          Flexible(
            child: InkWell(
              onTap: inStockCount == 0
                  ? null
                  : () {
                      if (isAllSelected) {
                        ref
                            .read(selectedCartItemIdsProvider.notifier)
                            .deselectAll();
                      } else {
                        ref
                            .read(selectedCartItemIdsProvider.notifier)
                            .selectAll(items);
                      }
                    },
              child: Text(
                'Chọn tất cả ($inStockCount)',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: inStockCount == 0
                      ? AppColors.textMuted
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.space8),
          if (selectedCount > 0) ...[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textMuted,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space8),
              ),
              onPressed: () =>
                  ref.read(selectedCartItemIdsProvider.notifier).deselectAll(),
              child: const Text('Bỏ chọn tất cả'),
            ),
            const SizedBox(width: AppDimensions.space8),
          ],
          Text(
            'Đã chọn: $selectedCount',
            style: AppTypography.bodySmall.copyWith(
              color: selectedCount > 0
                  ? AppColors.primary
                  : AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    int subtotal,
    int shippingFee,
    int total,
    int selectedCount,
    bool hasOutOfStockInCart,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tóm tắt đơn hàng',
            style: AppTypography.titleLarge,
          ),
          const SizedBox(height: AppDimensions.space16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tạm tính ($selectedCount sản phẩm):',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(width: AppDimensions.space8),
              Flexible(
                child: Text(
                  CurrencyFormatter.format(subtotal),
                  style: AppTypography.titleMedium,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text('Phí giao hàng (COD):', style: AppTypography.bodyMedium),
              ),
              const SizedBox(width: AppDimensions.space8),
              Flexible(
                child: Text(
                  CurrencyFormatter.format(shippingFee),
                  style: AppTypography.bodyMedium,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const Divider(height: AppDimensions.space32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text('Tổng thanh toán:', style: AppTypography.titleMedium),
              ),
              const SizedBox(width: AppDimensions.space8),
              Flexible(
                child: Text(
                  CurrencyFormatter.format(total),
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space8),
          const Text(
            'Đơn hàng áp dụng hình thức thanh toán khi nhận hàng (COD).',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppDimensions.space24),
          if (hasOutOfStockInCart) ...[
            Container(
              padding: const EdgeInsets.all(AppDimensions.space12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppDimensions.radius8),
                border:
                    Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.error, size: 20),
                  SizedBox(width: AppDimensions.space8),
                  Expanded(
                    child: Text(
                      'Có sản phẩm trong giỏ đã hết hàng hoặc không đủ tồn kho nên không thể tick chọn.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space16),
          ],
          if (selectedCount == 0) ...[
            Container(
              padding: const EdgeInsets.all(AppDimensions.space12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppDimensions.radius8),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_box_outlined,
                      color: AppColors.textMuted, size: 20),
                  SizedBox(width: AppDimensions.space8),
                  Expanded(
                    child: Text(
                      'Vui lòng tick chọn ít nhất 1 sản phẩm để tiến hành đặt hàng.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space16),
          ],
          AppButton(
            label: selectedCount > 0
                ? 'Tiến hành đặt hàng COD ($selectedCount)'
                : 'Tiến hành đặt hàng COD',
            icon: const Icon(Icons.arrow_forward, size: 18),
            isFullWidth: true,
            height: AppDimensions.buttonHeightLg,
            onPressed: selectedCount == 0
                ? null
                : () => context.push(RouteNames.checkoutPath),
          ),
        ],
      ),
    );
  }
}

/// Widget dòng hiển thị từng mặt hàng trong giỏ
class _CartItemTile extends ConsumerWidget {
  final CartItemModel item;

  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = ref.watch(
      selectedCartItemIdsProvider.select((ids) => ids.contains(item.id)),
    );

    return Container(
      padding: const EdgeInsets.all(AppDimensions.space12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius8),
        border: Border.all(
          color: !item.inStock
              ? AppColors.error.withValues(alpha: 0.5)
              : (isSelected ? AppColors.primary : AppColors.border),
          width: (item.inStock && isSelected) ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox chọn sản phẩm thanh toán
          Padding(
            padding: const EdgeInsets.only(
              top: AppDimensions.space24,
              right: AppDimensions.space8,
            ),
            child: Checkbox(
              value: item.inStock && isSelected,
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onChanged: item.inStock
                  ? (_) => ref
                      .read(selectedCartItemIdsProvider.notifier)
                      .toggle(item.id)
                  : null,
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radius8),
            child: Container(
              width: 80,
              height: 100,
              color: AppColors.surfaceVariant,
              child: item.imageUrl != null
                  ? Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.textMuted,
                      ),
                    )
                  : const Icon(
                      Icons.checkroom_outlined,
                      color: AppColors.textMuted,
                    ),
            ),
          ),
          const SizedBox(width: AppDimensions.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.productName,
                        style: AppTypography.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          size: 20, color: AppColors.textMuted),
                      tooltip: 'Xóa khỏi giỏ',
                      onPressed: () => ref
                          .read(cartNotifierProvider.notifier)
                          .removeItem(item.id),
                    ),
                  ],
                ),
                Text(
                  'Phân loại: ${item.displayVariantLabel}',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                ),
                Text(
                  'Mã SKU: ${item.sku}',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: AppDimensions.space8),
                Row(
                  children: [
                    Text(
                      CurrencyFormatter.format(item.price),
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (item.compareAtPrice != null &&
                        item.compareAtPrice! > item.price) ...[
                      const SizedBox(width: AppDimensions.space8),
                      Text(
                        CurrencyFormatter.format(item.compareAtPrice!),
                        style: AppTypography.bodySmall.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
                if (!item.inStock) ...[
                  const SizedBox(height: AppDimensions.space4),
                  Text(
                    item.stockQuantity <= 0
                        ? 'Tạm hết hàng'
                        : 'Chỉ còn ${item.stockQuantity} sản phẩm trong kho',
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: AppDimensions.space12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radius8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 16),
                            onPressed: item.quantity > 1
                                ? () => ref
                                    .read(cartNotifierProvider.notifier)
                                    .updateQuantity(
                                      itemId: item.id,
                                      quantity: item.quantity - 1,
                                    )
                                : () => ref
                                    .read(cartNotifierProvider.notifier)
                                    .removeItem(item.id),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '${item.quantity}',
                              style: AppTypography.titleMedium,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 16),
                            onPressed: item.quantity < item.stockQuantity
                                ? () => ref
                                    .read(cartNotifierProvider.notifier)
                                    .updateQuantity(
                                      itemId: item.id,
                                      quantity: item.quantity + 1,
                                    )
                                : null,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Thành tiền: ${CurrencyFormatter.format(item.lineTotal)}',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
