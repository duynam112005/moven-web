// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Order _$OrderFromJson(Map<String, dynamic> json) {
  return _Order.fromJson(json);
}

/// @nodoc
mixin _$Order {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'order_code')
  String get orderCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  OrderStatus get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_method')
  String get paymentMethod => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_status')
  String get paymentStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'recipient_name')
  String get recipientName => throw _privateConstructorUsedError;
  @JsonKey(name: 'recipient_phone')
  String get recipientPhone => throw _privateConstructorUsedError;
  @JsonKey(name: 'shipping_address')
  Map<String, dynamic> get shippingAddress =>
      throw _privateConstructorUsedError;
  int get subtotal => throw _privateConstructorUsedError;
  @JsonKey(name: 'shipping_fee')
  int get shippingFee => throw _privateConstructorUsedError;
  @JsonKey(name: 'discount_amount')
  int get discountAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_amount')
  int get totalAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_note')
  String? get customerNote => throw _privateConstructorUsedError;
  @JsonKey(name: 'cancellation_reason')
  String? get cancellationReason => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'cancelled_at')
  DateTime? get cancelledAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'delivered_at')
  DateTime? get deliveredAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'order_items')
  List<OrderItem> get items => throw _privateConstructorUsedError;
  @JsonKey(name: 'order_status_history')
  List<OrderStatusHistory> get statusHistory =>
      throw _privateConstructorUsedError;

  /// Serializes this Order to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderCopyWith<Order> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderCopyWith<$Res> {
  factory $OrderCopyWith(Order value, $Res Function(Order) then) =
      _$OrderCopyWithImpl<$Res, Order>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'order_code') String orderCode,
    @JsonKey(name: 'user_id') String userId,
    OrderStatus status,
    @JsonKey(name: 'payment_method') String paymentMethod,
    @JsonKey(name: 'payment_status') String paymentStatus,
    @JsonKey(name: 'recipient_name') String recipientName,
    @JsonKey(name: 'recipient_phone') String recipientPhone,
    @JsonKey(name: 'shipping_address') Map<String, dynamic> shippingAddress,
    int subtotal,
    @JsonKey(name: 'shipping_fee') int shippingFee,
    @JsonKey(name: 'discount_amount') int discountAmount,
    @JsonKey(name: 'total_amount') int totalAmount,
    @JsonKey(name: 'customer_note') String? customerNote,
    @JsonKey(name: 'cancellation_reason') String? cancellationReason,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
    @JsonKey(name: 'cancelled_at') DateTime? cancelledAt,
    @JsonKey(name: 'delivered_at') DateTime? deliveredAt,
    @JsonKey(name: 'order_items') List<OrderItem> items,
    @JsonKey(name: 'order_status_history')
    List<OrderStatusHistory> statusHistory,
  });
}

