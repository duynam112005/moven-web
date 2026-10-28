// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderImpl _$$OrderImplFromJson(Map<String, dynamic> json) => _$OrderImpl(
  id: json['id'] as String,
  orderCode: json['order_code'] as String,
  userId: json['user_id'] as String,
  status: $enumDecode(
    _$OrderStatusEnumMap,
    json['status'],
    unknownValue: OrderStatus.pendingConfirmation,
  ),
  paymentMethod: json['payment_method'] as String? ?? 'cod',
  paymentStatus: json['payment_status'] as String? ?? 'unpaid',
  recipientName: json['recipient_name'] as String,
  recipientPhone: json['recipient_phone'] as String,
  shippingAddress:
      json['shipping_address'] as Map<String, dynamic>? ?? const {},
  subtotal: (json['subtotal'] as num).toInt(),
  shippingFee: (json['shipping_fee'] as num?)?.toInt() ?? 20000,
  discountAmount: (json['discount_amount'] as num?)?.toInt() ?? 0,
  totalAmount: (json['total_amount'] as num).toInt(),
  customerNote: json['customer_note'] as String?,
  cancellationReason: json['cancellation_reason'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  cancelledAt: json['cancelled_at'] == null
      ? null
      : DateTime.parse(json['cancelled_at'] as String),
  deliveredAt: json['delivered_at'] == null
      ? null
      : DateTime.parse(json['delivered_at'] as String),
  items:
      (json['order_items'] as List<dynamic>?)
          ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  statusHistory:
      (json['order_status_history'] as List<dynamic>?)
          ?.map((e) => OrderStatusHistory.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$OrderImplToJson(_$OrderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_code': instance.orderCode,
      'user_id': instance.userId,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'payment_method': instance.paymentMethod,
      'payment_status': instance.paymentStatus,
      'recipient_name': instance.recipientName,
      'recipient_phone': instance.recipientPhone,
      'shipping_address': instance.shippingAddress,
      'subtotal': instance.subtotal,
      'shipping_fee': instance.shippingFee,
      'discount_amount': instance.discountAmount,
      'total_amount': instance.totalAmount,
      'customer_note': instance.customerNote,
      'cancellation_reason': instance.cancellationReason,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'cancelled_at': instance.cancelledAt?.toIso8601String(),
      'delivered_at': instance.deliveredAt?.toIso8601String(),
      'order_items': instance.items,
      'order_status_history': instance.statusHistory,
    };

const _$OrderStatusEnumMap = {
  OrderStatus.pendingConfirmation: 'pending_confirmation',
  OrderStatus.shipping: 'shipping',
  OrderStatus.delivered: 'delivered',
  OrderStatus.deliveryFailed: 'delivery_failed',
  OrderStatus.cancelled: 'cancelled',
  OrderStatus.returned: 'returned',
};
