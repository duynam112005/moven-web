// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'store_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

StoreSettings _$StoreSettingsFromJson(Map<String, dynamic> json) {
  return _StoreSettings.fromJson(json);
}

/// @nodoc
mixin _$StoreSettings {
  @JsonKey(name: 'store_name')
  String get storeName => throw _privateConstructorUsedError;
  @JsonKey(name: 'logo_path')
  String? get logoPath => throw _privateConstructorUsedError;
  @JsonKey(name: 'contact_email')
  String get contactEmail => throw _privateConstructorUsedError;
  @JsonKey(name: 'contact_phone')
  String get contactPhone => throw _privateConstructorUsedError;
  @JsonKey(name: 'default_shipping_fee')
  int get defaultShippingFee => throw _privateConstructorUsedError;
  @JsonKey(name: 'low_stock_threshold')
  int get lowStockThreshold => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this StoreSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StoreSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StoreSettingsCopyWith<StoreSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StoreSettingsCopyWith<$Res> {
  factory $StoreSettingsCopyWith(
    StoreSettings value,
    $Res Function(StoreSettings) then,
  ) = _$StoreSettingsCopyWithImpl<$Res, StoreSettings>;
  @useResult
  $Res call({
    @JsonKey(name: 'store_name') String storeName,
    @JsonKey(name: 'logo_path') String? logoPath,
    @JsonKey(name: 'contact_email') String contactEmail,
    @JsonKey(name: 'contact_phone') String contactPhone,
    @JsonKey(name: 'default_shipping_fee') int defaultShippingFee,
    @JsonKey(name: 'low_stock_threshold') int lowStockThreshold,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  });
}

/// @nodoc
class _$StoreSettingsCopyWithImpl<$Res, $Val extends StoreSettings>
    implements $StoreSettingsCopyWith<$Res> {
  _$StoreSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StoreSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? storeName = null,
    Object? logoPath = freezed,
    Object? contactEmail = null,
    Object? contactPhone = null,
    Object? defaultShippingFee = null,
    Object? lowStockThreshold = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            storeName: null == storeName
                ? _value.storeName
                : storeName // ignore: cast_nullable_to_non_nullable
                      as String,
            logoPath: freezed == logoPath
                ? _value.logoPath
                : logoPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            contactEmail: null == contactEmail
                ? _value.contactEmail
                : contactEmail // ignore: cast_nullable_to_non_nullable
                      as String,
            contactPhone: null == contactPhone
                ? _value.contactPhone
                : contactPhone // ignore: cast_nullable_to_non_nullable
                      as String,
            defaultShippingFee: null == defaultShippingFee
                ? _value.defaultShippingFee
                : defaultShippingFee // ignore: cast_nullable_to_non_nullable
                      as int,
            lowStockThreshold: null == lowStockThreshold
                ? _value.lowStockThreshold
                : lowStockThreshold // ignore: cast_nullable_to_non_nullable
                      as int,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StoreSettingsImplCopyWith<$Res>
    implements $StoreSettingsCopyWith<$Res> {
  factory _$$StoreSettingsImplCopyWith(
    _$StoreSettingsImpl value,
    $Res Function(_$StoreSettingsImpl) then,
  ) = __$$StoreSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'store_name') String storeName,
    @JsonKey(name: 'logo_path') String? logoPath,
    @JsonKey(name: 'contact_email') String contactEmail,
    @JsonKey(name: 'contact_phone') String contactPhone,
    @JsonKey(name: 'default_shipping_fee') int defaultShippingFee,
    @JsonKey(name: 'low_stock_threshold') int lowStockThreshold,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  });
}

