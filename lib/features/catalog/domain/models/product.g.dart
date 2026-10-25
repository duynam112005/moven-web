// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductImpl _$$ProductImplFromJson(Map<String, dynamic> json) =>
    _$ProductImpl(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      material: json['material'] as String?,
      targetAudience: json['target_audience'] as String? ?? 'unisex',
      isFeatured: json['is_featured'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      category: _categoryFromJson(json['categories']),
      variants: json['product_variants'] == null
          ? const <ProductVariant>[]
          : _variantsFromJson(json['product_variants']),
      images: json['product_images'] == null
          ? const <ProductImage>[]
          : _imagesFromJson(json['product_images']),
    );

Map<String, dynamic> _$$ProductImplToJson(_$ProductImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category_id': instance.categoryId,
      'name': instance.name,
      'slug': instance.slug,
      'description': instance.description,
      'material': instance.material,
      'target_audience': instance.targetAudience,
      'is_featured': instance.isFeatured,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'categories': instance.category,
      'product_variants': instance.variants,
      'product_images': instance.images,
    };
