import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/supabase_client.dart';
import '../domain/models/banner.dart';
import '../domain/models/category.dart';
import '../domain/models/catalog_filter.dart';
import '../domain/models/paginated_result.dart';
import '../domain/models/product.dart';
import '../domain/models/product_image.dart';
import '../domain/models/product_variant.dart';

/// Repository xử lý dữ liệu Danh mục, Sản phẩm, Biến thể, Ảnh và Banner.
///
/// Tuân thủ quy tắc kiến trúc MOVEN:
/// - Storefront/Public: Chỉ đọc bản ghi active (và banner còn trong hạn).
/// - Nguồn giá duy nhất là variant.price, giá min/max tính động.
/// - Không tin tưởng dữ liệu client tự gắn role.
class CatalogRepository {
  final SupabaseClient _client;

  CatalogRepository(this._client);

  static const String _productSelectQuery = '''
    *,
    categories (*),
    product_variants (*),
    product_images (*)
  ''';

  // ==========================================
  // STOREFRONT / PUBLIC QUERIES
  // ==========================================

  /// Lấy danh sách danh mục đang hoạt động
  Future<List<Category>> getActiveCategories() async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      return (response as List)
          .map((json) => Category.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException('Lỗi tải danh mục: ${e.message}', code: e.code);
    } catch (e) {
      throw ServerException('Lỗi kết nối khi tải danh mục: $e');
    }
  }

  /// Lấy danh sách banner trang chủ đang hoạt động và trong lịch hiển thị
  Future<List<HomeBanner>> getActiveBanners() async {
    try {
      final response = await _client
          .from('banners')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      final now = DateTime.now();
      return (response as List)
          .map((json) => HomeBanner.fromJson(json as Map<String, dynamic>))
          .where((banner) => banner.isCurrentlyVisible(now))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException('Lỗi tải banner: ${e.message}', code: e.code);
    } catch (e) {
      throw ServerException('Lỗi kết nối khi tải banner: $e');
    }
  }

  /// Lấy danh sách sản phẩm nổi bật cho trang chủ
  Future<List<Product>> getFeaturedProducts({int limit = 8}) async {
    try {
      final response = await _client
          .from('products')
          .select(_productSelectQuery)
          .eq('is_active', true)
          .eq('is_featured', true)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .where((p) => p.category?.isActive ?? true)
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException('Lỗi tải sản phẩm nổi bật: ${e.message}', code: e.code);
    } catch (e) {
      throw ServerException('Lỗi kết nối khi tải sản phẩm nổi bật: $e');
    }
  }

  /// Truy vấn sản phẩm theo bộ lọc và phân trang cho Catalog
  Future<PaginatedResult<Product>> getProducts({
    CatalogFilter filter = const CatalogFilter(),
    int page = 1,
    int pageSize = 12,
  }) async {
    try {
      final from = (page - 1) * pageSize;
      final to = from + pageSize - 1;

      var query = _client
          .from('products')
          .select(_productSelectQuery)
          .eq('is_active', true);

      // Lọc theo Category ID hoặc Category Slug
      if (filter.categoryId != null && filter.categoryId!.isNotEmpty) {
        query = query.eq('category_id', filter.categoryId!);
      }

      // Lọc theo đối tượng (men, women, unisex)
      if (filter.targetAudience != null && filter.targetAudience!.isNotEmpty) {
        query = query.eq('target_audience', filter.targetAudience!);
      }

      // Tìm kiếm từ khóa theo tên
      if (filter.searchKeyword != null && filter.searchKeyword!.trim().isNotEmpty) {
        query = query.ilike('name', '%${filter.searchKeyword!.trim()}%');
      }

      // Lọc chỉ sản phẩm nổi bật
      if (filter.isFeaturedOnly) {
        query = query.eq('is_featured', true);
      }

      // Sắp xếp
      PostgrestTransformBuilder<PostgrestList> transform;
      switch (filter.sortBy) {
        case 'name_asc':
          transform = query.order('name', ascending: true);
          break;
        case 'newest':
        default:
          transform = query.order('created_at', ascending: false);
          break;
      }

      final response = await transform.range(from, to).count(CountOption.exact);
      final rawList = response.data;
      final totalCount = response.count;

      var products = rawList.map(Product.fromJson).toList();

      // Client-side filter bổ sung: inStockOnly & price range nếu có
      if (filter.inStockOnly) {
        products = products.where((p) => p.inStock).toList();
      }
      if (filter.minPrice != null) {
        products = products.where((p) => (p.minPrice ?? 0) >= filter.minPrice!).toList();
      }
      if (filter.maxPrice != null) {
        products = products.where((p) => (p.minPrice ?? 0) <= filter.maxPrice!).toList();
      }

      // Sắp xếp giá nếu được yêu cầu
      if (filter.sortBy == 'price_asc') {
        products.sort((a, b) => (a.minPrice ?? 0).compareTo(b.minPrice ?? 0));
      } else if (filter.sortBy == 'price_desc') {
        products.sort((a, b) => (b.minPrice ?? 0).compareTo(a.minPrice ?? 0));
      }

      return PaginatedResult<Product>(
        items: products,
        totalCount: totalCount,
        page: page,
        pageSize: pageSize,
      );
    } on PostgrestException catch (e) {
      throw ServerException('Lỗi tải danh mục sản phẩm: ${e.message}', code: e.code);
    } catch (e) {
      throw ServerException('Lỗi kết nối khi tải danh mục sản phẩm: $e');
    }
  }

  /// Lấy chi tiết sản phẩm theo slug cho trang Product Detail
  Future<Product?> getProductBySlug(String slug) async {
    try {
      final response = await _client
          .from('products')
          .select(_productSelectQuery)
          .eq('slug', slug)
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) return null;
      return Product.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException('Lỗi tải chi tiết sản phẩm: ${e.message}', code: e.code);
    } catch (e) {
      throw ServerException('Lỗi kết nối khi tải chi tiết sản phẩm: $e');
    }
  }

  // ==========================================
  // ADMIN CRUD OPERATIONS
  // ==========================================

  /// [Admin] Lấy tất cả danh mục (bao gồm cả danh mục bị ẩn)
  Future<List<Category>> getAdminCategories() async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .order('sort_order', ascending: true);

      return (response as List)
          .map((json) => Category.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException('Lỗi quản trị danh mục: ${e.message}', code: e.code);
    }
  }

  /// [Admin] Tạo danh mục mới
  Future<Category> createCategory(Category category) async {
    try {
      final response = await _client
          .from('categories')
          .insert(category.toInsertJson())
          .select()
          .single();

      return Category.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException('Lỗi tạo danh mục: ${e.message}', code: e.code);
    }
  }

  /// [Admin] Cập nhật danh mục
  Future<Category> updateCategory(Category category) async {
    try {
      final response = await _client
          .from('categories')
          .update(category.toUpdateJson())
          .eq('id', category.id)
          .select()
          .single();

      return Category.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException('Lỗi cập nhật danh mục: ${e.message}', code: e.code);
    }
  }

  /// [Admin] Ẩn/Hiện danh mục (soft toggle)
  Future<void> toggleCategoryActive(String categoryId, bool isActive) async {
    try {
      await _client
          .from('categories')
          .update({'is_active': isActive})
          .eq('id', categoryId);
    } on PostgrestException catch (e) {
      throw ServerException('Lỗi đổi trạng thái danh mục: ${e.message}', code: e.code);
    }
  }

  /// [Admin] Lấy danh sách sản phẩm quản trị (kèm phân trang, tìm kiếm)
  Future<PaginatedResult<Product>> getAdminProducts({
    String? search,
    String? categoryId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final from = (page - 1) * pageSize;
      final to = from + pageSize - 1;

      var query = _client
          .from('products')
          .select(_productSelectQuery);

      if (categoryId != null && categoryId.isNotEmpty) {
        query = query.eq('category_id', categoryId);
      }
      if (search != null && search.trim().isNotEmpty) {
        query = query.ilike('name', '%${search.trim()}%');
      }

      final transform = query.order('created_at', ascending: false);

      final response = await transform.range(from, to).count(CountOption.exact);
      final rawList = response.data;
      final totalCount = response.count;

      final products = rawList.map(Product.fromJson).toList();

      return PaginatedResult<Product>(
        items: products,
        totalCount: totalCount,
        page: page,
        pageSize: pageSize,
      );
    } on PostgrestException catch (e) {
      throw ServerException('Lỗi tải sản phẩm quản trị: ${e.message}', code: e.code);
    }
  }

  /// [Admin] Lấy chi tiết sản phẩm theo ID để chỉnh sửa
  Future<Product?> getAdminProductById(String id) async {
    try {
      final response = await _client
          .from('products')
          .select(_productSelectQuery)
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return Product.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException('Lỗi tải sản phẩm: ${e.message}', code: e.code);
    }
  }

  /// [Admin] Tạo sản phẩm mới kèm các biến thể và ảnh
  Future<Product> createProduct({
    required Product product,
    required List<ProductVariant> variants,
    List<ProductImage> images = const [],
  }) async {
    try {
      // 1. Tạo sản phẩm
      final createdProductMap = await _client
          .from('products')
          .insert(product.toInsertJson())
          .select()
          .single();

      final productId = createdProductMap['id'] as String;

      // 2. Thêm các biến thể
      if (variants.isNotEmpty) {
        final variantPayloads = variants
            .map((v) => v.copyWith(productId: productId).toInsertJson())
            .toList();

        await _client.from('product_variants').insert(variantPayloads);
      }

      // 3. Thêm các ảnh sản phẩm
      if (images.isNotEmpty) {
        final imagePayloads = images
            .map((img) => img.copyWith(productId: productId).toInsertJson())
            .toList();

        await _client.from('product_images').insert(imagePayloads);
      }

      // 4. Lấy lại sản phẩm hoàn chỉnh kèm relations
      final fullProduct = await getAdminProductById(productId);
      if (fullProduct == null) {
        throw const ServerException('Không thể nạp lại sản phẩm vừa tạo');
      }
      return fullProduct;
    } on PostgrestException catch (e) {
      throw ServerException('Lỗi tạo sản phẩm: ${e.message}', code: e.code);
    }
  }

  /// [Admin] Cập nhật sản phẩm, biến thể và ảnh
  Future<Product> updateProduct({
    required Product product,
    List<ProductVariant>? variants,
    List<ProductImage>? images,
  }) async {
    try {
      // 1. Cập nhật thông tin chung sản phẩm
      await _client
          .from('products')
          .update(product.toUpdateJson())
          .eq('id', product.id);

      // 2. Cập nhật hoặc thêm mới biến thể
      if (variants != null) {
        for (final v in variants) {
          if (v.id.isNotEmpty && !v.id.startsWith('temp_')) {
            await _client
                .from('product_variants')
                .update(v.toUpdateJson())
                .eq('id', v.id);
          } else {
            await _client
                .from('product_variants')
                .insert(v.copyWith(productId: product.id).toInsertJson());
          }
        }
      }

      // 3. Cập nhật ảnh
      if (images != null) {
        for (final img in images) {
          if (img.id.isNotEmpty && !img.id.startsWith('temp_')) {
            await _client
                .from('product_images')
                .update(img.toUpdateJson())
                .eq('id', img.id);
          } else {
            await _client
                .from('product_images')
                .insert(img.copyWith(productId: product.id).toInsertJson());
          }
        }
      }

      final fullProduct = await getAdminProductById(product.id);
      if (fullProduct == null) {
        throw const ServerException('Không tìm thấy sản phẩm sau khi cập nhật');
      }
      return fullProduct;
    } on PostgrestException catch (e) {
      throw ServerException('Lỗi cập nhật sản phẩm: ${e.message}', code: e.code);
    }
  }

  /// [Admin] Ẩn/Hiện sản phẩm
  Future<void> toggleProductActive(String productId, bool isActive) async {
    try {
      await _client
          .from('products')
          .update({'is_active': isActive})
          .eq('id', productId);
    } on PostgrestException catch (e) {
      throw ServerException('Lỗi đổi trạng thái sản phẩm: ${e.message}', code: e.code);
    }
  }

  /// [Admin] Xóa ảnh sản phẩm
  Future<void> deleteProductImage(String imageId) async {
    try {
      await _client.from('product_images').delete().eq('id', imageId);
    } on PostgrestException catch (e) {
      throw ServerException('Lỗi xóa ảnh: ${e.message}', code: e.code);
    }
  }

  // ==========================================
  // ADMIN BANNER CRUD
  // ==========================================

  /// [Admin] Lấy tất cả banner
  Future<List<HomeBanner>> getAdminBanners() async {
    try {
      final response = await _client
          .from('banners')
          .select()
          .order('sort_order', ascending: true);

      return (response as List)
          .map((json) => HomeBanner.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException('Lỗi tải banner quản trị: ${e.message}', code: e.code);
    }
  }

  /// [Admin] Tạo banner mới
  Future<HomeBanner> createBanner(HomeBanner banner) async {
    try {
      final response = await _client
          .from('banners')
          .insert(banner.toInsertJson())
          .select()
          .single();

      return HomeBanner.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException('Lỗi tạo banner: ${e.message}', code: e.code);
    }
  }

  /// [Admin] Cập nhật banner
  Future<HomeBanner> updateBanner(HomeBanner banner) async {
    try {
      final response = await _client
          .from('banners')
          .update(banner.toUpdateJson())
          .eq('id', banner.id)
          .select()
          .single();

      return HomeBanner.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException('Lỗi cập nhật banner: ${e.message}', code: e.code);
    }
  }

  /// [Admin] Xóa banner
  Future<void> deleteBanner(String bannerId) async {
    try {
      await _client.from('banners').delete().eq('id', bannerId);
    } on PostgrestException catch (e) {
      throw ServerException('Lỗi xóa banner: ${e.message}', code: e.code);
    }
  }
}

/// Provider toàn cục cho CatalogRepository
final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return CatalogRepository(client);
});
