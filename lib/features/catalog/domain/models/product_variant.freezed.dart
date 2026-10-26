// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_variant.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProductVariant _$ProductVariantFromJson(Map<String, dynamic> json) {
  return _ProductVariant.fromJson(json);
}

/// @nodoc
mixin _$ProductVariant {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'product_id')
  String get productId => throw _privateConstructorUsedError;
  String get sku => throw _privateConstructorUsedError;
  String? get size => throw _privateConstructorUsedError;
  @JsonKey(name: 'color_name')
  String? get colorName => throw _privateConstructorUsedError;
  @JsonKey(name: 'color_hex')
  String? get colorHex => throw _privateConstructorUsedError;
  int get price => throw _privateConstructorUsedError;
  @JsonKey(name: 'compare_at_price')
  int? get compareAtPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_quantity', defaultValue: 0)
  int get stockQuantity => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active', defaultValue: true)
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ProductVariant to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductVariant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductVariantCopyWith<ProductVariant> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductVariantCopyWith<$Res> {
  factory $ProductVariantCopyWith(
    ProductVariant value,
    $Res Function(ProductVariant) then,
  ) = _$ProductVariantCopyWithImpl<$Res, ProductVariant>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'product_id') String productId,
    String sku,
    String? size,
    @JsonKey(name: 'color_name') String? colorName,
    @JsonKey(name: 'color_hex') String? colorHex,
    int price,
    @JsonKey(name: 'compare_at_price') int? compareAtPrice,
    @JsonKey(name: 'stock_quantity', defaultValue: 0) int stockQuantity,
    @JsonKey(name: 'is_active', defaultValue: true) bool isActive,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class _$ProductVariantCopyWithImpl<$Res, $Val extends ProductVariant>
    implements $ProductVariantCopyWith<$Res> {
  _$ProductVariantCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductVariant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? sku = null,
    Object? size = freezed,
    Object? colorName = freezed,
    Object? colorHex = freezed,
    Object? price = null,
    Object? compareAtPrice = freezed,
    Object? stockQuantity = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            productId: null == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as String,
            sku: null == sku
                ? _value.sku
                : sku // ignore: cast_nullable_to_non_nullable
                      as String,
            size: freezed == size
                ? _value.size
                : size // ignore: cast_nullable_to_non_nullable
                      as String?,
            colorName: freezed == colorName
                ? _value.colorName
                : colorName // ignore: cast_nullable_to_non_nullable
                      as String?,
            colorHex: freezed == colorHex
                ? _value.colorHex
                : colorHex // ignore: cast_nullable_to_non_nullable
                      as String?,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as int,
            compareAtPrice: freezed == compareAtPrice
                ? _value.compareAtPrice
                : compareAtPrice // ignore: cast_nullable_to_non_nullable
                      as int?,
            stockQuantity: null == stockQuantity
                ? _value.stockQuantity
                : stockQuantity // ignore: cast_nullable_to_non_nullable
                      as int,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductVariantImplCopyWith<$Res>
    implements $ProductVariantCopyWith<$Res> {
  factory _$$ProductVariantImplCopyWith(
    _$ProductVariantImpl value,
    $Res Function(_$ProductVariantImpl) then,
  ) = __$$ProductVariantImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'product_id') String productId,
    String sku,
    String? size,
    @JsonKey(name: 'color_name') String? colorName,
    @JsonKey(name: 'color_hex') String? colorHex,
    int price,
    @JsonKey(name: 'compare_at_price') int? compareAtPrice,
    @JsonKey(name: 'stock_quantity', defaultValue: 0) int stockQuantity,
    @JsonKey(name: 'is_active', defaultValue: true) bool isActive,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class __$$ProductVariantImplCopyWithImpl<$Res>
    extends _$ProductVariantCopyWithImpl<$Res, _$ProductVariantImpl>
    implements _$$ProductVariantImplCopyWith<$Res> {
  __$$ProductVariantImplCopyWithImpl(
    _$ProductVariantImpl _value,
    $Res Function(_$ProductVariantImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductVariant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? sku = null,
    Object? size = freezed,
    Object? colorName = freezed,
    Object? colorHex = freezed,
    Object? price = null,
    Object? compareAtPrice = freezed,
    Object? stockQuantity = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$ProductVariantImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        productId: null == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String,
        sku: null == sku
            ? _value.sku
            : sku // ignore: cast_nullable_to_non_nullable
                  as String,
        size: freezed == size
            ? _value.size
            : size // ignore: cast_nullable_to_non_nullable
                  as String?,
        colorName: freezed == colorName
            ? _value.colorName
            : colorName // ignore: cast_nullable_to_non_nullable
                  as String?,
        colorHex: freezed == colorHex
            ? _value.colorHex
            : colorHex // ignore: cast_nullable_to_non_nullable
                  as String?,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as int,
        compareAtPrice: freezed == compareAtPrice
            ? _value.compareAtPrice
            : compareAtPrice // ignore: cast_nullable_to_non_nullable
                  as int?,
        stockQuantity: null == stockQuantity
            ? _value.stockQuantity
            : stockQuantity // ignore: cast_nullable_to_non_nullable
                  as int,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductVariantImpl extends _ProductVariant {
  const _$ProductVariantImpl({
    required this.id,
    @JsonKey(name: 'product_id') required this.productId,
    required this.sku,
    this.size,
    @JsonKey(name: 'color_name') this.colorName,
    @JsonKey(name: 'color_hex') this.colorHex,
    required this.price,
    @JsonKey(name: 'compare_at_price') this.compareAtPrice,
    @JsonKey(name: 'stock_quantity', defaultValue: 0)
    required this.stockQuantity,
    @JsonKey(name: 'is_active', defaultValue: true) required this.isActive,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
  }) : super._();

  factory _$ProductVariantImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductVariantImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'product_id')
  final String productId;
  @override
  final String sku;
  @override
  final String? size;
  @override
  @JsonKey(name: 'color_name')
  final String? colorName;
  @override
  @JsonKey(name: 'color_hex')
  final String? colorHex;
  @override
  final int price;
  @override
  @JsonKey(name: 'compare_at_price')
  final int? compareAtPrice;
  @override
  @JsonKey(name: 'stock_quantity', defaultValue: 0)
  final int stockQuantity;
  @override
  @JsonKey(name: 'is_active', defaultValue: true)
  final bool isActive;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'ProductVariant(id: $id, productId: $productId, sku: $sku, size: $size, colorName: $colorName, colorHex: $colorHex, price: $price, compareAtPrice: $compareAtPrice, stockQuantity: $stockQuantity, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductVariantImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.sku, sku) || other.sku == sku) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.colorName, colorName) ||
                other.colorName == colorName) &&
            (identical(other.colorHex, colorHex) ||
                other.colorHex == colorHex) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.compareAtPrice, compareAtPrice) ||
                other.compareAtPrice == compareAtPrice) &&
            (identical(other.stockQuantity, stockQuantity) ||
                other.stockQuantity == stockQuantity) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    productId,
    sku,
    size,
    colorName,
    colorHex,
    price,
    compareAtPrice,
    stockQuantity,
    isActive,
    createdAt,
    updatedAt,
  );

  /// Create a copy of ProductVariant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductVariantImplCopyWith<_$ProductVariantImpl> get copyWith =>
      __$$ProductVariantImplCopyWithImpl<_$ProductVariantImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductVariantImplToJson(this);
  }
}

