import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moven/core/constants/app_colors.dart';
import 'package:moven/core/constants/app_dimensions.dart';
import 'package:moven/core/constants/app_typography.dart';
import 'package:moven/features/reviews/presentation/providers/reviews_providers.dart';

/// Modal báo cáo đánh giá vi phạm với danh sách lý do theo đặc tả
class ReportReviewDialog extends ConsumerStatefulWidget {
  final String reviewId;

  const ReportReviewDialog({
    super.key,
    required this.reviewId,
  });

  static Future<bool?> show(BuildContext context, {required String reviewId}) {
    return showDialog<bool>(
      context: context,
      builder: (_) => ReportReviewDialog(reviewId: reviewId),
    );
  }

  @override
  ConsumerState<ReportReviewDialog> createState() =>
      _ReportReviewDialogState();
}

class _ReportReviewDialogState extends ConsumerState<ReportReviewDialog> {
  String? _selectedReason;
  final _detailsController = TextEditingController();
  bool _isSubmitting = false;

  static const _reasons = [
    {'value': 'spam', 'label': 'Spam / Quảng cáo', 'icon': Icons.block},
    {
      'value': 'inappropriate',
      'label': 'Ngôn từ phản cảm / Thô tục',
      'icon': Icons.warning_amber_rounded,
    },
    {
      'value': 'fake',
      'label': 'Nội dung sai sự thật / Đánh giá giả',
      'icon': Icons.gpp_bad_outlined,
    },
    {
      'value': 'other',
      'label': 'Lý do khác',
      'icon': Icons.help_outline_rounded,
    },
  ];

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_selectedReason == null) return;

    setState(() => _isSubmitting = true);

    final success = await ref
        .read(reviewActionControllerProvider.notifier)
        .reportReview(
          reviewId: widget.reviewId,
          reason: _selectedReason!,
          details: _detailsController.text.trim().isEmpty
              ? null
              : _detailsController.text.trim(),
        );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.info,
          content: Text(
            'Cảm ơn bạn. Báo cáo đã được gửi tới quản trị viên để xem xét.',
          ),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text(
            ref.read(reviewActionControllerProvider).error?.toString() ??
                'Có lỗi xảy ra khi gửi báo cáo.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.flag_rounded,
                      color: AppColors.warning, size: 24),
                  const SizedBox(width: AppDimensions.space8),
                  Expanded(
                    child: Text(
                      'Báo cáo đánh giá vi phạm',
                      style: AppTypography.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.space4),
              Text(
                'Vui lòng chọn lý do bạn muốn báo cáo đánh giá này:',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: AppDimensions.space16),

              // Reason selection
              ...(_reasons.map((r) {
                final value = r['value'] as String;
                final label = r['label'] as String;
                final icon = r['icon'] as IconData;
                final isSelected = _selectedReason == value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.space8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radius8),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.04)
                          : Colors.transparent,
                    ),
                    child: RadioListTile<String>(
                      value: value,
                      groupValue: _selectedReason,
                      onChanged: (v) =>
                          setState(() => _selectedReason = v),
                      title: Row(
                        children: [
                          Icon(icon,
                              size: 18,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary),
                          const SizedBox(width: AppDimensions.space8),
                          Expanded(
                            child: Text(
                              label,
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                );
              })),

              const SizedBox(height: AppDimensions.space8),

              // Details input
              TextField(
                controller: _detailsController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Mô tả chi tiết (tùy chọn)',
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textMuted,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radius8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radius8),
                    borderSide: const BorderSide(
                        color: AppColors.borderFocused, width: 1.5),
                  ),
                  contentPadding:
                      const EdgeInsets.all(AppDimensions.space12),
                ),
              ),

              const SizedBox(height: AppDimensions.space20),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radius8),
                        ),
                      ),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          (_selectedReason != null && !_isSubmitting)
                              ? _handleSubmit
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warning,
                        foregroundColor: AppColors.onWarning,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radius8),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.onWarning,
                              ),
                            )
                          : const Text('Gửi báo cáo'),
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
