import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';
part 'category.g.dart';

/// Model danh mục sản phẩm ánh xạ bảng `categories` trong Supabase.
@freezed
class Category with _$Category {
  const Category._();

  const factory Category({
    required String id,
    required String name,
    required String slug,
    String? description,
    @JsonKey(name: 'image_path') String? imagePath,
    @JsonKey(name: 'is_active', defaultValue: true) required bool isActive,
    @JsonKey(name: 'sort_order', defaultValue: 0) required int sortOrder,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toInsertJson() => {
        'name': name,
        'slug': slug,
        if (description != null) 'description': description,
        if (imagePath != null) 'image_path': imagePath,
        'is_active': isActive,
        'sort_order': sortOrder,
      };

  Map<String, dynamic> toUpdateJson() => {
        'name': name,
        'slug': slug,
        'description': description,
        'image_path': imagePath,
        'is_active': isActive,
        'sort_order': sortOrder,
      };
}
