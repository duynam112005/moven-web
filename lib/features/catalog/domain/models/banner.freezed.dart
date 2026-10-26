// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'banner.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

HomeBanner _$HomeBannerFromJson(Map<String, dynamic> json) {
  return _HomeBanner.fromJson(json);
}

/// @nodoc
mixin _$HomeBanner {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get subtitle => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_path')
  String get imagePath => throw _privateConstructorUsedError;
  @JsonKey(name: 'link_type', defaultValue: 'none')
  String get linkType => throw _privateConstructorUsedError;
  @JsonKey(name: 'link_value')
  String? get linkValue => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_at')
  DateTime? get startAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_at')
  DateTime? get endAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active', defaultValue: true)
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'sort_order', defaultValue: 0)
  int get sortOrder => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this HomeBanner to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HomeBanner
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HomeBannerCopyWith<HomeBanner> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomeBannerCopyWith<$Res> {
  factory $HomeBannerCopyWith(
    HomeBanner value,
    $Res Function(HomeBanner) then,
  ) = _$HomeBannerCopyWithImpl<$Res, HomeBanner>;
  @useResult
  $Res call({
    String id,
    String title,
    String? subtitle,
    @JsonKey(name: 'image_path') String imagePath,
    @JsonKey(name: 'link_type', defaultValue: 'none') String linkType,
    @JsonKey(name: 'link_value') String? linkValue,
    @JsonKey(name: 'start_at') DateTime? startAt,
    @JsonKey(name: 'end_at') DateTime? endAt,
    @JsonKey(name: 'is_active', defaultValue: true) bool isActive,
    @JsonKey(name: 'sort_order', defaultValue: 0) int sortOrder,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class _$HomeBannerCopyWithImpl<$Res, $Val extends HomeBanner>
    implements $HomeBannerCopyWith<$Res> {
  _$HomeBannerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HomeBanner
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? subtitle = freezed,
    Object? imagePath = null,
    Object? linkType = null,
    Object? linkValue = freezed,
    Object? startAt = freezed,
    Object? endAt = freezed,
    Object? isActive = null,
    Object? sortOrder = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            subtitle: freezed == subtitle
                ? _value.subtitle
                : subtitle // ignore: cast_nullable_to_non_nullable
                      as String?,
            imagePath: null == imagePath
                ? _value.imagePath
                : imagePath // ignore: cast_nullable_to_non_nullable
                      as String,
            linkType: null == linkType
                ? _value.linkType
                : linkType // ignore: cast_nullable_to_non_nullable
                      as String,
            linkValue: freezed == linkValue
                ? _value.linkValue
                : linkValue // ignore: cast_nullable_to_non_nullable
                      as String?,
            startAt: freezed == startAt
                ? _value.startAt
                : startAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            endAt: freezed == endAt
                ? _value.endAt
                : endAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            sortOrder: null == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                      as int,
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
abstract class _$$HomeBannerImplCopyWith<$Res>
    implements $HomeBannerCopyWith<$Res> {
  factory _$$HomeBannerImplCopyWith(
    _$HomeBannerImpl value,
    $Res Function(_$HomeBannerImpl) then,
  ) = __$$HomeBannerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String? subtitle,
    @JsonKey(name: 'image_path') String imagePath,
    @JsonKey(name: 'link_type', defaultValue: 'none') String linkType,
    @JsonKey(name: 'link_value') String? linkValue,
    @JsonKey(name: 'start_at') DateTime? startAt,
    @JsonKey(name: 'end_at') DateTime? endAt,
    @JsonKey(name: 'is_active', defaultValue: true) bool isActive,
    @JsonKey(name: 'sort_order', defaultValue: 0) int sortOrder,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class __$$HomeBannerImplCopyWithImpl<$Res>
    extends _$HomeBannerCopyWithImpl<$Res, _$HomeBannerImpl>
    implements _$$HomeBannerImplCopyWith<$Res> {
  __$$HomeBannerImplCopyWithImpl(
    _$HomeBannerImpl _value,
    $Res Function(_$HomeBannerImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HomeBanner
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? subtitle = freezed,
    Object? imagePath = null,
    Object? linkType = null,
    Object? linkValue = freezed,
    Object? startAt = freezed,
    Object? endAt = freezed,
    Object? isActive = null,
    Object? sortOrder = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$HomeBannerImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        subtitle: freezed == subtitle
            ? _value.subtitle
            : subtitle // ignore: cast_nullable_to_non_nullable
                  as String?,
        imagePath: null == imagePath
            ? _value.imagePath
            : imagePath // ignore: cast_nullable_to_non_nullable
                  as String,
        linkType: null == linkType
            ? _value.linkType
            : linkType // ignore: cast_nullable_to_non_nullable
                  as String,
        linkValue: freezed == linkValue
            ? _value.linkValue
            : linkValue // ignore: cast_nullable_to_non_nullable
                  as String?,
        startAt: freezed == startAt
            ? _value.startAt
            : startAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        endAt: freezed == endAt
            ? _value.endAt
            : endAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        sortOrder: null == sortOrder
            ? _value.sortOrder
            : sortOrder // ignore: cast_nullable_to_non_nullable
                  as int,
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
class _$HomeBannerImpl extends _HomeBanner {
  const _$HomeBannerImpl({
    required this.id,
    required this.title,
    this.subtitle,
    @JsonKey(name: 'image_path') required this.imagePath,
    @JsonKey(name: 'link_type', defaultValue: 'none') required this.linkType,
    @JsonKey(name: 'link_value') this.linkValue,
    @JsonKey(name: 'start_at') this.startAt,
    @JsonKey(name: 'end_at') this.endAt,
    @JsonKey(name: 'is_active', defaultValue: true) required this.isActive,
    @JsonKey(name: 'sort_order', defaultValue: 0) required this.sortOrder,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
  }) : super._();

  factory _$HomeBannerImpl.fromJson(Map<String, dynamic> json) =>
      _$$HomeBannerImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String? subtitle;
  @override
  @JsonKey(name: 'image_path')
  final String imagePath;
  @override
  @JsonKey(name: 'link_type', defaultValue: 'none')
  final String linkType;
  @override
  @JsonKey(name: 'link_value')
  final String? linkValue;
  @override
  @JsonKey(name: 'start_at')
  final DateTime? startAt;
  @override
  @JsonKey(name: 'end_at')
  final DateTime? endAt;
  @override
  @JsonKey(name: 'is_active', defaultValue: true)
  final bool isActive;
  @override
  @JsonKey(name: 'sort_order', defaultValue: 0)
  final int sortOrder;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'HomeBanner(id: $id, title: $title, subtitle: $subtitle, imagePath: $imagePath, linkType: $linkType, linkValue: $linkValue, startAt: $startAt, endAt: $endAt, isActive: $isActive, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeBannerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.subtitle, subtitle) ||
                other.subtitle == subtitle) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.linkType, linkType) ||
                other.linkType == linkType) &&
            (identical(other.linkValue, linkValue) ||
                other.linkValue == linkValue) &&
            (identical(other.startAt, startAt) || other.startAt == startAt) &&
            (identical(other.endAt, endAt) || other.endAt == endAt) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
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
    title,
    subtitle,
    imagePath,
    linkType,
    linkValue,
    startAt,
    endAt,
    isActive,
    sortOrder,
    createdAt,
    updatedAt,
  );

  /// Create a copy of HomeBanner
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HomeBannerImplCopyWith<_$HomeBannerImpl> get copyWith =>
      __$$HomeBannerImplCopyWithImpl<_$HomeBannerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HomeBannerImplToJson(this);
  }
}

abstract class _HomeBanner extends HomeBanner {
  const factory _HomeBanner({
    required final String id,
    required final String title,
    final String? subtitle,
    @JsonKey(name: 'image_path') required final String imagePath,
    @JsonKey(name: 'link_type', defaultValue: 'none')
    required final String linkType,
    @JsonKey(name: 'link_value') final String? linkValue,
    @JsonKey(name: 'start_at') final DateTime? startAt,
    @JsonKey(name: 'end_at') final DateTime? endAt,
    @JsonKey(name: 'is_active', defaultValue: true)
    required final bool isActive,
    @JsonKey(name: 'sort_order', defaultValue: 0) required final int sortOrder,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
  }) = _$HomeBannerImpl;
  const _HomeBanner._() : super._();

  factory _HomeBanner.fromJson(Map<String, dynamic> json) =
      _$HomeBannerImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String? get subtitle;
  @override
  @JsonKey(name: 'image_path')
  String get imagePath;
  @override
  @JsonKey(name: 'link_type', defaultValue: 'none')
  String get linkType;
  @override
  @JsonKey(name: 'link_value')
  String? get linkValue;
  @override
  @JsonKey(name: 'start_at')
  DateTime? get startAt;
  @override
  @JsonKey(name: 'end_at')
  DateTime? get endAt;
  @override
  @JsonKey(name: 'is_active', defaultValue: true)
  bool get isActive;
  @override
  @JsonKey(name: 'sort_order', defaultValue: 0)
  int get sortOrder;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of HomeBanner
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HomeBannerImplCopyWith<_$HomeBannerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
