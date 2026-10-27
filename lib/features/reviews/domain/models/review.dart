import 'package:freezed_annotation/freezed_annotation.dart';

part 'review.freezed.dart';
part 'review.g.dart';

/// Thực thể Đánh giá sản phẩm trong MOVEN (Freezed)
@freezed
class Review with _$Review {
  const Review._();

  const factory Review({
    required String id,
    @JsonKey(name: 'product_id') required String productId,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'user_name') @Default('Khách hàng MOVEN') String userName,
    @JsonKey(name: 'user_avatar') String? userAvatar,
    @JsonKey(name: 'order_item_id') String? orderItemId,
    @JsonKey(name: 'order_code') String? orderCode,
    @JsonKey(name: 'variant_label') String? variantLabel,
    required int rating,
    String? comment,
    @JsonKey(name: 'is_hidden') @Default(false) bool isHidden,
    @JsonKey(name: 'hidden_reason') String? hiddenReason,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Review;

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);

  /// Tên khách hàng hiển thị an toàn (Ví dụ: "Nguyễn V***")
  String get maskedUserName {
    final trimmed = userName.trim();
    if (trimmed.isEmpty || trimmed == 'Khách hàng MOVEN') {
      return 'Khách hàng MOVEN';
    }
    final parts = trimmed.split(' ');
    if (parts.length == 1) {
      if (parts[0].length <= 2) return parts[0];
      return '${parts[0].substring(0, 2)}***';
    }
    final firstName = parts.first;
    final lastInitial = parts.last.isNotEmpty ? parts.last[0] : '';
    return '$firstName $lastInitial***';
  }

  /// Kiểm tra có nhận xét bằng chữ hay không
  bool get hasComment => comment != null && comment!.trim().isNotEmpty;
}
