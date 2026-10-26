import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moven/core/constants/app_colors.dart';
import 'package:moven/core/constants/app_dimensions.dart';
import 'package:moven/core/constants/app_typography.dart';
import 'package:moven/features/reviews/domain/models/review.dart';
import 'rating_stars.dart';

/// Thẻ đánh giá sản phẩm của khách hàng với huy hiệu "Đã mua hàng"
/// và nút cờ báo cáo vi phạm
class ReviewItemCard extends StatefulWidget {
  final Review review;
  final VoidCallback? onReport;

  const ReviewItemCard({
    super.key,
    required this.review,
    this.onReport,
  });

  @override
  State<ReviewItemCard> createState() => _ReviewItemCardState();
}

class _ReviewItemCardState extends State<ReviewItemCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
    final dateStr = DateFormat('dd/MM/yyyy').format(review.createdAt);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(AppDimensions.space16),
        decoration: BoxDecoration(
          color: _isHovered
              ? AppColors.surfaceVariant.withValues(alpha: 0.5)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radius12),
          border: Border.all(
            color: _isHovered ? AppColors.border : Colors.transparent,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar + Name + Badge + Date
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    review.userName.isNotEmpty
                        ? review.userName[0].toUpperCase()
                        : 'K',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.space12),

                // Name + Badge + Variant
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              review.maskedUserName,
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.space8),
                          // "Đã mua hàng" badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusRound,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified,
                                  size: 11,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'Đã mua hàng',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      // Variant label + Date
                      Row(
                        children: [
                          if (review.variantLabel != null) ...[
                            Flexible(
                              child: Text(
                                review.variantLabel!,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              ' • ',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                          Text(
                            dateStr,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Report button (visible on hover)
                if (widget.onReport != null)
                  AnimatedOpacity(
                    opacity: _isHovered ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: IconButton(
                      icon: const Icon(
                        Icons.flag_outlined,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                      tooltip: 'Báo cáo đánh giá này',
                      onPressed: widget.onReport,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: AppDimensions.space8),

            // Star rating
            RatingStars.small(rating: review.rating.toDouble()),

            // Comment text
            if (review.hasComment) ...[
              const SizedBox(height: AppDimensions.space8),
              Text(
                review.comment!,
                style: AppTypography.bodyMedium.copyWith(height: 1.6),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
