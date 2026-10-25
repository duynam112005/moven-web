import 'package:freezed_annotation/freezed_annotation.dart';

part 'banner.freezed.dart';
part 'banner.g.dart';

/// Model banner trang chủ ánh xạ bảng `banners` trong Supabase.
/// Đặt tên là HomeBanner để tránh xung đột với widget Banner của Flutter.
@freezed
class HomeBanner with _$HomeBanner {
  const HomeBanner._();

  const factory HomeBanner({
    required String id,
    required String title,
    String? subtitle,
    @JsonKey(name: 'image_path') required String imagePath,
    @JsonKey(name: 'link_type', defaultValue: 'none') required String linkType,
    @JsonKey(name: 'link_value') String? linkValue,
    @JsonKey(name: 'start_at') DateTime? startAt,
    @JsonKey(name: 'end_at') DateTime? endAt,
    @JsonKey(name: 'is_active', defaultValue: true) required bool isActive,
    @JsonKey(name: 'sort_order', defaultValue: 0) required int sortOrder,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _HomeBanner;

  factory HomeBanner.fromJson(Map<String, dynamic> json) =>
      _$HomeBannerFromJson(json);

  /// Banner có đang trong thời gian hiển thị hợp lệ hay không
  bool isCurrentlyVisible([DateTime? now]) {
    if (!isActive) return false;
    final current = now ?? DateTime.now();
    if (startAt != null && current.isBefore(startAt!)) return false;
    if (endAt != null && current.isAfter(endAt!)) return false;
    return true;
  }

  Map<String, dynamic> toInsertJson() => {
        'title': title,
        if (subtitle != null) 'subtitle': subtitle,
        'image_path': imagePath,
        'link_type': linkType,
        if (linkValue != null) 'link_value': linkValue,
        if (startAt != null) 'start_at': startAt!.toIso8601String(),
        if (endAt != null) 'end_at': endAt!.toIso8601String(),
        'is_active': isActive,
        'sort_order': sortOrder,
      };

  Map<String, dynamic> toUpdateJson() => {
        'title': title,
        'subtitle': subtitle,
        'image_path': imagePath,
        'link_type': linkType,
        'link_value': linkValue,
        'start_at': startAt?.toIso8601String(),
        'end_at': endAt?.toIso8601String(),
        'is_active': isActive,
        'sort_order': sortOrder,
      };
}
