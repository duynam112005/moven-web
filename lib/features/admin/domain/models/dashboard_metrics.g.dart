// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_metrics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BestSellerItemImpl _$$BestSellerItemImplFromJson(Map<String, dynamic> json) =>
    _$BestSellerItemImpl(
      productName: json['product_name'] as String,
      productId: json['product_id'] as String?,
      totalSold: (json['total_sold'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['total_revenue'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$BestSellerItemImplToJson(
  _$BestSellerItemImpl instance,
) => <String, dynamic>{
  'product_name': instance.productName,
  'product_id': instance.productId,
  'total_sold': instance.totalSold,
  'total_revenue': instance.totalRevenue,
};

_$LowStockVariantItemImpl _$$LowStockVariantItemImplFromJson(
  Map<String, dynamic> json,
) => _$LowStockVariantItemImpl(
  variantId: json['variant_id'] as String,
  sku: json['sku'] as String,
  size: json['size'] as String,
  colorName: json['color_name'] as String,
  stockQuantity: (json['stock_quantity'] as num).toInt(),
  productName: json['product_name'] as String,
  productId: json['product_id'] as String?,
);

Map<String, dynamic> _$$LowStockVariantItemImplToJson(
  _$LowStockVariantItemImpl instance,
) => <String, dynamic>{
  'variant_id': instance.variantId,
  'sku': instance.sku,
  'size': instance.size,
  'color_name': instance.colorName,
  'stock_quantity': instance.stockQuantity,
  'product_name': instance.productName,
  'product_id': instance.productId,
};

_$RecentOrderItemImpl _$$RecentOrderItemImplFromJson(
  Map<String, dynamic> json,
) => _$RecentOrderItemImpl(
  id: json['id'] as String,
  orderCode: json['order_code'] as String,
  recipientName: json['recipient_name'] as String,
  totalAmount: (json['total_amount'] as num).toInt(),
  status: json['status'] as String,
  paymentStatus: json['payment_status'] as String? ?? 'unpaid',
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$RecentOrderItemImplToJson(
  _$RecentOrderItemImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'order_code': instance.orderCode,
  'recipient_name': instance.recipientName,
  'total_amount': instance.totalAmount,
  'status': instance.status,
  'payment_status': instance.paymentStatus,
  'created_at': instance.createdAt.toIso8601String(),
};

_$DashboardMetricsImpl _$$DashboardMetricsImplFromJson(
  Map<String, dynamic> json,
) => _$DashboardMetricsImpl(
  deliveredRevenue: (json['delivered_revenue'] as num?)?.toInt() ?? 0,
  lowStockThreshold: (json['low_stock_threshold'] as num?)?.toInt() ?? 5,
  statusCounts:
      (json['status_counts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
  bestSellers:
      (json['best_sellers'] as List<dynamic>?)
          ?.map((e) => BestSellerItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  lowStockVariants:
      (json['low_stock_variants'] as List<dynamic>?)
          ?.map((e) => LowStockVariantItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  recentOrders:
      (json['recent_orders'] as List<dynamic>?)
          ?.map((e) => RecentOrderItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$DashboardMetricsImplToJson(
  _$DashboardMetricsImpl instance,
) => <String, dynamic>{
  'delivered_revenue': instance.deliveredRevenue,
  'low_stock_threshold': instance.lowStockThreshold,
  'status_counts': instance.statusCounts,
  'best_sellers': instance.bestSellers,
  'low_stock_variants': instance.lowStockVariants,
  'recent_orders': instance.recentOrders,
};
