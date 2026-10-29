import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moven/core/constants/app_colors.dart';
import 'package:moven/core/constants/app_dimensions.dart';
import 'package:moven/core/constants/app_typography.dart';
import 'package:moven/core/utils/currency_formatter.dart';
import 'package:moven/core/utils/date_time_utils.dart';
import 'package:moven/features/orders/domain/models/order.dart';
import 'package:moven/features/orders/presentation/customer/widgets/order_status_badge.dart';
import 'package:moven/features/orders/presentation/providers/orders_providers.dart';
import 'admin_order_status_dialog.dart';

/// Hộp thoại xem chi tiết đơn hàng và thao tác kiểm duyệt cho Quản trị viên
class AdminOrderDetailDialog extends ConsumerWidget {
  final Order order;

  const AdminOrderDetailDialog({
    super.key,
    required this.order,
  });

  static Future<void> show(BuildContext context, Order order) {
    return showDialog(
      context: context,
      builder: (_) => AdminOrderDetailDialog(order: order),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateStr = DateTimeUtils.formatDateTimeWithSeconds(order.createdAt);
    final canUpdateStatus = order.status.validNextStatusesAdmin.isNotEmpty;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
      ),
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Chi tiết đơn hàng ${order.orderCode}',
                            style: AppTypography.headlineMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.space12),
                          OrderStatusBadge(status: order.status),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Thời gian tạo: $dateStr • User ID: ${order.userId}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppDimensions.space12),
                child: Divider(color: AppColors.border, height: 1),
              ),

              // 2. Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer & Shipping Info
                      _buildInfoSection(context, ref),
                      const SizedBox(height: AppDimensions.space20),

                      // Order Items Table
                      _buildItemsSection(),
                      const SizedBox(height: AppDimensions.space20),

                      // Audit Status History Log
                      _buildAuditLogSection(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.space16),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: AppDimensions.space16),

              // 3. Actions Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Payment status toggle button (ADR-0002)
                  OutlinedButton.icon(
                    onPressed: () async {
                      final newPayment = order.isPaid ? 'unpaid' : 'paid';
                      await ref
                          .read(orderActionControllerProvider.notifier)
                          .adminUpdatePayment(
                            orderId: order.id,
                            orderCode: order.orderCode,
                            paymentStatus: newPayment,
                            note: 'Admin chuyển sang $newPayment',
                          );
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    icon: Icon(
                      order.isPaid ? Icons.undo : Icons.check_circle_outline,
                      size: 16,
                      color: order.isPaid ? AppColors.warning : AppColors.success,
                    ),
                    label: Text(
                      order.isPaid
                          ? (order.isQrPayment
                              ? 'Đánh dấu Chưa nhận QR'
                              : 'Đánh dấu Chưa thu COD')
                          : (order.isQrPayment
                              ? 'Xác nhận Đã nhận chuyển khoản QR'
                              : 'Xác nhận Đã thu tiền COD'),
                      style: TextStyle(
                        color: order.isPaid ? AppColors.warning : AppColors.success,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: order.isPaid ? AppColors.warning : AppColors.success,
                      ),
                    ),
                  ),

                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Đóng'),
                      ),
                      if (canUpdateStatus) ...[
                        const SizedBox(width: AppDimensions.space12),
                        ElevatedButton.icon(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await AdminOrderStatusDialog.show(context, order);
                          },
                          icon: const Icon(Icons.local_shipping_outlined, size: 16),
                          label: const Text('Cập nhật trạng thái'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                          ),
                        ),
                      ],
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

  Widget _buildInfoSection(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
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
                order.isQrPayment
                    ? 'Thông tin giao nhận & Thanh toán QR'
                    : 'Thông tin giao nhận & Thanh toán COD',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: order.isPaid
                      ? AppColors.success.withValues(alpha: 0.15)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
                ),
                child: Text(
                  order.isPaid
                      ? (order.isQrPayment
                          ? 'Thanh toán QR: Đã nhận tiền'
                          : 'Tiền COD: Đã đối soát nộp')
                      : (order.isQrPayment
                          ? 'Thanh toán QR: Chưa nhận tiền'
                          : 'Tiền COD: Chưa thu/chưa nộp'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: order.isPaid ? AppColors.success : const Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Người nhận: ${order.recipientName}',
                      style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Số điện thoại: ${order.recipientPhone}',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Địa chỉ: ${order.fullAddress}',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tiền hàng: ${CurrencyFormatter.format(order.subtotal)}',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Phí giao hàng: ${CurrencyFormatter.format(order.shippingFee)}',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${order.isQrPayment ? "Tổng thanh toán:" : "Tổng thu COD:"} ${CurrencyFormatter.format(order.totalAmount)}',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (order.customerNote != null && order.customerNote!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.space8),
            Text(
              'Ghi chú của khách: "${order.customerNote}"',
              style: AppTypography.bodySmall.copyWith(
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danh sách sản phẩm (${order.totalItemCount} món)',
          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppDimensions.space12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppDimensions.radius8),
          ),
          child: Column(
            children: order.items.map((item) {
              return Padding(
                padding: const EdgeInsets.all(AppDimensions.space12),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppDimensions.radius4),
                      ),
                      child: const Icon(Icons.checkroom, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: AppDimensions.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'SKU: ${item.sku} | ${item.variantDescription}',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          CurrencyFormatter.format(item.lineTotal),
                          style: AppTypography.bodyMedium.copyWith(
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
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAuditLogSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lịch sử thay đổi trạng thái (Audit Trail)',
          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppDimensions.space12),
        if (order.statusHistory.isEmpty)
          Text('Chưa có lịch sử trạng thái.', style: AppTypography.bodySmall)
        else
          Container(
            padding: const EdgeInsets.all(AppDimensions.space12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppDimensions.radius8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: order.statusHistory.map((hist) {
                final time = DateTimeUtils.formatDateTimeWithSeconds(hist.createdAt);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(time, style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
                      const SizedBox(width: AppDimensions.space12),
                      Text(
                        hist.toStatus.displayName,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: hist.toStatus.badgeTextColor,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space12),
                      Expanded(
                        child: Text(
                          hist.note ?? '',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
