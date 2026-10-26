import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_eligibility.freezed.dart';
part 'review_eligibility.g.dart';

/// Kết quả kiểm tra điều kiện đánh giá của khách hàng (Freezed)
@freezed
class ReviewEligibility with _$ReviewEligibility {
  const ReviewEligibility._();

  const factory ReviewEligibility({
    @JsonKey(name: 'is_authenticated') @Default(false) bool isAuthenticated,
    @JsonKey(name: 'is_eligible') @Default(false) bool isEligible,
    @JsonKey(name: 'has_reviewed') @Default(false) bool hasReviewed,
    @Default('UNAUTHENTICATED') String reason,
    @Default('') String message,
    @JsonKey(name: 'order_item_id') String? orderItemId,
    @JsonKey(name: 'order_code') String? orderCode,
    @JsonKey(name: 'size_snapshot') String? sizeSnapshot,
    @JsonKey(name: 'color_snapshot') String? colorSnapshot,
  }) = _ReviewEligibility;

  factory ReviewEligibility.fromJson(Map<String, dynamic> json) =>
      _$ReviewEligibilityFromJson(json);

  String? get variantLabel {
    final parts = <String>[];
    if (sizeSnapshot != null && sizeSnapshot!.isNotEmpty) {
      parts.add('Size $sizeSnapshot');
    }
    if (colorSnapshot != null && colorSnapshot!.isNotEmpty) {
      parts.add('Màu $colorSnapshot');
    }
    return parts.isEmpty ? null : parts.join(' • ');
  }
}
