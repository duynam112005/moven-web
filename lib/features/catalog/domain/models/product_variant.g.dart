// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_variant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductVariantImpl _$$ProductVariantImplFromJson(Map<String, dynamic> json) =>
    _$ProductVariantImpl(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      sku: json['sku'] as String,
      size: json['size'] as String?,
      colorName: json['color_name'] as String?,
      colorHex: json['color_hex'] as String?,
      price: (json['price'] as num).toInt(),
      compareAtPrice: (json['compare_at_price'] as num?)?.toInt(),
      stockQuantity: (json['stock_quantity'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$ProductVariantImplToJson(
  _$ProductVariantImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'product_id': instance.productId,
  'sku': instance.sku,
  'size': instance.size,
  'color_name': instance.colorName,
  'color_hex': instance.colorHex,
  'price': instance.price,
  'compare_at_price': instance.compareAtPrice,
  'stock_quantity': instance.stockQuantity,
  'is_active': instance.isActive,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
