// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_metrics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BestSellerItem _$BestSellerItemFromJson(Map<String, dynamic> json) {
  return _BestSellerItem.fromJson(json);
}

/// @nodoc
mixin _$BestSellerItem {
  @JsonKey(name: 'product_name')
  String get productName => throw _privateConstructorUsedError;
  @JsonKey(name: 'product_id')
  String? get productId => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_sold')
  int get totalSold => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_revenue')
  int get totalRevenue => throw _privateConstructorUsedError;

  /// Serializes this BestSellerItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BestSellerItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BestSellerItemCopyWith<BestSellerItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BestSellerItemCopyWith<$Res> {
  factory $BestSellerItemCopyWith(
    BestSellerItem value,
    $Res Function(BestSellerItem) then,
  ) = _$BestSellerItemCopyWithImpl<$Res, BestSellerItem>;
  @useResult
  $Res call({
    @JsonKey(name: 'product_name') String productName,
    @JsonKey(name: 'product_id') String? productId,
    @JsonKey(name: 'total_sold') int totalSold,
    @JsonKey(name: 'total_revenue') int totalRevenue,
  });
}

/// @nodoc
class _$BestSellerItemCopyWithImpl<$Res, $Val extends BestSellerItem>
    implements $BestSellerItemCopyWith<$Res> {
  _$BestSellerItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BestSellerItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productName = null,
    Object? productId = freezed,
    Object? totalSold = null,
    Object? totalRevenue = null,
  }) {
    return _then(
      _value.copyWith(
            productName: null == productName
                ? _value.productName
                : productName // ignore: cast_nullable_to_non_nullable
                      as String,
            productId: freezed == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as String?,
            totalSold: null == totalSold
                ? _value.totalSold
                : totalSold // ignore: cast_nullable_to_non_nullable
                      as int,
            totalRevenue: null == totalRevenue
                ? _value.totalRevenue
                : totalRevenue // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BestSellerItemImplCopyWith<$Res>
    implements $BestSellerItemCopyWith<$Res> {
  factory _$$BestSellerItemImplCopyWith(
    _$BestSellerItemImpl value,
    $Res Function(_$BestSellerItemImpl) then,
  ) = __$$BestSellerItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'product_name') String productName,
    @JsonKey(name: 'product_id') String? productId,
    @JsonKey(name: 'total_sold') int totalSold,
    @JsonKey(name: 'total_revenue') int totalRevenue,
  });
}

/// @nodoc
class __$$BestSellerItemImplCopyWithImpl<$Res>
    extends _$BestSellerItemCopyWithImpl<$Res, _$BestSellerItemImpl>
    implements _$$BestSellerItemImplCopyWith<$Res> {
  __$$BestSellerItemImplCopyWithImpl(
    _$BestSellerItemImpl _value,
    $Res Function(_$BestSellerItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BestSellerItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productName = null,
    Object? productId = freezed,
    Object? totalSold = null,
    Object? totalRevenue = null,
  }) {
    return _then(
      _$BestSellerItemImpl(
        productName: null == productName
            ? _value.productName
            : productName // ignore: cast_nullable_to_non_nullable
                  as String,
        productId: freezed == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String?,
        totalSold: null == totalSold
            ? _value.totalSold
            : totalSold // ignore: cast_nullable_to_non_nullable
                  as int,
        totalRevenue: null == totalRevenue
            ? _value.totalRevenue
            : totalRevenue // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BestSellerItemImpl implements _BestSellerItem {
  const _$BestSellerItemImpl({
    @JsonKey(name: 'product_name') required this.productName,
    @JsonKey(name: 'product_id') this.productId,
    @JsonKey(name: 'total_sold') this.totalSold = 0,
    @JsonKey(name: 'total_revenue') this.totalRevenue = 0,
  });

  factory _$BestSellerItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$BestSellerItemImplFromJson(json);

  @override
  @JsonKey(name: 'product_name')
  final String productName;
  @override
  @JsonKey(name: 'product_id')
  final String? productId;
  @override
  @JsonKey(name: 'total_sold')
  final int totalSold;
  @override
  @JsonKey(name: 'total_revenue')
  final int totalRevenue;

  @override
  String toString() {
    return 'BestSellerItem(productName: $productName, productId: $productId, totalSold: $totalSold, totalRevenue: $totalRevenue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BestSellerItemImpl &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.totalSold, totalSold) ||
                other.totalSold == totalSold) &&
            (identical(other.totalRevenue, totalRevenue) ||
                other.totalRevenue == totalRevenue));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, productName, productId, totalSold, totalRevenue);

  /// Create a copy of BestSellerItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BestSellerItemImplCopyWith<_$BestSellerItemImpl> get copyWith =>
      __$$BestSellerItemImplCopyWithImpl<_$BestSellerItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BestSellerItemImplToJson(this);
  }
}

