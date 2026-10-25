import 'package:freezed_annotation/freezed_annotation.dart';
import 'category.dart';
import 'product_image.dart';
import 'product_variant.dart';

part 'product.freezed.dart';
part 'product.g.dart';

Category? _categoryFromJson(dynamic val) {
  if (val is Map<String, dynamic>) {
    return Category.fromJson(val);
  }
  return null;
}

List<ProductVariant> _variantsFromJson(dynamic val) {
  if (val is List) {
    return val
        .whereType<Map<String, dynamic>>()
        .map((e) => ProductVariant.fromJson(e))
        .toList();
  }
  return const [];
}

List<ProductImage> _imagesFromJson(dynamic val) {
  if (val is List) {
    final list = val
        .whereType<Map<String, dynamic>>()
        .map((e) => ProductImage.fromJson(e))
        .toList();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }
  return const [];
}

/// Model sản phẩm ánh xạ bảng `products` trong Supabase.
///
/// Tuân thủ quy tắc DATABASE_SPEC:
/// - Không lưu base_price ở cấp sản phẩm.
/// - Giá min/max tính động từ các biến thể đang hoạt động (active variants).
@freezed
class Product with _$Product {
  const Product._();

  const factory Product({
    required String id,
    @JsonKey(name: 'category_id') required String categoryId,
    required String name,
    required String slug,
    String? description,
    String? material,
    @JsonKey(name: 'target_audience', defaultValue: 'unisex')
    required String targetAudience,
    @JsonKey(name: 'is_featured', defaultValue: false) required bool isFeatured,
    @JsonKey(name: 'is_active', defaultValue: true) required bool isActive,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    // Quan hệ lồng nhau khi JOIN
    @JsonKey(name: 'categories', fromJson: _categoryFromJson)
    Category? category,
    @JsonKey(name: 'product_variants', fromJson: _variantsFromJson)
    @Default(<ProductVariant>[])
    List<ProductVariant> variants,
    @JsonKey(name: 'product_images', fromJson: _imagesFromJson)
    @Default(<ProductImage>[])
    List<ProductImage> images,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  /// Danh sách biến thể đang mở bán
  List<ProductVariant> get activeVariants =>
      variants.where((v) => v.isActive).toList();

  /// Giá bán thấp nhất từ các biến thể đang hoạt động
  int? get minPrice {
    final active = activeVariants;
    if (active.isEmpty) return null;
    return active.map((v) => v.price).reduce((a, b) => a < b ? a : b);
  }

  /// Giá bán cao nhất từ các biến thể đang hoạt động
  int? get maxPrice {
    final active = activeVariants;
    if (active.isEmpty) return null;
    return active.map((v) => v.price).reduce((a, b) => a > b ? a : b);
  }

  /// Giá gốc/giá so sánh tương ứng với minPrice (nếu có)
  int? get minCompareAtPrice {
    final active = activeVariants;
    if (active.isEmpty) return null;
    final cheapest = active.reduce((a, b) => a.price < b.price ? a : b);
    return cheapest.compareAtPrice;
  }

  /// Kiểm tra sản phẩm còn hàng không
  bool get inStock => activeVariants.any((v) => v.inStock);

  /// Tổng tồn kho của tất cả biến thể
  int get totalStock =>
      activeVariants.fold(0, (sum, v) => sum + v.stockQuantity);

  /// Ảnh chính của sản phẩm (is_primary = true hoặc ảnh đầu tiên)
  ProductImage? get primaryImage {
    if (images.isEmpty) return null;
    return images.firstWhere(
      (img) => img.isPrimary,
      orElse: () => images.first,
    );
  }

  /// Tìm ảnh theo variant ID, fallback sang ảnh chính nếu không có
  ProductImage? imageForVariant(String? variantId) {
    if (variantId != null && images.isNotEmpty) {
      final variantImg =
          images.where((img) => img.variantId == variantId).firstOrNull;
      if (variantImg != null) return variantImg;
    }
    return primaryImage;
  }

  Map<String, dynamic> toInsertJson() => {
        'category_id': categoryId,
        'name': name,
        'slug': slug,
        if (description != null) 'description': description,
        if (material != null) 'material': material,
        'target_audience': targetAudience,
        'is_featured': isFeatured,
        'is_active': isActive,
      };

  Map<String, dynamic> toUpdateJson() => {
        'category_id': categoryId,
        'name': name,
        'slug': slug,
        'description': description,
        'material': material,
        'target_audience': targetAudience,
        'is_featured': isFeatured,
        'is_active': isActive,
      };
}
