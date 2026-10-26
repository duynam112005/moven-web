// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review_report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ReviewReport _$ReviewReportFromJson(Map<String, dynamic> json) {
  return _ReviewReport.fromJson(json);
}

/// @nodoc
mixin _$ReviewReport {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'review_id')
  String get reviewId => throw _privateConstructorUsedError;
  @JsonKey(name: 'reporter_id')
  String get reporterId => throw _privateConstructorUsedError;
  @JsonKey(name: 'reporter_name')
  String get reporterName => throw _privateConstructorUsedError;
  @JsonKey(name: 'review_comment')
  String? get reviewComment => throw _privateConstructorUsedError;
  @JsonKey(name: 'review_rating')
  int? get reviewRating => throw _privateConstructorUsedError;
  @JsonKey(name: 'review_author_name')
  String? get reviewAuthorName => throw _privateConstructorUsedError;
  @JsonKey(name: 'product_id')
  String? get productId => throw _privateConstructorUsedError;
  @JsonKey(name: 'product_name')
  String? get productName => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;
  String? get details => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'resolved_by')
  String? get resolvedBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'resolution_note')
  String? get resolutionNote => throw _privateConstructorUsedError;
  @JsonKey(name: 'resolved_at')
  DateTime? get resolvedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ReviewReport to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReviewReport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReviewReportCopyWith<ReviewReport> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReviewReportCopyWith<$Res> {
  factory $ReviewReportCopyWith(
    ReviewReport value,
    $Res Function(ReviewReport) then,
  ) = _$ReviewReportCopyWithImpl<$Res, ReviewReport>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'review_id') String reviewId,
    @JsonKey(name: 'reporter_id') String reporterId,
    @JsonKey(name: 'reporter_name') String reporterName,
    @JsonKey(name: 'review_comment') String? reviewComment,
    @JsonKey(name: 'review_rating') int? reviewRating,
    @JsonKey(name: 'review_author_name') String? reviewAuthorName,
    @JsonKey(name: 'product_id') String? productId,
    @JsonKey(name: 'product_name') String? productName,
    String reason,
    String? details,
    String status,
    @JsonKey(name: 'resolved_by') String? resolvedBy,
    @JsonKey(name: 'resolution_note') String? resolutionNote,
    @JsonKey(name: 'resolved_at') DateTime? resolvedAt,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$ReviewReportCopyWithImpl<$Res, $Val extends ReviewReport>
    implements $ReviewReportCopyWith<$Res> {
  _$ReviewReportCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReviewReport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reviewId = null,
    Object? reporterId = null,
    Object? reporterName = null,
    Object? reviewComment = freezed,
    Object? reviewRating = freezed,
    Object? reviewAuthorName = freezed,
    Object? productId = freezed,
    Object? productName = freezed,
    Object? reason = null,
    Object? details = freezed,
    Object? status = null,
    Object? resolvedBy = freezed,
    Object? resolutionNote = freezed,
    Object? resolvedAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            reviewId: null == reviewId
                ? _value.reviewId
                : reviewId // ignore: cast_nullable_to_non_nullable
                      as String,
            reporterId: null == reporterId
                ? _value.reporterId
                : reporterId // ignore: cast_nullable_to_non_nullable
                      as String,
            reporterName: null == reporterName
                ? _value.reporterName
                : reporterName // ignore: cast_nullable_to_non_nullable
                      as String,
            reviewComment: freezed == reviewComment
                ? _value.reviewComment
                : reviewComment // ignore: cast_nullable_to_non_nullable
                      as String?,
            reviewRating: freezed == reviewRating
                ? _value.reviewRating
                : reviewRating // ignore: cast_nullable_to_non_nullable
                      as int?,
            reviewAuthorName: freezed == reviewAuthorName
                ? _value.reviewAuthorName
                : reviewAuthorName // ignore: cast_nullable_to_non_nullable
                      as String?,
            productId: freezed == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as String?,
            productName: freezed == productName
                ? _value.productName
                : productName // ignore: cast_nullable_to_non_nullable
                      as String?,
            reason: null == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String,
            details: freezed == details
                ? _value.details
                : details // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            resolvedBy: freezed == resolvedBy
                ? _value.resolvedBy
                : resolvedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            resolutionNote: freezed == resolutionNote
                ? _value.resolutionNote
                : resolutionNote // ignore: cast_nullable_to_non_nullable
                      as String?,
            resolvedAt: freezed == resolvedAt
                ? _value.resolvedAt
                : resolvedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
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
abstract class _$$ReviewReportImplCopyWith<$Res>
    implements $ReviewReportCopyWith<$Res> {
  factory _$$ReviewReportImplCopyWith(
    _$ReviewReportImpl value,
    $Res Function(_$ReviewReportImpl) then,
  ) = __$$ReviewReportImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'review_id') String reviewId,
    @JsonKey(name: 'reporter_id') String reporterId,
    @JsonKey(name: 'reporter_name') String reporterName,
    @JsonKey(name: 'review_comment') String? reviewComment,
    @JsonKey(name: 'review_rating') int? reviewRating,
    @JsonKey(name: 'review_author_name') String? reviewAuthorName,
    @JsonKey(name: 'product_id') String? productId,
    @JsonKey(name: 'product_name') String? productName,
    String reason,
    String? details,
    String status,
    @JsonKey(name: 'resolved_by') String? resolvedBy,
    @JsonKey(name: 'resolution_note') String? resolutionNote,
    @JsonKey(name: 'resolved_at') DateTime? resolvedAt,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$ReviewReportImplCopyWithImpl<$Res>
    extends _$ReviewReportCopyWithImpl<$Res, _$ReviewReportImpl>
    implements _$$ReviewReportImplCopyWith<$Res> {
  __$$ReviewReportImplCopyWithImpl(
    _$ReviewReportImpl _value,
    $Res Function(_$ReviewReportImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReviewReport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reviewId = null,
    Object? reporterId = null,
    Object? reporterName = null,
    Object? reviewComment = freezed,
    Object? reviewRating = freezed,
    Object? reviewAuthorName = freezed,
    Object? productId = freezed,
    Object? productName = freezed,
    Object? reason = null,
    Object? details = freezed,
    Object? status = null,
    Object? resolvedBy = freezed,
    Object? resolutionNote = freezed,
    Object? resolvedAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$ReviewReportImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        reviewId: null == reviewId
            ? _value.reviewId
            : reviewId // ignore: cast_nullable_to_non_nullable
                  as String,
        reporterId: null == reporterId
            ? _value.reporterId
            : reporterId // ignore: cast_nullable_to_non_nullable
                  as String,
        reporterName: null == reporterName
            ? _value.reporterName
            : reporterName // ignore: cast_nullable_to_non_nullable
                  as String,
        reviewComment: freezed == reviewComment
            ? _value.reviewComment
            : reviewComment // ignore: cast_nullable_to_non_nullable
                  as String?,
        reviewRating: freezed == reviewRating
            ? _value.reviewRating
            : reviewRating // ignore: cast_nullable_to_non_nullable
                  as int?,
        reviewAuthorName: freezed == reviewAuthorName
            ? _value.reviewAuthorName
            : reviewAuthorName // ignore: cast_nullable_to_non_nullable
                  as String?,
        productId: freezed == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String?,
        productName: freezed == productName
            ? _value.productName
            : productName // ignore: cast_nullable_to_non_nullable
                  as String?,
        reason: null == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String,
        details: freezed == details
            ? _value.details
            : details // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        resolvedBy: freezed == resolvedBy
            ? _value.resolvedBy
            : resolvedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        resolutionNote: freezed == resolutionNote
            ? _value.resolutionNote
            : resolutionNote // ignore: cast_nullable_to_non_nullable
                  as String?,
        resolvedAt: freezed == resolvedAt
            ? _value.resolvedAt
            : resolvedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
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
class _$ReviewReportImpl extends _ReviewReport {
  const _$ReviewReportImpl({
    required this.id,
    @JsonKey(name: 'review_id') required this.reviewId,
    @JsonKey(name: 'reporter_id') required this.reporterId,
    @JsonKey(name: 'reporter_name') this.reporterName = 'Người dùng',
    @JsonKey(name: 'review_comment') this.reviewComment,
    @JsonKey(name: 'review_rating') this.reviewRating,
    @JsonKey(name: 'review_author_name') this.reviewAuthorName,
    @JsonKey(name: 'product_id') this.productId,
    @JsonKey(name: 'product_name') this.productName,
    required this.reason,
    this.details,
    this.status = 'pending',
    @JsonKey(name: 'resolved_by') this.resolvedBy,
    @JsonKey(name: 'resolution_note') this.resolutionNote,
    @JsonKey(name: 'resolved_at') this.resolvedAt,
    @JsonKey(name: 'created_at') required this.createdAt,
  }) : super._();

  factory _$ReviewReportImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReviewReportImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'review_id')
  final String reviewId;
  @override
  @JsonKey(name: 'reporter_id')
  final String reporterId;
  @override
  @JsonKey(name: 'reporter_name')
  final String reporterName;
  @override
  @JsonKey(name: 'review_comment')
  final String? reviewComment;
  @override
  @JsonKey(name: 'review_rating')
  final int? reviewRating;
  @override
  @JsonKey(name: 'review_author_name')
  final String? reviewAuthorName;
  @override
  @JsonKey(name: 'product_id')
  final String? productId;
  @override
  @JsonKey(name: 'product_name')
  final String? productName;
  @override
  final String reason;
  @override
  final String? details;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(name: 'resolved_by')
  final String? resolvedBy;
  @override
  @JsonKey(name: 'resolution_note')
  final String? resolutionNote;
  @override
  @JsonKey(name: 'resolved_at')
  final DateTime? resolvedAt;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'ReviewReport(id: $id, reviewId: $reviewId, reporterId: $reporterId, reporterName: $reporterName, reviewComment: $reviewComment, reviewRating: $reviewRating, reviewAuthorName: $reviewAuthorName, productId: $productId, productName: $productName, reason: $reason, details: $details, status: $status, resolvedBy: $resolvedBy, resolutionNote: $resolutionNote, resolvedAt: $resolvedAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReviewReportImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.reviewId, reviewId) ||
                other.reviewId == reviewId) &&
            (identical(other.reporterId, reporterId) ||
                other.reporterId == reporterId) &&
            (identical(other.reporterName, reporterName) ||
                other.reporterName == reporterName) &&
            (identical(other.reviewComment, reviewComment) ||
                other.reviewComment == reviewComment) &&
            (identical(other.reviewRating, reviewRating) ||
                other.reviewRating == reviewRating) &&
            (identical(other.reviewAuthorName, reviewAuthorName) ||
                other.reviewAuthorName == reviewAuthorName) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.details, details) || other.details == details) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.resolvedBy, resolvedBy) ||
                other.resolvedBy == resolvedBy) &&
            (identical(other.resolutionNote, resolutionNote) ||
                other.resolutionNote == resolutionNote) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    reviewId,
    reporterId,
    reporterName,
    reviewComment,
    reviewRating,
    reviewAuthorName,
    productId,
    productName,
    reason,
    details,
    status,
    resolvedBy,
    resolutionNote,
    resolvedAt,
    createdAt,
  );

  /// Create a copy of ReviewReport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReviewReportImplCopyWith<_$ReviewReportImpl> get copyWith =>
      __$$ReviewReportImplCopyWithImpl<_$ReviewReportImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReviewReportImplToJson(this);
  }
}

