import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_typography.dart';
import 'app_button.dart';

/// Widget hiển thị trạng thái lỗi kèm nút "Thử lại" (Retry) cho các màn hình
class ErrorStateView extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final String retryLabel;

  const ErrorStateView({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.retryLabel = 'Thử lại',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.space16),
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppDimensions.space16),
            Text(
              title ?? 'Đã xảy ra lỗi',
              style: AppTypography.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.space8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Text(
                message,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.space24),
              AppButton(
                label: retryLabel,
                icon: const Icon(Icons.refresh, size: 18),
                onPressed: onRetry,
                variant: AppButtonVariant.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
