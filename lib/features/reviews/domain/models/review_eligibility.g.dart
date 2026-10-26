// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_eligibility.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReviewEligibilityImpl _$$ReviewEligibilityImplFromJson(
  Map<String, dynamic> json,
) => _$ReviewEligibilityImpl(
  isAuthenticated: json['is_authenticated'] as bool? ?? false,
  isEligible: json['is_eligible'] as bool? ?? false,
  hasReviewed: json['has_reviewed'] as bool? ?? false,
  reason: json['reason'] as String? ?? 'UNAUTHENTICATED',
  message: json['message'] as String? ?? '',
  orderItemId: json['order_item_id'] as String?,
  orderCode: json['order_code'] as String?,
  sizeSnapshot: json['size_snapshot'] as String?,
  colorSnapshot: json['color_snapshot'] as String?,
);

Map<String, dynamic> _$$ReviewEligibilityImplToJson(
  _$ReviewEligibilityImpl instance,
) => <String, dynamic>{
  'is_authenticated': instance.isAuthenticated,
  'is_eligible': instance.isEligible,
  'has_reviewed': instance.hasReviewed,
  'reason': instance.reason,
  'message': instance.message,
  'order_item_id': instance.orderItemId,
  'order_code': instance.orderCode,
  'size_snapshot': instance.sizeSnapshot,
  'color_snapshot': instance.colorSnapshot,
};
