import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/models/checkout_result.dart';

/// Modal dialog hoặc màn hình thông báo đặt hàng COD thành công
class OrderSuccessDialog extends StatelessWidget {
  final CheckoutResult result;
  final String recipientName;
  final String recipientPhone;
  final String shippingAddressText;

  const OrderSuccessDialog({
    super.key,
    required this.result,
    required this.recipientName,
    required this.recipientPhone,
    required this.shippingAddressText,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon thành công
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 40,
                  color: AppColors.onPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.space20),
              const Text(
                'Đặt hàng thành công!',
                style: AppTypography.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.space8),
              const Text(
                'Cảm ơn bạn đã tin chọn MOVEN. Đơn hàng của bạn đã được tiếp nhận và đang chờ xác nhận.',
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.space24),
              // Hộp tóm tắt thông tin đơn hàng
              Container(
                padding: const EdgeInsets.all(AppDimensions.space16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppDimensions.radius12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildRow('Mã đơn hàng:', result.orderCode, isBold: true),
                    const Divider(height: AppDimensions.space16),
                    _buildRow('Người nhận:', '$recipientName ($recipientPhone)'),
                    const SizedBox(height: AppDimensions.space8),
                    _buildRow('Địa chỉ giao:', shippingAddressText),
                    const Divider(height: AppDimensions.space16),
                    _buildRow('Hình thức:', 'Thanh toán COD khi nhận hàng'),
                    const SizedBox(height: AppDimensions.space8),
                    _buildRow(
                      'Tổng thanh toán:',
                      CurrencyFormatter.format(result.totalAmount),
                      isHighlight: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space24),
              // Nút hành động
              AppButton(
                label: 'Tiếp tục mua sắm',
                isFullWidth: true,
                onPressed: () {
                  context.pop();
                  context.go(RouteNames.catalogPath);
                },
              ),
              const SizedBox(height: AppDimensions.space12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, AppDimensions.buttonHeightMd),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radius8),
                  ),
                ),
                onPressed: () {
                  context.pop();
                  context.go(RouteNames.ordersPath);
                },
                child: const Text('Xem danh sách đơn hàng'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, bool isHighlight = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(width: AppDimensions.space12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13,
              fontWeight: (isBold || isHighlight) ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
