import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../data/inventory_repository.dart';
import '../../domain/models/inventory_item.dart';

/// Provider cung cấp InventoryRepository
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  try {
    final client = ref.watch(supabaseClientProvider);
    return InventoryRepository(client);
  } catch (_) {
    return InventoryRepository();
  }
});

/// Từ khóa tìm kiếm SKU hoặc tên sản phẩm
final inventorySearchQueryProvider = StateProvider<String>((ref) => '');

/// Bộ lọc trạng thái: 'all' | 'low_stock' | 'out_of_stock'
final inventoryStatusFilterProvider = StateProvider<String>((ref) => 'all');

/// Provider tải danh sách biến thể tồn kho
final inventoryVariantsProvider = FutureProvider<List<InventoryVariantItem>>((ref) async {
  final repo = ref.watch(inventoryRepositoryProvider);
  final search = ref.watch(inventorySearchQueryProvider);
  final status = ref.watch(inventoryStatusFilterProvider);
  final settingsAsync = ref.watch(storeSettingsProvider);
  final threshold = settingsAsync.value?.lowStockThreshold ?? 5;

  return repo.getInventoryVariants(
    searchQuery: search,
    statusFilter: status,
    lowStockThreshold: threshold,
  );
});

/// Provider tải lịch sử biến động kho (Audit trail)
final inventoryMovementsProvider = FutureProvider<List<InventoryMovementItem>>((ref) async {
  final repo = ref.watch(inventoryRepositoryProvider);
  return repo.getInventoryMovements();
});

/// Provider tính toán số liệu thống kê kho
final inventorySummaryMetricsProvider = Provider<InventorySummaryMetrics>((ref) {
  final variantsAsync = ref.watch(inventoryVariantsProvider);
  final settingsAsync = ref.watch(storeSettingsProvider);
  final threshold = settingsAsync.value?.lowStockThreshold ?? 5;

  final variants = variantsAsync.value ?? [];
  var low = 0;
  var outOfStock = 0;

  for (final v in variants) {
    if (v.isOutOfStock) {
      outOfStock++;
    } else if (v.isLowStock(threshold)) {
      low++;
    }
  }

  return InventorySummaryMetrics(
    totalVariants: variants.length,
    lowStockCount: low,
    outOfStockCount: outOfStock,
  );
});
