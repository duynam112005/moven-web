// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_image.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProductImage _$ProductImageFromJson(Map<String, dynamic> json) {
  return _ProductImage.fromJson(json);
}

/// @nodoc
mixin _$ProductImage {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'product_id')
  String get productId => throw _privateConstructorUsedError;
  @JsonKey(name: 'variant_id')
  String? get variantId => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_path')
  String get imagePath => throw _privateConstructorUsedError;
  @JsonKey(name: 'alt_text')
  String? get altText => throw _privateConstructorUsedError;
  @JsonKey(name: 'sort_order', defaultValue: 0)
  int get sortOrder => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_primary', defaultValue: false)
  bool get isPrimary => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ProductImage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductImage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductImageCopyWith<ProductImage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductImageCopyWith<$Res> {
  factory $ProductImageCopyWith(
    ProductImage value,
    $Res Function(ProductImage) then,
  ) = _$ProductImageCopyWithImpl<$Res, ProductImage>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'product_id') String productId,
    @JsonKey(name: 'variant_id') String? variantId,
    @JsonKey(name: 'image_path') String imagePath,
    @JsonKey(name: 'alt_text') String? altText,
    @JsonKey(name: 'sort_order', defaultValue: 0) int sortOrder,
    @JsonKey(name: 'is_primary', defaultValue: false) bool isPrimary,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$ProductImageCopyWithImpl<$Res, $Val extends ProductImage>
    implements $ProductImageCopyWith<$Res> {
  _$ProductImageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductImage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? variantId = freezed,
    Object? imagePath = null,
    Object? altText = freezed,
    Object? sortOrder = null,
    Object? isPrimary = null,
    Object? createdAt = null,
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
            variantId: freezed == variantId
                ? _value.variantId
                : variantId // ignore: cast_nullable_to_non_nullable
                      as String?,
            imagePath: null == imagePath
                ? _value.imagePath
                : imagePath // ignore: cast_nullable_to_non_nullable
                      as String,
            altText: freezed == altText
                ? _value.altText
                : altText // ignore: cast_nullable_to_non_nullable
                      as String?,
            sortOrder: null == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                      as int,
            isPrimary: null == isPrimary
                ? _value.isPrimary
                : isPrimary // ignore: cast_nullable_to_non_nullable
                      as bool,
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
abstract class _$$ProductImageImplCopyWith<$Res>
    implements $ProductImageCopyWith<$Res> {
  factory _$$ProductImageImplCopyWith(
    _$ProductImageImpl value,
    $Res Function(_$ProductImageImpl) then,
  ) = __$$ProductImageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'product_id') String productId,
    @JsonKey(name: 'variant_id') String? variantId,
    @JsonKey(name: 'image_path') String imagePath,
    @JsonKey(name: 'alt_text') String? altText,
    @JsonKey(name: 'sort_order', defaultValue: 0) int sortOrder,
    @JsonKey(name: 'is_primary', defaultValue: false) bool isPrimary,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$ProductImageImplCopyWithImpl<$Res>
    extends _$ProductImageCopyWithImpl<$Res, _$ProductImageImpl>
    implements _$$ProductImageImplCopyWith<$Res> {
  __$$ProductImageImplCopyWithImpl(
    _$ProductImageImpl _value,
    $Res Function(_$ProductImageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductImage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? variantId = freezed,
    Object? imagePath = null,
    Object? altText = freezed,
    Object? sortOrder = null,
    Object? isPrimary = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$ProductImageImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        productId: null == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String,
        variantId: freezed == variantId
            ? _value.variantId
            : variantId // ignore: cast_nullable_to_non_nullable
                  as String?,
        imagePath: null == imagePath
            ? _value.imagePath
            : imagePath // ignore: cast_nullable_to_non_nullable
                  as String,
        altText: freezed == altText
            ? _value.altText
            : altText // ignore: cast_nullable_to_non_nullable
                  as String?,
        sortOrder: null == sortOrder
            ? _value.sortOrder
            : sortOrder // ignore: cast_nullable_to_non_nullable
                  as int,
        isPrimary: null == isPrimary
            ? _value.isPrimary
            : isPrimary // ignore: cast_nullable_to_non_nullable
                  as bool,
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
class _$ProductImageImpl extends _ProductImage {
  const _$ProductImageImpl({
    required this.id,
    @JsonKey(name: 'product_id') required this.productId,
    @JsonKey(name: 'variant_id') this.variantId,
    @JsonKey(name: 'image_path') required this.imagePath,
    @JsonKey(name: 'alt_text') this.altText,
    @JsonKey(name: 'sort_order', defaultValue: 0) required this.sortOrder,
    @JsonKey(name: 'is_primary', defaultValue: false) required this.isPrimary,
    @JsonKey(name: 'created_at') required this.createdAt,
  }) : super._();

  factory _$ProductImageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductImageImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'product_id')
  final String productId;
  @override
  @JsonKey(name: 'variant_id')
  final String? variantId;
  @override
  @JsonKey(name: 'image_path')
  final String imagePath;
  @override
  @JsonKey(name: 'alt_text')
  final String? altText;
  @override
  @JsonKey(name: 'sort_order', defaultValue: 0)
  final int sortOrder;
  @override
  @JsonKey(name: 'is_primary', defaultValue: false)
  final bool isPrimary;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'ProductImage(id: $id, productId: $productId, variantId: $variantId, imagePath: $imagePath, altText: $altText, sortOrder: $sortOrder, isPrimary: $isPrimary, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductImageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.variantId, variantId) ||
                other.variantId == variantId) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.altText, altText) || other.altText == altText) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.isPrimary, isPrimary) ||
                other.isPrimary == isPrimary) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    productId,
    variantId,
    imagePath,
    altText,
    sortOrder,
    isPrimary,
    createdAt,
  );

  /// Create a copy of ProductImage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductImageImplCopyWith<_$ProductImageImpl> get copyWith =>
      __$$ProductImageImplCopyWithImpl<_$ProductImageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductImageImplToJson(this);
  }
}

abstract class _ProductImage extends ProductImage {
  const factory _ProductImage({
    required final String id,
    @JsonKey(name: 'product_id') required final String productId,
    @JsonKey(name: 'variant_id') final String? variantId,
    @JsonKey(name: 'image_path') required final String imagePath,
    @JsonKey(name: 'alt_text') final String? altText,
    @JsonKey(name: 'sort_order', defaultValue: 0) required final int sortOrder,
    @JsonKey(name: 'is_primary', defaultValue: false)
    required final bool isPrimary,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$ProductImageImpl;
  const _ProductImage._() : super._();

  factory _ProductImage.fromJson(Map<String, dynamic> json) =
      _$ProductImageImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'product_id')
  String get productId;
  @override
  @JsonKey(name: 'variant_id')
  String? get variantId;
  @override
  @JsonKey(name: 'image_path')
  String get imagePath;
  @override
  @JsonKey(name: 'alt_text')
  String? get altText;
  @override
  @JsonKey(name: 'sort_order', defaultValue: 0)
  int get sortOrder;
  @override
  @JsonKey(name: 'is_primary', defaultValue: false)
  bool get isPrimary;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of ProductImage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductImageImplCopyWith<_$ProductImageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