/// @nodoc
class __$$StoreSettingsImplCopyWithImpl<$Res>
    extends _$StoreSettingsCopyWithImpl<$Res, _$StoreSettingsImpl>
    implements _$$StoreSettingsImplCopyWith<$Res> {
  __$$StoreSettingsImplCopyWithImpl(
    _$StoreSettingsImpl _value,
    $Res Function(_$StoreSettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StoreSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? storeName = null,
    Object? logoPath = freezed,
    Object? contactEmail = null,
    Object? contactPhone = null,
    Object? defaultShippingFee = null,
    Object? lowStockThreshold = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$StoreSettingsImpl(
        storeName: null == storeName
            ? _value.storeName
            : storeName // ignore: cast_nullable_to_non_nullable
                  as String,
        logoPath: freezed == logoPath
            ? _value.logoPath
            : logoPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        contactEmail: null == contactEmail
            ? _value.contactEmail
            : contactEmail // ignore: cast_nullable_to_non_nullable
                  as String,
        contactPhone: null == contactPhone
            ? _value.contactPhone
            : contactPhone // ignore: cast_nullable_to_non_nullable
                  as String,
        defaultShippingFee: null == defaultShippingFee
            ? _value.defaultShippingFee
            : defaultShippingFee // ignore: cast_nullable_to_non_nullable
                  as int,
        lowStockThreshold: null == lowStockThreshold
            ? _value.lowStockThreshold
            : lowStockThreshold // ignore: cast_nullable_to_non_nullable
                  as int,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StoreSettingsImpl extends _StoreSettings {
  const _$StoreSettingsImpl({
    @JsonKey(name: 'store_name') this.storeName = 'MOVEN',
    @JsonKey(name: 'logo_path') this.logoPath,
    @JsonKey(name: 'contact_email') this.contactEmail = 'contact@moven.vn',
    @JsonKey(name: 'contact_phone') this.contactPhone = '0901234567',
    @JsonKey(name: 'default_shipping_fee') this.defaultShippingFee = 20000,
    @JsonKey(name: 'low_stock_threshold') this.lowStockThreshold = 5,
    @JsonKey(name: 'updated_at') this.updatedAt,
  }) : super._();

  factory _$StoreSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$StoreSettingsImplFromJson(json);

  @override
  @JsonKey(name: 'store_name')
  final String storeName;
  @override
  @JsonKey(name: 'logo_path')
  final String? logoPath;
  @override
  @JsonKey(name: 'contact_email')
  final String contactEmail;
  @override
  @JsonKey(name: 'contact_phone')
  final String contactPhone;
  @override
  @JsonKey(name: 'default_shipping_fee')
  final int defaultShippingFee;
  @override
  @JsonKey(name: 'low_stock_threshold')
  final int lowStockThreshold;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'StoreSettings(storeName: $storeName, logoPath: $logoPath, contactEmail: $contactEmail, contactPhone: $contactPhone, defaultShippingFee: $defaultShippingFee, lowStockThreshold: $lowStockThreshold, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StoreSettingsImpl &&
            (identical(other.storeName, storeName) ||
                other.storeName == storeName) &&
            (identical(other.logoPath, logoPath) ||
                other.logoPath == logoPath) &&
            (identical(other.contactEmail, contactEmail) ||
                other.contactEmail == contactEmail) &&
            (identical(other.contactPhone, contactPhone) ||
                other.contactPhone == contactPhone) &&
            (identical(other.defaultShippingFee, defaultShippingFee) ||
                other.defaultShippingFee == defaultShippingFee) &&
            (identical(other.lowStockThreshold, lowStockThreshold) ||
                other.lowStockThreshold == lowStockThreshold) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    storeName,
    logoPath,
    contactEmail,
    contactPhone,
    defaultShippingFee,
    lowStockThreshold,
    updatedAt,
  );

  /// Create a copy of StoreSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StoreSettingsImplCopyWith<_$StoreSettingsImpl> get copyWith =>
      __$$StoreSettingsImplCopyWithImpl<_$StoreSettingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StoreSettingsImplToJson(this);
  }
}

abstract class _StoreSettings extends StoreSettings {
  const factory _StoreSettings({
    @JsonKey(name: 'store_name') final String storeName,
    @JsonKey(name: 'logo_path') final String? logoPath,
    @JsonKey(name: 'contact_email') final String contactEmail,
    @JsonKey(name: 'contact_phone') final String contactPhone,
    @JsonKey(name: 'default_shipping_fee') final int defaultShippingFee,
    @JsonKey(name: 'low_stock_threshold') final int lowStockThreshold,
    @JsonKey(name: 'updated_at') final DateTime? updatedAt,
  }) = _$StoreSettingsImpl;
  const _StoreSettings._() : super._();

  factory _StoreSettings.fromJson(Map<String, dynamic> json) =
      _$StoreSettingsImpl.fromJson;

  @override
  @JsonKey(name: 'store_name')
  String get storeName;
  @override
  @JsonKey(name: 'logo_path')
  String? get logoPath;
  @override
  @JsonKey(name: 'contact_email')
  String get contactEmail;
  @override
  @JsonKey(name: 'contact_phone')
  String get contactPhone;
  @override
  @JsonKey(name: 'default_shipping_fee')
  int get defaultShippingFee;
  @override
  @JsonKey(name: 'low_stock_threshold')
  int get lowStockThreshold;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of StoreSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StoreSettingsImplCopyWith<_$StoreSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
