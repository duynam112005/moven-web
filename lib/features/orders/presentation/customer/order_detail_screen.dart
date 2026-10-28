import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:moven/core/constants/app_colors.dart';
import 'package:moven/core/constants/app_dimensions.dart';
import 'package:moven/core/constants/app_typography.dart';
import 'package:moven/core/router/route_names.dart';
import 'package:moven/core/utils/currency_formatter.dart';
import 'package:moven/core/utils/responsive_layout.dart';
import 'package:moven/core/widgets/app_loading.dart';
import 'package:moven/core/widgets/error_state_view.dart';
import 'package:moven/features/orders/domain/models/order.dart';
import 'package:moven/features/orders/domain/models/order_status.dart';
import 'package:moven/features/orders/presentation/providers/orders_providers.dart';
import 'package:moven/features/reviews/presentation/widgets/submit_review_dialog.dart';
import 'widgets/cancel_order_dialog.dart';
import 'widgets/order_status_badge.dart';
import 'widgets/order_timeline_stepper.dart';

/// Màn hình xem chi tiết đơn hàng cho khách hàng (/orders/:code)
class OrderDetailScreen extends ConsumerWidget {
  final String orderCode;

  const OrderDetailScreen({
    super.key,
    required this.orderCode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _OrderDetailView(orderCode: orderCode);
  }
}

class _OrderDetailView extends ConsumerWidget {
  final String orderCode;

  const _OrderDetailView({required this.orderCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderCode));

    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: ResponsiveLayout(
          mobile: _buildBody(context, ref, orderAsync, isMobile: true),
          tablet: _buildBody(context, ref, orderAsync, isMobile: false),
          desktop: _buildBody(context, ref, orderAsync, isMobile: false),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<Order> orderAsync, {
    required bool isMobile,
  }) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppDimensions.space16 : AppDimensions.space32,
        vertical: AppDimensions.space24,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Back button with hover effect
              InkWell(
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(RouteNames.ordersPath);
                  }
                },
                borderRadius: BorderRadius.circular(AppDimensions.radius8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space8,
                    vertical: AppDimensions.space4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_back, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: AppDimensions.space6),
                      Text(
                        'Quay lại danh sách đơn hàng',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.space16),

