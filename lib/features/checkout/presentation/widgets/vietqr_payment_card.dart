import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/payment_constants.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Card hiển thị mã VietQR chuyển khoản ngân hàng qua SePay
/// Tự động sinh mã VietQR chuẩn ngân hàng và hỗ trợ sao chép nhanh
class VietQrPaymentCard extends StatelessWidget {
  final String orderCode;
  final int totalAmount;
  final Duration? remainingTime;
  final bool isExpired;
  final bool isPaid;
  final String? bankName;
  final String? accountNumber;
  final String? accountHolder;

  const VietQrPaymentCard({
    super.key,
    required this.orderCode,
    required this.totalAmount,
    this.remainingTime,
    this.isExpired = false,
    this.isPaid = false,
    this.bankName,
    this.accountNumber,
    this.accountHolder,
  });

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã sao chép $label: $text'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeBankName = bankName ?? PaymentConstants.defaultBankName;
    final activeAccountNumber = accountNumber ?? PaymentConstants.defaultAccountNumber;
    final activeAccountHolder = accountHolder ?? PaymentConstants.defaultAccountHolder;

    final vietQrUrl = PaymentConstants.buildVietQrImageUrl(
      amount: totalAmount,
      orderCode: orderCode,
      accountNumber: activeAccountNumber,
    );

    final fallbackPayload = PaymentConstants.buildFallbackQrPayload(
      orderCode: orderCode,
      amount: totalAmount,
      bankName: activeBankName,
      accountNumber: activeAccountNumber,
      accountHolder: activeAccountHolder,
    );

    // Trường hợp 1: Đã thanh toán thành công
    if (isPaid) {
      return Container(
        padding: const EdgeInsets.all(AppDimensions.space20),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppDimensions.radius12),
          border: Border.all(color: AppColors.success, width: 1.5),
        ),
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 54),
            const SizedBox(height: AppDimensions.space12),
            const Text(
              'Thanh toán thành công!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: AppDimensions.space6),
            const Text(
              'Hệ thống SePay đã tự động xác nhận giao dịch. Cửa hàng MOVEN đang chuẩn bị đơn hàng cho bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    // Trường hợp 2: Đã hết hạn thanh toán
    if (isExpired) {
      return Container(
        padding: const EdgeInsets.all(AppDimensions.space20),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppDimensions.radius12),
          border: Border.all(color: AppColors.error, width: 1.5),
        ),
        child: Column(
          children: [
            const Icon(Icons.timer_off_outlined, color: AppColors.error, size: 54),
            const SizedBox(height: AppDimensions.space12),
            const Text(
              'Mã QR đã hết hạn!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppDimensions.space6),
            const Text(
              'Đơn hàng đã quá hạn 15 phút và được tự động hủy để hoàn trả tồn kho. Quý khách vui lòng đặt lại đơn mới.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    // Trường hợp 3: Đang chờ quét mã
    return Column(
      children: [
        // Khung hiển thị mã QR VietQR
        Container(
          padding: const EdgeInsets.all(AppDimensions.space16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radius12),
            border: Border.all(color: AppColors.primary, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radius8),
                child: Image.network(
                  vietQrUrl,
                  width: 220,
                  height: 220,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return SizedBox(
                      width: 220,
                      height: 220,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback sang QrImageView cục bộ nếu máy không có mạng ngoài
                    return QrImageView(
                      data: fallbackPayload,
                      version: QrVersions.auto,
                      size: 200.0,
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(8),
                    );
                  },
                ),
              ),
              if (remainingTime != null) ...[
                const SizedBox(height: AppDimensions.space10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space12,
                    vertical: AppDimensions.space6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppDimensions.radius8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Thời gian quét mã: ${_formatDuration(remainingTime!)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.space8),
        const Text(
          'Quét bằng App Ngân hàng hoặc ví MoMo để tự động điền thông tin',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.space16),

        // Khung chi tiết thông tin chuyển khoản kèm nút sao chép
        Container(
          padding: const EdgeInsets.all(AppDimensions.space16),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppDimensions.radius12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.account_balance, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Thông tin chuyển khoản',
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Divider(height: AppDimensions.space16),

              _buildCopyRow(
                context,
                label: 'Ngân hàng:',
                value: activeBankName,
                copyText: activeBankName,
                showCopy: false,
              ),
              const SizedBox(height: AppDimensions.space8),

              _buildCopyRow(
                context,
                label: 'Số tài khoản:',
                value: activeAccountNumber,
                copyText: activeAccountNumber,
                isBold: true,
                showCopy: true,
              ),
              const SizedBox(height: AppDimensions.space8),

              _buildCopyRow(
                context,
                label: 'Chủ tài khoản:',
                value: activeAccountHolder,
                copyText: activeAccountHolder,
                showCopy: false,
              ),
              const SizedBox(height: AppDimensions.space8),

              _buildCopyRow(
                context,
                label: 'Số tiền:',
                value: CurrencyFormatter.format(totalAmount),
                copyText: totalAmount.toString(),
                isHighlight: true,
                showCopy: true,
              ),
              const Divider(height: AppDimensions.space16),

              _buildCopyRow(
                context,
                label: 'Nội dung CK:',
                value: orderCode,
                copyText: orderCode,
                isBold: true,
                isHighlight: true,
                showCopy: true,
              ),
              const SizedBox(height: AppDimensions.space8),

              Container(
                padding: const EdgeInsets.all(AppDimensions.space8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(AppDimensions.radius8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Vui lòng giữ nguyên nội dung chuyển khoản để đơn hàng được tự động kích hoạt ngay lập tức.',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.primary.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCopyRow(
    BuildContext context, {
    required String label,
    required String value,
    required String copyText,
    bool isBold = false,
    bool isHighlight = false,
    bool showCopy = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(width: AppDimensions.space12),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: (isBold || isHighlight) ? FontWeight.bold : FontWeight.normal,
                    color: isHighlight ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              ),
              if (showCopy) ...[
                const SizedBox(width: 6),
                InkWell(
                  onTap: () => _copyToClipboard(context, copyText, label.replaceAll(':', '')),
                  borderRadius: BorderRadius.circular(AppDimensions.radius4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppDimensions.radius4),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy_rounded, size: 12, color: AppColors.primary),
                        SizedBox(width: 3),
                        Text(
                          'Sao chép',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
