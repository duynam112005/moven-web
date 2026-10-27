import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moven/core/network/supabase_client.dart';
import 'package:moven/features/reviews/data/reviews_repository.dart';
import 'package:moven/features/reviews/domain/models/product_rating_summary.dart';
import 'package:moven/features/reviews/domain/models/review.dart';
import 'package:moven/features/reviews/domain/models/review_eligibility.dart';
import 'package:moven/features/reviews/domain/models/review_report.dart';

/// Provider cung cấp ReviewsRepository
final reviewsRepositoryProvider = Provider<ReviewsRepository>((ref) {
  try {
    final client = ref.watch(supabaseClientProvider);
    return ReviewsRepository(client);
  } catch (_) {
    return ReviewsRepository();
  }
});

// ==========================================
// CUSTOMER PROVIDERS
// ==========================================

/// Provider danh sách đánh giá công khai cho một sản phẩm (mới nhất trước)
final productReviewsProvider =
    FutureProvider.family<List<Review>, String>((ref, productId) async {
  final repo = ref.watch(reviewsRepositoryProvider);
  return repo.getProductReviews(productId);
});

/// Provider thống kê điểm sao và số lượng đánh giá của một sản phẩm
final productRatingSummaryProvider =
    FutureProvider.family<ProductRatingSummary, String>((ref, productId) async {
  final repo = ref.watch(reviewsRepositoryProvider);
  return repo.getProductRatingSummary(productId);
});

/// Provider kiểm tra điều kiện đánh giá của khách hàng hiện hành
final reviewEligibilityProvider =
    FutureProvider.family<ReviewEligibility, String>((ref, productId) async {
  final repo = ref.watch(reviewsRepositoryProvider);
  return repo.checkEligibility(productId);
});

/// Provider bộ lọc sao cho danh sách đánh giá tại trang chi tiết (0 = Tất cả)
final reviewStarFilterProvider =
    StateProvider.family<int, String>((ref, productId) => 0);

/// Provider danh sách đánh giá sau khi áp dụng bộ lọc sao phía client
final filteredProductReviewsProvider =
    Provider.family<List<Review>, String>((ref, productId) {
  final reviewsAsync = ref.watch(productReviewsProvider(productId));
  final starFilter = ref.watch(reviewStarFilterProvider(productId));

  final list = reviewsAsync.value ?? [];
  if (starFilter == 0) return list;
  return list.where((r) => r.rating == starFilter).toList();
});

// ==========================================
// ADMIN PROVIDERS
// ==========================================

/// Bộ lọc cho bảng quản lý đánh giá Admin
class AdminReviewsFilterState {
  final String searchQuery;
  final int? ratingFilter;
  final bool? isHiddenFilter;

  const AdminReviewsFilterState({
    this.searchQuery = '',
    this.ratingFilter,
    this.isHiddenFilter,
  });

  AdminReviewsFilterState copyWith({
    String? searchQuery,
    int? Function()? ratingFilter,
    bool? Function()? isHiddenFilter,
  }) {
    return AdminReviewsFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      ratingFilter:
          ratingFilter != null ? ratingFilter() : this.ratingFilter,
      isHiddenFilter:
          isHiddenFilter != null ? isHiddenFilter() : this.isHiddenFilter,
    );
  }
}

final adminReviewsFilterProvider =
    StateProvider<AdminReviewsFilterState>((ref) {
  return const AdminReviewsFilterState();
});

/// Provider danh sách toàn bộ đánh giá cho Admin
final adminReviewsProvider = FutureProvider<List<Review>>((ref) async {
  final repo = ref.watch(reviewsRepositoryProvider);
  final filter = ref.watch(adminReviewsFilterProvider);

  return repo.getAdminReviews(
    searchQuery: filter.searchQuery,
    ratingFilter: filter.ratingFilter,
    isHiddenFilter: filter.isHiddenFilter,
  );
});

/// Bộ lọc trạng thái báo cáo Admin (all, pending, reviewed, dismissed)
final adminReportsStatusFilterProvider =
    StateProvider<String>((ref) => 'pending');

/// Provider danh sách báo cáo vi phạm cho Admin
final adminReportsProvider = FutureProvider<List<ReviewReport>>((ref) async {
  final repo = ref.watch(reviewsRepositoryProvider);
  final status = ref.watch(adminReportsStatusFilterProvider);

  return repo.getAdminReports(
    statusFilter: status == 'all' ? null : status,
  );
});

// ==========================================
// ACTION CONTROLLER
// ==========================================

/// Controller xử lý thao tác gửi đánh giá, báo cáo và kiểm duyệt Admin
class ReviewActionController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  ReviewActionController(this._ref) : super(const AsyncValue.data(null));

  /// Khách hàng gửi đánh giá sản phẩm
  Future<bool> submitReview({
    required String productId,
    required int rating,
    String? comment,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repo = _ref.read(reviewsRepositoryProvider);
      await repo.submitReview(
        productId: productId,
        rating: rating,
        comment: comment,
      );

      // Invalidate relevant providers to refresh UI smoothly
      _ref.invalidate(productReviewsProvider(productId));
      _ref.invalidate(productRatingSummaryProvider(productId));
      _ref.invalidate(reviewEligibilityProvider(productId));
      _ref.invalidate(adminReviewsProvider);

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Khách hàng báo cáo đánh giá vi phạm
  Future<bool> reportReview({
    required String reviewId,
    required String reason,
    String? details,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repo = _ref.read(reviewsRepositoryProvider);
      await repo.reportReview(
        reviewId: reviewId,
        reason: reason,
        details: details,
      );

      _ref.invalidate(adminReportsProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Admin kiểm duyệt đánh giá (hide / unhide / dismiss)
  Future<bool> adminModerate({
    required String reviewId,
    required String action,
    String? reason,
    String? reportId,
    String? productId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repo = _ref.read(reviewsRepositoryProvider);
      await repo.adminModerateReview(
        reviewId: reviewId,
        action: action,
        reason: reason,
        reportId: reportId,
      );

      // Invalidate admin and public providers
      _ref.invalidate(adminReviewsProvider);
      _ref.invalidate(adminReportsProvider);
      if (productId != null) {
        _ref.invalidate(productReviewsProvider(productId));
        _ref.invalidate(productRatingSummaryProvider(productId));
      }

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final reviewActionControllerProvider =
    StateNotifierProvider<ReviewActionController, AsyncValue<void>>((ref) {
  return ReviewActionController(ref);
});
