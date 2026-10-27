// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Review _$ReviewFromJson(Map<String, dynamic> json) {
  return _Review.fromJson(json);
}

/// @nodoc
mixin _$Review {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'product_id')
  String get productId => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_name')
  String get userName => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_avatar')
  String? get userAvatar => throw _privateConstructorUsedError;
  @JsonKey(name: 'order_item_id')
  String? get orderItemId => throw _privateConstructorUsedError;
  @JsonKey(name: 'order_code')
  String? get orderCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'variant_label')
  String? get variantLabel => throw _privateConstructorUsedError;
  int get rating => throw _privateConstructorUsedError;
  String? get comment => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_hidden')
  bool get isHidden => throw _privateConstructorUsedError;
  @JsonKey(name: 'hidden_reason')
  String? get hiddenReason => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Review to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Review
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReviewCopyWith<Review> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReviewCopyWith<$Res> {
  factory $ReviewCopyWith(Review value, $Res Function(Review) then) =
      _$ReviewCopyWithImpl<$Res, Review>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'product_id') String productId,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'user_name') String userName,
    @JsonKey(name: 'user_avatar') String? userAvatar,
    @JsonKey(name: 'order_item_id') String? orderItemId,
    @JsonKey(name: 'order_code') String? orderCode,
    @JsonKey(name: 'variant_label') String? variantLabel,
    int rating,
    String? comment,
    @JsonKey(name: 'is_hidden') bool isHidden,
    @JsonKey(name: 'hidden_reason') String? hiddenReason,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  });
}

/// @nodoc
class _$ReviewCopyWithImpl<$Res, $Val extends Review>
    implements $ReviewCopyWith<$Res> {
  _$ReviewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Review
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? userId = null,
    Object? userName = null,
    Object? userAvatar = freezed,
    Object? orderItemId = freezed,
    Object? orderCode = freezed,
    Object? variantLabel = freezed,
    Object? rating = null,
    Object? comment = freezed,
    Object? isHidden = null,
    Object? hiddenReason = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
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
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            userName: null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String,
            userAvatar: freezed == userAvatar
                ? _value.userAvatar
                : userAvatar // ignore: cast_nullable_to_non_nullable
                      as String?,
            orderItemId: freezed == orderItemId
                ? _value.orderItemId
                : orderItemId // ignore: cast_nullable_to_non_nullable
                      as String?,
            orderCode: freezed == orderCode
                ? _value.orderCode
                : orderCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            variantLabel: freezed == variantLabel
                ? _value.variantLabel
                : variantLabel // ignore: cast_nullable_to_non_nullable
                      as String?,
            rating: null == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as int,
            comment: freezed == comment
                ? _value.comment
                : comment // ignore: cast_nullable_to_non_nullable
                      as String?,
            isHidden: null == isHidden
                ? _value.isHidden
                : isHidden // ignore: cast_nullable_to_non_nullable
                      as bool,
            hiddenReason: freezed == hiddenReason
                ? _value.hiddenReason
                : hiddenReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
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
abstract class _$$ReviewImplCopyWith<$Res> implements $ReviewCopyWith<$Res> {
  factory _$$ReviewImplCopyWith(
    _$ReviewImpl value,
    $Res Function(_$ReviewImpl) then,
  ) = __$$ReviewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'product_id') String productId,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'user_name') String userName,
    @JsonKey(name: 'user_avatar') String? userAvatar,
    @JsonKey(name: 'order_item_id') String? orderItemId,
    @JsonKey(name: 'order_code') String? orderCode,
    @JsonKey(name: 'variant_label') String? variantLabel,
    int rating,
    String? comment,
    @JsonKey(name: 'is_hidden') bool isHidden,
    @JsonKey(name: 'hidden_reason') String? hiddenReason,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  });
}

