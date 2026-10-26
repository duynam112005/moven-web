import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moven/core/constants/app_colors.dart';
import 'package:moven/core/constants/app_dimensions.dart';
import 'package:moven/core/constants/app_typography.dart';
import 'package:moven/features/orders/presentation/providers/orders_providers.dart';

/// Hộp thoại xác nhận hủy đơn hàng kèm lựa chọn lý do sinh động
class CancelOrderDialog extends ConsumerStatefulWidget {
  final String orderCode;

  const CancelOrderDialog({
    super.key,
    required this.orderCode,
  });

  static Future<bool?> show(BuildContext context, String orderCode) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CancelOrderDialog(orderCode: orderCode),
    );
  }

  @override
  ConsumerState<CancelOrderDialog> createState() => _CancelOrderDialogState();
}

class _CancelOrderDialogState extends ConsumerState<CancelOrderDialog> {
  static const List<String> _predefinedReasons = [
    'Muốn thay đổi sản phẩm / kích cỡ / màu sắc',
    'Nhập sai địa chỉ nhận hàng hoặc số điện thoại',
    'Đổi ý, không còn nhu cầu mua sắm nữa',
    'Tìm thấy giá tốt hơn ở nơi khác',
    'Lý do khác...',
  ];

  String _selectedReason = _predefinedReasons[0];
  final _otherReasonController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    final effectiveReason = _selectedReason == 'Lý do khác...'
        ? _otherReasonController.text.trim()
        : _selectedReason;

    if (effectiveReason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập rõ lý do hủy đơn hàng của bạn.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await ref
        .read(orderActionControllerProvider.notifier)
        .cancelOrder(
          orderCode: widget.orderCode,
          reason: effectiveReason,
        );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã hủy đơn hàng thành công.'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        final error = ref.read(orderActionControllerProvider).error?.toString() ??
            'Không thể hủy đơn hàng. Vui lòng thử lại sau.';
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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
      ),
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
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
                      color: AppColors.error.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.error,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xác nhận hủy đơn hàng?',
                          style: AppTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Mã đơn: ${widget.orderCode}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space16),

              Text(
                'Sản phẩm trong đơn sẽ được hoàn lại vào kho hàng. Vui lòng cho MOVEN biết lý do bạn muốn hủy đơn:',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.space12),

              // Reason Radio Options
              ..._predefinedReasons.map((reason) {
                final isSelected = _selectedReason == reason;
                return InkWell(
                  onTap: _isSubmitting
                      ? null
                      : () => setState(() => _selectedReason = reason),
                  borderRadius: BorderRadius.circular(AppDimensions.radius8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.space12,
                      vertical: AppDimensions.space8,
                    ),
                    margin: const EdgeInsets.only(bottom: AppDimensions.space4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.05)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppDimensions.radius8),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          size: 18,
                          color: isSelected ? AppColors.primary : AppColors.textMuted,
                        ),
                        const SizedBox(width: AppDimensions.space8),
                        Expanded(
                          child: Text(
                            reason,
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              // Expandable input for "Lý do khác..."
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                firstCurve: Curves.easeOutCubic,
                secondCurve: Curves.easeInCubic,
                crossFadeState: _selectedReason == 'Lý do khác...'
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox(width: double.infinity),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: AppDimensions.space8),
                  child: TextField(
                    controller: _otherReasonController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Nhập lý do cụ thể của bạn...',
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
                ),
              ),

              const SizedBox(height: AppDimensions.space24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.space16,
                        vertical: AppDimensions.space12,
                      ),
                    ),
                    child: const Text('Giữ đơn hàng'),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: AppColors.onError,
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
                              color: AppColors.onError,
                            ),
                          )
                        : const Text(
                            'Xác nhận hủy',
                            style: TextStyle(fontWeight: FontWeight.w600),
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
}
