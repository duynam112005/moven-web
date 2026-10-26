import 'package:flutter_test/flutter_test.dart';
import 'package:moven/features/reviews/data/reviews_repository.dart';

void main() {
  group('ReviewsRepository Tests (Mock Mode)', () {
    late ReviewsRepository repo;

    setUp(() {
      repo = ReviewsRepository();
    });

    test('getProductReviews returns only visible reviews sorted by date desc', () async {
      final reviews = await repo.getProductReviews('prod-001');

      expect(reviews, isNotEmpty);
      // All reviews returned must be visible (isHidden == false)
      for (final r in reviews) {
        expect(r.isHidden, isFalse);
        expect(r.productId, 'prod-001');
      }

      // Check sorting: newer first
      for (int i = 0; i < reviews.length - 1; i++) {
        expect(
          reviews[i].createdAt.isAfter(reviews[i + 1].createdAt) ||
              reviews[i].createdAt.isAtSameMomentAs(reviews[i + 1].createdAt),
          isTrue,
        );
      }
    });

    test('getProductRatingSummary computes valid average and star counts', () async {
      final summary = await repo.getProductRatingSummary('prod-001');

      expect(summary.productId, 'prod-001');
      expect(summary.totalReviews, greaterThan(0));
      expect(summary.averageRating, inInclusiveRange(1.0, 5.0));
      expect(summary.countForStar(5), greaterThanOrEqualTo(0));
    });

    test('checkEligibility handles mock user check', () async {
      final eligibility = await repo.checkEligibility('prod-001');

      expect(eligibility.isAuthenticated, isTrue);
      // In mock mode, usr-current is eligible
      expect(eligibility.isEligible, isTrue);
      expect(eligibility.reason, 'ELIGIBLE');
    });

    test('submitReview adds review to repository', () async {
      final result = await repo.submitReview(
        productId: 'prod-001',
        rating: 5,
        comment: 'Áo tuyệt vời!',
      );

      expect(result['success'], isTrue);
      expect(result['review_id'], isNotNull);

      final reviews = await repo.getProductReviews('prod-001');
      final newRev = reviews.firstWhere((r) => r.id == result['review_id']);
      expect(newRev.comment, 'Áo tuyệt vời!');
      expect(newRev.rating, 5);
    });

    test('reportReview creates new pending report', () async {
      final result = await repo.reportReview(
        reviewId: 'rev-001',
        reason: 'spam',
        details: 'Nội dung spam quảng cáo',
      );

      expect(result['success'], isTrue);

      final reports = await repo.getAdminReports(statusFilter: 'pending');
      expect(reports.any((rep) => rep.reviewId == 'rev-001'), isTrue);
    });

    test('adminModerateReview hides review and updates report status', () async {
      // 1. Hide review
      final hideRes = await repo.adminModerateReview(
        reviewId: 'rev-002',
        action: 'hide',
        reason: 'Nội dung không phù hợp',
      );
      expect(hideRes['success'], isTrue);

      // Verify it is no longer in public reviews
      final publicReviews = await repo.getProductReviews('prod-001');
      expect(publicReviews.any((r) => r.id == 'rev-002'), isFalse);

      // 2. Unhide review
      final unhideRes = await repo.adminModerateReview(
        reviewId: 'rev-002',
        action: 'unhide',
      );
      expect(unhideRes['success'], isTrue);

      // Verify it is back in public reviews
      final restoredReviews = await repo.getProductReviews('prod-001');
      expect(restoredReviews.any((r) => r.id == 'rev-002'), isTrue);
    });

    test('getAdminReviews supports search and rating filtering', () async {
      final allReviews = await repo.getAdminReviews();
      expect(allReviews, isNotEmpty);

      final fiveStarReviews = await repo.getAdminReviews(ratingFilter: 5);
      for (final r in fiveStarReviews) {
        expect(r.rating, 5);
      }

      final searchReviews = await repo.getAdminReviews(searchQuery: 'cotton');
      expect(searchReviews, isNotEmpty);
    });
  });
}
