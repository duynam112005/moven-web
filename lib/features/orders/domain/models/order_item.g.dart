// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderItemImpl _$$OrderItemImplFromJson(Map<String, dynamic> json) =>
    _$OrderItemImpl(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      variantId: json['variant_id'] as String?,
      productId: json['product_id'] as String?,
      productName: json['product_name_snapshot'] as String,
      sku: json['sku_snapshot'] as String,
      size: json['size_snapshot'] as String?,
      colorName: json['color_snapshot'] as String?,
      unitPrice: (json['unit_price'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
      lineTotal: (json['line_total'] as num).toInt(),
      imageUrl: json['image_url'] as String?,
    );

Map<String, dynamic> _$$OrderItemImplToJson(_$OrderItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_id': instance.orderId,
      'variant_id': instance.variantId,
      'product_id': instance.productId,
      'product_name_snapshot': instance.productName,
      'sku_snapshot': instance.sku,
      'size_snapshot': instance.size,
      'color_snapshot': instance.colorName,
      'unit_price': instance.unitPrice,
      'quantity': instance.quantity,
      'line_total': instance.lineTotal,
      'image_url': instance.imageUrl,
    };