/// @nodoc
class _$OrderCopyWithImpl<$Res, $Val extends Order>
    implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderCode = null,
    Object? userId = null,
    Object? status = null,
    Object? paymentMethod = null,
    Object? paymentStatus = null,
    Object? recipientName = null,
    Object? recipientPhone = null,
    Object? shippingAddress = null,
    Object? subtotal = null,
    Object? shippingFee = null,
    Object? discountAmount = null,
    Object? totalAmount = null,
    Object? customerNote = freezed,
    Object? cancellationReason = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? cancelledAt = freezed,
    Object? deliveredAt = freezed,
    Object? items = null,
    Object? statusHistory = null,
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
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as OrderStatus,
            paymentMethod: null == paymentMethod
                ? _value.paymentMethod
                : paymentMethod // ignore: cast_nullable_to_non_nullable
                      as String,
            paymentStatus: null == paymentStatus
                ? _value.paymentStatus
                : paymentStatus // ignore: cast_nullable_to_non_nullable
                      as String,
            recipientName: null == recipientName
                ? _value.recipientName
                : recipientName // ignore: cast_nullable_to_non_nullable
                      as String,
            recipientPhone: null == recipientPhone
                ? _value.recipientPhone
                : recipientPhone // ignore: cast_nullable_to_non_nullable
                      as String,
            shippingAddress: null == shippingAddress
                ? _value.shippingAddress
                : shippingAddress // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            subtotal: null == subtotal
                ? _value.subtotal
                : subtotal // ignore: cast_nullable_to_non_nullable
                      as int,
            shippingFee: null == shippingFee
                ? _value.shippingFee
                : shippingFee // ignore: cast_nullable_to_non_nullable
                      as int,
            discountAmount: null == discountAmount
                ? _value.discountAmount
                : discountAmount // ignore: cast_nullable_to_non_nullable
                      as int,
            totalAmount: null == totalAmount
                ? _value.totalAmount
                : totalAmount // ignore: cast_nullable_to_non_nullable
                      as int,
            customerNote: freezed == customerNote
                ? _value.customerNote
                : customerNote // ignore: cast_nullable_to_non_nullable
                      as String?,
            cancellationReason: freezed == cancellationReason
                ? _value.cancellationReason
                : cancellationReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            cancelledAt: freezed == cancelledAt
                ? _value.cancelledAt
                : cancelledAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            deliveredAt: freezed == deliveredAt
                ? _value.deliveredAt
                : deliveredAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<OrderItem>,
            statusHistory: null == statusHistory
                ? _value.statusHistory
                : statusHistory // ignore: cast_nullable_to_non_nullable
                      as List<OrderStatusHistory>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OrderImplCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$$OrderImplCopyWith(
    _$OrderImpl value,
    $Res Function(_$OrderImpl) then,
  ) = __$$OrderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'order_code') String orderCode,
    @JsonKey(name: 'user_id') String userId,
    OrderStatus status,
    @JsonKey(name: 'payment_method') String paymentMethod,
    @JsonKey(name: 'payment_status') String paymentStatus,
    @JsonKey(name: 'recipient_name') String recipientName,
    @JsonKey(name: 'recipient_phone') String recipientPhone,
    @JsonKey(name: 'shipping_address') Map<String, dynamic> shippingAddress,
    int subtotal,
    @JsonKey(name: 'shipping_fee') int shippingFee,
    @JsonKey(name: 'discount_amount') int discountAmount,
    @JsonKey(name: 'total_amount') int totalAmount,
    @JsonKey(name: 'customer_note') String? customerNote,
    @JsonKey(name: 'cancellation_reason') String? cancellationReason,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
    @JsonKey(name: 'cancelled_at') DateTime? cancelledAt,
    @JsonKey(name: 'delivered_at') DateTime? deliveredAt,
    @JsonKey(name: 'order_items') List<OrderItem> items,
    @JsonKey(name: 'order_status_history')
    List<OrderStatusHistory> statusHistory,
  });
}

