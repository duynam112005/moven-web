// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review_eligibility.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ReviewEligibility _$ReviewEligibilityFromJson(Map<String, dynamic> json) {
  return _ReviewEligibility.fromJson(json);
}

/// @nodoc
mixin _$ReviewEligibility {
  @JsonKey(name: 'is_authenticated')
  bool get isAuthenticated => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_eligible')
  bool get isEligible => throw _privateConstructorUsedError;
  @JsonKey(name: 'has_reviewed')
  bool get hasReviewed => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  @JsonKey(name: 'order_item_id')
  String? get orderItemId => throw _privateConstructorUsedError;
  @JsonKey(name: 'order_code')
  String? get orderCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'size_snapshot')
  String? get sizeSnapshot => throw _privateConstructorUsedError;
  @JsonKey(name: 'color_snapshot')
  String? get colorSnapshot => throw _privateConstructorUsedError;

  /// Serializes this ReviewEligibility to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReviewEligibility
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReviewEligibilityCopyWith<ReviewEligibility> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReviewEligibilityCopyWith<$Res> {
  factory $ReviewEligibilityCopyWith(
    ReviewEligibility value,
    $Res Function(ReviewEligibility) then,
  ) = _$ReviewEligibilityCopyWithImpl<$Res, ReviewEligibility>;
  @useResult
  $Res call({
    @JsonKey(name: 'is_authenticated') bool isAuthenticated,
    @JsonKey(name: 'is_eligible') bool isEligible,
    @JsonKey(name: 'has_reviewed') bool hasReviewed,
    String reason,
    String message,
    @JsonKey(name: 'order_item_id') String? orderItemId,
    @JsonKey(name: 'order_code') String? orderCode,
    @JsonKey(name: 'size_snapshot') String? sizeSnapshot,
    @JsonKey(name: 'color_snapshot') String? colorSnapshot,
  });
}

/// @nodoc
class _$ReviewEligibilityCopyWithImpl<$Res, $Val extends ReviewEligibility>
    implements $ReviewEligibilityCopyWith<$Res> {
  _$ReviewEligibilityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReviewEligibility
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isAuthenticated = null,
    Object? isEligible = null,
    Object? hasReviewed = null,
    Object? reason = null,
    Object? message = null,
    Object? orderItemId = freezed,
    Object? orderCode = freezed,
    Object? sizeSnapshot = freezed,
    Object? colorSnapshot = freezed,
  }) {
    return _then(
      _value.copyWith(
            isAuthenticated: null == isAuthenticated
                ? _value.isAuthenticated
                : isAuthenticated // ignore: cast_nullable_to_non_nullable
                      as bool,
            isEligible: null == isEligible
                ? _value.isEligible
                : isEligible // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasReviewed: null == hasReviewed
                ? _value.hasReviewed
                : hasReviewed // ignore: cast_nullable_to_non_nullable
                      as bool,
            reason: null == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            orderItemId: freezed == orderItemId
                ? _value.orderItemId
                : orderItemId // ignore: cast_nullable_to_non_nullable
                      as String?,
            orderCode: freezed == orderCode
                ? _value.orderCode
                : orderCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            sizeSnapshot: freezed == sizeSnapshot
                ? _value.sizeSnapshot
                : sizeSnapshot // ignore: cast_nullable_to_non_nullable
                      as String?,
            colorSnapshot: freezed == colorSnapshot
                ? _value.colorSnapshot
                : colorSnapshot // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReviewEligibilityImplCopyWith<$Res>
    implements $ReviewEligibilityCopyWith<$Res> {
  factory _$$ReviewEligibilityImplCopyWith(
    _$ReviewEligibilityImpl value,
    $Res Function(_$ReviewEligibilityImpl) then,
  ) = __$$ReviewEligibilityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'is_authenticated') bool isAuthenticated,
    @JsonKey(name: 'is_eligible') bool isEligible,
    @JsonKey(name: 'has_reviewed') bool hasReviewed,
    String reason,
    String message,
    @JsonKey(name: 'order_item_id') String? orderItemId,
    @JsonKey(name: 'order_code') String? orderCode,
    @JsonKey(name: 'size_snapshot') String? sizeSnapshot,
    @JsonKey(name: 'color_snapshot') String? colorSnapshot,
  });
}

