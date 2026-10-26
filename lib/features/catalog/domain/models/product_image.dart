import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_image.freezed.dart';
part 'product_image.g.dart';

/// Model ảnh sản phẩm ánh xạ bảng `product_images` trong Supabase.
@freezed
class ProductImage with _$ProductImage {
  const ProductImage._();

  const factory ProductImage({
    required String id,
    @JsonKey(name: 'product_id') required String productId,
    @JsonKey(name: 'variant_id') String? variantId,
    @JsonKey(name: 'image_path') required String imagePath,
    @JsonKey(name: 'alt_text') String? altText,
    @JsonKey(name: 'sort_order', defaultValue: 0) required int sortOrder,
    @JsonKey(name: 'is_primary', defaultValue: false) required bool isPrimary,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _ProductImage;

  factory ProductImage.fromJson(Map<String, dynamic> json) =>
      _$ProductImageFromJson(json);

  Map<String, dynamic> toInsertJson() => {
        'product_id': productId,
        if (variantId != null) 'variant_id': variantId,
        'image_path': imagePath,
        if (altText != null) 'alt_text': altText,
        'sort_order': sortOrder,
        'is_primary': isPrimary,
      };

  Map<String, dynamic> toUpdateJson() => {
        if (variantId != null) 'variant_id': variantId,
        'image_path': imagePath,
        'alt_text': altText,
        'sort_order': sortOrder,
        'is_primary': isPrimary,
      };
}
