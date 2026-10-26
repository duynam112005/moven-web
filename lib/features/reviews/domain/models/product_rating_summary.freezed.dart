// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_rating_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProductRatingSummary _$ProductRatingSummaryFromJson(Map<String, dynamic> json) {
  return _ProductRatingSummary.fromJson(json);
}

/// @nodoc
mixin _$ProductRatingSummary {
  @JsonKey(name: 'product_id')
  String get productId => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_reviews')
  int get totalReviews => throw _privateConstructorUsedError;
  @JsonKey(name: 'average_rating')
  double get averageRating => throw _privateConstructorUsedError;
  @JsonKey(name: 'counts')
  Map<String, int> get counts => throw _privateConstructorUsedError;

  /// Serializes this ProductRatingSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductRatingSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductRatingSummaryCopyWith<ProductRatingSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductRatingSummaryCopyWith<$Res> {
  factory $ProductRatingSummaryCopyWith(
    ProductRatingSummary value,
    $Res Function(ProductRatingSummary) then,
  ) = _$ProductRatingSummaryCopyWithImpl<$Res, ProductRatingSummary>;
  @useResult
  $Res call({
    @JsonKey(name: 'product_id') String productId,
    @JsonKey(name: 'total_reviews') int totalReviews,
    @JsonKey(name: 'average_rating') double averageRating,
    @JsonKey(name: 'counts') Map<String, int> counts,
  });
}

/// @nodoc
class _$ProductRatingSummaryCopyWithImpl<
  $Res,
  $Val extends ProductRatingSummary
>
    implements $ProductRatingSummaryCopyWith<$Res> {
  _$ProductRatingSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductRatingSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? totalReviews = null,
    Object? averageRating = null,
    Object? counts = null,
  }) {
    return _then(
      _value.copyWith(
            productId: null == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as String,
            totalReviews: null == totalReviews
                ? _value.totalReviews
                : totalReviews // ignore: cast_nullable_to_non_nullable
                      as int,
            averageRating: null == averageRating
                ? _value.averageRating
                : averageRating // ignore: cast_nullable_to_non_nullable
                      as double,
            counts: null == counts
                ? _value.counts
                : counts // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductRatingSummaryImplCopyWith<$Res>
    implements $ProductRatingSummaryCopyWith<$Res> {
  factory _$$ProductRatingSummaryImplCopyWith(
    _$ProductRatingSummaryImpl value,
    $Res Function(_$ProductRatingSummaryImpl) then,
  ) = __$$ProductRatingSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'product_id') String productId,
    @JsonKey(name: 'total_reviews') int totalReviews,
    @JsonKey(name: 'average_rating') double averageRating,
    @JsonKey(name: 'counts') Map<String, int> counts,
  });
}

/// @nodoc
class __$$ProductRatingSummaryImplCopyWithImpl<$Res>
    extends _$ProductRatingSummaryCopyWithImpl<$Res, _$ProductRatingSummaryImpl>
    implements _$$ProductRatingSummaryImplCopyWith<$Res> {
  __$$ProductRatingSummaryImplCopyWithImpl(
    _$ProductRatingSummaryImpl _value,
    $Res Function(_$ProductRatingSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductRatingSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? totalReviews = null,
    Object? averageRating = null,
    Object? counts = null,
  }) {
    return _then(
      _$ProductRatingSummaryImpl(
        productId: null == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String,
        totalReviews: null == totalReviews
            ? _value.totalReviews
            : totalReviews // ignore: cast_nullable_to_non_nullable
                  as int,
        averageRating: null == averageRating
            ? _value.averageRating
            : averageRating // ignore: cast_nullable_to_non_nullable
                  as double,
        counts: null == counts
            ? _value._counts
            : counts // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductRatingSummaryImpl extends _ProductRatingSummary {
  const _$ProductRatingSummaryImpl({
    @JsonKey(name: 'product_id') required this.productId,
    @JsonKey(name: 'total_reviews') this.totalReviews = 0,
    @JsonKey(name: 'average_rating') this.averageRating = 0.0,
    @JsonKey(name: 'counts') final Map<String, int> counts = const {},
  }) : _counts = counts,
       super._();

  factory _$ProductRatingSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductRatingSummaryImplFromJson(json);

  @override
  @JsonKey(name: 'product_id')
  final String productId;
  @override
  @JsonKey(name: 'total_reviews')
  final int totalReviews;
  @override
  @JsonKey(name: 'average_rating')
  final double averageRating;
  final Map<String, int> _counts;
  @override
  @JsonKey(name: 'counts')
  Map<String, int> get counts {
    if (_counts is EqualUnmodifiableMapView) return _counts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_counts);
  }

  @override
  String toString() {
    return 'ProductRatingSummary(productId: $productId, totalReviews: $totalReviews, averageRating: $averageRating, counts: $counts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductRatingSummaryImpl &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.totalReviews, totalReviews) ||
                other.totalReviews == totalReviews) &&
            (identical(other.averageRating, averageRating) ||
                other.averageRating == averageRating) &&
            const DeepCollectionEquality().equals(other._counts, _counts));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    productId,
    totalReviews,
    averageRating,
    const DeepCollectionEquality().hash(_counts),
  );

  /// Create a copy of ProductRatingSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductRatingSummaryImplCopyWith<_$ProductRatingSummaryImpl>
  get copyWith =>
      __$$ProductRatingSummaryImplCopyWithImpl<_$ProductRatingSummaryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductRatingSummaryImplToJson(this);
  }
}

abstract class _ProductRatingSummary extends ProductRatingSummary {
  const factory _ProductRatingSummary({
    @JsonKey(name: 'product_id') required final String productId,
    @JsonKey(name: 'total_reviews') final int totalReviews,
    @JsonKey(name: 'average_rating') final double averageRating,
    @JsonKey(name: 'counts') final Map<String, int> counts,
  }) = _$ProductRatingSummaryImpl;
  const _ProductRatingSummary._() : super._();

  factory _ProductRatingSummary.fromJson(Map<String, dynamic> json) =
      _$ProductRatingSummaryImpl.fromJson;

  @override
  @JsonKey(name: 'product_id')
  String get productId;
  @override
  @JsonKey(name: 'total_reviews')
  int get totalReviews;
  @override
  @JsonKey(name: 'average_rating')
  double get averageRating;
  @override
  @JsonKey(name: 'counts')
  Map<String, int> get counts;

  /// Create a copy of ProductRatingSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductRatingSummaryImplCopyWith<_$ProductRatingSummaryImpl>
  get copyWith => throw _privateConstructorUsedError;
}
