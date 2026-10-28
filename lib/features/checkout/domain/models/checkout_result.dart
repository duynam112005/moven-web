import 'package:flutter/foundation.dart';

/// Kết quả phản hồi từ RPC checkout COD
@immutable
class CheckoutResult {
  final bool success;
  final String orderId;
  final String orderCode;
  final int subtotal;
  final int shippingFee;
  final int totalAmount;

  const CheckoutResult({
    required this.success,
    required this.orderId,
    required this.orderCode,
    required this.subtotal,
    required this.shippingFee,
    required this.totalAmount,
  });

  factory CheckoutResult.fromJson(Map<String, dynamic> json) {
    return CheckoutResult(
      success: json['success'] == true,
      orderId: json['order_id']?.toString() ?? '',
      orderCode: json['order_code']?.toString() ?? '',
      subtotal: (json['subtotal'] as num?)?.toInt() ?? 0,
      shippingFee: (json['shipping_fee'] as num?)?.toInt() ?? 20000,
      totalAmount: (json['total_amount'] as num?)?.toInt() ?? 0,
    );
  }
}
