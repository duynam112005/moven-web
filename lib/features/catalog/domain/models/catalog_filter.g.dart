// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_filter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CatalogFilterImpl _$$CatalogFilterImplFromJson(Map<String, dynamic> json) =>
    _$CatalogFilterImpl(
      categoryId: json['categoryId'] as String?,
      categorySlug: json['categorySlug'] as String?,
      targetAudience: json['targetAudience'] as String?,
      searchKeyword: json['searchKeyword'] as String?,
      minPrice: (json['minPrice'] as num?)?.toInt(),
      maxPrice: (json['maxPrice'] as num?)?.toInt(),
      sortBy: json['sortBy'] as String? ?? 'newest',
      inStockOnly: json['inStockOnly'] as bool? ?? false,
      isFeaturedOnly: json['isFeaturedOnly'] as bool? ?? false,
    );

Map<String, dynamic> _$$CatalogFilterImplToJson(_$CatalogFilterImpl instance) =>
    <String, dynamic>{
      'categoryId': instance.categoryId,
      'categorySlug': instance.categorySlug,
      'targetAudience': instance.targetAudience,
      'searchKeyword': instance.searchKeyword,
      'minPrice': instance.minPrice,
      'maxPrice': instance.maxPrice,
      'sortBy': instance.sortBy,
      'inStockOnly': instance.inStockOnly,
      'isFeaturedOnly': instance.isFeaturedOnly,
    };
