// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) {
  return _OrderItem.fromJson(json);
}

/// @nodoc
mixin _$OrderItem {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'order_id')
  String get orderId => throw _privateConstructorUsedError;
  @JsonKey(name: 'variant_id')
  String? get variantId => throw _privateConstructorUsedError;
  @JsonKey(name: 'product_name_snapshot')
  String get productName => throw _privateConstructorUsedError;
  @JsonKey(name: 'sku_snapshot')
  String get sku => throw _privateConstructorUsedError;
  @JsonKey(name: 'size_snapshot')
  String? get size => throw _privateConstructorUsedError;
  @JsonKey(name: 'color_snapshot')
  String? get colorName => throw _privateConstructorUsedError;
  @JsonKey(name: 'unit_price')
  int get unitPrice => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  @JsonKey(name: 'line_total')
  int get lineTotal => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError;

  /// Serializes this OrderItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderItemCopyWith<OrderItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderItemCopyWith<$Res> {
  factory $OrderItemCopyWith(OrderItem value, $Res Function(OrderItem) then) =
      _$OrderItemCopyWithImpl<$Res, OrderItem>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'order_id') String orderId,
    @JsonKey(name: 'variant_id') String? variantId,
    @JsonKey(name: 'product_name_snapshot') String productName,
    @JsonKey(name: 'sku_snapshot') String sku,
    @JsonKey(name: 'size_snapshot') String? size,
    @JsonKey(name: 'color_snapshot') String? colorName,
    @JsonKey(name: 'unit_price') int unitPrice,
    int quantity,
    @JsonKey(name: 'line_total') int lineTotal,
    @JsonKey(name: 'image_url') String? imageUrl,
  });
}

/// @nodoc
class _$OrderItemCopyWithImpl<$Res, $Val extends OrderItem>
    implements $OrderItemCopyWith<$Res> {
  _$OrderItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? variantId = freezed,
    Object? productName = null,
    Object? sku = null,
    Object? size = freezed,
    Object? colorName = freezed,
    Object? unitPrice = null,
    Object? quantity = null,
    Object? lineTotal = null,
    Object? imageUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            orderId: null == orderId
                ? _value.orderId
                : orderId // ignore: cast_nullable_to_non_nullable
                      as String,
            variantId: freezed == variantId
                ? _value.variantId
                : variantId // ignore: cast_nullable_to_non_nullable
                      as String?,
            productName: null == productName
                ? _value.productName
                : productName // ignore: cast_nullable_to_non_nullable
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
            unitPrice: null == unitPrice
                ? _value.unitPrice
                : unitPrice // ignore: cast_nullable_to_non_nullable
                      as int,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as int,
            lineTotal: null == lineTotal
                ? _value.lineTotal
                : lineTotal // ignore: cast_nullable_to_non_nullable
                      as int,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OrderItemImplCopyWith<$Res>
    implements $OrderItemCopyWith<$Res> {
  factory _$$OrderItemImplCopyWith(
    _$OrderItemImpl value,
    $Res Function(_$OrderItemImpl) then,
  ) = __$$OrderItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'order_id') String orderId,
    @JsonKey(name: 'variant_id') String? variantId,
    @JsonKey(name: 'product_name_snapshot') String productName,
    @JsonKey(name: 'sku_snapshot') String sku,
    @JsonKey(name: 'size_snapshot') String? size,
    @JsonKey(name: 'color_snapshot') String? colorName,
    @JsonKey(name: 'unit_price') int unitPrice,
    int quantity,
    @JsonKey(name: 'line_total') int lineTotal,
    @JsonKey(name: 'image_url') String? imageUrl,
  });
}

