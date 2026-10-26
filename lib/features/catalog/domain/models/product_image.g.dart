// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductImageImpl _$$ProductImageImplFromJson(Map<String, dynamic> json) =>
    _$ProductImageImpl(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      variantId: json['variant_id'] as String?,
      imagePath: json['image_path'] as String,
      altText: json['alt_text'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      isPrimary: json['is_primary'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$ProductImageImplToJson(_$ProductImageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_id': instance.productId,
      'variant_id': instance.variantId,
      'image_path': instance.imagePath,
      'alt_text': instance.altText,
      'sort_order': instance.sortOrder,
      'is_primary': instance.isPrimary,
      'created_at': instance.createdAt.toIso8601String(),
    };
