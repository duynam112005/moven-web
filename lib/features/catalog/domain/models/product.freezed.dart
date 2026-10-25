// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Product _$ProductFromJson(Map<String, dynamic> json) {
  return _Product.fromJson(json);
}

/// @nodoc
mixin _$Product {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'category_id')
  String get categoryId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get material => throw _privateConstructorUsedError;
  @JsonKey(name: 'target_audience', defaultValue: 'unisex')
  String get targetAudience => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_featured', defaultValue: false)
  bool get isFeatured => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active', defaultValue: true)
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError; // Quan hệ lồng nhau khi JOIN
  @JsonKey(name: 'categories', fromJson: _categoryFromJson)
  Category? get category => throw _privateConstructorUsedError;
  @JsonKey(name: 'product_variants', fromJson: _variantsFromJson)
  List<ProductVariant> get variants => throw _privateConstructorUsedError;
  @JsonKey(name: 'product_images', fromJson: _imagesFromJson)
  List<ProductImage> get images => throw _privateConstructorUsedError;

  /// Serializes this Product to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductCopyWith<Product> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductCopyWith<$Res> {
  factory $ProductCopyWith(Product value, $Res Function(Product) then) =
      _$ProductCopyWithImpl<$Res, Product>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'category_id') String categoryId,
    String name,
    String slug,
    String? description,
    String? material,
    @JsonKey(name: 'target_audience', defaultValue: 'unisex')
    String targetAudience,
    @JsonKey(name: 'is_featured', defaultValue: false) bool isFeatured,
    @JsonKey(name: 'is_active', defaultValue: true) bool isActive,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
    @JsonKey(name: 'categories', fromJson: _categoryFromJson)
    Category? category,
    @JsonKey(name: 'product_variants', fromJson: _variantsFromJson)
    List<ProductVariant> variants,
    @JsonKey(name: 'product_images', fromJson: _imagesFromJson)
    List<ProductImage> images,
  });

  $CategoryCopyWith<$Res>? get category;
}

