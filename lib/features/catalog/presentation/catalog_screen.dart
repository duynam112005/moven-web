import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_state_view.dart';
import '../data/catalog_providers.dart';
import '../domain/models/catalog_filter.dart';
import 'widgets/product_card.dart';

/// Màn hình danh mục sản phẩm (Storefront Catalog Screen)
class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final filter = ref.read(catalogFilterProvider);
    final lastTimestamp = ref.read(catalogSearchTimestampProvider);
    final isExpired =
        filter.searchKeyword != null && isCatalogSearchExpired(lastTimestamp);

    final initialKeyword = isExpired ? '' : (filter.searchKeyword ?? '');
    _searchController = TextEditingController(text: initialKeyword);
    _searchController.addListener(_onSearchControllerChanged);

    if (isExpired) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(catalogFilterProvider.notifier).state =
              ref.read(catalogFilterProvider).copyWith(searchKeyword: null);
          ref.read(catalogSearchTimestampProvider.notifier).state = null;
          ref.read(catalogPageProvider.notifier).state = 1;
        }
      });
    }
  }

  void _onSearchControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchControllerChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String value) {
    final trimmed = value.trim();
    final current = ref.read(catalogFilterProvider);
    final newKeyword = trimmed.isEmpty ? null : trimmed;
    if (current.searchKeyword != newKeyword) {
      ref.read(catalogFilterProvider.notifier).state = current.copyWith(
        searchKeyword: newKeyword,
      );
      ref.read(catalogSearchTimestampProvider.notifier).state =
          newKeyword != null ? DateTime.now() : null;
      ref.read(catalogPageProvider.notifier).state = 1;
    }
  }

  void _onSearchChanged(String value) {
    final trimmed = value.trim();
    final current = ref.read(catalogFilterProvider);
    // Khi xóa hết ký tự trên thanh tìm kiếm, lập tức hoàn nguyên danh sách sản phẩm ban đầu
    if (trimmed.isEmpty && current.searchKeyword != null) {
      ref.read(catalogFilterProvider.notifier).state = current.copyWith(
        searchKeyword: null,
      );
      ref.read(catalogSearchTimestampProvider.notifier).state = null;
      ref.read(catalogPageProvider.notifier).state = 1;
    }
  }

  void _onClearSearch() {
    _searchController.clear();
    final current = ref.read(catalogFilterProvider);
    if (current.searchKeyword != null) {
      ref.read(catalogFilterProvider.notifier).state = current.copyWith(
        searchKeyword: null,
      );
      ref.read(catalogSearchTimestampProvider.notifier).state = null;
      ref.read(catalogPageProvider.notifier).state = 1;
    }
  }

  void _onCategorySelected(String? categoryId) {
    final current = ref.read(catalogFilterProvider);
    ref.read(catalogFilterProvider.notifier).state = current.copyWith(
      categoryId: categoryId,
      categorySlug: null,
    );
    ref.read(catalogPageProvider.notifier).state = 1;
  }

  void _onAudienceSelected(String? audience) {
    final current = ref.read(catalogFilterProvider);
    ref.read(catalogFilterProvider.notifier).state = current.copyWith(
      targetAudience: audience,
    );
    ref.read(catalogPageProvider.notifier).state = 1;
  }

  void _onSortChanged(String? sortBy) {
    if (sortBy == null) return;
    final current = ref.read(catalogFilterProvider);
    ref.read(catalogFilterProvider.notifier).state = current.copyWith(
      sortBy: sortBy,
    );
    ref.read(catalogPageProvider.notifier).state = 1;
  }

  void _onInStockToggled(bool? value) {
    final current = ref.read(catalogFilterProvider);
    ref.read(catalogFilterProvider.notifier).state = current.copyWith(
      inStockOnly: value ?? false,
    );
    ref.read(catalogPageProvider.notifier).state = 1;
  }

  void _resetAllFilters() {
    _searchController.clear();
    ref.read(catalogSearchTimestampProvider.notifier).state = null;
    ref.read(catalogFilterProvider.notifier).state = const CatalogFilter();
    ref.read(catalogPageProvider.notifier).state = 1;
  }

  @override
  Widget build(BuildContext context) {
    // Đồng bộ ngược lại controller nếu searchKeyword bị thay đổi từ bên ngoài (reset filter, timeout, logout)
    ref.listen<CatalogFilter>(catalogFilterProvider, (previous, next) {
      final nextKeyword = next.searchKeyword ?? '';
      if (_searchController.text != nextKeyword) {
        _searchController.text = nextKeyword;
        _searchController.selection = TextSelection.fromPosition(
          TextPosition(offset: nextKeyword.length),
        );
      }
    });

    final filter = ref.watch(catalogFilterProvider);
    final currentPage = ref.watch(catalogPageProvider);
    final categoriesAsync = ref.watch(activeCategoriesProvider);
    final productsAsync = ref.watch(catalogProductsProvider);

    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;

    int crossAxisCount = 4;
    if (!isDesktop) {
      crossAxisCount = isTablet ? 3 : 2;
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppDimensions.maxContentWidth,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space20,
            vertical: AppDimensions.space24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thanh tiêu đề và tìm kiếm
              _buildHeaderSection(context),

              const SizedBox(height: AppDimensions.space20),

              // Bộ lọc danh mục và đối tượng
              _buildFilterChips(categoriesAsync, filter),

              const SizedBox(height: AppDimensions.space16),

              // Thanh công cụ sắp xếp và đếm số lượng
              _buildToolbar(productsAsync, filter),

              const SizedBox(height: AppDimensions.space20),

              // Danh sách sản phẩm (Grid)
              productsAsync.when(
                loading: () => const SizedBox(
                  height: 350,
                  child: AppLoading(message: 'Đang tải danh sách sản phẩm...'),
                ),
                error: (error, stack) => SizedBox(
                  height: 350,
                  child: ErrorStateView(
                    title: 'Không thể tải sản phẩm',
                    message: error.toString(),
                    onRetry: () => ref.refresh(catalogProductsProvider),
                  ),
                ),
                data: (paginated) {
                  final products = paginated.items;
                  if (products.isEmpty) {
                    return SizedBox(
                      height: 350,
                      child: EmptyStateView(
                        icon: Icons.search_off_outlined,
                        title: 'Không tìm thấy sản phẩm nào',
                        description: filter.hasActiveFilters
                            ? 'Hãy thử điều chỉnh lại bộ lọc hoặc từ khóa tìm kiếm.'
                            : 'Cửa hàng hiện chưa có sản phẩm nào đang mở bán.',
                        actionLabel:
                            filter.hasActiveFilters ? 'Xóa bộ lọc' : null,
                        onAction:
                            filter.hasActiveFilters ? _resetAllFilters : null,
                      ),
                    );
                  }

                  return Column(
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: AppDimensions.space16,
                          mainAxisSpacing: AppDimensions.space20,
                          childAspectRatio: isDesktop ? 0.60 : 0.58,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          return ProductCard(product: products[index]);
                        },
                      ),

                      const SizedBox(height: AppDimensions.space32),

                      // Điều khiển phân trang
                      _buildPaginationBar(paginated, currentPage),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;

        final searchBar = SizedBox(
          width: isNarrow ? double.infinity : 320,
          height: AppDimensions.inputHeight,
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: _onSearchSubmitted,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm trang phục...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: _onClearSearch,
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radius8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              filled: true,
              fillColor: AppColors.surface,
            ),
          ),
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tất cả sản phẩm', style: AppTypography.headlineLarge),
              const SizedBox(height: AppDimensions.space12),
              searchBar,
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tất cả sản phẩm', style: AppTypography.headlineLarge),
                SizedBox(height: AppDimensions.space4),
                Text(
                  'Thời trang tối giản và hiện đại cho tủ đồ của bạn',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
            searchBar,
          ],
        );
      },
    );
  }

  Widget _buildFilterChips(
    AsyncValue<List<dynamic>> categoriesAsync,
    CatalogFilter filter,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Lọc đối tượng
          _buildChoiceChip(
            label: 'Tất cả',
            isSelected: filter.targetAudience == null &&
                filter.categoryId == null &&
                filter.categorySlug == null,
            onSelected: () {
              _onAudienceSelected(null);
              _onCategorySelected(null);
            },
          ),
          _buildChoiceChip(
            label: 'Nam',
            isSelected: filter.targetAudience == 'men',
            onSelected: () => _onAudienceSelected(
                filter.targetAudience == 'men' ? null : 'men'),
          ),
          _buildChoiceChip(
            label: 'Nữ',
            isSelected: filter.targetAudience == 'women',
            onSelected: () => _onAudienceSelected(
                filter.targetAudience == 'women' ? null : 'women'),
          ),
          _buildChoiceChip(
            label: 'Unisex',
            isSelected: filter.targetAudience == 'unisex',
            onSelected: () => _onAudienceSelected(
                filter.targetAudience == 'unisex' ? null : 'unisex'),
          ),

          const SizedBox(
            height: 24,
            child: VerticalDivider(
              color: AppColors.border,
              thickness: 1,
              width: 24,
            ),
          ),

          // Lọc theo danh mục nạp từ Supabase
          categoriesAsync.when(
            data: (categories) => Row(
              children: categories.map((cat) {
                final isSelected = filter.categoryId == cat.id ||
                    (filter.categorySlug != null &&
                        filter.categorySlug == cat.slug);
                return _buildChoiceChip(
                  label: cat.name,
                  isSelected: isSelected,
                  onSelected: () =>
                      _onCategorySelected(isSelected ? null : cat.id),
                );
              }).toList(),
            ),
            loading: () => const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (error, stack) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: AppDimensions.space8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surface,
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? AppColors.onPrimary : AppColors.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius8),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
      ),
    );
  }

  Widget _buildToolbar(
    AsyncValue<dynamic> productsAsync,
    CatalogFilter filter,
  ) {
    final totalCount = productsAsync.valueOrNull?.totalCount ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space16,
        vertical: AppDimensions.space8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius8),
        border: Border.all(color: AppColors.border),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppDimensions.space16,
        runSpacing: AppDimensions.space8,
        children: [
          // Số lượng sản phẩm
          Text(
            '$totalCount sản phẩm',
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Checkbox chỉ còn hàng
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: filter.inStockOnly,
                    onChanged: _onInStockToggled,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const Text('Còn hàng', style: AppTypography.bodySmall),
                ],
              ),

              const SizedBox(width: AppDimensions.space16),

              // Dropdown sắp xếp
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: filter.sortBy,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'newest',
                      child: Text('Mới nhất'),
                    ),
                    DropdownMenuItem(
                      value: 'price_asc',
                      child: Text('Giá: Thấp đến Cao'),
                    ),
                    DropdownMenuItem(
                      value: 'price_desc',
                      child: Text('Giá: Cao đến Thấp'),
                    ),
                    DropdownMenuItem(
                      value: 'name_asc',
                      child: Text('Tên: A - Z'),
                    ),
                  ],
                  onChanged: _onSortChanged,
                ),
              ),

              if (filter.hasActiveFilters) ...[
                const SizedBox(width: AppDimensions.space8),
                TextButton(
                  onPressed: _resetAllFilters,
                  child: const Text('Xóa bộ lọc'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationBar(dynamic paginated, int currentPage) {
    final totalPages = paginated.totalPages;
    if (totalPages <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton.icon(
          onPressed: paginated.hasPrevious
              ? () => ref.read(catalogPageProvider.notifier).state--
              : null,
          icon: const Icon(Icons.chevron_left, size: 18),
          label: const Text('Trước'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space16,
          ),
          child: Text(
            'Trang $currentPage / $totalPages',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: paginated.hasMore
              ? () => ref.read(catalogPageProvider.notifier).state++
              : null,
          icon: const Icon(Icons.chevron_right, size: 18),
          label: const Text('Sau'),
        ),
      ],
    );
  }
}