/// @nodoc
class __$$ReviewEligibilityImplCopyWithImpl<$Res>
    extends _$ReviewEligibilityCopyWithImpl<$Res, _$ReviewEligibilityImpl>
    implements _$$ReviewEligibilityImplCopyWith<$Res> {
  __$$ReviewEligibilityImplCopyWithImpl(
    _$ReviewEligibilityImpl _value,
    $Res Function(_$ReviewEligibilityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReviewEligibility
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isAuthenticated = null,
    Object? isEligible = null,
    Object? hasReviewed = null,
    Object? reason = null,
    Object? message = null,
    Object? orderItemId = freezed,
    Object? orderCode = freezed,
    Object? sizeSnapshot = freezed,
    Object? colorSnapshot = freezed,
  }) {
    return _then(
      _$ReviewEligibilityImpl(
        isAuthenticated: null == isAuthenticated
            ? _value.isAuthenticated
            : isAuthenticated // ignore: cast_nullable_to_non_nullable
                  as bool,
        isEligible: null == isEligible
            ? _value.isEligible
            : isEligible // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasReviewed: null == hasReviewed
            ? _value.hasReviewed
            : hasReviewed // ignore: cast_nullable_to_non_nullable
                  as bool,
        reason: null == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        orderItemId: freezed == orderItemId
            ? _value.orderItemId
            : orderItemId // ignore: cast_nullable_to_non_nullable
                  as String?,
        orderCode: freezed == orderCode
            ? _value.orderCode
            : orderCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        sizeSnapshot: freezed == sizeSnapshot
            ? _value.sizeSnapshot
            : sizeSnapshot // ignore: cast_nullable_to_non_nullable
                  as String?,
        colorSnapshot: freezed == colorSnapshot
            ? _value.colorSnapshot
            : colorSnapshot // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReviewEligibilityImpl extends _ReviewEligibility {
  const _$ReviewEligibilityImpl({
    @JsonKey(name: 'is_authenticated') this.isAuthenticated = false,
    @JsonKey(name: 'is_eligible') this.isEligible = false,
    @JsonKey(name: 'has_reviewed') this.hasReviewed = false,
    this.reason = 'UNAUTHENTICATED',
    this.message = '',
    @JsonKey(name: 'order_item_id') this.orderItemId,
    @JsonKey(name: 'order_code') this.orderCode,
    @JsonKey(name: 'size_snapshot') this.sizeSnapshot,
    @JsonKey(name: 'color_snapshot') this.colorSnapshot,
  }) : super._();

  factory _$ReviewEligibilityImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReviewEligibilityImplFromJson(json);

  @override
  @JsonKey(name: 'is_authenticated')
  final bool isAuthenticated;
  @override
  @JsonKey(name: 'is_eligible')
  final bool isEligible;
  @override
  @JsonKey(name: 'has_reviewed')
  final bool hasReviewed;
  @override
  @JsonKey()
  final String reason;
  @override
  @JsonKey()
  final String message;
  @override
  @JsonKey(name: 'order_item_id')
  final String? orderItemId;
  @override
  @JsonKey(name: 'order_code')
  final String? orderCode;
  @override
  @JsonKey(name: 'size_snapshot')
  final String? sizeSnapshot;
  @override
  @JsonKey(name: 'color_snapshot')
  final String? colorSnapshot;

  @override
  String toString() {
    return 'ReviewEligibility(isAuthenticated: $isAuthenticated, isEligible: $isEligible, hasReviewed: $hasReviewed, reason: $reason, message: $message, orderItemId: $orderItemId, orderCode: $orderCode, sizeSnapshot: $sizeSnapshot, colorSnapshot: $colorSnapshot)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReviewEligibilityImpl &&
            (identical(other.isAuthenticated, isAuthenticated) ||
                other.isAuthenticated == isAuthenticated) &&
            (identical(other.isEligible, isEligible) ||
                other.isEligible == isEligible) &&
            (identical(other.hasReviewed, hasReviewed) ||
                other.hasReviewed == hasReviewed) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.orderItemId, orderItemId) ||
                other.orderItemId == orderItemId) &&
            (identical(other.orderCode, orderCode) ||
                other.orderCode == orderCode) &&
            (identical(other.sizeSnapshot, sizeSnapshot) ||
                other.sizeSnapshot == sizeSnapshot) &&
            (identical(other.colorSnapshot, colorSnapshot) ||
                other.colorSnapshot == colorSnapshot));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    isAuthenticated,
    isEligible,
    hasReviewed,
    reason,
    message,
    orderItemId,
    orderCode,
    sizeSnapshot,
    colorSnapshot,
  );

  /// Create a copy of ReviewEligibility
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReviewEligibilityImplCopyWith<_$ReviewEligibilityImpl> get copyWith =>
      __$$ReviewEligibilityImplCopyWithImpl<_$ReviewEligibilityImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ReviewEligibilityImplToJson(this);
  }
}

abstract class _ReviewEligibility extends ReviewEligibility {
  const factory _ReviewEligibility({
    @JsonKey(name: 'is_authenticated') final bool isAuthenticated,
    @JsonKey(name: 'is_eligible') final bool isEligible,
    @JsonKey(name: 'has_reviewed') final bool hasReviewed,
    final String reason,
    final String message,
    @JsonKey(name: 'order_item_id') final String? orderItemId,
    @JsonKey(name: 'order_code') final String? orderCode,
    @JsonKey(name: 'size_snapshot') final String? sizeSnapshot,
    @JsonKey(name: 'color_snapshot') final String? colorSnapshot,
  }) = _$ReviewEligibilityImpl;
  const _ReviewEligibility._() : super._();

  factory _ReviewEligibility.fromJson(Map<String, dynamic> json) =
      _$ReviewEligibilityImpl.fromJson;

  @override
  @JsonKey(name: 'is_authenticated')
  bool get isAuthenticated;
  @override
  @JsonKey(name: 'is_eligible')
  bool get isEligible;
  @override
  @JsonKey(name: 'has_reviewed')
  bool get hasReviewed;
  @override
  String get reason;
  @override
  String get message;
  @override
  @JsonKey(name: 'order_item_id')
  String? get orderItemId;
  @override
  @JsonKey(name: 'order_code')
  String? get orderCode;
  @override
  @JsonKey(name: 'size_snapshot')
  String? get sizeSnapshot;
  @override
  @JsonKey(name: 'color_snapshot')
  String? get colorSnapshot;

  /// Create a copy of ReviewEligibility
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReviewEligibilityImplCopyWith<_$ReviewEligibilityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
