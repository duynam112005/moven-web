import 'package:freezed_annotation/freezed_annotation.dart';

part 'store_settings.freezed.dart';
part 'store_settings.g.dart';

/// Cấu hình cửa hàng Singleton trong MOVEN (Freezed)
@freezed
class StoreSettings with _$StoreSettings {
  const StoreSettings._();

  const factory StoreSettings({
    @JsonKey(name: 'store_name') @Default('MOVEN') String storeName,
    @JsonKey(name: 'logo_path') String? logoPath,
    @JsonKey(name: 'contact_email') @Default('contact@moven.vn') String contactEmail,
    @JsonKey(name: 'contact_phone') @Default('0901234567') String contactPhone,
    @JsonKey(name: 'default_shipping_fee') @Default(20000) int defaultShippingFee,
    @JsonKey(name: 'low_stock_threshold') @Default(5) int lowStockThreshold,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _StoreSettings;

  factory StoreSettings.fromJson(Map<String, dynamic> json) =>
      _$StoreSettingsFromJson(json);
}
