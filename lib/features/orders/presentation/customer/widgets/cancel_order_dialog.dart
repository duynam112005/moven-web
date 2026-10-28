import 'package:flutter/material.dart';
import 'package:moven/core/constants/app_colors.dart';
import 'package:moven/core/constants/app_dimensions.dart';
import 'package:moven/core/constants/app_typography.dart';

/// Hộp thoại xác nhận hủy đơn hàng kèm lựa chọn lý do sinh động.
/// Trả về chuỗi lý do hủy nếu người dùng xác nhận, hoặc null nếu người dùng hủy bỏ.
class CancelOrderDialog extends StatefulWidget {
  final String orderCode;

  const CancelOrderDialog({
    super.key,
    required this.orderCode,
  });

  /// Hiển thị hộp thoại và trả về lý do hủy đã chọn (hoặc null nếu đóng/hủy)
  static Future<String?> show(BuildContext context, String orderCode) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CancelOrderDialog(orderCode: orderCode),
    );
  }

  @override
  State<CancelOrderDialog> createState() => _CancelOrderDialogState();
}

class _CancelOrderDialogState extends State<CancelOrderDialog> {
  static const List<String> _predefinedReasons = [
    'Muốn thay đổi sản phẩm / kích cỡ / màu sắc',
    'Nhập sai địa chỉ nhận hàng hoặc số điện thoại',
    'Đổi ý, không còn nhu cầu mua sắm nữa',
    'Tìm thấy giá tốt hơn ở nơi khác',
    'Lý do khác...',
  ];

  String _selectedReason = _predefinedReasons[0];
  final _otherReasonController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    final effectiveReason = _selectedReason == 'Lý do khác...'
        ? _otherReasonController.text.trim()
        : _selectedReason;

    if (effectiveReason.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập rõ lý do hủy đơn hàng của bạn.';
      });
      return;
    }

    Navigator.of(context).pop(effectiveReason);
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
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
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
                  onTap: () {
                    setState(() {
                      _selectedReason = reason;
                      _errorMessage = null;
                    });
                  },
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
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: AppDimensions.space8),
                  child: TextField(
                    controller: _otherReasonController,
                    maxLines: 2,
                    onChanged: (_) {
                      if (_errorMessage != null) {
                        setState(() => _errorMessage = null);
                      }
                    },
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

              // Inline validation error message
              if (_errorMessage != null) ...[
                const SizedBox(height: AppDimensions.space8),
                Row(
                  children: [
                    const Icon(Icons.error_outline, size: 16, color: AppColors.error),
                    const SizedBox(width: AppDimensions.space6),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: AppDimensions.space24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    key: const ValueKey('dismiss_cancel_order_button'),
                    onPressed: () => Navigator.of(context).pop(null),
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
                    key: const ValueKey('confirm_cancel_order_button'),
                    onPressed: _handleConfirm,
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
                    child: const Text(
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
    ),
  );
  }
}