abstract class _BestSellerItem implements BestSellerItem {
  const factory _BestSellerItem({
    @JsonKey(name: 'product_name') required final String productName,
    @JsonKey(name: 'product_id') final String? productId,
    @JsonKey(name: 'total_sold') final int totalSold,
    @JsonKey(name: 'total_revenue') final int totalRevenue,
  }) = _$BestSellerItemImpl;

  factory _BestSellerItem.fromJson(Map<String, dynamic> json) =
      _$BestSellerItemImpl.fromJson;

  @override
  @JsonKey(name: 'product_name')
  String get productName;
  @override
  @JsonKey(name: 'product_id')
  String? get productId;
  @override
  @JsonKey(name: 'total_sold')
  int get totalSold;
  @override
  @JsonKey(name: 'total_revenue')
  int get totalRevenue;

  /// Create a copy of BestSellerItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BestSellerItemImplCopyWith<_$BestSellerItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LowStockVariantItem _$LowStockVariantItemFromJson(Map<String, dynamic> json) {
  return _LowStockVariantItem.fromJson(json);
}

/// @nodoc
mixin _$LowStockVariantItem {
  @JsonKey(name: 'variant_id')
  String get variantId => throw _privateConstructorUsedError;
  String get sku => throw _privateConstructorUsedError;
  String get size => throw _privateConstructorUsedError;
  @JsonKey(name: 'color_name')
  String get colorName => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_quantity')
  int get stockQuantity => throw _privateConstructorUsedError;
  @JsonKey(name: 'product_name')
  String get productName => throw _privateConstructorUsedError;
  @JsonKey(name: 'product_id')
  String? get productId => throw _privateConstructorUsedError;

  /// Serializes this LowStockVariantItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LowStockVariantItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LowStockVariantItemCopyWith<LowStockVariantItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LowStockVariantItemCopyWith<$Res> {
  factory $LowStockVariantItemCopyWith(
    LowStockVariantItem value,
    $Res Function(LowStockVariantItem) then,
  ) = _$LowStockVariantItemCopyWithImpl<$Res, LowStockVariantItem>;
  @useResult
  $Res call({
    @JsonKey(name: 'variant_id') String variantId,
    String sku,
    String size,
    @JsonKey(name: 'color_name') String colorName,
    @JsonKey(name: 'stock_quantity') int stockQuantity,
    @JsonKey(name: 'product_name') String productName,
    @JsonKey(name: 'product_id') String? productId,
  });
}

