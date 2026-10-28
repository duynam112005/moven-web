// Admin Catalog Screen
// Provides a tabbed interface for managing categories and products.
// Tab 0: Category list with toggle active / edit / add actions.
// Tab 1: Product list with search / filter / toggle active / edit / add actions.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/router/route_names.dart';
import '../../../../features/catalog/data/catalog_providers.dart';
import '../../../../features/catalog/data/catalog_repository.dart';
import '../../../../features/catalog/domain/models/category.dart';
import '../../../../features/catalog/domain/models/product.dart';

class AdminCatalogScreen extends ConsumerStatefulWidget {
  const AdminCatalogScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminCatalogScreen> createState() => _AdminCatalogScreenState();
}

class _AdminCatalogScreenState extends ConsumerState<AdminCatalogScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _productSearchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      final tab = GoRouterState.of(context).uri.queryParameters['tab'];
      if (tab == 'products' || tab == '1') {
        if (_tabController.index != 1) {
          _tabController.animateTo(1);
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _tabController.dispose();
    _productSearchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quản trị Catalog',
                        style: AppTypography.headlineMedium,
                      ),
                      const SizedBox(height: AppDimensions.space4),
                      Text(
                        'Quản lý danh mục phân loại, thêm mới và cập nhật sản phẩm cùng các biến thể',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.space16),
                Row(
                  children: [
                    AppButton(
                      label: 'Thêm danh mục',
                      icon: const Icon(Icons.create_new_folder_outlined, size: 18),
                      variant: AppButtonVariant.outlined,
                      onPressed: () => context.pushNamed(RouteNames.adminCategoryCreate),
                    ),
                    const SizedBox(width: AppDimensions.space12),
                    AppButton(
                      label: 'Thêm sản phẩm',
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: () => context.pushNamed(RouteNames.adminProductCreate),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.space20),

            // 2. Tab Bar
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radius8),
                border: Border.all(color: AppColors.border),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelStyle: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.category_outlined, size: 20),
                    text: 'Danh mục',
                  ),
                  Tab(
                    icon: Icon(Icons.checkroom_outlined, size: 20),
                    text: 'Sản phẩm',
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.space16),

            // 3. Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _CategoryTab(key: const ValueKey('cat_tab')),
                  _ProductTab(key: const ValueKey('prod_tab')),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            context.pushNamed(RouteNames.adminCategoryCreate);
          } else {
            context.pushNamed(RouteNames.adminProductCreate);
          }
        },
        icon: const Icon(Icons.add),
        label: Text(_tabController.index == 0 ? 'Thêm danh mục' : 'Thêm sản phẩm'),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CATEGORY TAB
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryTab extends ConsumerWidget {
  const _CategoryTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(adminCategoriesProvider);

    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text('Không thể tải danh mục: $e'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(adminCategoriesProvider),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
      data: (categories) {
        if (categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.category_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 12),
                const Text('Chưa có danh mục nào'),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.refresh(adminCategoriesProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) =>
                _CategoryCard(category: categories[i]),
          ),
        );
      },
    );
  }
}