/// @nodoc
class __$$OrderImplCopyWithImpl<$Res>
    extends _$OrderCopyWithImpl<$Res, _$OrderImpl>
    implements _$$OrderImplCopyWith<$Res> {
  __$$OrderImplCopyWithImpl(
    _$OrderImpl _value,
    $Res Function(_$OrderImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderCode = null,
    Object? userId = null,
    Object? status = null,
    Object? paymentMethod = null,
    Object? paymentStatus = null,
    Object? recipientName = null,
    Object? recipientPhone = null,
    Object? shippingAddress = null,
    Object? subtotal = null,
    Object? shippingFee = null,
    Object? discountAmount = null,
    Object? totalAmount = null,
    Object? customerNote = freezed,
    Object? cancellationReason = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? cancelledAt = freezed,
    Object? deliveredAt = freezed,
    Object? items = null,
    Object? statusHistory = null,
  }) {
    return _then(
      _$OrderImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orderCode: null == orderCode
            ? _value.orderCode
            : orderCode // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as OrderStatus,
        paymentMethod: null == paymentMethod
            ? _value.paymentMethod
            : paymentMethod // ignore: cast_nullable_to_non_nullable
                  as String,
        paymentStatus: null == paymentStatus
            ? _value.paymentStatus
            : paymentStatus // ignore: cast_nullable_to_non_nullable
                  as String,
        recipientName: null == recipientName
            ? _value.recipientName
            : recipientName // ignore: cast_nullable_to_non_nullable
                  as String,
        recipientPhone: null == recipientPhone
            ? _value.recipientPhone
            : recipientPhone // ignore: cast_nullable_to_non_nullable
                  as String,
        shippingAddress: null == shippingAddress
            ? _value._shippingAddress
            : shippingAddress // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        subtotal: null == subtotal
            ? _value.subtotal
            : subtotal // ignore: cast_nullable_to_non_nullable
                  as int,
        shippingFee: null == shippingFee
            ? _value.shippingFee
            : shippingFee // ignore: cast_nullable_to_non_nullable
                  as int,
        discountAmount: null == discountAmount
            ? _value.discountAmount
            : discountAmount // ignore: cast_nullable_to_non_nullable
                  as int,
        totalAmount: null == totalAmount
            ? _value.totalAmount
            : totalAmount // ignore: cast_nullable_to_non_nullable
                  as int,
        customerNote: freezed == customerNote
            ? _value.customerNote
            : customerNote // ignore: cast_nullable_to_non_nullable
                  as String?,
        cancellationReason: freezed == cancellationReason
            ? _value.cancellationReason
            : cancellationReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        cancelledAt: freezed == cancelledAt
            ? _value.cancelledAt
            : cancelledAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        deliveredAt: freezed == deliveredAt
            ? _value.deliveredAt
            : deliveredAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<OrderItem>,
        statusHistory: null == statusHistory
            ? _value._statusHistory
            : statusHistory // ignore: cast_nullable_to_non_nullable
                  as List<OrderStatusHistory>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderImpl extends _Order {
  const _$OrderImpl({
    required this.id,
    @JsonKey(name: 'order_code') required this.orderCode,
    @JsonKey(name: 'user_id') required this.userId,
    required this.status,
    @JsonKey(name: 'payment_method') this.paymentMethod = 'cod',
    @JsonKey(name: 'payment_status') this.paymentStatus = 'unpaid',
    @JsonKey(name: 'recipient_name') required this.recipientName,
    @JsonKey(name: 'recipient_phone') required this.recipientPhone,
    @JsonKey(name: 'shipping_address')
    final Map<String, dynamic> shippingAddress = const {},
    required this.subtotal,
    @JsonKey(name: 'shipping_fee') this.shippingFee = 20000,
    @JsonKey(name: 'discount_amount') this.discountAmount = 0,
    @JsonKey(name: 'total_amount') required this.totalAmount,
    @JsonKey(name: 'customer_note') this.customerNote,
    @JsonKey(name: 'cancellation_reason') this.cancellationReason,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
    @JsonKey(name: 'cancelled_at') this.cancelledAt,
    @JsonKey(name: 'delivered_at') this.deliveredAt,
    @JsonKey(name: 'order_items') final List<OrderItem> items = const [],
    @JsonKey(name: 'order_status_history')
    final List<OrderStatusHistory> statusHistory = const [],
  }) : _shippingAddress = shippingAddress,
       _items = items,
       _statusHistory = statusHistory,
       super._();

  factory _$OrderImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'order_code')
  final String orderCode;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final OrderStatus status;
  @override
  @JsonKey(name: 'payment_method')
  final String paymentMethod;
  @override
  @JsonKey(name: 'payment_status')
  final String paymentStatus;
  @override
  @JsonKey(name: 'recipient_name')
  final String recipientName;
  @override
  @JsonKey(name: 'recipient_phone')
  final String recipientPhone;
  final Map<String, dynamic> _shippingAddress;
  @override
  @JsonKey(name: 'shipping_address')
  Map<String, dynamic> get shippingAddress {
    if (_shippingAddress is EqualUnmodifiableMapView) return _shippingAddress;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_shippingAddress);
  }

  @override
  final int subtotal;
  @override
  @JsonKey(name: 'shipping_fee')
  final int shippingFee;
  @override
  @JsonKey(name: 'discount_amount')
  final int discountAmount;
  @override
  @JsonKey(name: 'total_amount')
  final int totalAmount;
  @override
  @JsonKey(name: 'customer_note')
  final String? customerNote;
  @override
  @JsonKey(name: 'cancellation_reason')
  final String? cancellationReason;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @override
  @JsonKey(name: 'cancelled_at')
  final DateTime? cancelledAt;
  @override
  @JsonKey(name: 'delivered_at')
  final DateTime? deliveredAt;
  final List<OrderItem> _items;
  @override
  @JsonKey(name: 'order_items')
  List<OrderItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  final List<OrderStatusHistory> _statusHistory;
  @override
  @JsonKey(name: 'order_status_history')
  List<OrderStatusHistory> get statusHistory {
    if (_statusHistory is EqualUnmodifiableListView) return _statusHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_statusHistory);
  }

  @override
  String toString() {
    return 'Order(id: $id, orderCode: $orderCode, userId: $userId, status: $status, paymentMethod: $paymentMethod, paymentStatus: $paymentStatus, recipientName: $recipientName, recipientPhone: $recipientPhone, shippingAddress: $shippingAddress, subtotal: $subtotal, shippingFee: $shippingFee, discountAmount: $discountAmount, totalAmount: $totalAmount, customerNote: $customerNote, cancellationReason: $cancellationReason, createdAt: $createdAt, updatedAt: $updatedAt, cancelledAt: $cancelledAt, deliveredAt: $deliveredAt, items: $items, statusHistory: $statusHistory)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderCode, orderCode) ||
                other.orderCode == orderCode) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.recipientName, recipientName) ||
                other.recipientName == recipientName) &&
            (identical(other.recipientPhone, recipientPhone) ||
                other.recipientPhone == recipientPhone) &&
            const DeepCollectionEquality().equals(
              other._shippingAddress,
              _shippingAddress,
            ) &&
            (identical(other.subtotal, subtotal) ||
                other.subtotal == subtotal) &&
            (identical(other.shippingFee, shippingFee) ||
                other.shippingFee == shippingFee) &&
            (identical(other.discountAmount, discountAmount) ||
                other.discountAmount == discountAmount) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.customerNote, customerNote) ||
                other.customerNote == customerNote) &&
            (identical(other.cancellationReason, cancellationReason) ||
                other.cancellationReason == cancellationReason) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.cancelledAt, cancelledAt) ||
                other.cancelledAt == cancelledAt) &&
            (identical(other.deliveredAt, deliveredAt) ||
                other.deliveredAt == deliveredAt) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            const DeepCollectionEquality().equals(
              other._statusHistory,
              _statusHistory,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    orderCode,
    userId,
    status,
    paymentMethod,
    paymentStatus,
    recipientName,
    recipientPhone,
    const DeepCollectionEquality().hash(_shippingAddress),
    subtotal,
    shippingFee,
    discountAmount,
    totalAmount,
    customerNote,
    cancellationReason,
    createdAt,
    updatedAt,
    cancelledAt,
    deliveredAt,
    const DeepCollectionEquality().hash(_items),
    const DeepCollectionEquality().hash(_statusHistory),
  ]);

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderImplCopyWith<_$OrderImpl> get copyWith =>
      __$$OrderImplCopyWithImpl<_$OrderImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderImplToJson(this);
  }
}