/// @nodoc
class _$LowStockVariantItemCopyWithImpl<$Res, $Val extends LowStockVariantItem>
    implements $LowStockVariantItemCopyWith<$Res> {
  _$LowStockVariantItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LowStockVariantItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? variantId = null,
    Object? sku = null,
    Object? size = null,
    Object? colorName = null,
    Object? stockQuantity = null,
    Object? productName = null,
    Object? productId = freezed,
  }) {
    return _then(
      _value.copyWith(
            variantId: null == variantId
                ? _value.variantId
                : variantId // ignore: cast_nullable_to_non_nullable
                      as String,
            sku: null == sku
                ? _value.sku
                : sku // ignore: cast_nullable_to_non_nullable
                      as String,
            size: null == size
                ? _value.size
                : size // ignore: cast_nullable_to_non_nullable
                      as String,
            colorName: null == colorName
                ? _value.colorName
                : colorName // ignore: cast_nullable_to_non_nullable
                      as String,
            stockQuantity: null == stockQuantity
                ? _value.stockQuantity
                : stockQuantity // ignore: cast_nullable_to_non_nullable
                      as int,
            productName: null == productName
                ? _value.productName
                : productName // ignore: cast_nullable_to_non_nullable
                      as String,
            productId: freezed == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LowStockVariantItemImplCopyWith<$Res>
    implements $LowStockVariantItemCopyWith<$Res> {
  factory _$$LowStockVariantItemImplCopyWith(
    _$LowStockVariantItemImpl value,
    $Res Function(_$LowStockVariantItemImpl) then,
  ) = __$$LowStockVariantItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'variant_id') String variantId,
    String sku,
    String size,
    @JsonKey(name: 'color_name') String colorName,
    @JsonKey(name: 'stock_quantity') int stockQuantity,
    @JsonKey(name: 'product_name') String productName,
    @JsonKey(name: 'product_id') String? productId,
  });
}

/// @nodoc
class __$$LowStockVariantItemImplCopyWithImpl<$Res>
    extends _$LowStockVariantItemCopyWithImpl<$Res, _$LowStockVariantItemImpl>
    implements _$$LowStockVariantItemImplCopyWith<$Res> {
  __$$LowStockVariantItemImplCopyWithImpl(
    _$LowStockVariantItemImpl _value,
    $Res Function(_$LowStockVariantItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LowStockVariantItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? variantId = null,
    Object? sku = null,
    Object? size = null,
    Object? colorName = null,
    Object? stockQuantity = null,
    Object? productName = null,
    Object? productId = freezed,
  }) {
    return _then(
      _$LowStockVariantItemImpl(
        variantId: null == variantId
            ? _value.variantId
            : variantId // ignore: cast_nullable_to_non_nullable
                  as String,
        sku: null == sku
            ? _value.sku
            : sku // ignore: cast_nullable_to_non_nullable
                  as String,
        size: null == size
            ? _value.size
            : size // ignore: cast_nullable_to_non_nullable
                  as String,
        colorName: null == colorName
            ? _value.colorName
            : colorName // ignore: cast_nullable_to_non_nullable
                  as String,
        stockQuantity: null == stockQuantity
            ? _value.stockQuantity
            : stockQuantity // ignore: cast_nullable_to_non_nullable
                  as int,
        productName: null == productName
            ? _value.productName
            : productName // ignore: cast_nullable_to_non_nullable
                  as String,
        productId: freezed == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LowStockVariantItemImpl implements _LowStockVariantItem {
  const _$LowStockVariantItemImpl({
    @JsonKey(name: 'variant_id') required this.variantId,
    required this.sku,
    required this.size,
    @JsonKey(name: 'color_name') required this.colorName,
    @JsonKey(name: 'stock_quantity') required this.stockQuantity,
    @JsonKey(name: 'product_name') required this.productName,
    @JsonKey(name: 'product_id') this.productId,
  });

  factory _$LowStockVariantItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$LowStockVariantItemImplFromJson(json);

  @override
  @JsonKey(name: 'variant_id')
  final String variantId;
  @override
  final String sku;
  @override
  final String size;
  @override
  @JsonKey(name: 'color_name')
  final String colorName;
  @override
  @JsonKey(name: 'stock_quantity')
  final int stockQuantity;
  @override
  @JsonKey(name: 'product_name')
  final String productName;
  @override
  @JsonKey(name: 'product_id')
  final String? productId;

  @override
  String toString() {
    return 'LowStockVariantItem(variantId: $variantId, sku: $sku, size: $size, colorName: $colorName, stockQuantity: $stockQuantity, productName: $productName, productId: $productId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LowStockVariantItemImpl &&
            (identical(other.variantId, variantId) ||
                other.variantId == variantId) &&
            (identical(other.sku, sku) || other.sku == sku) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.colorName, colorName) ||
                other.colorName == colorName) &&
            (identical(other.stockQuantity, stockQuantity) ||
                other.stockQuantity == stockQuantity) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.productId, productId) ||
                other.productId == productId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    variantId,
    sku,
    size,
    colorName,
    stockQuantity,
    productName,
    productId,
  );

  /// Create a copy of LowStockVariantItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LowStockVariantItemImplCopyWith<_$LowStockVariantItemImpl> get copyWith =>
      __$$LowStockVariantItemImplCopyWithImpl<_$LowStockVariantItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LowStockVariantItemImplToJson(this);
  }
}

