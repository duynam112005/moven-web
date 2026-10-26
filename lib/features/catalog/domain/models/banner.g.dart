// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HomeBannerImpl _$$HomeBannerImplFromJson(Map<String, dynamic> json) =>
    _$HomeBannerImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      imagePath: json['image_path'] as String,
      linkType: json['link_type'] as String? ?? 'none',
      linkValue: json['link_value'] as String?,
      startAt: json['start_at'] == null
          ? null
          : DateTime.parse(json['start_at'] as String),
      endAt: json['end_at'] == null
          ? null
          : DateTime.parse(json['end_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$HomeBannerImplToJson(_$HomeBannerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'image_path': instance.imagePath,
      'link_type': instance.linkType,
      'link_value': instance.linkValue,
      'start_at': instance.startAt?.toIso8601String(),
      'end_at': instance.endAt?.toIso8601String(),
      'is_active': instance.isActive,
      'sort_order': instance.sortOrder,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