abstract class _ReviewReport extends ReviewReport {
  const factory _ReviewReport({
    required final String id,
    @JsonKey(name: 'review_id') required final String reviewId,
    @JsonKey(name: 'reporter_id') required final String reporterId,
    @JsonKey(name: 'reporter_name') final String reporterName,
    @JsonKey(name: 'review_comment') final String? reviewComment,
    @JsonKey(name: 'review_rating') final int? reviewRating,
    @JsonKey(name: 'review_author_name') final String? reviewAuthorName,
    @JsonKey(name: 'product_id') final String? productId,
    @JsonKey(name: 'product_name') final String? productName,
    required final String reason,
    final String? details,
    final String status,
    @JsonKey(name: 'resolved_by') final String? resolvedBy,
    @JsonKey(name: 'resolution_note') final String? resolutionNote,
    @JsonKey(name: 'resolved_at') final DateTime? resolvedAt,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$ReviewReportImpl;
  const _ReviewReport._() : super._();

  factory _ReviewReport.fromJson(Map<String, dynamic> json) =
      _$ReviewReportImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'review_id')
  String get reviewId;
  @override
  @JsonKey(name: 'reporter_id')
  String get reporterId;
  @override
  @JsonKey(name: 'reporter_name')
  String get reporterName;
  @override
  @JsonKey(name: 'review_comment')
  String? get reviewComment;
  @override
  @JsonKey(name: 'review_rating')
  int? get reviewRating;
  @override
  @JsonKey(name: 'review_author_name')
  String? get reviewAuthorName;
  @override
  @JsonKey(name: 'product_id')
  String? get productId;
  @override
  @JsonKey(name: 'product_name')
  String? get productName;
  @override
  String get reason;
  @override
  String? get details;
  @override
  String get status;
  @override
  @JsonKey(name: 'resolved_by')
  String? get resolvedBy;
  @override
  @JsonKey(name: 'resolution_note')
  String? get resolutionNote;
  @override
  @JsonKey(name: 'resolved_at')
  DateTime? get resolvedAt;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of ReviewReport
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReviewReportImplCopyWith<_$ReviewReportImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