class _CategoryCard extends ConsumerWidget {
  final Category category;
  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: category.isActive
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.grey.shade200,
          child: Icon(
            Icons.category_outlined,
            color: category.isActive
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
          ),
        ),
        title: Text(
          category.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: category.isActive ? null : Colors.grey,
          ),
        ),
        subtitle: Text(
          'Slug: ${category.slug}  •  Thứ tự: ${category.sortOrder}'
          '${category.isActive ? '' : '  •  Đã ẩn'}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Toggle active
            Switch(
              value: category.isActive,
              onChanged: (val) async {
                try {
                  await ref
                      .read(catalogRepositoryProvider)
                      .toggleCategoryActive(category.id, val);
                  ref.invalidate(adminCategoriesProvider);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: $e')),
                    );
                  }
                }
              },
            ),
            // Edit button
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Chỉnh sửa',
              onPressed: () {
                context.pushNamed(
                  RouteNames.adminCategoryEdit,
                  pathParameters: {'id': category.id},
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PRODUCT TAB
// ─────────────────────────────────────────────────────────────────────────────

class _ProductTab extends ConsumerStatefulWidget {
  const _ProductTab({Key? key}) : super(key: key);

  @override
  ConsumerState<_ProductTab> createState() => _ProductTabState();
}

class _ProductTabState extends ConsumerState<_ProductTab> {
  final _searchCtrl = TextEditingController();
  String? _categoryId;
  int _page = 1;

  AdminProductQuery get _query =>
      AdminProductQuery(search: _searchCtrl.text.trim(), categoryId: _categoryId, page: _page);

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(adminCategoriesProvider);
    final productsAsync = ref.watch(adminProductsProvider(_query));

    return Column(
      children: [
        // ── Search & filter bar ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Tìm sản phẩm…',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _page = 1);
                            },
                          )
                        : null,
                  ),
                  onSubmitted: (_) => setState(() => _page = 1),
                ),
              ),
              const SizedBox(width: 8),
              categoriesAsync.maybeWhen(
                data: (cats) => DropdownButton<String?>(
                  value: _categoryId,
                  hint: const Text('Tất cả danh mục'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Tất cả')),
                    ...cats.map(
                      (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                    ),
                  ],
                  onChanged: (v) => setState(() {
                    _categoryId = v;
                    _page = 1;
                  }),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // ── Product list ─────────────────────────────────────────────────
        Expanded(
          child: productsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 8),
                  Text('Không thể tải sản phẩm: $e'),
                  ElevatedButton(
                    onPressed: () => ref.refresh(adminProductsProvider(_query)),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
            data: (result) {
              if (result.items.isEmpty) {
                return const Center(
                  child: Text('Không tìm thấy sản phẩm nào'),
                );
              }
              return RefreshIndicator(
                onRefresh: () async => ref.refresh(adminProductsProvider(_query)),
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: result.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _ProductCard(product: result.items[i]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProductCard extends ConsumerWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = AdminProductQuery();
    final priceText = product.minPrice == null
        ? 'Chưa có biến thể'
        : product.minPrice == product.maxPrice
            ? '${_fmt(product.minPrice!)}₫'
            : '${_fmt(product.minPrice!)}₫ – ${_fmt(product.maxPrice!)}₫';

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: product.isActive
              ? Theme.of(context).colorScheme.secondaryContainer
              : Colors.grey.shade200,
          child: Icon(
            product.isFeatured ? Icons.star : Icons.checkroom_outlined,
            color: product.isActive
                ? Theme.of(context).colorScheme.secondary
                : Colors.grey,
          ),
        ),
        title: Text(
          product.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: product.isActive ? null : Colors.grey,
          ),
        ),
        subtitle: Text(
          '$priceText  •  ${product.variants.length} biến thể'
          '${product.isActive ? '' : '  •  Đã ẩn'}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: product.isActive,
              onChanged: (val) async {
                try {
                  await ref
                      .read(catalogRepositoryProvider)
                      .toggleProductActive(product.id, val);
                  ref.invalidate(adminProductsProvider(query));
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: $e')),
                    );
                  }
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Chỉnh sửa',
              onPressed: () {
                context.pushNamed(
                  RouteNames.adminProductEdit,
                  pathParameters: {'id': product.id},
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Xóa',
              onPressed: () => _confirmDelete(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa sản phẩm'),
        content: Text('Bạn có chắc chắn muốn xóa sản phẩm "${product.name}" không? Thao tác này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(catalogRepositoryProvider).deleteProduct(product.id);
      ref.invalidate(adminProductsProvider);
      ref.invalidate(catalogProductsProvider);
      ref.invalidate(featuredProductsProvider);
      ref.invalidate(activeCategoriesProvider);
      ref.invalidate(productDetailProvider(product.slug));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa sản phẩm thành công')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  String _fmt(int price) {
    // Simple VND formatter: insert dots every 3 digits
    final s = price.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