abstract class _LowStockVariantItem implements LowStockVariantItem {
  const factory _LowStockVariantItem({
    @JsonKey(name: 'variant_id') required final String variantId,
    required final String sku,
    required final String size,
    @JsonKey(name: 'color_name') required final String colorName,
    @JsonKey(name: 'stock_quantity') required final int stockQuantity,
    @JsonKey(name: 'product_name') required final String productName,
    @JsonKey(name: 'product_id') final String? productId,
  }) = _$LowStockVariantItemImpl;

  factory _LowStockVariantItem.fromJson(Map<String, dynamic> json) =
      _$LowStockVariantItemImpl.fromJson;

  @override
  @JsonKey(name: 'variant_id')
  String get variantId;
  @override
  String get sku;
  @override
  String get size;
  @override
  @JsonKey(name: 'color_name')
  String get colorName;
  @override
  @JsonKey(name: 'stock_quantity')
  int get stockQuantity;
  @override
  @JsonKey(name: 'product_name')
  String get productName;
  @override
  @JsonKey(name: 'product_id')
  String? get productId;

  /// Create a copy of LowStockVariantItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LowStockVariantItemImplCopyWith<_$LowStockVariantItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RecentOrderItem _$RecentOrderItemFromJson(Map<String, dynamic> json) {
  return _RecentOrderItem.fromJson(json);
}

