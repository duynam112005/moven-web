/// Model thông tin tồn kho của từng biến thể sản phẩm cho Admin
class InventoryVariantItem {
  final String id;
  final String productId;
  final String productName;
  final String sku;
  final String? size;
  final String? colorName;
  final int price;
  final int stockQuantity;
  final bool isActive;
  final DateTime updatedAt;

  const InventoryVariantItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.sku,
    this.size,
    this.colorName,
    required this.price,
    required this.stockQuantity,
    this.isActive = true,
    required this.updatedAt,
  });

  bool get inStock => stockQuantity > 0;
  bool isLowStock(int threshold) => stockQuantity > 0 && stockQuantity <= threshold;
  bool get isOutOfStock => stockQuantity <= 0;

  String get variantLabel {
    final parts = <String>[];
    if (size != null && size!.isNotEmpty) parts.add(size!);
    if (colorName != null && colorName!.isNotEmpty) parts.add(colorName!);
    return parts.isEmpty ? sku : parts.join(' / ');
  }

  factory InventoryVariantItem.fromJson(Map<String, dynamic> json) {
    final productMap = json['products'] as Map<String, dynamic>? ?? {};
    return InventoryVariantItem(
      id: json['id'] as String,
      productId: json['product_id'] as String? ?? (productMap['id'] as String? ?? ''),
      productName: (productMap['name'] as String?) ?? (json['product_name'] as String? ?? 'Sản phẩm'),
      sku: json['sku'] as String? ?? '',
      size: json['size'] as String?,
      colorName: json['color_name'] as String?,
      price: (json['price'] as num?)?.toInt() ?? 0,
      stockQuantity: (json['stock_quantity'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  InventoryVariantItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? sku,
    String? size,
    String? colorName,
    int? price,
    int? stockQuantity,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return InventoryVariantItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      sku: sku ?? this.sku,
      size: size ?? this.size,
      colorName: colorName ?? this.colorName,
      price: price ?? this.price,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      isActive: isActive ?? this.isActive,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Model nhật ký biến động kho (Audit trail: `inventory_movements`)
class InventoryMovementItem {
  final String id;
  final String variantId;
  final String variantSku;
  final String productName;
  final String? orderId;
  final String? orderCode;
  final int quantityDelta;
  final String reason;
  final String? note;
  final String? createdBy;
  final DateTime createdAt;

  const InventoryMovementItem({
    required this.id,
    required this.variantId,
    required this.variantSku,
    required this.productName,
    this.orderId,
    this.orderCode,
    required this.quantityDelta,
    required this.reason,
    this.note,
    this.createdBy,
    required this.createdAt,
  });

  String get reasonLabel {
    switch (reason) {
      case 'order_created':
        return 'Đặt hàng (Trừ kho)';
      case 'order_cancelled':
        return 'Khách hủy đơn (Hoàn kho)';
      case 'return_received':
        return 'Nhận hàng hoàn trả (Hoàn kho)';
      case 'restock':
        return 'Nhập thêm hàng';
      case 'adjustment':
        return 'Điều chỉnh thủ công';
      default:
        return reason;
    }
  }

  factory InventoryMovementItem.fromJson(Map<String, dynamic> json) {
    final variantMap = json['product_variants'] as Map<String, dynamic>? ?? {};
    final productMap = variantMap['products'] as Map<String, dynamic>? ?? {};
    final orderMap = json['orders'] as Map<String, dynamic>? ?? {};

    return InventoryMovementItem(
      id: json['id'] as String,
      variantId: json['variant_id'] as String,
      variantSku: (variantMap['sku'] as String?) ?? (json['variant_sku'] as String? ?? ''),
      productName: (productMap['name'] as String?) ?? (json['product_name'] as String? ?? 'Sản phẩm'),
      orderId: json['order_id'] as String?,
      orderCode: orderMap['order_code'] as String? ?? json['order_code'] as String?,
      quantityDelta: (json['quantity_delta'] as num?)?.toInt() ?? 0,
      reason: json['reason'] as String? ?? 'adjustment',
      note: json['note'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// Model thống kê KPI kho hàng
class InventorySummaryMetrics {
  final int totalVariants;
  final int lowStockCount;
  final int outOfStockCount;

  const InventorySummaryMetrics({
    required this.totalVariants,
    required this.lowStockCount,
    required this.outOfStockCount,
  });

  int get inStockCount => totalVariants - lowStockCount - outOfStockCount;
}
