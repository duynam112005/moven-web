import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../orders/presentation/providers/orders_providers.dart';
import '../../domain/models/checkout_result.dart';
import 'vietqr_payment_card.dart';

/// Giao diện xác nhận đặt hàng (COD hoặc Quét mã VietQR qua SePay)
class OrderSuccessView extends ConsumerStatefulWidget {
  final CheckoutResult result;
  final String recipientName;
  final String recipientPhone;
  final String shippingAddressText;
  final VoidCallback onContinueShopping;
  final VoidCallback onViewOrders;

  const OrderSuccessView({
    super.key,
    required this.result,
    required this.recipientName,
    required this.recipientPhone,
    required this.shippingAddressText,
    required this.onContinueShopping,
    required this.onViewOrders,
  });

  @override
  ConsumerState<OrderSuccessView> createState() => _OrderSuccessViewState();
}

class _OrderSuccessViewState extends ConsumerState<OrderSuccessView> {
  Timer? _countdownTimer;
  Timer? _statusPollingTimer;
  Duration _remainingTime = const Duration(minutes: 15);
  bool _isPaid = false;

  @override
  void initState() {
    super.initState();
    _initCountdown();
    _startStatusPolling();
  }

  void _initCountdown() {
    if (widget.result.paymentMethod != 'qr_code') return;

    final expiredAt = widget.result.paymentExpiredAt ??
        DateTime.now().add(const Duration(minutes: 15));
    final diff = expiredAt.difference(DateTime.now());
    _remainingTime = diff.isNegative ? Duration.zero : diff;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final remaining = expiredAt.difference(DateTime.now());
      if (remaining.isNegative) {
        setState(() => _remainingTime = Duration.zero);
        timer.cancel();
      } else {
        setState(() => _remainingTime = remaining);
      }
    });
  }

  /// Lắng nghe tự động trạng thái thanh toán từ SePay webhook
  void _startStatusPolling() {
    if (widget.result.paymentMethod != 'qr_code') return;

    _statusPollingTimer =
        Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted || _isPaid) {
        timer.cancel();
        return;
      }
      try {
        final order = await ref
            .read(ordersRepositoryProvider)
            .getOrderByCode(widget.result.orderCode);
        if (order.paymentStatus == 'paid' && mounted) {
          setState(() {
            _isPaid = true;
          });
          _countdownTimer?.cancel();
          timer.cancel();
        }
      } catch (_) {
        // Bỏ qua lỗi polling khi đang ở chế độ mock hoặc mạng chập chờn
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _statusPollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isQr = widget.result.paymentMethod == 'qr_code';
    final isExpired = isQr && _remainingTime == Duration.zero && !_isPaid;

    Color iconBgColor;
    IconData iconData;
    String title;
    String subtitle;

    if (!isQr) {
      // Đơn hàng COD
      iconBgColor = AppColors.success;
      iconData = Icons.check;
      title = 'Đặt hàng thành công!';
      subtitle =
          'Cảm ơn bạn đã tin chọn MOVEN. Đơn hàng của bạn đã được tiếp nhận và đang chờ xác nhận.';
    } else if (_isPaid) {
      // Đơn QR đã thanh toán thành công qua SePay
      iconBgColor = AppColors.success;
      iconData = Icons.verified_rounded;
      title = 'Thanh toán thành công!';
      subtitle =
          'Hệ thống SePay đã tự động xác nhận tiền về và đơn hàng đã được duyệt tự động.';
    } else if (isExpired) {
      // Đơn QR đã quá hạn 15 phút
      iconBgColor = AppColors.error;
      iconData = Icons.timer_off_outlined;
      title = 'Mã QR đã hết hạn!';
      subtitle =
          'Đơn hàng đã quá hạn 15 phút và sẽ được hệ thống hủy tự động để hoàn trả tồn kho.';
    } else {
      // Đơn QR đang chờ thanh toán
      iconBgColor = AppColors.primary;
      iconData = Icons.qr_code_2_rounded;
      title = 'Đặt hàng thành công! Quét mã VietQR';
      subtitle =
          'Mở ứng dụng Ngân hàng hoặc Momo để quét mã VietQR bên dưới chuyển khoản nhanh.';
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppDimensions.space24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon trạng thái
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              iconData,
              size: 38,
              color: AppColors.onPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.space16),

          // Tiêu đề
          Text(
            title,
            style: AppTypography.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.space8),

          // Mô tả phụ
          Text(
            subtitle,
            style: AppTypography.bodyMedium,
            textAlign: TextAlign.center,
          ),

          // Khu vực hiển thị thẻ VietQR SePay
          if (isQr) ...[
            const SizedBox(height: AppDimensions.space20),
            VietQrPaymentCard(
              orderCode: widget.result.orderCode,
              totalAmount: widget.result.totalAmount,
              remainingTime: _remainingTime,
              isExpired: isExpired,
              isPaid: _isPaid,
            ),
          ],

          const SizedBox(height: AppDimensions.space20),

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
                _buildRow('Mã đơn hàng:', widget.result.orderCode, isBold: true),
                const Divider(height: AppDimensions.space16),
                _buildRow('Người nhận:',
                    '${widget.recipientName} (${widget.recipientPhone})'),
                const SizedBox(height: AppDimensions.space8),
                _buildRow('Địa chỉ giao:', widget.shippingAddressText),
                const Divider(height: AppDimensions.space16),
                _buildRow(
                  'Hình thức:',
                  isQr ? 'Quét mã VietQR SePay' : 'Thanh toán COD khi nhận hàng',
                ),
                const SizedBox(height: AppDimensions.space8),
                _buildRow(
                  'Trạng thái:',
                  _isPaid
                      ? 'Đã thanh toán (Paid)'
                      : (isQr ? 'Chờ thanh toán (Unpaid)' : 'Chờ xác nhận'),
                  isHighlight: _isPaid,
                  isBold: true,
                ),
                const SizedBox(height: AppDimensions.space8),
                _buildRow(
                  'Tổng thanh toán:',
                  CurrencyFormatter.format(widget.result.totalAmount),
                  isHighlight: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space24),

          // Nút hành động
          AppButton(
            label: 'Xem danh sách đơn hàng',
            isFullWidth: true,
            onPressed: widget.onViewOrders,
          ),
          const SizedBox(height: AppDimensions.space12),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize:
                  const Size(double.infinity, AppDimensions.buttonHeightMd),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radius8),
              ),
            ),
            onPressed: widget.onContinueShopping,
            child: const Text('Tiếp tục mua sắm'),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value,
      {bool isBold = false, bool isHighlight = false}) {
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
              fontWeight:
                  (isBold || isHighlight) ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Modal dialog hiển thị thông tin xác nhận đặt hàng thành công
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

  /// Hiển thị dialog xác nhận đặt hàng an toàn không gây nghẽn route GoRouter
  static Future<String?> show({
    required BuildContext context,
    required CheckoutResult result,
    required String recipientName,
    required String recipientPhone,
    required String shippingAddressText,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => OrderSuccessDialog(
        result: result,
        recipientName: recipientName,
        recipientPhone: recipientPhone,
        shippingAddressText: shippingAddressText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
      ),
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space16,
        vertical: AppDimensions.space24,
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          child: OrderSuccessView(
            result: result,
            recipientName: recipientName,
            recipientPhone: recipientPhone,
            shippingAddressText: shippingAddressText,
            onContinueShopping: () {
              Navigator.of(context).pop(RouteNames.catalogPath);
            },
            onViewOrders: () {
              Navigator.of(context).pop(RouteNames.ordersPath);
            },
          ),
        ),
      ),
    );
  }
}