/// @nodoc
mixin _$RecentOrderItem {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'order_code')
  String get orderCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'recipient_name')
  String get recipientName => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_amount')
  int get totalAmount => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_status')
  String get paymentStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this RecentOrderItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecentOrderItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecentOrderItemCopyWith<RecentOrderItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecentOrderItemCopyWith<$Res> {
  factory $RecentOrderItemCopyWith(
    RecentOrderItem value,
    $Res Function(RecentOrderItem) then,
  ) = _$RecentOrderItemCopyWithImpl<$Res, RecentOrderItem>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'order_code') String orderCode,
    @JsonKey(name: 'recipient_name') String recipientName,
    @JsonKey(name: 'total_amount') int totalAmount,
    String status,
    @JsonKey(name: 'payment_status') String paymentStatus,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$RecentOrderItemCopyWithImpl<$Res, $Val extends RecentOrderItem>
    implements $RecentOrderItemCopyWith<$Res> {
  _$RecentOrderItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecentOrderItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderCode = null,
    Object? recipientName = null,
    Object? totalAmount = null,
    Object? status = null,
    Object? paymentStatus = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            orderCode: null == orderCode
                ? _value.orderCode
                : orderCode // ignore: cast_nullable_to_non_nullable
                      as String,
            recipientName: null == recipientName
                ? _value.recipientName
                : recipientName // ignore: cast_nullable_to_non_nullable
                      as String,
            totalAmount: null == totalAmount
                ? _value.totalAmount
                : totalAmount // ignore: cast_nullable_to_non_nullable
                      as int,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            paymentStatus: null == paymentStatus
                ? _value.paymentStatus
                : paymentStatus // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RecentOrderItemImplCopyWith<$Res>
    implements $RecentOrderItemCopyWith<$Res> {
  factory _$$RecentOrderItemImplCopyWith(
    _$RecentOrderItemImpl value,
    $Res Function(_$RecentOrderItemImpl) then,
  ) = __$$RecentOrderItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'order_code') String orderCode,
    @JsonKey(name: 'recipient_name') String recipientName,
    @JsonKey(name: 'total_amount') int totalAmount,
    String status,
    @JsonKey(name: 'payment_status') String paymentStatus,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$RecentOrderItemImplCopyWithImpl<$Res>
    extends _$RecentOrderItemCopyWithImpl<$Res, _$RecentOrderItemImpl>
    implements _$$RecentOrderItemImplCopyWith<$Res> {
  __$$RecentOrderItemImplCopyWithImpl(
    _$RecentOrderItemImpl _value,
    $Res Function(_$RecentOrderItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RecentOrderItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderCode = null,
    Object? recipientName = null,
    Object? totalAmount = null,
    Object? status = null,
    Object? paymentStatus = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$RecentOrderItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orderCode: null == orderCode
            ? _value.orderCode
            : orderCode // ignore: cast_nullable_to_non_nullable
                  as String,
        recipientName: null == recipientName
            ? _value.recipientName
            : recipientName // ignore: cast_nullable_to_non_nullable
                  as String,
        totalAmount: null == totalAmount
            ? _value.totalAmount
            : totalAmount // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        paymentStatus: null == paymentStatus
            ? _value.paymentStatus
            : paymentStatus // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RecentOrderItemImpl implements _RecentOrderItem {
  const _$RecentOrderItemImpl({
    required this.id,
    @JsonKey(name: 'order_code') required this.orderCode,
    @JsonKey(name: 'recipient_name') required this.recipientName,
    @JsonKey(name: 'total_amount') required this.totalAmount,
    required this.status,
    @JsonKey(name: 'payment_status') this.paymentStatus = 'unpaid',
    @JsonKey(name: 'created_at') required this.createdAt,
  });

  factory _$RecentOrderItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecentOrderItemImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'order_code')
  final String orderCode;
  @override
  @JsonKey(name: 'recipient_name')
  final String recipientName;
  @override
  @JsonKey(name: 'total_amount')
  final int totalAmount;
  @override
  final String status;
  @override
  @JsonKey(name: 'payment_status')
  final String paymentStatus;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'RecentOrderItem(id: $id, orderCode: $orderCode, recipientName: $recipientName, totalAmount: $totalAmount, status: $status, paymentStatus: $paymentStatus, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecentOrderItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderCode, orderCode) ||
                other.orderCode == orderCode) &&
            (identical(other.recipientName, recipientName) ||
                other.recipientName == recipientName) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    orderCode,
    recipientName,
    totalAmount,
    status,
    paymentStatus,
    createdAt,
  );

  /// Create a copy of RecentOrderItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecentOrderItemImplCopyWith<_$RecentOrderItemImpl> get copyWith =>
      __$$RecentOrderItemImplCopyWithImpl<_$RecentOrderItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RecentOrderItemImplToJson(this);
  }
}

