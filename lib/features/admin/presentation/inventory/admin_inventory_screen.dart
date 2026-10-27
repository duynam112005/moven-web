import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../providers/inventory_providers.dart';
import '../../domain/models/inventory_item.dart';

/// Màn hình Quản lý Tồn kho & Biến động cho Admin (/admin/inventory)
class AdminInventoryScreen extends ConsumerStatefulWidget {
  const AdminInventoryScreen({super.key});

  @override
  ConsumerState<AdminInventoryScreen> createState() => _AdminInventoryScreenState();
}

class _AdminInventoryScreenState extends ConsumerState<AdminInventoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metrics = ref.watch(inventorySummaryMetricsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header
          _buildHeader(context),

          const SizedBox(height: AppDimensions.space20),

          // 2. KPI Cards
          _buildKpiCards(metrics),

          const SizedBox(height: AppDimensions.space24),

          // 3. Tab Bar
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
                  icon: Icon(Icons.inventory_2_outlined, size: 20),
                  text: 'Danh sách tồn kho biến thể',
                ),
                Tab(
                  icon: Icon(Icons.history_outlined, size: 20),
                  text: 'Lịch sử biến động kho (Audit Trail)',
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.space16),

          // 4. Tab Views
          SizedBox(
            height: 750,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVariantsTab(context),
                _buildMovementsTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quản lý Tồn kho & Biến động',
                style: AppTypography.headlineMedium,
              ),
              const SizedBox(height: AppDimensions.space4),
              Text(
                'Theo dõi chi tiết số lượng tồn kho từng biến thể và kiểm toán lịch sử xuất/nhập/điều chỉnh',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppDimensions.space16),
        AppButton(
          label: 'Làm mới',
          icon: const Icon(Icons.refresh, size: 18),
          variant: AppButtonVariant.outlined,
          height: 38,
          onPressed: () {
            ref.invalidate(inventoryVariantsProvider);
            ref.invalidate(inventoryMovementsProvider);
          },
        ),
      ],
    );
  }

  Widget _buildKpiCards(InventorySummaryMetrics metrics) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            title: 'Tổng biến thể',
            value: '${metrics.totalVariants}',
            icon: Icons.layers_outlined,
            color: AppColors.primary,
            bgColor: AppColors.primary.withValues(alpha: 0.08),
          ),
        ),
        const SizedBox(width: AppDimensions.space16),
        Expanded(
          child: _buildMetricCard(
            title: 'Sắp hết hàng (<= 5)',
            value: '${metrics.lowStockCount}',
            icon: Icons.warning_amber_rounded,
            color: const Color(0xFFD97706),
            bgColor: const Color(0xFFFEF3C7),
          ),
        ),
        const SizedBox(width: AppDimensions.space16),
        Expanded(
          child: _buildMetricCard(
            title: 'Đã hết hàng (0)',
            value: '${metrics.outOfStockCount}',
            icon: Icons.cancel_outlined,
            color: AppColors.error,
            bgColor: AppColors.error.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppDimensions.space8),
              Text(
                value,
                style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(AppDimensions.space12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppDimensions.radius8),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: DANH SÁCH TỒN KHO BIẾN THỂ
  // ==========================================
  Widget _buildVariantsTab(BuildContext context) {
    final variantsAsync = ref.watch(inventoryVariantsProvider);
    final currentStatus = ref.watch(inventoryStatusFilterProvider);
    final settingsAsync = ref.watch(storeSettingsProvider);
    final threshold = settingsAsync.value?.lowStockThreshold ?? 5;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Toolbar: Search & Filter Chips
          Padding(
            padding: const EdgeInsets.all(AppDimensions.space16),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm theo SKU, tên sản phẩm, size, màu...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                ref.read(inventorySearchQueryProvider.notifier).state = '';
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.space12,
                        vertical: AppDimensions.space8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radius8),
                      ),
                    ),
                    onChanged: (val) {
                      ref.read(inventorySearchQueryProvider.notifier).state = val;
                    },
                  ),
                ),
                const SizedBox(width: AppDimensions.space16),
                _buildFilterChip('all', 'Tất cả', currentStatus),
                const SizedBox(width: AppDimensions.space8),
                _buildFilterChip('low_stock', 'Sắp hết hàng', currentStatus, isWarning: true),
                const SizedBox(width: AppDimensions.space8),
                _buildFilterChip('out_of_stock', 'Hết hàng', currentStatus, isError: true),
              ],
            ),
          ),
          const Divider(height: 1),

          // Variants Table
          Expanded(
            child: variantsAsync.when(
              loading: () => const Center(child: AppLoading(message: 'Đang tải tồn kho...')),
              error: (err, _) => Center(
                child: ErrorStateView(
                  message: 'Không thể tải danh sách tồn kho: $err',
                  onRetry: () => ref.refresh(inventoryVariantsProvider),
                ),
              ),
              data: (variants) {
                if (variants.isEmpty) {
                  return const EmptyStateView(
                    icon: Icons.inventory_2_outlined,
                    title: 'Không tìm thấy biến thể nào',
                    description: 'Thử thay đổi từ khóa tìm kiếm hoặc bộ lọc trạng thái.',
                  );
                }

                return ListView.separated(
                  itemCount: variants.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = variants[index];
                    return _buildVariantRow(context, item, threshold);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String key,
    String label,
    String current, {
    bool isWarning = false,
    bool isError = false,
  }) {
    final isSelected = current == key;
    Color chipColor = AppColors.primary;
    if (isWarning) chipColor = const Color(0xFFD97706);
    if (isError) chipColor = AppColors.error;

    return FilterChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      selectedColor: chipColor,
      backgroundColor: AppColors.background,
      onSelected: (_) {
        ref.read(inventoryStatusFilterProvider.notifier).state = key;
      },
    );
  }

  Widget _buildVariantRow(BuildContext context, InventoryVariantItem item, int threshold) {
    Widget statusBadge;
    if (item.isOutOfStock) {
      statusBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'HẾT HÀNG',
          style: TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      );
    } else if (item.isLowStock(threshold)) {
      statusBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'SẮP HẾT HÀNG',
          style: TextStyle(color: Color(0xFFD97706), fontSize: 11, fontWeight: FontWeight.bold),
        ),
      );
    } else {
      statusBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'CÒN HÀNG',
          style: TextStyle(color: Color(0xFF16A34A), fontSize: 11, fontWeight: FontWeight.bold),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Tên sản phẩm & SKU
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'SKU: ${item.sku}',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),

          // Phân loại (Size / Màu)
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                item.variantLabel,
                style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          ),

          // Giá niêm yết
          Expanded(
            flex: 2,
            child: Text(
              CurrencyFormatter.format(item.price),
              style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
          ),

          // Số lượng tồn kho
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Text(
                  '${item.stockQuantity}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: item.isOutOfStock
                        ? AppColors.error
                        : (item.isLowStock(threshold) ? const Color(0xFFD97706) : AppColors.textPrimary),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('cái', style: AppTypography.bodySmall),
              ],
            ),
          ),

          // Trạng thái
          Expanded(
            flex: 2,
            child: statusBadge,
          ),

          // Thao tác điều chỉnh
          OutlinedButton.icon(
            onPressed: () => _showAdjustStockDialog(context, item),
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: const Text('Điều chỉnh', style: TextStyle(fontSize: 13)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.border),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: LỊCH SỬ BIẾN ĐỘNG KHO (AUDIT TRAIL)
  // ==========================================
  Widget _buildMovementsTab(BuildContext context) {
    final movementsAsync = ref.watch(inventoryMovementsProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
        border: Border.all(color: AppColors.border),
      ),
      child: movementsAsync.when(
        loading: () => const Center(child: AppLoading(message: 'Đang tải lịch sử kho...')),
        error: (err, _) => Center(
          child: ErrorStateView(
            message: 'Không thể tải lịch sử kho: $err',
            onRetry: () => ref.refresh(inventoryMovementsProvider),
          ),
        ),
        data: (movements) {
          if (movements.isEmpty) {
            return const EmptyStateView(
              icon: Icons.history_outlined,
              title: 'Chưa có biến động kho nào',
              description: 'Mọi hoạt động bán hàng, hoàn hàng hay điều chỉnh sẽ được ghi nhận tại đây.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppDimensions.space16),
            itemCount: movements.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final mov = movements[index];
              final isPositive = mov.quantityDelta > 0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    // Icon lý do
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isPositive
                            ? const Color(0xFFDCFCE7)
                            : AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isPositive ? Icons.add_circle_outline : Icons.remove_circle_outline,
                        color: isPositive ? const Color(0xFF16A34A) : AppColors.error,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space16),

                    // Sản phẩm & SKU
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mov.productName,
                            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'SKU: ${mov.variantSku}',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),

                    // Biến động số lượng
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${isPositive ? "+" : ""}${mov.quantityDelta} cái',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isPositive ? const Color(0xFF16A34A) : AppColors.error,
                        ),
                      ),
                    ),

                    // Lý do biến động
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mov.reasonLabel,
                            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                          ),
                          if (mov.note != null && mov.note!.isNotEmpty)
                            Text(
                              mov.note!,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Mã đơn hàng liên quan (nếu có)
                    Expanded(
                      flex: 2,
                      child: Text(
                        mov.orderCode != null ? '#${mov.orderCode}' : '-',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ),

                    // Thời gian UTC+7
                    Text(
                      DateTimeUtils.formatDateTime(mov.createdAt),
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ==========================================
  // MODAL ĐIỀU CHỈNH TỒN KHO THỦ CÔNG
  // ==========================================
  void _showAdjustStockDialog(BuildContext context, InventoryVariantItem item) {
    final qtyController = TextEditingController(text: '${item.stockQuantity}');
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.edit_note, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Điều chỉnh tồn kho'),
                ],
              ),
              content: SizedBox(
                width: 440,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'SKU: ${item.sku} • Phân loại: ${item.variantLabel}',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: qtyController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          labelText: 'Số lượng tồn kho mới',
                          border: OutlineInputBorder(),
                          suffixText: 'cái',
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Vui lòng nhập số lượng tồn kho mới';
                          }
                          final parsed = int.tryParse(val.trim());
                          if (parsed == null || parsed < 0) {
                            return 'Số lượng phải lớn hơn hoặc bằng 0';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: reasonController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Lý do điều chỉnh (Bắt buộc)',
                          hintText: 'Vd: Kiểm kê định kỳ, bù hao hụt, nhập thêm hàng...',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Vui lòng nêu rõ lý do điều chỉnh tồn kho';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(ctx),
                  child: const Text('Hủy'),
                ),
                AppButton(
                  label: 'Xác nhận lưu',
                  isLoading: isSaving,
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    setDialogState(() => isSaving = true);

                    try {
                      final newQty = int.parse(qtyController.text.trim());
                      final reason = reasonController.text.trim();

                      await ref.read(inventoryRepositoryProvider).adjustStock(
                            variantId: item.id,
                            newStock: newQty,
                            reasonNote: reason,
                          );

                      ref.invalidate(inventoryVariantsProvider);
                      ref.invalidate(inventoryMovementsProvider);

                      if (context.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Đã cập nhật tồn kho biến thể ${item.sku} thành $newQty cái.',
                            ),
                            backgroundColor: const Color(0xFF16A34A),
                          ),
                        );
                      }
                    } catch (e) {
                      setDialogState(() => isSaving = false);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Lỗi: $e'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
