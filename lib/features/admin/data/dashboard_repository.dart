import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:moven/features/admin/domain/models/dashboard_metrics.dart';

/// Repository quản lý truy vấn số liệu KPI cho Admin Dashboard
class DashboardRepository {
  final SupabaseClient? _client;

  DashboardRepository([this._client]);

  bool get _isSupabaseConfigured => _client != null;

  static final DashboardMetrics _mockMetrics = DashboardMetrics(
    deliveredRevenue: 5280000,
    lowStockThreshold: 5,
    statusCounts: const {
      'pending_confirmation': 3,
      'confirmed': 2,
      'preparing': 1,
      'shipping': 4,
      'delivered': 18,
      'delivery_failed': 1,
      'cancelled': 2,
      'returned': 1,
    },
    bestSellers: const [
      BestSellerItem(
        productName: 'Áo Phông Nam Basic Cotton 100%',
        productId: 'prod-001',
        totalSold: 28,
        totalRevenue: 5572000,
      ),
      BestSellerItem(
        productName: 'Quần Khaki Slim-fit Co Giãn',
        productId: 'prod-002',
        totalSold: 16,
        totalRevenue: 5584000,
      ),
      BestSellerItem(
        productName: 'Áo Polo Thể Thao Quick-Dry',
        productId: 'prod-003',
        totalSold: 12,
        totalRevenue: 3348000,
      ),
      BestSellerItem(
        productName: 'Áo Sơ Mi Oxford Dài Tay',
        productId: 'prod-004',
        totalSold: 8,
        totalRevenue: 3032000,
      ),
    ],
    lowStockVariants: const [
      LowStockVariantItem(
        variantId: 'var-001',
        sku: 'MVN-TSH-BLK-S',
        size: 'S',
        colorName: 'Đen',
        stockQuantity: 2,
        productName: 'Áo Phông Nam Basic Cotton 100%',
        productId: 'prod-001',
      ),
      LowStockVariantItem(
        variantId: 'var-002',
        sku: 'MVN-KHK-BGE-30',
        size: '30',
        colorName: 'Be',
        stockQuantity: 3,
        productName: 'Quần Khaki Slim-fit Co Giãn',
        productId: 'prod-002',
      ),
      LowStockVariantItem(
        variantId: 'var-003',
        sku: 'MVN-POL-NVY-XL',
        size: 'XL',
        colorName: 'Xanh Navy',
        stockQuantity: 0,
        productName: 'Áo Polo Thể Thao Quick-Dry',
        productId: 'prod-003',
      ),
    ],
    recentOrders: [
      RecentOrderItem(
        id: 'ord-001',
        orderCode: 'MVN-8A9F1B2C',
        recipientName: 'Nguyễn Văn An',
        totalAmount: 418000,
        status: 'pending_confirmation',
        paymentStatus: 'unpaid',
        createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
      ),
      RecentOrderItem(
        id: 'ord-002',
        orderCode: 'MVN-3D4E5F6A',
        recipientName: 'Trần Thị Bình',
        totalAmount: 718000,
        status: 'shipping',
        paymentStatus: 'unpaid',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      RecentOrderItem(
        id: 'ord-003',
        orderCode: 'MVN-7B8C9D0E',
        recipientName: 'Lê Hoàng Cường',
        totalAmount: 219000,
        status: 'delivered',
        paymentStatus: 'paid',
        createdAt: DateTime.now().subtract(const Duration(hours: 14)),
      ),
      RecentOrderItem(
        id: 'ord-004',
        orderCode: 'MVN-1A2B3C4D',
        recipientName: 'Phạm Minh Đức',
        totalAmount: 569000,
        status: 'delivered',
        paymentStatus: 'paid',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      RecentOrderItem(
        id: 'ord-005',
        orderCode: 'MVN-5E6F7A8B',
        recipientName: 'Vũ Thị Hoa',
        totalAmount: 349000,
        status: 'delivery_failed',
        paymentStatus: 'unpaid',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ],
  );

  /// Lấy số liệu Dashboard
  Future<DashboardMetrics> getDashboardMetrics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!_isSupabaseConfigured) {
      return _mockMetrics;
    }

    try {
      final res = await _client!.rpc(
        'admin_get_dashboard_metrics',
        params: {
          'p_start_date': startDate?.toIso8601String(),
          'p_end_date': endDate?.toIso8601String(),
        },
      );

      return DashboardMetrics.fromJson(res as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) debugPrint('[DashboardRepository] getDashboardMetrics error: $e');
      return _mockMetrics;
    }
  }
}
