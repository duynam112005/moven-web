import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_variant.freezed.dart';
part 'product_variant.g.dart';

/// Model biến thể sản phẩm ánh xạ bảng `product_variants` trong Supabase.
///
/// `price` (VND, integer) là nguồn giá duy nhất có thẩm quyền theo DATABASE_SPEC.
@freezed
class ProductVariant with _$ProductVariant {
  const ProductVariant._();

  const factory ProductVariant({
    required String id,
    @JsonKey(name: 'product_id') required String productId,
    required String sku,
    String? size,
    @JsonKey(name: 'color_name') String? colorName,
    @JsonKey(name: 'color_hex') String? colorHex,
    required int price,
    @JsonKey(name: 'compare_at_price') int? compareAtPrice,
    @JsonKey(name: 'stock_quantity', defaultValue: 0)
    required int stockQuantity,
    @JsonKey(name: 'is_active', defaultValue: true) required bool isActive,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _ProductVariant;

  factory ProductVariant.fromJson(Map<String, dynamic> json) =>
      _$ProductVariantFromJson(json);

  /// Có hàng trong kho hay không
  bool get inStock => stockQuantity > 0 && isActive;

  /// Có giảm giá so sánh hay không
  bool get hasDiscount => compareAtPrice != null && compareAtPrice! > price;

  /// Phần trăm giảm giá (0–100)
  int get discountPercent {
    if (!hasDiscount || compareAtPrice! == 0) return 0;
    return (((compareAtPrice! - price) / compareAtPrice!) * 100).round();
  }

  /// Nhãn hiển thị kết hợp size và màu (ví dụ: "L / Đen")
  String get displayLabel {
    final parts = <String>[];
    if (size != null && size!.isNotEmpty) parts.add(size!);
    if (colorName != null && colorName!.isNotEmpty) parts.add(colorName!);
    return parts.isEmpty ? sku : parts.join(' / ');
  }

  Map<String, dynamic> toInsertJson() => {
        'product_id': productId,
        'sku': sku,
        if (size != null) 'size': size,
        if (colorName != null) 'color_name': colorName,
        if (colorHex != null) 'color_hex': colorHex,
        'price': price,
        if (compareAtPrice != null) 'compare_at_price': compareAtPrice,
        'stock_quantity': stockQuantity,
        'is_active': isActive,
      };

  Map<String, dynamic> toUpdateJson() => {
        'sku': sku,
        'size': size,
        'color_name': colorName,
        'color_hex': colorHex,
        'price': price,
        'compare_at_price': compareAtPrice,
        'stock_quantity': stockQuantity,
        'is_active': isActive,
      };
}
