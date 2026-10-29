import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:moven/features/admin/domain/models/dashboard_metrics.dart';
import 'package:moven/features/orders/data/orders_repository.dart';
import 'package:moven/features/orders/domain/models/order.dart';
import 'package:moven/features/orders/domain/models/order_status.dart';

/// Repository quản lý truy vấn số liệu KPI cho Admin Dashboard
class DashboardRepository {
  final SupabaseClient? _client;
  final OrdersRepository? _ordersRepository;

  DashboardRepository([this._client, this._ordersRepository]);

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
      return _generateDynamicMetrics(startDate: startDate, endDate: endDate);
    }

    try {
      final res = await _client!.rpc(
        'admin_get_dashboard_metrics',
        params: {
          'p_start_date': startDate?.toUtc().toIso8601String(),
          'p_end_date': endDate?.toUtc().toIso8601String(),
        },
      );

      return DashboardMetrics.fromJson(res as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) debugPrint('[DashboardRepository] getDashboardMetrics error: $e');
      return _generateDynamicMetrics(startDate: startDate, endDate: endDate);
    }
  }

  /// Tính toán số liệu Dashboard động từ OrdersRepository trong chế độ Preview hoặc Fallback
  DashboardMetrics _generateDynamicMetrics({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final orders = _ordersRepository?.mockOrders;
    if (orders == null || orders.isEmpty) {
      return _mockMetrics;
    }

    // 1. Doanh thu đơn giao thành công (delivered) trong khoảng thời gian lọc (ADR-0005)
    final deliveredOrders = orders.where((o) => o.status == OrderStatus.delivered).where((o) {
      final date = o.deliveredAt ?? o.updatedAt ?? o.createdAt;
      if (startDate != null && date.isBefore(startDate)) return false;
      if (endDate != null && date.isAfter(endDate)) return false;
      return true;
    });
    final deliveredRevenue = deliveredOrders.fold<int>(0, (sum, o) => sum + o.totalAmount);

    // 2. Thống kê số lượng đơn theo từng trạng thái
    final filteredForCounts = orders.where((o) {
      if (startDate != null && o.createdAt.isBefore(startDate)) return false;
      if (endDate != null && o.createdAt.isAfter(endDate)) return false;
      return true;
    });
    final Map<String, int> counts = {};
    for (final s in OrderStatus.values) {
      counts[s.value] = filteredForCounts.where((o) => o.status == s).length;
    }

    // 3. Danh sách 5 đơn hàng mới nhất
    final sortedOrders = List<Order>.from(orders)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final recent = sortedOrders.take(5).map((o) => RecentOrderItem(
      id: o.id,
      orderCode: o.orderCode,
      recipientName: o.recipientName,
      totalAmount: o.totalAmount,
      status: o.status.value,
      paymentStatus: o.paymentStatus,
      createdAt: o.createdAt,
    )).toList();

    return _mockMetrics.copyWith(
      deliveredRevenue: deliveredRevenue,
      statusCounts: counts,
      recentOrders: recent,
    );
  }
}