/// @nodoc
class __$$ReviewImplCopyWithImpl<$Res>
    extends _$ReviewCopyWithImpl<$Res, _$ReviewImpl>
    implements _$$ReviewImplCopyWith<$Res> {
  __$$ReviewImplCopyWithImpl(
    _$ReviewImpl _value,
    $Res Function(_$ReviewImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Review
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? userId = null,
    Object? userName = null,
    Object? userAvatar = freezed,
    Object? orderItemId = freezed,
    Object? orderCode = freezed,
    Object? variantLabel = freezed,
    Object? rating = null,
    Object? comment = freezed,
    Object? isHidden = null,
    Object? hiddenReason = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$ReviewImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        productId: null == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        userName: null == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String,
        userAvatar: freezed == userAvatar
            ? _value.userAvatar
            : userAvatar // ignore: cast_nullable_to_non_nullable
                  as String?,
        orderItemId: freezed == orderItemId
            ? _value.orderItemId
            : orderItemId // ignore: cast_nullable_to_non_nullable
                  as String?,
        orderCode: freezed == orderCode
            ? _value.orderCode
            : orderCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        variantLabel: freezed == variantLabel
            ? _value.variantLabel
            : variantLabel // ignore: cast_nullable_to_non_nullable
                  as String?,
        rating: null == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as int,
        comment: freezed == comment
            ? _value.comment
            : comment // ignore: cast_nullable_to_non_nullable
                  as String?,
        isHidden: null == isHidden
            ? _value.isHidden
            : isHidden // ignore: cast_nullable_to_non_nullable
                  as bool,
        hiddenReason: freezed == hiddenReason
            ? _value.hiddenReason
            : hiddenReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
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
class _$ReviewImpl extends _Review {
  const _$ReviewImpl({
    required this.id,
    @JsonKey(name: 'product_id') required this.productId,
    @JsonKey(name: 'user_id') required this.userId,
    @JsonKey(name: 'user_name') this.userName = 'Khách hàng MOVEN',
    @JsonKey(name: 'user_avatar') this.userAvatar,
    @JsonKey(name: 'order_item_id') this.orderItemId,
    @JsonKey(name: 'order_code') this.orderCode,
    @JsonKey(name: 'variant_label') this.variantLabel,
    required this.rating,
    this.comment,
    @JsonKey(name: 'is_hidden') this.isHidden = false,
    @JsonKey(name: 'hidden_reason') this.hiddenReason,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
  }) : super._();

  factory _$ReviewImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReviewImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'product_id')
  final String productId;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'user_name')
  final String userName;
  @override
  @JsonKey(name: 'user_avatar')
  final String? userAvatar;
  @override
  @JsonKey(name: 'order_item_id')
  final String? orderItemId;
  @override
  @JsonKey(name: 'order_code')
  final String? orderCode;
  @override
  @JsonKey(name: 'variant_label')
  final String? variantLabel;
  @override
  final int rating;
  @override
  final String? comment;
  @override
  @JsonKey(name: 'is_hidden')
  final bool isHidden;
  @override
  @JsonKey(name: 'hidden_reason')
  final String? hiddenReason;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Review(id: $id, productId: $productId, userId: $userId, userName: $userName, userAvatar: $userAvatar, orderItemId: $orderItemId, orderCode: $orderCode, variantLabel: $variantLabel, rating: $rating, comment: $comment, isHidden: $isHidden, hiddenReason: $hiddenReason, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReviewImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.userAvatar, userAvatar) ||
                other.userAvatar == userAvatar) &&
            (identical(other.orderItemId, orderItemId) ||
                other.orderItemId == orderItemId) &&
            (identical(other.orderCode, orderCode) ||
                other.orderCode == orderCode) &&
            (identical(other.variantLabel, variantLabel) ||
                other.variantLabel == variantLabel) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.isHidden, isHidden) ||
                other.isHidden == isHidden) &&
            (identical(other.hiddenReason, hiddenReason) ||
                other.hiddenReason == hiddenReason) &&
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
    userId,
    userName,
    userAvatar,
    orderItemId,
    orderCode,
    variantLabel,
    rating,
    comment,
    isHidden,
    hiddenReason,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Review
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReviewImplCopyWith<_$ReviewImpl> get copyWith =>
      __$$ReviewImplCopyWithImpl<_$ReviewImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReviewImplToJson(this);
  }
}

abstract class _Review extends Review {
  const factory _Review({
    required final String id,
    @JsonKey(name: 'product_id') required final String productId,
    @JsonKey(name: 'user_id') required final String userId,
    @JsonKey(name: 'user_name') final String userName,
    @JsonKey(name: 'user_avatar') final String? userAvatar,
    @JsonKey(name: 'order_item_id') final String? orderItemId,
    @JsonKey(name: 'order_code') final String? orderCode,
    @JsonKey(name: 'variant_label') final String? variantLabel,
    required final int rating,
    final String? comment,
    @JsonKey(name: 'is_hidden') final bool isHidden,
    @JsonKey(name: 'hidden_reason') final String? hiddenReason,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') final DateTime? updatedAt,
  }) = _$ReviewImpl;
  const _Review._() : super._();

  factory _Review.fromJson(Map<String, dynamic> json) = _$ReviewImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'product_id')
  String get productId;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'user_name')
  String get userName;
  @override
  @JsonKey(name: 'user_avatar')
  String? get userAvatar;
  @override
  @JsonKey(name: 'order_item_id')
  String? get orderItemId;
  @override
  @JsonKey(name: 'order_code')
  String? get orderCode;
  @override
  @JsonKey(name: 'variant_label')
  String? get variantLabel;
  @override
  int get rating;
  @override
  String? get comment;
  @override
  @JsonKey(name: 'is_hidden')
  bool get isHidden;
  @override
  @JsonKey(name: 'hidden_reason')
  String? get hiddenReason;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of Review
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReviewImplCopyWith<_$ReviewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