abstract class _Order extends Order {
  const factory _Order({
    required final String id,
    @JsonKey(name: 'order_code') required final String orderCode,
    @JsonKey(name: 'user_id') required final String userId,
    required final OrderStatus status,
    @JsonKey(name: 'payment_method') final String paymentMethod,
    @JsonKey(name: 'payment_status') final String paymentStatus,
    @JsonKey(name: 'recipient_name') required final String recipientName,
    @JsonKey(name: 'recipient_phone') required final String recipientPhone,
    @JsonKey(name: 'shipping_address')
    final Map<String, dynamic> shippingAddress,
    required final int subtotal,
    @JsonKey(name: 'shipping_fee') final int shippingFee,
    @JsonKey(name: 'discount_amount') final int discountAmount,
    @JsonKey(name: 'total_amount') required final int totalAmount,
    @JsonKey(name: 'customer_note') final String? customerNote,
    @JsonKey(name: 'cancellation_reason') final String? cancellationReason,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
    @JsonKey(name: 'cancelled_at') final DateTime? cancelledAt,
    @JsonKey(name: 'delivered_at') final DateTime? deliveredAt,
    @JsonKey(name: 'order_items') final List<OrderItem> items,
    @JsonKey(name: 'order_status_history')
    final List<OrderStatusHistory> statusHistory,
  }) = _$OrderImpl;
  const _Order._() : super._();

  factory _Order.fromJson(Map<String, dynamic> json) = _$OrderImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'order_code')
  String get orderCode;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  OrderStatus get status;
  @override
  @JsonKey(name: 'payment_method')
  String get paymentMethod;
  @override
  @JsonKey(name: 'payment_status')
  String get paymentStatus;
  @override
  @JsonKey(name: 'recipient_name')
  String get recipientName;
  @override
  @JsonKey(name: 'recipient_phone')
  String get recipientPhone;
  @override
  @JsonKey(name: 'shipping_address')
  Map<String, dynamic> get shippingAddress;
  @override
  int get subtotal;
  @override
  @JsonKey(name: 'shipping_fee')
  int get shippingFee;
  @override
  @JsonKey(name: 'discount_amount')
  int get discountAmount;
  @override
  @JsonKey(name: 'total_amount')
  int get totalAmount;
  @override
  @JsonKey(name: 'customer_note')
  String? get customerNote;
  @override
  @JsonKey(name: 'cancellation_reason')
  String? get cancellationReason;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;
  @override
  @JsonKey(name: 'cancelled_at')
  DateTime? get cancelledAt;
  @override
  @JsonKey(name: 'delivered_at')
  DateTime? get deliveredAt;
  @override
  @JsonKey(name: 'order_items')
  List<OrderItem> get items;
  @override
  @JsonKey(name: 'order_status_history')
  List<OrderStatusHistory> get statusHistory;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderImplCopyWith<_$OrderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