abstract class _RecentOrderItem implements RecentOrderItem {
  const factory _RecentOrderItem({
    required final String id,
    @JsonKey(name: 'order_code') required final String orderCode,
    @JsonKey(name: 'recipient_name') required final String recipientName,
    @JsonKey(name: 'total_amount') required final int totalAmount,
    required final String status,
    @JsonKey(name: 'payment_status') final String paymentStatus,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$RecentOrderItemImpl;

  factory _RecentOrderItem.fromJson(Map<String, dynamic> json) =
      _$RecentOrderItemImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'order_code')
  String get orderCode;
  @override
  @JsonKey(name: 'recipient_name')
  String get recipientName;
  @override
  @JsonKey(name: 'total_amount')
  int get totalAmount;
  @override
  String get status;
  @override
  @JsonKey(name: 'payment_status')
  String get paymentStatus;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of RecentOrderItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecentOrderItemImplCopyWith<_$RecentOrderItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DashboardMetrics _$DashboardMetricsFromJson(Map<String, dynamic> json) {
  return _DashboardMetrics.fromJson(json);
}

/// @nodoc
mixin _$DashboardMetrics {
  @JsonKey(name: 'delivered_revenue')
  int get deliveredRevenue => throw _privateConstructorUsedError;
  @JsonKey(name: 'low_stock_threshold')
  int get lowStockThreshold => throw _privateConstructorUsedError;
  @JsonKey(name: 'status_counts')
  Map<String, int> get statusCounts => throw _privateConstructorUsedError;
  @JsonKey(name: 'best_sellers')
  List<BestSellerItem> get bestSellers => throw _privateConstructorUsedError;
  @JsonKey(name: 'low_stock_variants')
  List<LowStockVariantItem> get lowStockVariants =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'recent_orders')
  List<RecentOrderItem> get recentOrders => throw _privateConstructorUsedError;

  /// Serializes this DashboardMetrics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DashboardMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DashboardMetricsCopyWith<DashboardMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardMetricsCopyWith<$Res> {
  factory $DashboardMetricsCopyWith(
    DashboardMetrics value,
    $Res Function(DashboardMetrics) then,
  ) = _$DashboardMetricsCopyWithImpl<$Res, DashboardMetrics>;
  @useResult
  $Res call({
    @JsonKey(name: 'delivered_revenue') int deliveredRevenue,
    @JsonKey(name: 'low_stock_threshold') int lowStockThreshold,
    @JsonKey(name: 'status_counts') Map<String, int> statusCounts,
    @JsonKey(name: 'best_sellers') List<BestSellerItem> bestSellers,
    @JsonKey(name: 'low_stock_variants')
    List<LowStockVariantItem> lowStockVariants,
    @JsonKey(name: 'recent_orders') List<RecentOrderItem> recentOrders,
  });
}

/// @nodoc
class _$DashboardMetricsCopyWithImpl<$Res, $Val extends DashboardMetrics>
    implements $DashboardMetricsCopyWith<$Res> {
  _$DashboardMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DashboardMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deliveredRevenue = null,
    Object? lowStockThreshold = null,
    Object? statusCounts = null,
    Object? bestSellers = null,
    Object? lowStockVariants = null,
    Object? recentOrders = null,
  }) {
    return _then(
      _value.copyWith(
            deliveredRevenue: null == deliveredRevenue
                ? _value.deliveredRevenue
                : deliveredRevenue // ignore: cast_nullable_to_non_nullable
                      as int,
            lowStockThreshold: null == lowStockThreshold
                ? _value.lowStockThreshold
                : lowStockThreshold // ignore: cast_nullable_to_non_nullable
                      as int,
            statusCounts: null == statusCounts
                ? _value.statusCounts
                : statusCounts // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            bestSellers: null == bestSellers
                ? _value.bestSellers
                : bestSellers // ignore: cast_nullable_to_non_nullable
                      as List<BestSellerItem>,
            lowStockVariants: null == lowStockVariants
                ? _value.lowStockVariants
                : lowStockVariants // ignore: cast_nullable_to_non_nullable
                      as List<LowStockVariantItem>,
            recentOrders: null == recentOrders
                ? _value.recentOrders
                : recentOrders // ignore: cast_nullable_to_non_nullable
                      as List<RecentOrderItem>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DashboardMetricsImplCopyWith<$Res>
    implements $DashboardMetricsCopyWith<$Res> {
  factory _$$DashboardMetricsImplCopyWith(
    _$DashboardMetricsImpl value,
    $Res Function(_$DashboardMetricsImpl) then,
  ) = __$$DashboardMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'delivered_revenue') int deliveredRevenue,
    @JsonKey(name: 'low_stock_threshold') int lowStockThreshold,
    @JsonKey(name: 'status_counts') Map<String, int> statusCounts,
    @JsonKey(name: 'best_sellers') List<BestSellerItem> bestSellers,
    @JsonKey(name: 'low_stock_variants')
    List<LowStockVariantItem> lowStockVariants,
    @JsonKey(name: 'recent_orders') List<RecentOrderItem> recentOrders,
  });
}

