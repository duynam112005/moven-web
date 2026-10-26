import 'package:flutter_test/flutter_test.dart';
import 'package:moven/features/reviews/domain/models/product_rating_summary.dart';
import 'package:moven/features/reviews/domain/models/review.dart';
import 'package:moven/features/reviews/domain/models/review_eligibility.dart';
import 'package:moven/features/reviews/domain/models/review_report.dart';

void main() {
  group('Review Domain Model Tests', () {
    test('maskedUserName masks full name correctly', () {
      final r1 = Review(
        id: 'rev-1',
        productId: 'prod-1',
        userId: 'usr-1',
        userName: 'Nguyễn Văn An',
        rating: 5,
        createdAt: DateTime.now(),
      );
      expect(r1.maskedUserName, 'Nguyễn A***');

      final r2 = Review(
        id: 'rev-2',
        productId: 'prod-1',
        userId: 'usr-2',
        userName: 'Hoàng',
        rating: 4,
        createdAt: DateTime.now(),
      );
      expect(r2.maskedUserName, 'Ho***');

      final r3 = Review(
        id: 'rev-3',
        productId: 'prod-1',
        userId: 'usr-3',
        userName: 'Khách hàng MOVEN',
        rating: 5,
        createdAt: DateTime.now(),
      );
      expect(r3.maskedUserName, 'Khách hàng MOVEN');
    });

    test('hasComment returns true only when comment is non-empty', () {
      final rWithComment = Review(
        id: 'rev-1',
        productId: 'prod-1',
        userId: 'usr-1',
        rating: 5,
        comment: 'Áo rất đẹp',
        createdAt: DateTime.now(),
      );
      expect(rWithComment.hasComment, isTrue);

      final rWithoutComment = Review(
        id: 'rev-2',
        productId: 'prod-1',
        userId: 'usr-2',
        rating: 5,
        comment: null,
        createdAt: DateTime.now(),
      );
      expect(rWithoutComment.hasComment, isFalse);

      final rEmptyComment = Review(
        id: 'rev-3',
        productId: 'prod-1',
        userId: 'usr-3',
        rating: 5,
        comment: '   ',
        createdAt: DateTime.now(),
      );
      expect(rEmptyComment.hasComment, isFalse);
    });
  });

  group('ReviewReport Domain Model Tests', () {
    test('reasonDisplayName returns localized text', () {
      final repSpam = ReviewReport(
        id: 'rep-1',
        reviewId: 'rev-1',
        reporterId: 'usr-1',
        reason: 'spam',
        createdAt: DateTime.now(),
      );
      expect(repSpam.reasonDisplayName, 'Spam / Quảng cáo');

      final repFake = ReviewReport(
        id: 'rep-2',
        reviewId: 'rev-2',
        reporterId: 'usr-2',
        reason: 'fake',
        createdAt: DateTime.now(),
      );
      expect(repFake.reasonDisplayName, 'Nội dung sai sự thật / Đánh giá giả');

      final repOther = ReviewReport(
        id: 'rep-3',
        reviewId: 'rev-3',
        reporterId: 'usr-3',
        reason: 'other',
        createdAt: DateTime.now(),
      );
      expect(repOther.reasonDisplayName, 'Lý do khác');
    });

    test('ReviewReport properties and status helpers work correctly', () {
      final rep = ReviewReport(
        id: 'rep-1',
        reviewId: 'rev-1',
        reporterId: 'usr-1',
        reason: 'inappropriate',
        status: 'pending',
        createdAt: DateTime.now(),
      );

      expect(rep.reasonDisplayName, 'Ngôn từ phản cảm / Thô tục');
      expect(rep.statusDisplayName, 'Chờ xử lý');
      expect(rep.isPending, isTrue);

      final reviewed = rep.copyWith(status: 'reviewed');
      expect(reviewed.statusDisplayName, 'Đã xử lý (Đã ẩn)');
      expect(reviewed.isPending, isFalse);

      final dismissed = rep.copyWith(status: 'dismissed');
      expect(dismissed.statusDisplayName, 'Đã bỏ qua');
      expect(dismissed.isPending, isFalse);
    });
  });

  group('ProductRatingSummary Domain Model Tests', () {
    test('countForStar and percentageForStar calculate correctly', () {
      const summary = ProductRatingSummary(
        productId: 'prod-1',
        totalReviews: 10,
        averageRating: 4.5,
        counts: {'5': 6, '4': 3, '3': 1, '2': 0, '1': 0},
      );

      expect(summary.countForStar(5), 6);
      expect(summary.countForStar(4), 3);
      expect(summary.countForStar(2), 0);

      expect(summary.percentageForStar(5), 0.6);
      expect(summary.percentageForStar(4), 0.3);
      expect(summary.percentageForStar(1), 0.0);
    });

    test('percentageForStar handles zero totalReviews gracefully', () {
      const emptySummary = ProductRatingSummary(productId: 'prod-2');
      expect(emptySummary.percentageForStar(5), 0.0);
      expect(emptySummary.countForStar(5), 0);
    });
  });

  group('ReviewEligibility Domain Model Tests', () {
    test('variantLabel formats size and color snapshots', () {
      const eligible = ReviewEligibility(
        isAuthenticated: true,
        isEligible: true,
        sizeSnapshot: 'XL',
        colorSnapshot: 'Xanh Navy',
      );
      expect(eligible.variantLabel, 'Size XL • Màu Xanh Navy');

      const onlySize = ReviewEligibility(
        isAuthenticated: true,
        isEligible: true,
        sizeSnapshot: 'L',
      );
      expect(onlySize.variantLabel, 'Size L');

      const noVariant = ReviewEligibility(
        isAuthenticated: true,
        isEligible: true,
      );
      expect(noVariant.variantLabel, isNull);
    });
  });
}
