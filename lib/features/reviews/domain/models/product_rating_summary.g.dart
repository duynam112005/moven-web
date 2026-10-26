// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_rating_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductRatingSummaryImpl _$$ProductRatingSummaryImplFromJson(
  Map<String, dynamic> json,
) => _$ProductRatingSummaryImpl(
  productId: json['product_id'] as String,
  totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
  averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
  counts:
      (json['counts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
);

Map<String, dynamic> _$$ProductRatingSummaryImplToJson(
  _$ProductRatingSummaryImpl instance,
) => <String, dynamic>{
  'product_id': instance.productId,
  'total_reviews': instance.totalReviews,
  'average_rating': instance.averageRating,
  'counts': instance.counts,
};