/// @nodoc
class __$$DashboardMetricsImplCopyWithImpl<$Res>
    extends _$DashboardMetricsCopyWithImpl<$Res, _$DashboardMetricsImpl>
    implements _$$DashboardMetricsImplCopyWith<$Res> {
  __$$DashboardMetricsImplCopyWithImpl(
    _$DashboardMetricsImpl _value,
    $Res Function(_$DashboardMetricsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DashboardMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deliveredRevenue = null,
    Object? lowStockThreshold = null,
    Object? statusCounts = null,
    Object? bestSellers = null,
    Object? lowStockVariants = null,
    Object? recentOrders = null,
  }) {
    return _then(
      _$DashboardMetricsImpl(
        deliveredRevenue: null == deliveredRevenue
            ? _value.deliveredRevenue
            : deliveredRevenue // ignore: cast_nullable_to_non_nullable
                  as int,
        lowStockThreshold: null == lowStockThreshold
            ? _value.lowStockThreshold
            : lowStockThreshold // ignore: cast_nullable_to_non_nullable
                  as int,
        statusCounts: null == statusCounts
            ? _value._statusCounts
            : statusCounts // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        bestSellers: null == bestSellers
            ? _value._bestSellers
            : bestSellers // ignore: cast_nullable_to_non_nullable
                  as List<BestSellerItem>,
        lowStockVariants: null == lowStockVariants
            ? _value._lowStockVariants
            : lowStockVariants // ignore: cast_nullable_to_non_nullable
                  as List<LowStockVariantItem>,
        recentOrders: null == recentOrders
            ? _value._recentOrders
            : recentOrders // ignore: cast_nullable_to_non_nullable
                  as List<RecentOrderItem>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardMetricsImpl extends _DashboardMetrics {
  const _$DashboardMetricsImpl({
    @JsonKey(name: 'delivered_revenue') this.deliveredRevenue = 0,
    @JsonKey(name: 'low_stock_threshold') this.lowStockThreshold = 5,
    @JsonKey(name: 'status_counts')
    final Map<String, int> statusCounts = const {},
    @JsonKey(name: 'best_sellers')
    final List<BestSellerItem> bestSellers = const [],
    @JsonKey(name: 'low_stock_variants')
    final List<LowStockVariantItem> lowStockVariants = const [],
    @JsonKey(name: 'recent_orders')
    final List<RecentOrderItem> recentOrders = const [],
  }) : _statusCounts = statusCounts,
       _bestSellers = bestSellers,
       _lowStockVariants = lowStockVariants,
       _recentOrders = recentOrders,
       super._();

  factory _$DashboardMetricsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardMetricsImplFromJson(json);

  @override
  @JsonKey(name: 'delivered_revenue')
  final int deliveredRevenue;
  @override
  @JsonKey(name: 'low_stock_threshold')
  final int lowStockThreshold;
  final Map<String, int> _statusCounts;
  @override
  @JsonKey(name: 'status_counts')
  Map<String, int> get statusCounts {
    if (_statusCounts is EqualUnmodifiableMapView) return _statusCounts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_statusCounts);
  }

  final List<BestSellerItem> _bestSellers;
  @override
  @JsonKey(name: 'best_sellers')
  List<BestSellerItem> get bestSellers {
    if (_bestSellers is EqualUnmodifiableListView) return _bestSellers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_bestSellers);
  }

  final List<LowStockVariantItem> _lowStockVariants;
  @override
  @JsonKey(name: 'low_stock_variants')
  List<LowStockVariantItem> get lowStockVariants {
    if (_lowStockVariants is EqualUnmodifiableListView)
      return _lowStockVariants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lowStockVariants);
  }

  final List<RecentOrderItem> _recentOrders;
  @override
  @JsonKey(name: 'recent_orders')
  List<RecentOrderItem> get recentOrders {
    if (_recentOrders is EqualUnmodifiableListView) return _recentOrders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentOrders);
  }

  @override
  String toString() {
    return 'DashboardMetrics(deliveredRevenue: $deliveredRevenue, lowStockThreshold: $lowStockThreshold, statusCounts: $statusCounts, bestSellers: $bestSellers, lowStockVariants: $lowStockVariants, recentOrders: $recentOrders)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardMetricsImpl &&
            (identical(other.deliveredRevenue, deliveredRevenue) ||
                other.deliveredRevenue == deliveredRevenue) &&
            (identical(other.lowStockThreshold, lowStockThreshold) ||
                other.lowStockThreshold == lowStockThreshold) &&
            const DeepCollectionEquality().equals(
              other._statusCounts,
              _statusCounts,
            ) &&
            const DeepCollectionEquality().equals(
              other._bestSellers,
              _bestSellers,
            ) &&
            const DeepCollectionEquality().equals(
              other._lowStockVariants,
              _lowStockVariants,
            ) &&
            const DeepCollectionEquality().equals(
              other._recentOrders,
              _recentOrders,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    deliveredRevenue,
    lowStockThreshold,
    const DeepCollectionEquality().hash(_statusCounts),
    const DeepCollectionEquality().hash(_bestSellers),
    const DeepCollectionEquality().hash(_lowStockVariants),
    const DeepCollectionEquality().hash(_recentOrders),
  );

  /// Create a copy of DashboardMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardMetricsImplCopyWith<_$DashboardMetricsImpl> get copyWith =>
      __$$DashboardMetricsImplCopyWithImpl<_$DashboardMetricsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardMetricsImplToJson(this);
  }
}

