// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StoreSettingsImpl _$$StoreSettingsImplFromJson(Map<String, dynamic> json) =>
    _$StoreSettingsImpl(
      storeName: json['store_name'] as String? ?? 'MOVEN',
      logoPath: json['logo_path'] as String?,
      contactEmail: json['contact_email'] as String? ?? 'contact@moven.vn',
      contactPhone: json['contact_phone'] as String? ?? '0901234567',
      defaultShippingFee:
          (json['default_shipping_fee'] as num?)?.toInt() ?? 20000,
      lowStockThreshold: (json['low_stock_threshold'] as num?)?.toInt() ?? 5,
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$StoreSettingsImplToJson(_$StoreSettingsImpl instance) =>
    <String, dynamic>{
      'store_name': instance.storeName,
      'logo_path': instance.logoPath,
      'contact_email': instance.contactEmail,
      'contact_phone': instance.contactPhone,
      'default_shipping_fee': instance.defaultShippingFee,
      'low_stock_threshold': instance.lowStockThreshold,
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
