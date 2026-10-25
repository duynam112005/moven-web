// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'catalog_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CatalogFilter _$CatalogFilterFromJson(Map<String, dynamic> json) {
  return _CatalogFilter.fromJson(json);
}

/// @nodoc
mixin _$CatalogFilter {
  String? get categoryId => throw _privateConstructorUsedError;
  String? get categorySlug => throw _privateConstructorUsedError;
  String? get targetAudience =>
      throw _privateConstructorUsedError; // 'men', 'women', 'unisex'
  String? get searchKeyword => throw _privateConstructorUsedError;
  int? get minPrice => throw _privateConstructorUsedError;
  int? get maxPrice => throw _privateConstructorUsedError;
  String get sortBy =>
      throw _privateConstructorUsedError; // 'newest', 'price_asc', 'price_desc', 'name_asc'
  bool get inStockOnly => throw _privateConstructorUsedError;
  bool get isFeaturedOnly => throw _privateConstructorUsedError;

  /// Serializes this CatalogFilter to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CatalogFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CatalogFilterCopyWith<CatalogFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CatalogFilterCopyWith<$Res> {
  factory $CatalogFilterCopyWith(
    CatalogFilter value,
    $Res Function(CatalogFilter) then,
  ) = _$CatalogFilterCopyWithImpl<$Res, CatalogFilter>;
  @useResult
  $Res call({
    String? categoryId,
    String? categorySlug,
    String? targetAudience,
    String? searchKeyword,
    int? minPrice,
    int? maxPrice,
    String sortBy,
    bool inStockOnly,
    bool isFeaturedOnly,
  });
}

