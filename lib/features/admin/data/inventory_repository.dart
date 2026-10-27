import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/app_exception.dart';
import '../domain/models/inventory_item.dart';

/// Repository quản lý tồn kho và nhật ký biến động kho cho Admin
class InventoryRepository {
  final SupabaseClient? _client;

  InventoryRepository([this._client]);

  bool get _isSupabaseConfigured => _client != null;

  // Mock data in-memory cho chế độ xem trước hoặc khi Supabase chưa có dữ liệu
  static final List<InventoryVariantItem> _mockVariants = [
    InventoryVariantItem(
      id: '30000000-0000-0000-0000-000000000001',
      productId: '20000000-0000-0000-0000-000000000001',
      productName: 'Áo Thun Nam Cotton Compact MOVEN',
      sku: 'MVN-TSH-BLK-M',
      size: 'M',
      colorName: 'Đen',
      price: 199000,
      stockQuantity: 30,
      isActive: true,
      updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    InventoryVariantItem(
      id: '30000000-0000-0000-0000-000000000002',
      productId: '20000000-0000-0000-0000-000000000001',
      productName: 'Áo Thun Nam Cotton Compact MOVEN',
      sku: 'MVN-TSH-BLK-L',
      size: 'L',
      colorName: 'Đen',
      price: 199000,
      stockQuantity: 25,
      isActive: true,
      updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    InventoryVariantItem(
      id: '30000000-0000-0000-0000-000000000003',
      productId: '20000000-0000-0000-0000-000000000001',
      productName: 'Áo Thun Nam Cotton Compact MOVEN',
      sku: 'MVN-TSH-WHT-M',
      size: 'M',
      colorName: 'Trắng',
      price: 199000,
      stockQuantity: 3, // Low stock
      isActive: true,
      updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    InventoryVariantItem(
      id: '30000000-0000-0000-0000-000000000004',
      productId: '20000000-0000-0000-0000-000000000001',
      productName: 'Áo Thun Nam Cotton Compact MOVEN',
      sku: 'MVN-TSH-WHT-L',
      size: 'L',
      colorName: 'Trắng',
      price: 199000,
      stockQuantity: 0, // Out of stock
      isActive: true,
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    InventoryVariantItem(
      id: '30000000-0000-0000-0000-000000000005',
      productId: '20000000-0000-0000-0000-000000000002',
      productName: 'Áo Polo Nam Classic Fit Pique',
      sku: 'MVN-POL-NVY-M',
      size: 'M',
      colorName: 'Xanh Navy',
      price: 299000,
      stockQuantity: 40,
      isActive: true,
      updatedAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    InventoryVariantItem(
      id: '30000000-0000-0000-0000-000000000006',
      productId: '20000000-0000-0000-0000-000000000002',
      productName: 'Áo Polo Nam Classic Fit Pique',
      sku: 'MVN-POL-NVY-L',
      size: 'L',
      colorName: 'Xanh Navy',
      price: 299000,
      stockQuantity: 35,
      isActive: true,
      updatedAt: DateTime.now().subtract(const Duration(hours: 9)),
    ),
    InventoryVariantItem(
      id: '30000000-0000-0000-0000-000000000007',
      productId: '20000000-0000-0000-0000-000000000002',
      productName: 'Áo Polo Nam Classic Fit Pique',
      sku: 'MVN-POL-GRY-M',
      size: 'M',
      colorName: 'Xám Tiêu',
      price: 299000,
      stockQuantity: 4, // Low stock
      isActive: true,
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    InventoryVariantItem(
      id: '30000000-0000-0000-0000-000000000008',
      productId: '20000000-0000-0000-0000-000000000003',
      productName: 'Quần Khaki Nam Slim Fit Co Giãn',
      sku: 'MVN-KHK-BEI-30',
      size: '30',
      colorName: 'Beige',
      price: 399000,
      stockQuantity: 12,
      isActive: true,
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    InventoryVariantItem(
      id: '30000000-0000-0000-0000-000000000009',
      productId: '20000000-0000-0000-0000-000000000003',
      productName: 'Quần Khaki Nam Slim Fit Co Giãn',
      sku: 'MVN-KHK-BEI-31',
      size: '31',
      colorName: 'Beige',
      price: 399000,
      stockQuantity: 0, // Out of stock
      isActive: true,
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    InventoryVariantItem(
      id: '30000000-0000-0000-0000-000000000010',
      productId: '20000000-0000-0000-0000-000000000004',
      productName: 'Áo Sơ Mi Nữ Lụa Satin Cao Cấp',
      sku: 'MVN-SMI-CRM-S',
      size: 'S',
      colorName: 'Kem',
      price: 349000,
      stockQuantity: 22,
      isActive: true,
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  static final List<InventoryMovementItem> _mockMovements = [
    InventoryMovementItem(
      id: 'mov-001',
      variantId: '30000000-0000-0000-0000-000000000001',
      variantSku: 'MVN-TSH-BLK-M',
      productName: 'Áo Thun Nam Cotton Compact MOVEN',
      orderId: 'ord-001',
      orderCode: 'MVN-8A9F1B2C',
      quantityDelta: -2,
      reason: 'order_created',
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    InventoryMovementItem(
      id: 'mov-002',
      variantId: '30000000-0000-0000-0000-000000000003',
      variantSku: 'MVN-TSH-WHT-M',
      productName: 'Áo Thun Nam Cotton Compact MOVEN',
      orderId: 'ord-002',
      orderCode: 'MVN-3D4E5F6A',
      quantityDelta: -1,
      reason: 'order_created',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    InventoryMovementItem(
      id: 'mov-003',
      variantId: '30000000-0000-0000-0000-000000000004',
      variantSku: 'MVN-TSH-WHT-L',
      productName: 'Áo Thun Nam Cotton Compact MOVEN',
      orderId: 'ord-003',
      orderCode: 'MVN-7B8C9D0E',
      quantityDelta: 1,
      reason: 'return_received',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    InventoryMovementItem(
      id: 'mov-004',
      variantId: '30000000-0000-0000-0000-000000000005',
      variantSku: 'MVN-POL-NVY-M',
      productName: 'Áo Polo Nam Classic Fit Pique',
      quantityDelta: 20,
      reason: 'restock',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    InventoryMovementItem(
      id: 'mov-005',
      variantId: '30000000-0000-0000-0000-000000000007',
      variantSku: 'MVN-POL-GRY-M',
      productName: 'Áo Polo Nam Classic Fit Pique',
      quantityDelta: -2,
      reason: 'adjustment',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  /// Lấy danh sách tồn kho của tất cả các biến thể
  Future<List<InventoryVariantItem>> getInventoryVariants({
    String? searchQuery,
    String? statusFilter, // 'all', 'low_stock', 'out_of_stock'
    int lowStockThreshold = 5,
  }) async {
    if (!_isSupabaseConfigured) {
      return _filterVariants(_mockVariants, searchQuery, statusFilter, lowStockThreshold);
    }

    try {
      final response = await _client!
          .from('product_variants')
          .select('''
            id,
            product_id,
            sku,
            size,
            color_name,
            price,
            stock_quantity,
            is_active,
            updated_at,
            products (
              id,
              name
            )
          ''')
          .order('stock_quantity', ascending: true);

      final list = (response as List<dynamic>)
          .map((data) => InventoryVariantItem.fromJson(data as Map<String, dynamic>))
          .toList();

      if (list.isEmpty) {
        return _filterVariants(_mockVariants, searchQuery, statusFilter, lowStockThreshold);
      }

      return _filterVariants(list, searchQuery, statusFilter, lowStockThreshold);
    } catch (e) {
      if (kDebugMode) debugPrint('[InventoryRepository] getInventoryVariants error: $e');
      return _filterVariants(_mockVariants, searchQuery, statusFilter, lowStockThreshold);
    }
  }

  List<InventoryVariantItem> _filterVariants(
    List<InventoryVariantItem> source,
    String? search,
    String? status,
    int threshold,
  ) {
    var result = List<InventoryVariantItem>.from(source);

    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      result = result.where((item) {
        return item.sku.toLowerCase().contains(q) ||
            item.productName.toLowerCase().contains(q) ||
            (item.size?.toLowerCase().contains(q) ?? false) ||
            (item.colorName?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    if (status == 'low_stock') {
      result = result.where((item) => item.isLowStock(threshold)).toList();
    } else if (status == 'out_of_stock') {
      result = result.where((item) => item.isOutOfStock).toList();
    }

    return result;
  }

  /// Tính toán số liệu KPI tổng quan cho kho hàng
  Future<InventorySummaryMetrics> getSummaryMetrics({int lowStockThreshold = 5}) async {
    final variants = await getInventoryVariants(lowStockThreshold: lowStockThreshold);
    var low = 0;
    var outOfStock = 0;

    for (final v in variants) {
      if (v.isOutOfStock) {
        outOfStock++;
      } else if (v.isLowStock(lowStockThreshold)) {
        low++;
      }
    }

    return InventorySummaryMetrics(
      totalVariants: variants.length,
      lowStockCount: low,
      outOfStockCount: outOfStock,
    );
  }

  /// Điều chỉnh số lượng tồn kho của biến thể và ghi log `inventory_movements`
  Future<void> adjustStock({
    required String variantId,
    required int newStock,
    required String reasonNote,
  }) async {
    if (!_isSupabaseConfigured) {
      final idx = _mockVariants.indexWhere((v) => v.id == variantId);
      if (idx != -1) {
        final current = _mockVariants[idx];
        final delta = newStock - current.stockQuantity;
        _mockVariants[idx] = current.copyWith(
          stockQuantity: newStock,
          updatedAt: DateTime.now(),
        );

        _mockMovements.insert(
          0,
          InventoryMovementItem(
            id: 'mov-${DateTime.now().millisecondsSinceEpoch}',
            variantId: current.id,
            variantSku: current.sku,
            productName: current.productName,
            quantityDelta: delta,
            reason: 'adjustment',
            note: reasonNote,
            createdAt: DateTime.now(),
          ),
        );
      }
      return;
    }

    try {
      // 1. Lấy số lượng tồn kho hiện tại để tính delta
      final currentRes = await _client!
          .from('product_variants')
          .select('stock_quantity, sku, products(name)')
          .eq('id', variantId)
          .single();

      final currentStock = (currentRes['stock_quantity'] as num).toInt();
      final delta = newStock - currentStock;

      if (delta == 0) return; // Không có thay đổi

      // 2. Cập nhật số lượng mới trong product_variants
      await _client
          .from('product_variants')
          .update({
            'stock_quantity': newStock,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', variantId);

      // 3. Ghi log vào inventory_movements
      await _client.from('inventory_movements').insert({
        'variant_id': variantId,
        'quantity_delta': delta,
        'reason': 'adjustment',
        'note': reasonNote,
        'created_by': _client.auth.currentUser?.id,
      });
    } catch (e) {
      if (kDebugMode) debugPrint('[InventoryRepository] adjustStock error: $e');
      throw ServerException('Lỗi cập nhật tồn kho: $e');
    }
  }

  /// Lấy danh sách lịch sử biến động kho (Audit trail)
  Future<List<InventoryMovementItem>> getInventoryMovements({
    int limit = 50,
  }) async {
    if (!_isSupabaseConfigured) {
      return List<InventoryMovementItem>.from(_mockMovements);
    }

    try {
      final response = await _client!
          .from('inventory_movements')
          .select('''
            id,
            variant_id,
            order_id,
            quantity_delta,
            reason,
            created_by,
            created_at,
            product_variants (
              sku,
              products (
                name
              )
            ),
            orders (
              order_code
            )
          ''')
          .order('created_at', ascending: false)
          .limit(limit);

      final list = (response as List<dynamic>)
          .map((data) => InventoryMovementItem.fromJson(data as Map<String, dynamic>))
          .toList();

      if (list.isEmpty) {
        return List<InventoryMovementItem>.from(_mockMovements);
      }

      return list;
    } catch (e) {
      if (kDebugMode) debugPrint('[InventoryRepository] getInventoryMovements error: $e');
      return List<InventoryMovementItem>.from(_mockMovements);
    }
  }
}
