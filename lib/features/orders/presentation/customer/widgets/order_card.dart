import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:moven/core/constants/app_colors.dart';
import 'package:moven/core/constants/app_dimensions.dart';
import 'package:moven/core/constants/app_typography.dart';
import 'package:moven/core/utils/currency_formatter.dart';
import 'package:moven/features/orders/domain/models/order.dart';
import 'order_status_badge.dart';

/// Thẻ hiển thị tóm tắt đơn hàng với hover micro-interaction mượt mà
class OrderCard extends StatefulWidget {
  final Order order;
  final VoidCallback? onCancelPressed;

  const OrderCard({
    super.key,
    required this.order,
    this.onCancelPressed,
  });

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final dateStr = DateFormat('dd/MM/yyyy - HH:mm').format(order.createdAt);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.push('/orders/${order.orderCode}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _isHovered ? -3 : 0, 0),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radius12),
            border: Border.all(
              color: _isHovered ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border,
              width: _isHovered ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: _isHovered ? 0.08 : 0.03),
                blurRadius: _isHovered ? 12 : 4,
                offset: Offset(0, _isHovered ? 6 : 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(AppDimensions.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header: Mã đơn + Thời gian + Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.receipt_outlined,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppDimensions.space6),
                            Flexible(
                              child: Text(
                                order.orderCode,
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.space2),
                        Text(
                          dateStr,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: order.isPaid
                              ? AppColors.success.withValues(alpha: 0.12)
                              : (order.isQrPayment
                                  ? AppColors.primary.withValues(alpha: 0.1)
                                  : AppColors.surfaceVariant),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: order.isPaid
                                ? AppColors.success.withValues(alpha: 0.4)
                                : (order.isQrPayment
                                    ? AppColors.primary.withValues(alpha: 0.3)
                                    : AppColors.border),
                          ),
                        ),
                        child: Text(
                          order.isPaid
                              ? 'Đã thanh toán (0đ)'
                              : (order.isQrPayment
                                  ? 'Chờ thanh toán QR'
                                  : order.paymentMethodDisplayName),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: order.isPaid
                                ? AppColors.success
                                : (order.isQrPayment
                                    ? AppColors.primary
                                    : AppColors.textSecondary),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space6),
                      OrderStatusBadge(status: order.status),
                    ],
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppDimensions.space12),
                child: Divider(color: AppColors.border, height: 1),
              ),

              // 2. Danh sách sản phẩm rút gọn
              if (order.items.isNotEmpty)
                Column(
                  children: order.items.take(2).map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppDimensions.space8),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(AppDimensions.radius8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Icon(
                              Icons.checkroom_outlined,
                              size: 24,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.space12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: AppTypography.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${item.variantDescription} × ${item.quantity}',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppDimensions.space8),
                          Text(
                            CurrencyFormatter.format(item.lineTotal),
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

              if (order.items.length > 2)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.space8),
                  child: Text(
                    '+ thêm ${order.items.length - 2} sản phẩm khác',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: AppDimensions.space12),

              // 3. Footer: Tổng tiền + Còn lại cần trả + Hành động
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.isPaid
                            ? 'Đã thanh toán (${order.totalItemCount} món):'
                            : 'Cần thanh toán (${order.totalItemCount} món):',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            CurrencyFormatter.format(order.totalAmount),
                            style: AppTypography.titleMedium.copyWith(
                              color: order.isPaid ? AppColors.success : AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (order.isPaid) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Còn lại: 0đ',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (order.status.canCustomerCancel && widget.onCancelPressed != null) ...[
                        OutlinedButton(
                          onPressed: order.isPaid
                              ? () => _showPaidOrderCancelInfo(context)
                              : widget.onCancelPressed,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: order.isPaid ? AppColors.textSecondary : AppColors.error,
                            side: BorderSide(
                              color: order.isPaid ? AppColors.border : AppColors.error,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.space12,
                              vertical: AppDimensions.space8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppDimensions.radius8),
                            ),
                          ),
                          child: Text(
                            order.isPaid ? 'Yêu cầu hủy' : 'Hủy đơn',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space8),
                      ],
                      ElevatedButton(
                        onPressed: () => context.push('/orders/${order.orderCode}'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.space16,
                            vertical: AppDimensions.space8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radius8),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Chi tiết', style: TextStyle(fontSize: 13)),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_ios, size: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaidOrderCancelInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius12),
        ),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Đơn hàng đã thanh toán', style: AppTypography.titleMedium),
          ],
        ),
        content: const Text(
          'Đơn hàng này đã được thanh toán thành công (0đ khi nhận hàng). Để hủy đơn và được hoàn tiền vào tài khoản ngân hàng, quý khách vui lòng liên hệ trực tiếp Hotline/Zalo cửa hàng MOVEN.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
            ),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }
}