abstract class _DashboardMetrics extends DashboardMetrics {
  const factory _DashboardMetrics({
    @JsonKey(name: 'delivered_revenue') final int deliveredRevenue,
    @JsonKey(name: 'low_stock_threshold') final int lowStockThreshold,
    @JsonKey(name: 'status_counts') final Map<String, int> statusCounts,
    @JsonKey(name: 'best_sellers') final List<BestSellerItem> bestSellers,
    @JsonKey(name: 'low_stock_variants')
    final List<LowStockVariantItem> lowStockVariants,
    @JsonKey(name: 'recent_orders') final List<RecentOrderItem> recentOrders,
  }) = _$DashboardMetricsImpl;
  const _DashboardMetrics._() : super._();

  factory _DashboardMetrics.fromJson(Map<String, dynamic> json) =
      _$DashboardMetricsImpl.fromJson;

  @override
  @JsonKey(name: 'delivered_revenue')
  int get deliveredRevenue;
  @override
  @JsonKey(name: 'low_stock_threshold')
  int get lowStockThreshold;
  @override
  @JsonKey(name: 'status_counts')
  Map<String, int> get statusCounts;
  @override
  @JsonKey(name: 'best_sellers')
  List<BestSellerItem> get bestSellers;
  @override
  @JsonKey(name: 'low_stock_variants')
  List<LowStockVariantItem> get lowStockVariants;
  @override
  @JsonKey(name: 'recent_orders')
  List<RecentOrderItem> get recentOrders;

  /// Create a copy of DashboardMetrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardMetricsImplCopyWith<_$DashboardMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
