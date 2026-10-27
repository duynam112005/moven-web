import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_metrics.freezed.dart';
part 'dashboard_metrics.g.dart';

/// Top sản phẩm bán chạy nhất từ các đơn hàng delivered (Freezed)
@freezed
class BestSellerItem with _$BestSellerItem {
  const factory BestSellerItem({
    @JsonKey(name: 'product_name') required String productName,
    @JsonKey(name: 'product_id') String? productId,
    @JsonKey(name: 'total_sold') @Default(0) int totalSold,
    @JsonKey(name: 'total_revenue') @Default(0) int totalRevenue,
  }) = _BestSellerItem;

  factory BestSellerItem.fromJson(Map<String, dynamic> json) =>
      _$BestSellerItemFromJson(json);
}

/// Biến thể sản phẩm sắp hết hàng (stock <= low_stock_threshold) (Freezed)
@freezed
class LowStockVariantItem with _$LowStockVariantItem {
  const factory LowStockVariantItem({
    @JsonKey(name: 'variant_id') required String variantId,
    required String sku,
    required String size,
    @JsonKey(name: 'color_name') required String colorName,
    @JsonKey(name: 'stock_quantity') required int stockQuantity,
    @JsonKey(name: 'product_name') required String productName,
    @JsonKey(name: 'product_id') String? productId,
  }) = _LowStockVariantItem;

  factory LowStockVariantItem.fromJson(Map<String, dynamic> json) =>
      _$LowStockVariantItemFromJson(json);
}

/// Đơn hàng gần đây hiển thị trên Dashboard (Freezed)
@freezed
class RecentOrderItem with _$RecentOrderItem {
  const factory RecentOrderItem({
    required String id,
    @JsonKey(name: 'order_code') required String orderCode,
    @JsonKey(name: 'recipient_name') required String recipientName,
    @JsonKey(name: 'total_amount') required int totalAmount,
    required String status,
    @JsonKey(name: 'payment_status') @Default('unpaid') String paymentStatus,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _RecentOrderItem;

  factory RecentOrderItem.fromJson(Map<String, dynamic> json) =>
      _$RecentOrderItemFromJson(json);
}

/// Dữ liệu KPI tổng hợp cho Admin Dashboard (Freezed)
@freezed
class DashboardMetrics with _$DashboardMetrics {
  const DashboardMetrics._();

  const factory DashboardMetrics({
    @JsonKey(name: 'delivered_revenue') @Default(0) int deliveredRevenue,
    @JsonKey(name: 'low_stock_threshold') @Default(5) int lowStockThreshold,
    @JsonKey(name: 'status_counts') @Default({}) Map<String, int> statusCounts,
    @JsonKey(name: 'best_sellers') @Default([]) List<BestSellerItem> bestSellers,
    @JsonKey(name: 'low_stock_variants')
    @Default([])
    List<LowStockVariantItem> lowStockVariants,
    @JsonKey(name: 'recent_orders')
    @Default([])
    List<RecentOrderItem> recentOrders,
  }) = _DashboardMetrics;

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) =>
      _$DashboardMetricsFromJson(json);

  int get pendingConfirmationCount => statusCounts['pending_confirmation'] ?? 0;
  int get confirmedCount => statusCounts['confirmed'] ?? 0;
  int get preparingCount => statusCounts['preparing'] ?? 0;
  int get shippingCount => statusCounts['shipping'] ?? 0;
  int get deliveredCount => statusCounts['delivered'] ?? 0;
  int get deliveryFailedCount => statusCounts['delivery_failed'] ?? 0;
  int get cancelledCount => statusCounts['cancelled'] ?? 0;
  int get returnedCount => statusCounts['returned'] ?? 0;

  int get lowStockCount => lowStockVariants.length;
}
