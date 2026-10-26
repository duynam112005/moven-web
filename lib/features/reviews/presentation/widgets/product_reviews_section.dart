import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moven/core/constants/app_colors.dart';
import 'package:moven/core/constants/app_dimensions.dart';
import 'package:moven/core/constants/app_typography.dart';
import 'package:moven/core/router/route_names.dart';
import 'package:moven/core/widgets/app_button.dart';
import 'package:moven/core/widgets/app_loading.dart';
import 'package:moven/features/reviews/presentation/providers/reviews_providers.dart';
import 'rating_stars.dart';
import 'report_review_dialog.dart';
import 'review_item_card.dart';
import 'submit_review_dialog.dart';

/// Khối hiển thị toàn diện Đánh giá & Nhận xét của sản phẩm tại trang chi tiết
class ProductReviewsSection extends ConsumerWidget {
  final String productId;
  final String productName;

  const ProductReviewsSection({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(productRatingSummaryProvider(productId));
    final eligibilityAsync = ref.watch(reviewEligibilityProvider(productId));
    final reviews = ref.watch(filteredProductReviewsProvider(productId));
    final reviewsAsync = ref.watch(productReviewsProvider(productId));
    final selectedStar = ref.watch(reviewStarFilterProvider(productId));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(AppDimensions.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Đánh giá từ khách hàng',
                style: AppTypography.headlineMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              summaryAsync.maybeWhen(
                data: (summary) => Text(
                  '${summary.totalReviews} đánh giá',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.space20),

          // Rating Overview Card (Average + Star Distribution)
          summaryAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.space20),
                child: AppLoading(message: 'Đang tải thống kê đánh giá...'),
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (summary) => _buildRatingOverview(context, summary),
          ),

          const SizedBox(height: AppDimensions.space24),

          // Action & Filter Bar (Star chips + Write review button)
          _buildFilterAndActionBar(
            context,
            ref,
            selectedStar,
            eligibilityAsync.valueOrNull,
          ),

          const SizedBox(height: AppDimensions.space20),
          const Divider(color: AppColors.border),
          const SizedBox(height: AppDimensions.space12),

          // Reviews List / States
          reviewsAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.space24),
                child: AppLoading(message: 'Đang tải danh sách nhận xét...'),
              ),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.all(AppDimensions.space16),
              child: Text(
                'Không thể tải đánh giá: $err',
                style: const TextStyle(color: AppColors.error),
              ),
            ),
            data: (_) {
              if (reviews.isEmpty) {
                return _buildEmptyReviewsState(selectedStar);
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reviews.length,
                separatorBuilder: (_, __) =>
                    const Divider(color: AppColors.border, height: 1),
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  return ReviewItemCard(
                    review: review,
                    onReport: () => ReportReviewDialog.show(
                      context,
                      reviewId: review.id,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  /// Card tóm tắt điểm trung bình và phân bổ 5 cột sao
  Widget _buildRatingOverview(
    BuildContext context,
    dynamic summary,
  ) {
    final double avg = summary.averageRating as double;
    final int total = summary.totalReviews as int;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.space20),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 560;

          final scoreWidget = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                avg > 0 ? avg.toStringAsFixed(1) : '0.0',
                style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.space8),
              RatingStars(rating: avg, size: 20),
              const SizedBox(height: AppDimensions.space6),
              Text(
                '$total lượt đánh giá',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );

          final barsWidget = Column(
            children: List.generate(5, (index) {
              final star = 5 - index;
              final count = summary.countForStar(star) as int;
              final pct = summary.percentageForStar(star) as double;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    SizedBox(
                      width: 44,
                      child: Row(
                        children: [
                          Text(
                            '$star',
                            style: AppTypography.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Color(0xFFF59E0B),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusRound),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 7,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFF59E0B),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space12),
                    SizedBox(
                      width: 32,
                      child: Text(
                        '$count',
                        textAlign: TextAlign.end,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          );

          if (isNarrow) {
            return Column(
              children: [
                scoreWidget,
                const SizedBox(height: AppDimensions.space16),
                const Divider(color: AppColors.border),
                const SizedBox(height: AppDimensions.space12),
                barsWidget,
              ],
            );
          }

          return Row(
            children: [
              SizedBox(width: 160, child: scoreWidget),
              Container(
                height: 110,
                width: 1,
                color: AppColors.border,
                margin: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space20,
                ),
              ),
              Expanded(child: barsWidget),
            ],
          );
        },
      ),
    );
  }

  /// Thanh chọn lọc sao & nút "Viết đánh giá"
  Widget _buildFilterAndActionBar(
    BuildContext context,
    WidgetRef ref,
    int selectedStar,
    dynamic eligibility,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 640;

        final filterChips = SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildStarFilterChip(ref, 0, 'Tất cả', selectedStar == 0),
              const SizedBox(width: AppDimensions.space8),
              ...List.generate(5, (index) {
                final star = 5 - index;
                return Padding(
                  padding: const EdgeInsets.only(right: AppDimensions.space8),
                  child: _buildStarFilterChip(
                    ref,
                    star,
                    '$star sao',
                    selectedStar == star,
                  ),
                );
              }),
            ],
          ),
        );

        final writeButton = _buildWriteReviewButton(context, eligibility);

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              filterChips,
              const SizedBox(height: AppDimensions.space16),
              writeButton,
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: filterChips),
            const SizedBox(width: AppDimensions.space16),
            writeButton,
          ],
        );
      },
    );
  }

  Widget _buildStarFilterChip(
    WidgetRef ref,
    int star,
    String label,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () {
        ref.read(reviewStarFilterProvider(productId).notifier).state = star;
      },
      borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  /// Nút viết đánh giá theo điều kiện nghiệp vụ
  Widget _buildWriteReviewButton(
    BuildContext context,
    dynamic eligibility,
  ) {
    // 1. Chưa đăng nhập
    if (eligibility != null && !eligibility.isAuthenticated) {
      return OutlinedButton.icon(
        icon: const Icon(Icons.login_rounded, size: 16),
        label: const Text('Đăng nhập để đánh giá'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radius8),
          ),
        ),
        onPressed: () => context.push(RouteNames.loginPath),
      );
    }

    // 2. Đã đánh giá rồi (1 review / user / product - D-13)
    if (eligibility != null && eligibility.hasReviewed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radius8),
          border: Border.all(
            color: AppColors.success.withValues(alpha: 0.3),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, size: 16, color: AppColors.success),
            SizedBox(width: 6),
            Text(
              'Bạn đã đánh giá sản phẩm này',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      );
    }

    // 3. Đủ điều kiện (Đã mua và nhận hàng thành công)
    if (eligibility != null && eligibility.isEligible) {
      return AppButton(
        label: 'Viết đánh giá',
        icon: const Icon(Icons.rate_review_outlined, size: 18),
        height: 40,
        onPressed: () => SubmitReviewDialog.show(
          context,
          productId: productId,
          productName: productName,
        ),
      );
    }

    // 4. Chưa mua hoặc đơn chưa delivered
    return Tooltip(
      message:
          'Chỉ khách hàng đã nhận hàng thành công (đơn giao hoàn tất) mới có thể gửi đánh giá.',
      child: OutlinedButton.icon(
        icon: const Icon(Icons.lock_outline, size: 16, color: AppColors.textMuted),
        label: Text(
          'Viết đánh giá',
          style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.8)),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radius8),
          ),
        ),
        onPressed: null,
      ),
    );
  }

  Widget _buildEmptyReviewsState(int selectedStar) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.space32),
        child: Column(
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 48,
              color: AppColors.textMuted.withValues(alpha: 0.6),
            ),
            const SizedBox(height: AppDimensions.space12),
            Text(
              selectedStar > 0
                  ? 'Chưa có đánh giá nào cho $selectedStar sao'
                  : 'Chưa có đánh giá nào cho sản phẩm này',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Hãy là người đầu tiên trải nghiệm và chia sẻ cảm nhận!',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
