import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:moven/core/constants/app_colors.dart';
import 'package:moven/core/constants/app_dimensions.dart';
import 'package:moven/core/constants/app_typography.dart';
import 'package:moven/core/errors/app_exception.dart';
import 'package:moven/core/router/route_names.dart';
import 'package:moven/core/utils/currency_formatter.dart';
import 'package:moven/core/utils/responsive_layout.dart';
import 'package:moven/core/widgets/app_loading.dart';
import 'package:moven/core/widgets/error_state_view.dart';
import 'package:moven/features/checkout/presentation/widgets/vietqr_payment_card.dart';
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

        // Thông báo tiến trình vận chuyển (khi đơn đang shipping)
        if (order.status == OrderStatus.shipping) ...[
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: AppDimensions.space24),
            padding: const EdgeInsets.all(AppDimensions.space20),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppDimensions.radius12),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.space10),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_shipping_outlined,
                    color: AppColors.info,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppDimensions.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kiện hàng đang trên đường giao tới bạn',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.info,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space4),
                      Text(
                        'Nhân viên giao vận sẽ liên hệ với bạn qua số điện thoại ${order.recipientPhone} trước khi phát hàng. Quý khách vui lòng kiểm tra kiện hàng và thanh toán số tiền COD ${CurrencyFormatter.format(order.totalAmount)} khi nhận.',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space8),
                      Row(
                        children: [
                          const Icon(Icons.info_outline, size: 14, color: AppColors.textMuted),
                          const SizedBox(width: AppDimensions.space4),
                          Expanded(
                            child: Text(
                              'Sau khi giao hàng thành công, hệ thống sẽ mở tính năng đánh giá sản phẩm bên dưới.',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        // Thông báo giao hàng thành công & hướng dẫn đánh giá (khi đơn delivered)
        if (order.status == OrderStatus.delivered) ...[
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: AppDimensions.space24),
            padding: const EdgeInsets.all(AppDimensions.space20),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppDimensions.radius12),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.space10),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.success,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppDimensions.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đơn hàng đã giao thành công!',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space4),
                      Text(
                        'Cảm ơn bạn đã tin chọn MOVEN. Hãy chia sẻ cảm nhận và đánh giá chất lượng cho từng sản phẩm ở danh sách kiện hàng bên dưới nhé!',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ],
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
          _buildPaymentSummaryCard(context, order),
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
                child: _buildPaymentSummaryCard(context, order),
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
                  key: const ValueKey('customer_cancel_order_button'),
                  onPressed: () => _handleCustomerCancelOrder(context, ref, order),
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
                'Địa chỉ nhận hàng',
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

  Future<void> _handleCustomerCancelOrder(
    BuildContext context,
    WidgetRef ref,
    Order order,
  ) async {
    final reason = await CancelOrderDialog.show(context, order.orderCode);
    if (reason == null || !context.mounted) return;

    try {
      final success = await ref
          .read(orderActionControllerProvider.notifier)
          .cancelOrder(orderCode: order.orderCode, reason: reason);

      if (context.mounted) {
        final messenger = ScaffoldMessenger.maybeOf(context);
        if (success) {
          messenger?.showSnackBar(
            const SnackBar(
              content: Text('Đã hủy đơn hàng thành công.'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          final error = ref.read(orderActionControllerProvider).error;
          final message = error is AppException
              ? error.message
              : 'Không thể hủy đơn hàng. Vui lòng thử lại sau.';
          messenger?.showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(
            content: Text('Đã xảy ra lỗi khi hủy đơn hàng: $e'),
            backgroundColor: AppColors.error,
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

  Widget _buildPaymentSummaryCard(BuildContext context, Order order) {
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
            order.isQrPayment ? 'Thanh toán Quét mã QR' : 'Thanh toán COD',
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
                  order.isPaid
                      ? Icons.check_circle_outline
                      : (order.isQrPayment ? Icons.qr_code_2 : Icons.payments_outlined),
                  size: 18,
                  color: order.isPaid ? AppColors.success : AppColors.textSecondary,
                ),
                const SizedBox(width: AppDimensions.space8),
                Expanded(
                  child: Text(
                    'Hình thức: ${order.paymentMethodDisplayName} • ${order.paymentStatusDisplayName}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Nút xem lại mã QR nếu là đơn QR chưa thanh toán
          if (order.isQrPayment &&
              !order.isPaid &&
              order.status == OrderStatus.pendingConfirmation) ...[
            const SizedBox(height: AppDimensions.space12),
            if (!order.isPaymentExpired) ...[
              OutlinedButton.icon(
                onPressed: () => _showQrCodeDialog(context, order),
                icon: const Icon(Icons.qr_code_scanner, size: 18),
                label: const Text('Xem mã QR để quét'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, AppDimensions.buttonHeightMd),
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radius8),
                  ),
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.space12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radius8),
                  border: Border.all(color: AppColors.error),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.timer_off_outlined, color: AppColors.error, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Đơn hàng đã hết hạn thời gian thanh toán (15 phút)',
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
            ],
          ],
        ],
      ),
    );
  }

  void _showQrCodeDialog(BuildContext context, Order order) {
    final remaining = order.paymentExpiredAt?.difference(DateTime.now());

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius16),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.space24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Mã VietQR Thanh Toán', style: AppTypography.titleLarge),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(dialogCtx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space16),
                VietQrPaymentCard(
                  orderCode: order.orderCode,
                  totalAmount: order.totalAmount,
                  remainingTime:
                      remaining != null && !remaining.isNegative ? remaining : null,
                  isExpired: order.isPaymentExpired,
                  isPaid: order.isPaid,
                ),
                const SizedBox(height: AppDimensions.space16),
                ElevatedButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  style: ElevatedButton.styleFrom(
                    minimumSize:
                        const Size(double.infinity, AppDimensions.buttonHeightMd),
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                  ),
                  child: const Text('Đóng'),
                ),
              ],
            ),
          ),
        ),
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
