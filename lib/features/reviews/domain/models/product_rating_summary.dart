import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_rating_summary.freezed.dart';
part 'product_rating_summary.g.dart';

/// Thống kê đánh giá của một sản phẩm (Freezed)
@freezed
class ProductRatingSummary with _$ProductRatingSummary {
  const ProductRatingSummary._();

  const factory ProductRatingSummary({
    @JsonKey(name: 'product_id') required String productId,
    @JsonKey(name: 'total_reviews') @Default(0) int totalReviews,
    @JsonKey(name: 'average_rating') @Default(0.0) double averageRating,
    @JsonKey(name: 'counts') @Default({}) Map<String, int> counts,
  }) = _ProductRatingSummary;

  factory ProductRatingSummary.fromJson(Map<String, dynamic> json) =>
      _$ProductRatingSummaryFromJson(json);

  /// Lấy số lượng đánh giá theo số sao (1..5)
  int countForStar(int star) => counts['$star'] ?? 0;

  /// Lấy tỷ lệ phần trăm theo số sao (0.0 .. 1.0)
  double percentageForStar(int star) {
    if (totalReviews == 0) return 0.0;
    return countForStar(star) / totalReviews;
  }
}