abstract class _ProductVariant extends ProductVariant {
  const factory _ProductVariant({
    required final String id,
    @JsonKey(name: 'product_id') required final String productId,
    required final String sku,
    final String? size,
    @JsonKey(name: 'color_name') final String? colorName,
    @JsonKey(name: 'color_hex') final String? colorHex,
    required final int price,
    @JsonKey(name: 'compare_at_price') final int? compareAtPrice,
    @JsonKey(name: 'stock_quantity', defaultValue: 0)
    required final int stockQuantity,
    @JsonKey(name: 'is_active', defaultValue: true)
    required final bool isActive,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
  }) = _$ProductVariantImpl;
  const _ProductVariant._() : super._();

  factory _ProductVariant.fromJson(Map<String, dynamic> json) =
      _$ProductVariantImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'product_id')
  String get productId;
  @override
  String get sku;
  @override
  String? get size;
  @override
  @JsonKey(name: 'color_name')
  String? get colorName;
  @override
  @JsonKey(name: 'color_hex')
  String? get colorHex;
  @override
  int get price;
  @override
  @JsonKey(name: 'compare_at_price')
  int? get compareAtPrice;
  @override
  @JsonKey(name: 'stock_quantity', defaultValue: 0)
  int get stockQuantity;
  @override
  @JsonKey(name: 'is_active', defaultValue: true)
  bool get isActive;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of ProductVariant
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductVariantImplCopyWith<_$ProductVariantImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
