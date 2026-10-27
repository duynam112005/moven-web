import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moven/core/constants/app_colors.dart';
import 'package:moven/core/constants/app_dimensions.dart';
import 'package:moven/core/constants/app_typography.dart';
import 'package:moven/features/reviews/presentation/providers/reviews_providers.dart';
import 'rating_stars.dart';

/// Modal viết đánh giá sản phẩm với sao tương tác và bộ đếm ký tự
class SubmitReviewDialog extends ConsumerStatefulWidget {
  final String productId;
  final String productName;

  const SubmitReviewDialog({
    super.key,
    required this.productId,
    required this.productName,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String productId,
    required String productName,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SubmitReviewDialog(
        productId: productId,
        productName: productName,
      ),
    );
  }

  @override
  ConsumerState<SubmitReviewDialog> createState() =>
      _SubmitReviewDialogState();
}

class _SubmitReviewDialogState extends ConsumerState<SubmitReviewDialog>
    with SingleTickerProviderStateMixin {
  int _selectedRating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  static const int _maxCommentLength = 1000;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    );
    _scaleController.forward();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  String get _ratingLabel {
    switch (_selectedRating) {
      case 1:
        return 'Rất không hài lòng 😞';
      case 2:
        return 'Không hài lòng 😕';
      case 3:
        return 'Bình thường 😐';
      case 4:
        return 'Hài lòng 😊';
      case 5:
        return 'Rất hài lòng 🤩';
      default:
        return 'Chọn số sao đánh giá';
    }
  }

  Future<void> _handleSubmit() async {
    if (_selectedRating == 0) return;

    setState(() => _isSubmitting = true);

    final success = await ref
        .read(reviewActionControllerProvider.notifier)
        .submitReview(
          productId: widget.productId,
          rating: _selectedRating,
          comment: _commentController.text.trim().isEmpty
              ? null
              : _commentController.text.trim(),
        );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.success,
          content: Text('🎉 Đánh giá của bạn đã được gửi thành công!'),
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
                'Có lỗi xảy ra khi gửi đánh giá.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentLength = _commentController.text.length;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius16),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.space24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(Icons.rate_review_rounded,
                        color: AppColors.primary, size: 24),
                    const SizedBox(width: AppDimensions.space8),
                    Expanded(
                      child: Text(
                        'Đánh giá sản phẩm',
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
                  widget.productName,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: AppDimensions.space24),

                // Star rating picker
                Center(
                  child: Column(
                    children: [
                      RatingStars.interactive(
                        rating: _selectedRating.toDouble(),
                        onRatingChanged: (rating) {
                          setState(() => _selectedRating = rating);
                        },
                      ),
                      const SizedBox(height: AppDimensions.space8),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          _ratingLabel,
                          key: ValueKey(_selectedRating),
                          style: AppTypography.bodyMedium.copyWith(
                            color: _selectedRating > 0
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                            fontWeight: _selectedRating > 0
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.space20),

                // Comment input
                TextField(
                  controller: _commentController,
                  maxLines: 4,
                  maxLength: _maxCommentLength,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText:
                        'Chia sẻ trải nghiệm của bạn về sản phẩm... (tùy chọn)',
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
                    contentPadding: const EdgeInsets.all(AppDimensions.space12),
                    counterText:
                        '$commentLength / $_maxCommentLength',
                    counterStyle: AppTypography.bodySmall.copyWith(
                      color: commentLength > 900
                          ? AppColors.warning
                          : AppColors.textMuted,
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.space20),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            _isSubmitting ? null : () => Navigator.of(context).pop(),
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
                        onPressed: (_selectedRating > 0 && !_isSubmitting)
                            ? _handleSubmit
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
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
                                  color: AppColors.onPrimary,
                                ),
                              )
                            : const Text('Gửi đánh giá'),
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
