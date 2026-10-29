import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthChangeEvent, AuthState, User;
import '../../../core/config/app_config.dart';
import '../../../core/network/supabase_client.dart';
import '../domain/models/banner.dart';
import '../domain/models/category.dart';
import '../domain/models/catalog_filter.dart';
import '../domain/models/paginated_result.dart';
import '../domain/models/product.dart';
import 'catalog_repository.dart';

// ==========================================
// STOREFRONT PROVIDERS
// ==========================================

/// Provider danh sách danh mục đang hoạt động
final activeCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  if (!AppConfig.isSupabaseConfigured) return const [];
  try {
    final repo = ref.watch(catalogRepositoryProvider);
    return repo.getActiveCategories();
  } catch (_) {
    return const [];
  }
});

/// Provider danh sách banner đang hoạt động và trong thời hạn hiển thị
final activeBannersProvider = FutureProvider<List<HomeBanner>>((ref) async {
  if (!AppConfig.isSupabaseConfigured) return const [];
  try {
    final repo = ref.watch(catalogRepositoryProvider);
    return repo.getActiveBanners();
  } catch (_) {
    return const [];
  }
});

/// Provider danh sách sản phẩm nổi bật trên Trang chủ
final featuredProductsProvider = FutureProvider<List<Product>>((ref) async {
  if (!AppConfig.isSupabaseConfigured) return const [];
  try {
    final repo = ref.watch(catalogRepositoryProvider);
    return repo.getFeaturedProducts();
  } catch (_) {
    return const [];
  }
});

/// Thời hạn tối đa cho một phiên tìm kiếm sản phẩm trước khi tự động đặt lại (15 phút)
const Duration catalogSearchSessionDuration = Duration(minutes: 15);

/// Provider lưu thời điểm thực hiện tìm kiếm sản phẩm gần nhất
final catalogSearchTimestampProvider = StateProvider<DateTime?>((ref) => null);

/// Kiểm tra xem phiên tìm kiếm sản phẩm đã hết hạn hay chưa (mặc định sau 15 phút)
bool isCatalogSearchExpired(DateTime? timestamp, [DateTime? currentTime]) {
  if (timestamp == null) return false;
  final now = currentTime ?? DateTime.now();
  return now.difference(timestamp) > catalogSearchSessionDuration;
}

/// Provider lưu trạng thái bộ lọc của Catalog
final catalogFilterProvider = StateProvider<CatalogFilter>((ref) {
  // Tự động reset bộ lọc khi người dùng đăng xuất
  ref.listen<AsyncValue<AuthState>>(authStateChangesProvider, (_, next) {
    if (next.value?.event == AuthChangeEvent.signedOut) {
      ref.controller.state = const CatalogFilter();
      ref.read(catalogPageProvider.notifier).state = 1;
      ref.read(catalogSearchTimestampProvider.notifier).state = null;
    }
  });

  ref.listen<User?>(currentUserProvider, (previous, next) {
    if (previous != null && next == null) {
      ref.controller.state = const CatalogFilter();
      ref.read(catalogPageProvider.notifier).state = 1;
      ref.read(catalogSearchTimestampProvider.notifier).state = null;
    }
  });

  return const CatalogFilter();
});

/// Provider lưu trang hiện tại của Catalog
final catalogPageProvider = StateProvider<int>((ref) => 1);

/// Provider danh sách sản phẩm theo bộ lọc & phân trang cho trang Catalog
final catalogProductsProvider =
    FutureProvider<PaginatedResult<Product>>((ref) async {
  if (!AppConfig.isSupabaseConfigured) {
    return const PaginatedResult<Product>(
      items: [],
      totalCount: 0,
      page: 1,
      pageSize: 12,
    );
  }
  try {
    final repo = ref.watch(catalogRepositoryProvider);
    final filter = ref.watch(catalogFilterProvider);
    final page = ref.watch(catalogPageProvider);

    return await repo.getProducts(filter: filter, page: page, pageSize: 12);
  } catch (_) {
    return const PaginatedResult<Product>(
      items: [],
      totalCount: 0,
      page: 1,
      pageSize: 12,
    );
  }
});

/// Provider chi tiết sản phẩm theo slug
final productDetailProvider =
    FutureProvider.autoDispose.family<Product?, String>((ref, slug) async {
  if (!AppConfig.isSupabaseConfigured) return null;
  try {
    final repo = ref.watch(catalogRepositoryProvider);
    return repo.getProductBySlug(slug);
  } catch (_) {
    return null;
  }
});

// ==========================================
// ADMIN PROVIDERS
// ==========================================

/// Provider danh sách toàn bộ danh mục cho Admin (kèm auto-refresh khi cập nhật)
final adminCategoriesProvider =
    FutureProvider.autoDispose<List<Category>>((ref) async {
  if (!AppConfig.isSupabaseConfigured) return const [];
  try {
    final repo = ref.watch(catalogRepositoryProvider);
    return repo.getAdminCategories();
  } catch (_) {
    return const [];
  }
});

/// Provider danh sách banner cho Admin
final adminBannersProvider =
    FutureProvider.autoDispose<List<HomeBanner>>((ref) async {
  if (!AppConfig.isSupabaseConfigured) return const [];
  try {
    final repo = ref.watch(catalogRepositoryProvider);
    return repo.getAdminBanners();
  } catch (_) {
    return const [];
  }
});

/// Tham số lọc cho sản phẩm Admin
class AdminProductQuery {
  final String? search;
  final String? categoryId;
  final int page;

  const AdminProductQuery({
    this.search,
    this.categoryId,
    this.page = 1,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminProductQuery &&
          runtimeType == other.runtimeType &&
          search == other.search &&
          categoryId == other.categoryId &&
          page == other.page;

  @override
  int get hashCode => search.hashCode ^ categoryId.hashCode ^ page.hashCode;
}

/// Provider danh sách sản phẩm trang Admin
final adminProductsProvider = FutureProvider.autoDispose
    .family<PaginatedResult<Product>, AdminProductQuery>((ref, query) async {
  if (!AppConfig.isSupabaseConfigured) {
    return const PaginatedResult<Product>(
      items: [],
      totalCount: 0,
      page: 1,
      pageSize: 20,
    );
  }
  try {
    final repo = ref.watch(catalogRepositoryProvider);
    return repo.getAdminProducts(
      search: query.search,
      categoryId: query.categoryId,
      page: query.page,
      pageSize: 20,
    );
  } catch (_) {
    return const PaginatedResult<Product>(
      items: [],
      totalCount: 0,
      page: 1,
      pageSize: 20,
    );
  }
});

/// Provider chi tiết sản phẩm Admin theo ID
final adminProductDetailProvider =
    FutureProvider.autoDispose.family<Product?, String>((ref, id) async {
  if (!AppConfig.isSupabaseConfigured) return null;
  try {
    final repo = ref.watch(catalogRepositoryProvider);
    return repo.getAdminProductById(id);
  } catch (_) {
    return null;
  }
});