/// @nodoc
class _$CatalogFilterCopyWithImpl<$Res, $Val extends CatalogFilter>
    implements $CatalogFilterCopyWith<$Res> {
  _$CatalogFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CatalogFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categoryId = freezed,
    Object? categorySlug = freezed,
    Object? targetAudience = freezed,
    Object? searchKeyword = freezed,
    Object? minPrice = freezed,
    Object? maxPrice = freezed,
    Object? sortBy = null,
    Object? inStockOnly = null,
    Object? isFeaturedOnly = null,
  }) {
    return _then(
      _value.copyWith(
            categoryId: freezed == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as String?,
            categorySlug: freezed == categorySlug
                ? _value.categorySlug
                : categorySlug // ignore: cast_nullable_to_non_nullable
                      as String?,
            targetAudience: freezed == targetAudience
                ? _value.targetAudience
                : targetAudience // ignore: cast_nullable_to_non_nullable
                      as String?,
            searchKeyword: freezed == searchKeyword
                ? _value.searchKeyword
                : searchKeyword // ignore: cast_nullable_to_non_nullable
                      as String?,
            minPrice: freezed == minPrice
                ? _value.minPrice
                : minPrice // ignore: cast_nullable_to_non_nullable
                      as int?,
            maxPrice: freezed == maxPrice
                ? _value.maxPrice
                : maxPrice // ignore: cast_nullable_to_non_nullable
                      as int?,
            sortBy: null == sortBy
                ? _value.sortBy
                : sortBy // ignore: cast_nullable_to_non_nullable
                      as String,
            inStockOnly: null == inStockOnly
                ? _value.inStockOnly
                : inStockOnly // ignore: cast_nullable_to_non_nullable
                      as bool,
            isFeaturedOnly: null == isFeaturedOnly
                ? _value.isFeaturedOnly
                : isFeaturedOnly // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CatalogFilterImplCopyWith<$Res>
    implements $CatalogFilterCopyWith<$Res> {
  factory _$$CatalogFilterImplCopyWith(
    _$CatalogFilterImpl value,
    $Res Function(_$CatalogFilterImpl) then,
  ) = __$$CatalogFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? categoryId,
    String? categorySlug,
    String? targetAudience,
    String? searchKeyword,
    int? minPrice,
    int? maxPrice,
    String sortBy,
    bool inStockOnly,
    bool isFeaturedOnly,
  });
}

/// @nodoc
class __$$CatalogFilterImplCopyWithImpl<$Res>
    extends _$CatalogFilterCopyWithImpl<$Res, _$CatalogFilterImpl>
    implements _$$CatalogFilterImplCopyWith<$Res> {
  __$$CatalogFilterImplCopyWithImpl(
    _$CatalogFilterImpl _value,
    $Res Function(_$CatalogFilterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CatalogFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categoryId = freezed,
    Object? categorySlug = freezed,
    Object? targetAudience = freezed,
    Object? searchKeyword = freezed,
    Object? minPrice = freezed,
    Object? maxPrice = freezed,
    Object? sortBy = null,
    Object? inStockOnly = null,
    Object? isFeaturedOnly = null,
  }) {
    return _then(
      _$CatalogFilterImpl(
        categoryId: freezed == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as String?,
        categorySlug: freezed == categorySlug
            ? _value.categorySlug
            : categorySlug // ignore: cast_nullable_to_non_nullable
                  as String?,
        targetAudience: freezed == targetAudience
            ? _value.targetAudience
            : targetAudience // ignore: cast_nullable_to_non_nullable
                  as String?,
        searchKeyword: freezed == searchKeyword
            ? _value.searchKeyword
            : searchKeyword // ignore: cast_nullable_to_non_nullable
                  as String?,
        minPrice: freezed == minPrice
            ? _value.minPrice
            : minPrice // ignore: cast_nullable_to_non_nullable
                  as int?,
        maxPrice: freezed == maxPrice
            ? _value.maxPrice
            : maxPrice // ignore: cast_nullable_to_non_nullable
                  as int?,
        sortBy: null == sortBy
            ? _value.sortBy
            : sortBy // ignore: cast_nullable_to_non_nullable
                  as String,
        inStockOnly: null == inStockOnly
            ? _value.inStockOnly
            : inStockOnly // ignore: cast_nullable_to_non_nullable
                  as bool,
        isFeaturedOnly: null == isFeaturedOnly
            ? _value.isFeaturedOnly
            : isFeaturedOnly // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CatalogFilterImpl extends _CatalogFilter {
  const _$CatalogFilterImpl({
    this.categoryId,
    this.categorySlug,
    this.targetAudience,
    this.searchKeyword,
    this.minPrice,
    this.maxPrice,
    this.sortBy = 'newest',
    this.inStockOnly = false,
    this.isFeaturedOnly = false,
  }) : super._();

  factory _$CatalogFilterImpl.fromJson(Map<String, dynamic> json) =>
      _$$CatalogFilterImplFromJson(json);

  @override
  final String? categoryId;
  @override
  final String? categorySlug;
  @override
  final String? targetAudience;
  // 'men', 'women', 'unisex'
  @override
  final String? searchKeyword;
  @override
  final int? minPrice;
  @override
  final int? maxPrice;
  @override
  @JsonKey()
  final String sortBy;
  // 'newest', 'price_asc', 'price_desc', 'name_asc'
  @override
  @JsonKey()
  final bool inStockOnly;
  @override
  @JsonKey()
  final bool isFeaturedOnly;

  @override
  String toString() {
    return 'CatalogFilter(categoryId: $categoryId, categorySlug: $categorySlug, targetAudience: $targetAudience, searchKeyword: $searchKeyword, minPrice: $minPrice, maxPrice: $maxPrice, sortBy: $sortBy, inStockOnly: $inStockOnly, isFeaturedOnly: $isFeaturedOnly)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CatalogFilterImpl &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.categorySlug, categorySlug) ||
                other.categorySlug == categorySlug) &&
            (identical(other.targetAudience, targetAudience) ||
                other.targetAudience == targetAudience) &&
            (identical(other.searchKeyword, searchKeyword) ||
                other.searchKeyword == searchKeyword) &&
            (identical(other.minPrice, minPrice) ||
                other.minPrice == minPrice) &&
            (identical(other.maxPrice, maxPrice) ||
                other.maxPrice == maxPrice) &&
            (identical(other.sortBy, sortBy) || other.sortBy == sortBy) &&
            (identical(other.inStockOnly, inStockOnly) ||
                other.inStockOnly == inStockOnly) &&
            (identical(other.isFeaturedOnly, isFeaturedOnly) ||
                other.isFeaturedOnly == isFeaturedOnly));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    categoryId,
    categorySlug,
    targetAudience,
    searchKeyword,
    minPrice,
    maxPrice,
    sortBy,
    inStockOnly,
    isFeaturedOnly,
  );

  /// Create a copy of CatalogFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CatalogFilterImplCopyWith<_$CatalogFilterImpl> get copyWith =>
      __$$CatalogFilterImplCopyWithImpl<_$CatalogFilterImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CatalogFilterImplToJson(this);
  }
}

abstract class _CatalogFilter extends CatalogFilter {
  const factory _CatalogFilter({
    final String? categoryId,
    final String? categorySlug,
    final String? targetAudience,
    final String? searchKeyword,
    final int? minPrice,
    final int? maxPrice,
    final String sortBy,
    final bool inStockOnly,
    final bool isFeaturedOnly,
  }) = _$CatalogFilterImpl;
  const _CatalogFilter._() : super._();

  factory _CatalogFilter.fromJson(Map<String, dynamic> json) =
      _$CatalogFilterImpl.fromJson;

  @override
  String? get categoryId;
  @override
  String? get categorySlug;
  @override
  String? get targetAudience; // 'men', 'women', 'unisex'
  @override
  String? get searchKeyword;
  @override
  int? get minPrice;
  @override
  int? get maxPrice;
  @override
  String get sortBy; // 'newest', 'price_asc', 'price_desc', 'name_asc'
  @override
  bool get inStockOnly;
  @override
  bool get isFeaturedOnly;

  /// Create a copy of CatalogFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CatalogFilterImplCopyWith<_$CatalogFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
