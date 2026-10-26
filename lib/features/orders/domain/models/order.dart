import 'package:freezed_annotation/freezed_annotation.dart';
import 'order_item.dart';
import 'order_status.dart';
import 'order_status_history.dart';

part 'order.freezed.dart';
part 'order.g.dart';

/// Thực thể Đơn hàng toàn diện trong MOVEN (Freezed)
@freezed
class Order with _$Order {
  const Order._();

  const factory Order({
    required String id,
    @JsonKey(name: 'order_code') required String orderCode,
    @JsonKey(name: 'user_id') required String userId,
    required OrderStatus status,
    @JsonKey(name: 'payment_method') @Default('cod') String paymentMethod,
    @JsonKey(name: 'payment_status') @Default('unpaid') String paymentStatus,
    @JsonKey(name: 'recipient_name') required String recipientName,
    @JsonKey(name: 'recipient_phone') required String recipientPhone,
    @JsonKey(name: 'shipping_address')
    @Default({})
    Map<String, dynamic> shippingAddress,
    required int subtotal,
    @JsonKey(name: 'shipping_fee') @Default(20000) int shippingFee,
    @JsonKey(name: 'discount_amount') @Default(0) int discountAmount,
    @JsonKey(name: 'total_amount') required int totalAmount,
    @JsonKey(name: 'customer_note') String? customerNote,
    @JsonKey(name: 'cancellation_reason') String? cancellationReason,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'cancelled_at') DateTime? cancelledAt,
    @JsonKey(name: 'delivered_at') DateTime? deliveredAt,
    @JsonKey(name: 'order_items') @Default([]) List<OrderItem> items,
    @JsonKey(name: 'order_status_history')
    @Default([])
    List<OrderStatusHistory> statusHistory,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  /// Địa chỉ giao hàng định dạng chuỗi đầy đủ
  String get fullAddress {
    final street = shippingAddress['street'] as String? ??
        shippingAddress['street_address'] as String? ??
        '';
    final ward = shippingAddress['ward'] as String? ?? '';
    final district = shippingAddress['district'] as String? ?? '';
    final province = shippingAddress['province'] as String? ??
        shippingAddress['city'] as String? ??
        '';

    final parts = [street, ward, district, province]
        .where((p) => p.trim().isNotEmpty)
        .toList();

    return parts.isEmpty ? 'Chưa cập nhật địa chỉ' : parts.join(', ');
  }

  /// Tổng số lượng món đồ trong đơn
  int get totalItemCount {
    return items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  /// Trạng thái thanh toán hiển thị thân thiện
  String get paymentStatusDisplayName {
    switch (paymentStatus.toLowerCase()) {
      case 'paid':
        return 'Đã thanh toán COD';
      case 'unpaid':
        return 'Chưa thu tiền';
      case 'failed':
        return 'Thất bại';
      default:
        return 'Chưa thu tiền';
    }
  }

  /// Đã thu tiền mặt COD hay chưa
  bool get isPaid => paymentStatus.toLowerCase() == 'paid';
}
