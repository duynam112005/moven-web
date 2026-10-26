import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalog_filter.freezed.dart';
part 'catalog_filter.g.dart';

/// DTO chứa các tiêu chí lọc và sắp xếp catalog
@freezed
class CatalogFilter with _$CatalogFilter {
  const CatalogFilter._();

  const factory CatalogFilter({
    String? categoryId,
    String? categorySlug,
    String? targetAudience, // 'men', 'women', 'unisex'
    String? searchKeyword,
    int? minPrice,
    int? maxPrice,
    @Default('newest') String sortBy, // 'newest', 'price_asc', 'price_desc', 'name_asc'
    @Default(false) bool inStockOnly,
    @Default(false) bool isFeaturedOnly,
  }) = _CatalogFilter;

  factory CatalogFilter.fromJson(Map<String, dynamic> json) =>
      _$CatalogFilterFromJson(json);

  /// Kiểm tra có đang áp dụng bất kỳ bộ lọc nào hay không
  bool get hasActiveFilters =>
      categoryId != null ||
      categorySlug != null ||
      targetAudience != null ||
      (searchKeyword != null && searchKeyword!.trim().isNotEmpty) ||
      minPrice != null ||
      maxPrice != null ||
      inStockOnly ||
      isFeaturedOnly;
}