/// @nodoc
class __$$OrderItemImplCopyWithImpl<$Res>
    extends _$OrderItemCopyWithImpl<$Res, _$OrderItemImpl>
    implements _$$OrderItemImplCopyWith<$Res> {
  __$$OrderItemImplCopyWithImpl(
    _$OrderItemImpl _value,
    $Res Function(_$OrderItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? variantId = freezed,
    Object? productName = null,
    Object? sku = null,
    Object? size = freezed,
    Object? colorName = freezed,
    Object? unitPrice = null,
    Object? quantity = null,
    Object? lineTotal = null,
    Object? imageUrl = freezed,
  }) {
    return _then(
      _$OrderItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orderId: null == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as String,
        variantId: freezed == variantId
            ? _value.variantId
            : variantId // ignore: cast_nullable_to_non_nullable
                  as String?,
        productName: null == productName
            ? _value.productName
            : productName // ignore: cast_nullable_to_non_nullable
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
        unitPrice: null == unitPrice
            ? _value.unitPrice
            : unitPrice // ignore: cast_nullable_to_non_nullable
                  as int,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as int,
        lineTotal: null == lineTotal
            ? _value.lineTotal
            : lineTotal // ignore: cast_nullable_to_non_nullable
                  as int,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderItemImpl extends _OrderItem {
  const _$OrderItemImpl({
    required this.id,
    @JsonKey(name: 'order_id') required this.orderId,
    @JsonKey(name: 'variant_id') this.variantId,
    @JsonKey(name: 'product_name_snapshot') required this.productName,
    @JsonKey(name: 'sku_snapshot') required this.sku,
    @JsonKey(name: 'size_snapshot') this.size,
    @JsonKey(name: 'color_snapshot') this.colorName,
    @JsonKey(name: 'unit_price') required this.unitPrice,
    required this.quantity,
    @JsonKey(name: 'line_total') required this.lineTotal,
    @JsonKey(name: 'image_url') this.imageUrl,
  }) : super._();

  factory _$OrderItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderItemImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'order_id')
  final String orderId;
  @override
  @JsonKey(name: 'variant_id')
  final String? variantId;
  @override
  @JsonKey(name: 'product_name_snapshot')
  final String productName;
  @override
  @JsonKey(name: 'sku_snapshot')
  final String sku;
  @override
  @JsonKey(name: 'size_snapshot')
  final String? size;
  @override
  @JsonKey(name: 'color_snapshot')
  final String? colorName;
  @override
  @JsonKey(name: 'unit_price')
  final int unitPrice;
  @override
  final int quantity;
  @override
  @JsonKey(name: 'line_total')
  final int lineTotal;
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;

  @override
  String toString() {
    return 'OrderItem(id: $id, orderId: $orderId, variantId: $variantId, productName: $productName, sku: $sku, size: $size, colorName: $colorName, unitPrice: $unitPrice, quantity: $quantity, lineTotal: $lineTotal, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.variantId, variantId) ||
                other.variantId == variantId) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.sku, sku) || other.sku == sku) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.colorName, colorName) ||
                other.colorName == colorName) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.lineTotal, lineTotal) ||
                other.lineTotal == lineTotal) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    orderId,
    variantId,
    productName,
    sku,
    size,
    colorName,
    unitPrice,
    quantity,
    lineTotal,
    imageUrl,
  );

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderItemImplCopyWith<_$OrderItemImpl> get copyWith =>
      __$$OrderItemImplCopyWithImpl<_$OrderItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderItemImplToJson(this);
  }
}

abstract class _OrderItem extends OrderItem {
  const factory _OrderItem({
    required final String id,
    @JsonKey(name: 'order_id') required final String orderId,
    @JsonKey(name: 'variant_id') final String? variantId,
    @JsonKey(name: 'product_name_snapshot') required final String productName,
    @JsonKey(name: 'sku_snapshot') required final String sku,
    @JsonKey(name: 'size_snapshot') final String? size,
    @JsonKey(name: 'color_snapshot') final String? colorName,
    @JsonKey(name: 'unit_price') required final int unitPrice,
    required final int quantity,
    @JsonKey(name: 'line_total') required final int lineTotal,
    @JsonKey(name: 'image_url') final String? imageUrl,
  }) = _$OrderItemImpl;
  const _OrderItem._() : super._();

  factory _OrderItem.fromJson(Map<String, dynamic> json) =
      _$OrderItemImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'order_id')
  String get orderId;
  @override
  @JsonKey(name: 'variant_id')
  String? get variantId;
  @override
  @JsonKey(name: 'product_name_snapshot')
  String get productName;
  @override
  @JsonKey(name: 'sku_snapshot')
  String get sku;
  @override
  @JsonKey(name: 'size_snapshot')
  String? get size;
  @override
  @JsonKey(name: 'color_snapshot')
  String? get colorName;
  @override
  @JsonKey(name: 'unit_price')
  int get unitPrice;
  @override
  int get quantity;
  @override
  @JsonKey(name: 'line_total')
  int get lineTotal;
  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl;

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderItemImplCopyWith<_$OrderItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
