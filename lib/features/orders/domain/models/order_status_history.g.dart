// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_status_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderStatusHistoryImpl _$$OrderStatusHistoryImplFromJson(
  Map<String, dynamic> json,
) => _$OrderStatusHistoryImpl(
  id: json['id'] as String,
  orderId: json['order_id'] as String,
  fromStatus: $enumDecodeNullable(_$OrderStatusEnumMap, json['from_status']),
  toStatus: $enumDecode(_$OrderStatusEnumMap, json['to_status']),
  actorId: json['actor_id'] as String?,
  note: json['note'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$OrderStatusHistoryImplToJson(
  _$OrderStatusHistoryImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'order_id': instance.orderId,
  'from_status': _$OrderStatusEnumMap[instance.fromStatus],
  'to_status': _$OrderStatusEnumMap[instance.toStatus]!,
  'actor_id': instance.actorId,
  'note': instance.note,
  'created_at': instance.createdAt.toIso8601String(),
};

const _$OrderStatusEnumMap = {
  OrderStatus.pendingConfirmation: 'pendingConfirmation',
  OrderStatus.shipping: 'shipping',
  OrderStatus.delivered: 'delivered',
  OrderStatus.deliveryFailed: 'deliveryFailed',
  OrderStatus.cancelled: 'cancelled',
  OrderStatus.returned: 'returned',
};
