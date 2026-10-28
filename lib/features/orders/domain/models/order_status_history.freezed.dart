// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_status_history.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

OrderStatusHistory _$OrderStatusHistoryFromJson(Map<String, dynamic> json) {
  return _OrderStatusHistory.fromJson(json);
}

/// @nodoc
mixin _$OrderStatusHistory {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'order_id')
  String get orderId => throw _privateConstructorUsedError;
  @JsonKey(
    name: 'from_status',
    unknownEnumValue: OrderStatus.pendingConfirmation,
  )
  OrderStatus? get fromStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'to_status', unknownEnumValue: OrderStatus.pendingConfirmation)
  OrderStatus get toStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'actor_id')
  String? get actorId => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this OrderStatusHistory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderStatusHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderStatusHistoryCopyWith<OrderStatusHistory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderStatusHistoryCopyWith<$Res> {
  factory $OrderStatusHistoryCopyWith(
    OrderStatusHistory value,
    $Res Function(OrderStatusHistory) then,
  ) = _$OrderStatusHistoryCopyWithImpl<$Res, OrderStatusHistory>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'order_id') String orderId,
    @JsonKey(
      name: 'from_status',
      unknownEnumValue: OrderStatus.pendingConfirmation,
    )
    OrderStatus? fromStatus,
    @JsonKey(
      name: 'to_status',
      unknownEnumValue: OrderStatus.pendingConfirmation,
    )
    OrderStatus toStatus,
    @JsonKey(name: 'actor_id') String? actorId,
    String? note,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$OrderStatusHistoryCopyWithImpl<$Res, $Val extends OrderStatusHistory>
    implements $OrderStatusHistoryCopyWith<$Res> {
  _$OrderStatusHistoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderStatusHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? fromStatus = freezed,
    Object? toStatus = null,
    Object? actorId = freezed,
    Object? note = freezed,
    Object? createdAt = null,
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
            fromStatus: freezed == fromStatus
                ? _value.fromStatus
                : fromStatus // ignore: cast_nullable_to_non_nullable
                      as OrderStatus?,
            toStatus: null == toStatus
                ? _value.toStatus
                : toStatus // ignore: cast_nullable_to_non_nullable
                      as OrderStatus,
            actorId: freezed == actorId
                ? _value.actorId
                : actorId // ignore: cast_nullable_to_non_nullable
                      as String?,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$OrderStatusHistoryImplCopyWith<$Res>
    implements $OrderStatusHistoryCopyWith<$Res> {
  factory _$$OrderStatusHistoryImplCopyWith(
    _$OrderStatusHistoryImpl value,
    $Res Function(_$OrderStatusHistoryImpl) then,
  ) = __$$OrderStatusHistoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'order_id') String orderId,
    @JsonKey(
      name: 'from_status',
      unknownEnumValue: OrderStatus.pendingConfirmation,
    )
    OrderStatus? fromStatus,
    @JsonKey(
      name: 'to_status',
      unknownEnumValue: OrderStatus.pendingConfirmation,
    )
    OrderStatus toStatus,
    @JsonKey(name: 'actor_id') String? actorId,
    String? note,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$OrderStatusHistoryImplCopyWithImpl<$Res>
    extends _$OrderStatusHistoryCopyWithImpl<$Res, _$OrderStatusHistoryImpl>
    implements _$$OrderStatusHistoryImplCopyWith<$Res> {
  __$$OrderStatusHistoryImplCopyWithImpl(
    _$OrderStatusHistoryImpl _value,
    $Res Function(_$OrderStatusHistoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderStatusHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? fromStatus = freezed,
    Object? toStatus = null,
    Object? actorId = freezed,
    Object? note = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$OrderStatusHistoryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orderId: null == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as String,
        fromStatus: freezed == fromStatus
            ? _value.fromStatus
            : fromStatus // ignore: cast_nullable_to_non_nullable
                  as OrderStatus?,
        toStatus: null == toStatus
            ? _value.toStatus
            : toStatus // ignore: cast_nullable_to_non_nullable
                  as OrderStatus,
        actorId: freezed == actorId
            ? _value.actorId
            : actorId // ignore: cast_nullable_to_non_nullable
                  as String?,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
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
class _$OrderStatusHistoryImpl implements _OrderStatusHistory {
  const _$OrderStatusHistoryImpl({
    required this.id,
    @JsonKey(name: 'order_id') required this.orderId,
    @JsonKey(
      name: 'from_status',
      unknownEnumValue: OrderStatus.pendingConfirmation,
    )
    this.fromStatus,
    @JsonKey(
      name: 'to_status',
      unknownEnumValue: OrderStatus.pendingConfirmation,
    )
    required this.toStatus,
    @JsonKey(name: 'actor_id') this.actorId,
    this.note,
    @JsonKey(name: 'created_at') required this.createdAt,
  });

  factory _$OrderStatusHistoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderStatusHistoryImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'order_id')
  final String orderId;
  @override
  @JsonKey(
    name: 'from_status',
    unknownEnumValue: OrderStatus.pendingConfirmation,
  )
  final OrderStatus? fromStatus;
  @override
  @JsonKey(name: 'to_status', unknownEnumValue: OrderStatus.pendingConfirmation)
  final OrderStatus toStatus;
  @override
  @JsonKey(name: 'actor_id')
  final String? actorId;
  @override
  final String? note;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'OrderStatusHistory(id: $id, orderId: $orderId, fromStatus: $fromStatus, toStatus: $toStatus, actorId: $actorId, note: $note, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderStatusHistoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.fromStatus, fromStatus) ||
                other.fromStatus == fromStatus) &&
            (identical(other.toStatus, toStatus) ||
                other.toStatus == toStatus) &&
            (identical(other.actorId, actorId) || other.actorId == actorId) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    orderId,
    fromStatus,
    toStatus,
    actorId,
    note,
    createdAt,
  );

  /// Create a copy of OrderStatusHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderStatusHistoryImplCopyWith<_$OrderStatusHistoryImpl> get copyWith =>
      __$$OrderStatusHistoryImplCopyWithImpl<_$OrderStatusHistoryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderStatusHistoryImplToJson(this);
  }
}

abstract class _OrderStatusHistory implements OrderStatusHistory {
  const factory _OrderStatusHistory({
    required final String id,
    @JsonKey(name: 'order_id') required final String orderId,
    @JsonKey(
      name: 'from_status',
      unknownEnumValue: OrderStatus.pendingConfirmation,
    )
    final OrderStatus? fromStatus,
    @JsonKey(
      name: 'to_status',
      unknownEnumValue: OrderStatus.pendingConfirmation,
    )
    required final OrderStatus toStatus,
    @JsonKey(name: 'actor_id') final String? actorId,
    final String? note,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$OrderStatusHistoryImpl;

  factory _OrderStatusHistory.fromJson(Map<String, dynamic> json) =
      _$OrderStatusHistoryImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'order_id')
  String get orderId;
  @override
  @JsonKey(
    name: 'from_status',
    unknownEnumValue: OrderStatus.pendingConfirmation,
  )
  OrderStatus? get fromStatus;
  @override
  @JsonKey(name: 'to_status', unknownEnumValue: OrderStatus.pendingConfirmation)
  OrderStatus get toStatus;
  @override
  @JsonKey(name: 'actor_id')
  String? get actorId;
  @override
  String? get note;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of OrderStatusHistory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderStatusHistoryImplCopyWith<_$OrderStatusHistoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
