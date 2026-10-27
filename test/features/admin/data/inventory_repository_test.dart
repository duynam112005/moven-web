import 'package:flutter_test/flutter_test.dart';
import 'package:moven/features/admin/data/inventory_repository.dart';

void main() {
  group('InventoryRepository Tests (Mock Mode / In-memory fallback)', () {
    late InventoryRepository repo;

    setUp(() {
      repo = InventoryRepository();
    });

    test('1. getInventoryVariants trả về danh sách biến thể tồn kho hợp lệ', () async {
      final variants = await repo.getInventoryVariants();

      expect(variants, isNotEmpty);
      expect(variants.any((v) => v.productName.contains('Áo Thun')), isTrue);
      expect(variants.any((v) => v.stockQuantity == 0), isTrue); // có mặt hàng hết hàng
    });

    test('2. Lọc tồn kho: lọc theo tìm kiếm từ khóa', () async {
      final results = await repo.getInventoryVariants(searchQuery: 'Polo');

      expect(results, isNotEmpty);
      for (final item in results) {
        expect(
          item.productName.toLowerCase().contains('polo') ||
              item.sku.toLowerCase().contains('polo'),
          isTrue,
        );
      }
    });

    test('3. Lọc tồn kho: trạng thái sắp hết hàng (low_stock) và hết hàng (out_of_stock)', () async {
      final lowStock = await repo.getInventoryVariants(statusFilter: 'low_stock', lowStockThreshold: 5);
      expect(lowStock, isNotEmpty);
      for (final item in lowStock) {
        expect(item.stockQuantity, inInclusiveRange(1, 5));
      }

      final outOfStock = await repo.getInventoryVariants(statusFilter: 'out_of_stock');
      expect(outOfStock, isNotEmpty);
      for (final item in outOfStock) {
        expect(item.stockQuantity, 0);
      }
    });

    test('4. getSummaryMetrics tính toán đúng chỉ số KPI tổng quan', () async {
      final metrics = await repo.getSummaryMetrics(lowStockThreshold: 5);

      expect(metrics.totalVariants, greaterThan(0));
      expect(metrics.lowStockCount, greaterThan(0));
      expect(metrics.outOfStockCount, greaterThan(0));
      expect(metrics.inStockCount, equals(metrics.totalVariants - metrics.lowStockCount - metrics.outOfStockCount));
    });

    test('5. getInventoryMovements trả về danh sách lịch sử biến động kho', () async {
      final movements = await repo.getInventoryMovements();

      expect(movements, isNotEmpty);
      expect(movements.first.reason, isNotEmpty);
    });

    test('6. adjustStock cập nhật số lượng tồn kho và ghi nhận lịch sử biến động (audit trail)', () async {
      final variantsBefore = await repo.getInventoryVariants();
      final target = variantsBefore.first;
      final newQuantity = target.stockQuantity + 15;

      await repo.adjustStock(
        variantId: target.id,
        newStock: newQuantity,
        reasonNote: 'Nhập bổ sung kiểm kê quý',
      );

      final variantsAfter = await repo.getInventoryVariants();
      final updated = variantsAfter.firstWhere((v) => v.id == target.id);
      expect(updated.stockQuantity, newQuantity);

      final movements = await repo.getInventoryMovements();
      expect(movements.first.variantId, target.id);
      expect(movements.first.quantityDelta, 15);
      expect(movements.first.reason, 'adjustment');
      expect(movements.first.note, 'Nhập bổ sung kiểm kê quý');
    });
  });
}
