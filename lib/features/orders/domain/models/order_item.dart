import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_item.freezed.dart';
part 'order_item.g.dart';

/// Chi tiết sản phẩm trong đơn hàng với dữ liệu snapshot thời điểm đặt (Freezed)
@freezed
class OrderItem with _$OrderItem {
  const OrderItem._();

  const factory OrderItem({
    required String id,
    @JsonKey(name: 'order_id') required String orderId,
    @JsonKey(name: 'variant_id') String? variantId,
    @JsonKey(name: 'product_id') String? productId,
    @JsonKey(name: 'product_name_snapshot') required String productName,
    @JsonKey(name: 'sku_snapshot') required String sku,
    @JsonKey(name: 'size_snapshot') String? size,
    @JsonKey(name: 'color_snapshot') String? colorName,
    @JsonKey(name: 'unit_price') required int unitPrice,
    required int quantity,
    @JsonKey(name: 'line_total') required int lineTotal,
    @JsonKey(name: 'image_url') String? imageUrl,
  }) = _OrderItem;

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);

  /// Mô tả biến thể gọn gàng (VD: "Size: L | Màu: Đen")
  String get variantDescription {
    final parts = <String>[];
    if (size != null && size!.isNotEmpty) {
      parts.add('Size: $size');
    }
    if (colorName != null && colorName!.isNotEmpty) {
      parts.add('Màu: $colorName');
    }
    return parts.isEmpty ? 'Mặc định' : parts.join(' | ');
  }
}
