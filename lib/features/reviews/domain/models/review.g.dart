// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReviewImpl _$$ReviewImplFromJson(Map<String, dynamic> json) => _$ReviewImpl(
  id: json['id'] as String,
  productId: json['product_id'] as String,
  userId: json['user_id'] as String,
  userName: json['user_name'] as String? ?? 'Khách hàng MOVEN',
  userAvatar: json['user_avatar'] as String?,
  orderItemId: json['order_item_id'] as String?,
  orderCode: json['order_code'] as String?,
  variantLabel: json['variant_label'] as String?,
  rating: (json['rating'] as num).toInt(),
  comment: json['comment'] as String?,
  isHidden: json['is_hidden'] as bool? ?? false,
  hiddenReason: json['hidden_reason'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$$ReviewImplToJson(_$ReviewImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_id': instance.productId,
      'user_id': instance.userId,
      'user_name': instance.userName,
      'user_avatar': instance.userAvatar,
      'order_item_id': instance.orderItemId,
      'order_code': instance.orderCode,
      'variant_label': instance.variantLabel,
      'rating': instance.rating,
      'comment': instance.comment,
      'is_hidden': instance.isHidden,
      'hidden_reason': instance.hiddenReason,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