              // 2. Order Content
              orderAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 64),
                  child: Center(child: AppLoading()),
                ),
                error: (error, _) => ErrorStateView(
                  message: 'Không thể tải thông tin đơn hàng: $error',
                  onRetry: () => ref.invalidate(orderDetailProvider(orderCode)),
                ),
                data: (order) => _buildOrderDetailContent(context, ref, order, isMobile),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetailContent(
    BuildContext context,
    WidgetRef ref,
    Order order,
    bool isMobile,
  ) {
    final dateStr = DateFormat('dd/MM/yyyy - HH:mm').format(order.createdAt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Đơn hàng ${order.orderCode}',
                        style: isMobile
                            ? AppTypography.headlineMedium
                            : AppTypography.displayMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.space4),
                  Text(
                    'Ngày đặt: $dateStr',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            OrderStatusBadge(status: order.status, isLarge: true),
          ],
        ),
        const SizedBox(height: AppDimensions.space24),

        // Stepper Timeline
        OrderTimelineStepper(order: order),
        const SizedBox(height: AppDimensions.space24),

        // Customer Confirm Delivery action card (when status is shipping)
        if (order.status.canCustomerConfirmDelivery) ...[
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: AppDimensions.space24),
            padding: const EdgeInsets.all(AppDimensions.space20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppDimensions.radius12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.local_shipping_outlined,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: AppDimensions.space12),
                          Expanded(
                            child: Text(
                              'Kiện hàng đang được giao tới bạn',
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.space8),
                      Text(
                        'Nếu bạn đã nhận đủ kiện hàng từ shipper, hãy nhấn xác nhận để hoàn tất đơn và mở tính năng đánh giá sản phẩm.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space16),
                      FilledButton.icon(
                        key: const ValueKey('customer_confirm_delivery_button'),
                        onPressed: () => _showConfirmDeliveryDialog(context, ref, order),
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: const Text('Đã nhận được hàng'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.space20,
                            vertical: AppDimensions.space12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radius8),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      const Icon(
                        Icons.local_shipping_outlined,
                        color: AppColors.primary,
                        size: 32,
                      ),
                      const SizedBox(width: AppDimensions.space16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kiện hàng đang được giao tới bạn',
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Nếu bạn đã nhận đủ kiện hàng từ shipper, hãy nhấn xác nhận để hoàn tất đơn và mở tính năng đánh giá sản phẩm.',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space16),
                      FilledButton.icon(
                        key: const ValueKey('customer_confirm_delivery_button'),
                        onPressed: () => _showConfirmDeliveryDialog(context, ref, order),
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: const Text('Đã nhận được hàng'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.space20,
                            vertical: AppDimensions.space12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radius8),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],

        // Canceled reason banner
        if (order.status == OrderStatus.cancelled && order.cancellationReason != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: AppDimensions.space24),
            padding: const EdgeInsets.all(AppDimensions.space16),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppDimensions.radius12),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: AppColors.error, size: 20),
                const SizedBox(width: AppDimensions.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lý do hủy đơn hàng',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.cancellationReason!,
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Two columns layout on desktop/tablet, single column on mobile
        if (isMobile) ...[
          _buildShippingInfoCard(order),
          const SizedBox(height: AppDimensions.space20),
          _buildItemsCard(context, order),
          const SizedBox(height: AppDimensions.space20),
          _buildPaymentSummaryCard(order),
        ] else ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildItemsCard(context, order),
                    const SizedBox(height: AppDimensions.space20),
                    _buildShippingInfoCard(order),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.space24),
              Expanded(
                flex: 2,
                child: _buildPaymentSummaryCard(order),
              ),
            ],
          ),
        ],

        // Cancel order action footer
        if (order.status.canCustomerCancel) ...[
          const SizedBox(height: AppDimensions.space32),
          Container(
            padding: const EdgeInsets.all(AppDimensions.space20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radius12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bạn muốn thay đổi kế hoạch?',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Đơn hàng đang chờ xác nhận, bạn có thể tự hủy đơn trực tuyến.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () => CancelOrderDialog.show(context, order.orderCode),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.space20,
                      vertical: AppDimensions.space12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radius8),
                    ),
                  ),
                  child: const Text('Hủy đơn hàng'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildShippingInfoCard(Order order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.space20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: AppDimensions.space8),
              Text(
                'Địa chỉ nhận hàng (COD)',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space16),
          Text(
            order.recipientName,
            style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            'Số điện thoại: ${order.recipientPhone}',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            order.fullAddress,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          if (order.customerNote != null && order.customerNote!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.space12),
            Container(
              padding: const EdgeInsets.all(AppDimensions.space12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppDimensions.radius8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.textMuted),
                  const SizedBox(width: AppDimensions.space8),
                  Expanded(
                    child: Text(
                      'Ghi chú: ${order.customerNote}',
                      style: AppTypography.bodySmall.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showConfirmDeliveryDialog(
    BuildContext context,
    WidgetRef ref,
    Order order,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận đã nhận hàng?'),
        content: const Text(
          'Bạn xác nhận đã nhận được kiện hàng và sản phẩm trong tình trạng tốt?\n\n'
          'Sau khi xác nhận, đơn hàng sẽ chuyển sang trạng thái "Giao thành công" và bạn có thể đánh giá sản phẩm.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Chưa nhận'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Đã nhận hàng'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(orderActionControllerProvider.notifier)
          .customerConfirmDelivery(orderCode: order.orderCode);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.success,
            content: Text(
              'Xác nhận nhận hàng thành công! Bạn có thể đánh giá sản phẩm ngay bên dưới.',
            ),
          ),
        );
      }
    }
  }

  Widget _buildItemsCard(BuildContext context, Order order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.space20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kiện hàng (${order.totalItemCount} sản phẩm)',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            separatorBuilder: (_, _) =>
                const Divider(color: AppColors.border, height: AppDimensions.space24),
            itemBuilder: (context, index) {
              final item = order.items[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(AppDimensions.radius8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(
                          Icons.checkroom_outlined,
                          size: 32,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'SKU: ${item.sku}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                            Text(
                              item.variantDescription,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyFormatter.format(item.lineTotal),
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${CurrencyFormatter.format(item.unitPrice)} × ${item.quantity}',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (order.status == OrderStatus.delivered) ...[
                    const SizedBox(height: AppDimensions.space12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        key: ValueKey('review_btn_${item.id}'),
                        onPressed: () => SubmitReviewDialog.show(
                          context,
                          productId: item.productId ?? item.variantId ?? 'prod-001',
                          productName: item.productName,
                        ),
                        icon: const Icon(Icons.star_outline_rounded, size: 16),
                        label: const Text('Đánh giá sản phẩm'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.space16,
                            vertical: AppDimensions.space8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radius8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummaryCard(Order order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.space20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thanh toán COD',
            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppDimensions.space16),
          _buildSummaryRow('Tiền hàng', CurrencyFormatter.format(order.subtotal)),
          const SizedBox(height: AppDimensions.space8),
          _buildSummaryRow(
            'Phí giao hàng toàn quốc',
            CurrencyFormatter.format(order.shippingFee),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppDimensions.space12),
            child: Divider(color: AppColors.border, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Tổng thanh toán',
                  style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: AppDimensions.space8),
              Text(
                CurrencyFormatter.format(order.totalAmount),
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space16),
          Container(
            padding: const EdgeInsets.all(AppDimensions.space12),
            decoration: BoxDecoration(
              color: order.isPaid
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppDimensions.radius8),
            ),
            child: Row(
              children: [
                Icon(
                  order.isPaid ? Icons.check_circle_outline : Icons.payments_outlined,
                  size: 18,
                  color: order.isPaid ? AppColors.success : AppColors.textSecondary,
                ),
                const SizedBox(width: AppDimensions.space8),
                Expanded(
                  child: Text(
                    'Hình thức: Thanh toán tiền mặt khi nhận hàng (COD)',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(width: AppDimensions.space8),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
