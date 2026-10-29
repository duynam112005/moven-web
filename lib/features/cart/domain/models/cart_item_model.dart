import 'package:flutter/foundation.dart';

/// Model thể hiện một mục sản phẩm trong giỏ hàng (Cart Item)
@immutable
class CartItemModel {
  final String id;
  final String cartId;
  final String variantId;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Dữ liệu mở rộng từ quan hệ variant -> product (phục vụ hiển thị UI)
  final String productName;
  final String productSlug;
  final String sku;
  final String? size;
  final String? colorName;
  final int price;
  final int? compareAtPrice;
  final int stockQuantity;
  final String? imageUrl;
  final bool isActive;

  const CartItemModel({
    required this.id,
    required this.cartId,
    required this.variantId,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
    required this.productName,
    required this.productSlug,
    required this.sku,
    this.size,
    this.colorName,
    required this.price,
    this.compareAtPrice,
    required this.stockQuantity,
    this.imageUrl,
    this.isActive = true,
  });

  /// Tổng tiền của dòng sản phẩm
  int get lineTotal => price * quantity;

  /// Kiểm tra xem biến thể có còn đủ hàng cho số lượng trong giỏ không
  bool get inStock => isActive && stockQuantity >= quantity;

  /// Nhãn hiển thị biến thể (Ví dụ: "Size M / Đen")
  String get displayVariantLabel {
    final parts = <String>[];
    if (size != null && size!.isNotEmpty) parts.add('Size $size');
    if (colorName != null && colorName!.isNotEmpty) parts.add(colorName!);
    return parts.isEmpty ? 'Mặc định' : parts.join(' / ');
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    // Phân tích dữ liệu lồng nhau từ Supabase: variant(id, sku, size, color_name, price, compare_at_price, stock_quantity, is_active, product(...), product_images(...))
    final rawVariant = json['product_variants'] ?? json['variant'];
    final variant = rawVariant is Map ? Map<String, dynamic>.from(rawVariant) : <String, dynamic>{};
    final rawProduct = variant['products'] ?? variant['product'];
    final product = rawProduct is Map ? Map<String, dynamic>.from(rawProduct) : <String, dynamic>{};

    // Lấy ảnh ưu tiên: ảnh riêng biến thể -> ảnh chính sản phẩm (is_primary) -> ảnh đầu tiên
    String? img;
    final images = product['product_images'] as List<dynamic>?;
    if (images != null && images.isNotEmpty) {
      final imgList = images
          .whereType<Map>()
          .map((i) => Map<String, dynamic>.from(i))
          .toList();
      if (imgList.isNotEmpty) {
        final variantImg = imgList.firstWhere(
          (i) =>
              i['variant_id'] != null &&
              variant['id'] != null &&
              i['variant_id'] == variant['id'],
          orElse: () => imgList.firstWhere(
            (i) => i['is_primary'] == true,
            orElse: () => imgList.first,
          ),
        );
        img = variantImg['image_path'] as String?;
      }
    }

    return CartItemModel(
      id: json['id'] as String? ?? '',
      cartId: json['cart_id'] as String? ?? '',
      variantId: json['variant_id'] as String? ?? (variant['id'] as String? ?? ''),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      productName: product['name'] as String? ?? 'Sản phẩm',
      productSlug: product['slug'] as String? ?? '',
      sku: variant['sku'] as String? ?? '',
      size: variant['size'] as String?,
      colorName: variant['color_name'] as String?,
      price: (variant['price'] as num?)?.toInt() ?? 0,
      compareAtPrice: (variant['compare_at_price'] as num?)?.toInt(),
      stockQuantity: (variant['stock_quantity'] as num?)?.toInt() ?? 0,
      imageUrl: img,
      isActive: (variant['is_active'] as bool? ?? true) &&
          (product['is_active'] as bool? ?? true),
    );
  }

  CartItemModel copyWith({
    String? id,
    String? cartId,
    String? variantId,
    int? quantity,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? productName,
    String? productSlug,
    String? sku,
    String? size,
    String? colorName,
    int? price,
    int? compareAtPrice,
    int? stockQuantity,
    String? imageUrl,
    bool? isActive,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      cartId: cartId ?? this.cartId,
      variantId: variantId ?? this.variantId,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      productName: productName ?? this.productName,
      productSlug: productSlug ?? this.productSlug,
      sku: sku ?? this.sku,
      size: size ?? this.size,
      colorName: colorName ?? this.colorName,
      price: price ?? this.price,
      compareAtPrice: compareAtPrice ?? this.compareAtPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
    );
  }
}
