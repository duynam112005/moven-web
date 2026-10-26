import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moven/core/constants/app_colors.dart';
import 'package:moven/core/constants/app_dimensions.dart';
import 'package:moven/core/constants/app_typography.dart';
import 'package:moven/features/orders/domain/models/order.dart';
import 'package:moven/features/orders/domain/models/order_status.dart';
import 'package:moven/features/orders/presentation/providers/orders_providers.dart';

/// Hộp thoại cho phép Quản trị viên cập nhật trạng thái đơn hàng theo máy trạng thái ADR-0001
class AdminOrderStatusDialog extends ConsumerStatefulWidget {
  final Order order;

  const AdminOrderStatusDialog({
    super.key,
    required this.order,
  });

  static Future<bool?> show(BuildContext context, Order order) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AdminOrderStatusDialog(order: order),
    );
  }

  @override
  ConsumerState<AdminOrderStatusDialog> createState() =>
      _AdminOrderStatusDialogState();
}

class _AdminOrderStatusDialogState
    extends ConsumerState<AdminOrderStatusDialog> {
  late OrderStatus _selectedStatus;
  final _noteController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final validNext = widget.order.status.validNextStatusesAdmin;
    _selectedStatus = validNext.isNotEmpty ? validNext.first : widget.order.status;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    setState(() => _isSubmitting = true);

    final success = await ref
        .read(orderActionControllerProvider.notifier)
        .adminUpdateStatus(
          orderId: widget.order.id,
          orderCode: widget.order.orderCode,
          newStatus: _selectedStatus,
          note: _noteController.text.trim().isNotEmpty
              ? _noteController.text.trim()
              : null,
        );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đã cập nhật trạng thái đơn ${widget.order.orderCode} sang "${_selectedStatus.displayName}"',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        final error = ref.read(orderActionControllerProvider).error?.toString() ??
            'Cập nhật trạng thái thất bại.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final validNextStatuses = order.status.validNextStatusesAdmin;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
      ),
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.space8),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit_note_rounded,
                      color: AppColors.info,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cập nhật trạng thái vận chuyển',
                          style: AppTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Đơn hàng: ${order.orderCode} • Hiện tại: ${order.status.displayName}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space20),

              if (validNextStatuses.isEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(AppDimensions.space16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppDimensions.radius8),
                  ),
                  child: Text(
                    'Đơn hàng đã ở trạng thái kết thúc (${order.status.displayName}) và không thể chuyển đổi thêm.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.space20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Đóng'),
                  ),
                ),
              ] else ...[
                Text(
                  'Chọn trạng thái tiếp theo hợp lệ (ADR-0001):',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.space12),

                // Options list
                ...validNextStatuses.map((nextStatus) {
                  final isSelected = _selectedStatus == nextStatus;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppDimensions.space8),
                    child: InkWell(
                      onTap: _isSubmitting
                          ? null
                          : () => setState(() => _selectedStatus = nextStatus),
                      borderRadius: BorderRadius.circular(AppDimensions.radius8),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.all(AppDimensions.space12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? nextStatus.badgeBackgroundColor.withValues(alpha: 0.5)
                              : AppColors.surfaceVariant.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(AppDimensions.radius8),
                          border: Border.all(
                            color: isSelected
                                ? nextStatus.badgeTextColor
                                : AppColors.border,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              size: 18,
                              color: isSelected
                                  ? nextStatus.badgeTextColor
                                  : AppColors.textMuted,
                            ),
                            const SizedBox(width: AppDimensions.space8),
                            Icon(nextStatus.icon, size: 18, color: nextStatus.badgeTextColor),
                            const SizedBox(width: AppDimensions.space8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nextStatus.displayName,
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? nextStatus.badgeTextColor
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    nextStatus.description,
                                    style: AppTypography.bodySmall.copyWith(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                // Special Restock Info Callout
                if (_selectedStatus == OrderStatus.returned) ...[
                  const SizedBox(height: AppDimensions.space8),
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.space12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(AppDimensions.radius8),
                      border: Border.all(color: const Color(0xFFC084FC)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.inventory_2_outlined, color: Color(0xFF7E22CE), size: 18),
                        SizedBox(width: AppDimensions.space8),
                        Expanded(
                          child: Text(
                            'Bất biến MOVEN: Chuyển sang "Đã trả hàng hoàn" đồng nghĩa bạn xác nhận kiện hàng đã về kho an toàn. Hệ thống sẽ tự động hoàn lại tồn kho và ghi nhật ký inventory_movements (reason: return_received).',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B21A8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (_selectedStatus == OrderStatus.cancelled) ...[
                  const SizedBox(height: AppDimensions.space8),
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.space12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppDimensions.radius8),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 18),
                        SizedBox(width: AppDimensions.space8),
                        Expanded(
                          child: Text(
                            'Hủy đơn hàng: Sản phẩm sẽ được tự động hoàn lại vào kho biến thể và ghi nhật ký inventory_movements (reason: order_cancelled).',
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

                const SizedBox(height: AppDimensions.space16),

                // Note field
                Text(
                  'Ghi chú vận hành (tùy chọn):',
                  style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppDimensions.space6),
                TextField(
                  controller: _noteController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Nhập ghi chú hoặc mã vận đơn...',
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    contentPadding: const EdgeInsets.all(AppDimensions.space12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radius8),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radius8),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.space24),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                      child: const Text('Hủy bỏ'),
                    ),
                    const SizedBox(width: AppDimensions.space12),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.space20,
                          vertical: AppDimensions.space12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radius8),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.onPrimary,
                              ),
                            )
                          : const Text(
                              'Cập nhật trạng thái',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
