// Admin Catalog Screen
// Provides a tabbed interface for managing categories and products.
// Tab 0: Category list with toggle active / edit / add actions.
// Tab 1: Product list with search / filter / toggle active / edit / add actions.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  void dispose() {
    _tabController.dispose();
    _productSearchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản trị Catalog'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Danh mục'),
            Tab(text: 'Sản phẩm'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _CategoryTab(key: const ValueKey('cat_tab')),
          _ProductTab(key: const ValueKey('prod_tab')),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) {
          return FloatingActionButton.extended(
            onPressed: () {
              if (_tabController.index == 0) {
                // Navigate to create category
                context.pushNamed(RouteNames.adminCategoryCreate);
              } else {
                // Navigate to create product
                context.pushNamed(RouteNames.adminProductCreate);
              }
            },
            icon: const Icon(Icons.add),
            label: Text(
              _tabController.index == 0 ? 'Thêm danh mục' : 'Thêm sản phẩm',
            ),
          );
        },
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
          ],
        ),
      ),
    );
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
