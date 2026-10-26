// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReviewReportImpl _$$ReviewReportImplFromJson(Map<String, dynamic> json) =>
    _$ReviewReportImpl(
      id: json['id'] as String,
      reviewId: json['review_id'] as String,
      reporterId: json['reporter_id'] as String,
      reporterName: json['reporter_name'] as String? ?? 'Người dùng',
      reviewComment: json['review_comment'] as String?,
      reviewRating: (json['review_rating'] as num?)?.toInt(),
      reviewAuthorName: json['review_author_name'] as String?,
      productId: json['product_id'] as String?,
      productName: json['product_name'] as String?,
      reason: json['reason'] as String,
      details: json['details'] as String?,
      status: json['status'] as String? ?? 'pending',
      resolvedBy: json['resolved_by'] as String?,
      resolutionNote: json['resolution_note'] as String?,
      resolvedAt: json['resolved_at'] == null
          ? null
          : DateTime.parse(json['resolved_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$ReviewReportImplToJson(_$ReviewReportImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'review_id': instance.reviewId,
      'reporter_id': instance.reporterId,
      'reporter_name': instance.reporterName,
      'review_comment': instance.reviewComment,
      'review_rating': instance.reviewRating,
      'review_author_name': instance.reviewAuthorName,
      'product_id': instance.productId,
      'product_name': instance.productName,
      'reason': instance.reason,
      'details': instance.details,
      'status': instance.status,
      'resolved_by': instance.resolvedBy,
      'resolution_note': instance.resolutionNote,
      'resolved_at': instance.resolvedAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };
