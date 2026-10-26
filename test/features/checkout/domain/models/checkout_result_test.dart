import 'package:flutter_test/flutter_test.dart';
import 'package:moven/features/checkout/domain/models/checkout_result.dart';

void main() {
  group('CheckoutResult Tests', () {
    test('Phân tích JSON từ RPC checkout COD chính xác', () {
      final json = {
        'success': true,
        'order_id': '88888888-0000-0000-0000-000000000001',
        'order_code': 'MVN-AB12CD34',
        'subtotal': 398000,
        'shipping_fee': 20000,
        'total_amount': 418000,
      };

      final result = CheckoutResult.fromJson(json);

      expect(result.success, true);
      expect(result.orderId, '88888888-0000-0000-0000-000000000001');
      expect(result.orderCode, 'MVN-AB12CD34');
      expect(result.subtotal, 398000);
      expect(result.shippingFee, 20000);
      expect(result.totalAmount, 418000);
    });

    test('Xử lý fallback giá trị mặc định an toàn khi JSON thiếu trường', () {
      final json = <String, dynamic>{};
      final result = CheckoutResult.fromJson(json);

      expect(result.success, false);
      expect(result.orderId, '');
      expect(result.orderCode, '');
      expect(result.subtotal, 0);
      expect(result.shippingFee, 20000); // Mặc định 20.000đ theo đặc tả
      expect(result.totalAmount, 0);
    });
  });
}