/// @nodoc
class _$ProductCopyWithImpl<$Res, $Val extends Product>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? categoryId = null,
    Object? name = null,
    Object? slug = null,
    Object? description = freezed,
    Object? material = freezed,
    Object? targetAudience = null,
    Object? isFeatured = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? category = freezed,
    Object? variants = null,
    Object? images = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            categoryId: null == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            slug: null == slug
                ? _value.slug
                : slug // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            material: freezed == material
                ? _value.material
                : material // ignore: cast_nullable_to_non_nullable
                      as String?,
            targetAudience: null == targetAudience
                ? _value.targetAudience
                : targetAudience // ignore: cast_nullable_to_non_nullable
                      as String,
            isFeatured: null == isFeatured
                ? _value.isFeatured
                : isFeatured // ignore: cast_nullable_to_non_nullable
                      as bool,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            category: freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as Category?,
            variants: null == variants
                ? _value.variants
                : variants // ignore: cast_nullable_to_non_nullable
                      as List<ProductVariant>,
            images: null == images
                ? _value.images
                : images // ignore: cast_nullable_to_non_nullable
                      as List<ProductImage>,
          )
          as $Val,
    );
  }

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CategoryCopyWith<$Res>? get category {
    if (_value.category == null) {
      return null;
    }

    return $CategoryCopyWith<$Res>(_value.category!, (value) {
      return _then(_value.copyWith(category: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProductImplCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$$ProductImplCopyWith(
    _$ProductImpl value,
    $Res Function(_$ProductImpl) then,
  ) = __$$ProductImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'category_id') String categoryId,
    String name,
    String slug,
    String? description,
    String? material,
    @JsonKey(name: 'target_audience', defaultValue: 'unisex')
    String targetAudience,
    @JsonKey(name: 'is_featured', defaultValue: false) bool isFeatured,
    @JsonKey(name: 'is_active', defaultValue: true) bool isActive,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
    @JsonKey(name: 'categories', fromJson: _categoryFromJson)
    Category? category,
    @JsonKey(name: 'product_variants', fromJson: _variantsFromJson)
    List<ProductVariant> variants,
    @JsonKey(name: 'product_images', fromJson: _imagesFromJson)
    List<ProductImage> images,
  });

  @override
  $CategoryCopyWith<$Res>? get category;
}

/// @nodoc
class __$$ProductImplCopyWithImpl<$Res>
    extends _$ProductCopyWithImpl<$Res, _$ProductImpl>
    implements _$$ProductImplCopyWith<$Res> {
  __$$ProductImplCopyWithImpl(
    _$ProductImpl _value,
    $Res Function(_$ProductImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? categoryId = null,
    Object? name = null,
    Object? slug = null,
    Object? description = freezed,
    Object? material = freezed,
    Object? targetAudience = null,
    Object? isFeatured = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? category = freezed,
    Object? variants = null,
    Object? images = null,
  }) {
    return _then(
      _$ProductImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        categoryId: null == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        slug: null == slug
            ? _value.slug
            : slug // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        material: freezed == material
            ? _value.material
            : material // ignore: cast_nullable_to_non_nullable
                  as String?,
        targetAudience: null == targetAudience
            ? _value.targetAudience
            : targetAudience // ignore: cast_nullable_to_non_nullable
                  as String,
        isFeatured: null == isFeatured
            ? _value.isFeatured
            : isFeatured // ignore: cast_nullable_to_non_nullable
                  as bool,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        category: freezed == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as Category?,
        variants: null == variants
            ? _value._variants
            : variants // ignore: cast_nullable_to_non_nullable
                  as List<ProductVariant>,
        images: null == images
            ? _value._images
            : images // ignore: cast_nullable_to_non_nullable
                  as List<ProductImage>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductImpl extends _Product {
  const _$ProductImpl({
    required this.id,
    @JsonKey(name: 'category_id') required this.categoryId,
    required this.name,
    required this.slug,
    this.description,
    this.material,
    @JsonKey(name: 'target_audience', defaultValue: 'unisex')
    required this.targetAudience,
    @JsonKey(name: 'is_featured', defaultValue: false) required this.isFeatured,
    @JsonKey(name: 'is_active', defaultValue: true) required this.isActive,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
    @JsonKey(name: 'categories', fromJson: _categoryFromJson) this.category,
    @JsonKey(name: 'product_variants', fromJson: _variantsFromJson)
    final List<ProductVariant> variants = const <ProductVariant>[],
    @JsonKey(name: 'product_images', fromJson: _imagesFromJson)
    final List<ProductImage> images = const <ProductImage>[],
  }) : _variants = variants,
       _images = images,
       super._();

  factory _$ProductImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'category_id')
  final String categoryId;
  @override
  final String name;
  @override
  final String slug;
  @override
  final String? description;
  @override
  final String? material;
  @override
  @JsonKey(name: 'target_audience', defaultValue: 'unisex')
  final String targetAudience;
  @override
  @JsonKey(name: 'is_featured', defaultValue: false)
  final bool isFeatured;
  @override
  @JsonKey(name: 'is_active', defaultValue: true)
  final bool isActive;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  // Quan hệ lồng nhau khi JOIN
  @override
  @JsonKey(name: 'categories', fromJson: _categoryFromJson)
  final Category? category;
  final List<ProductVariant> _variants;
  @override
  @JsonKey(name: 'product_variants', fromJson: _variantsFromJson)
  List<ProductVariant> get variants {
    if (_variants is EqualUnmodifiableListView) return _variants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_variants);
  }

  final List<ProductImage> _images;
  @override
  @JsonKey(name: 'product_images', fromJson: _imagesFromJson)
  List<ProductImage> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @override
  String toString() {
    return 'Product(id: $id, categoryId: $categoryId, name: $name, slug: $slug, description: $description, material: $material, targetAudience: $targetAudience, isFeatured: $isFeatured, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, category: $category, variants: $variants, images: $images)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.material, material) ||
                other.material == material) &&
            (identical(other.targetAudience, targetAudience) ||
                other.targetAudience == targetAudience) &&
            (identical(other.isFeatured, isFeatured) ||
                other.isFeatured == isFeatured) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.category, category) ||
                other.category == category) &&
            const DeepCollectionEquality().equals(other._variants, _variants) &&
            const DeepCollectionEquality().equals(other._images, _images));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    categoryId,
    name,
    slug,
    description,
    material,
    targetAudience,
    isFeatured,
    isActive,
    createdAt,
    updatedAt,
    category,
    const DeepCollectionEquality().hash(_variants),
    const DeepCollectionEquality().hash(_images),
  );

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductImplCopyWith<_$ProductImpl> get copyWith =>
      __$$ProductImplCopyWithImpl<_$ProductImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductImplToJson(this);
  }
}

abstract class _Product extends Product {
  const factory _Product({
    required final String id,
    @JsonKey(name: 'category_id') required final String categoryId,
    required final String name,
    required final String slug,
    final String? description,
    final String? material,
    @JsonKey(name: 'target_audience', defaultValue: 'unisex')
    required final String targetAudience,
    @JsonKey(name: 'is_featured', defaultValue: false)
    required final bool isFeatured,
    @JsonKey(name: 'is_active', defaultValue: true)
    required final bool isActive,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
    @JsonKey(name: 'categories', fromJson: _categoryFromJson)
    final Category? category,
    @JsonKey(name: 'product_variants', fromJson: _variantsFromJson)
    final List<ProductVariant> variants,
    @JsonKey(name: 'product_images', fromJson: _imagesFromJson)
    final List<ProductImage> images,
  }) = _$ProductImpl;
  const _Product._() : super._();

  factory _Product.fromJson(Map<String, dynamic> json) = _$ProductImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'category_id')
  String get categoryId;
  @override
  String get name;
  @override
  String get slug;
  @override
  String? get description;
  @override
  String? get material;
  @override
  @JsonKey(name: 'target_audience', defaultValue: 'unisex')
  String get targetAudience;
  @override
  @JsonKey(name: 'is_featured', defaultValue: false)
  bool get isFeatured;
  @override
  @JsonKey(name: 'is_active', defaultValue: true)
  bool get isActive;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt; // Quan hệ lồng nhau khi JOIN
  @override
  @JsonKey(name: 'categories', fromJson: _categoryFromJson)
  Category? get category;
  @override
  @JsonKey(name: 'product_variants', fromJson: _variantsFromJson)
  List<ProductVariant> get variants;
  @override
  @JsonKey(name: 'product_images', fromJson: _imagesFromJson)
  List<ProductImage> get images;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductImplCopyWith<_$ProductImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
