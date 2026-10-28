import 'package:flutter_test/flutter_test.dart';
import 'package:moven/features/orders/domain/models/order.dart';
import 'package:moven/features/orders/domain/models/order_status.dart';

void main() {
  group('OrderStatus Domain Model Tests', () {
    test('Order.fromJson deserializes snake_case database statuses accurately', () {
      final json = {
        'id': 'ord-123',
        'order_code': 'MVN-TEST01',
        'user_id': 'usr-001',
        'status': 'pending_confirmation',
        'payment_method': 'cod',
        'payment_status': 'unpaid',
        'recipient_name': 'Test User',
        'recipient_phone': '0901234567',
        'subtotal': 100000,
        'shipping_fee': 20000,
        'discount_amount': 0,
        'total_amount': 120000,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'order_items': <Map<String, dynamic>>[],
        'order_status_history': [
          {
            'id': 'hist-001',
            'order_id': 'ord-123',
            'from_status': null,
            'to_status': 'pending_confirmation',
            'created_at': DateTime.now().toIso8601String(),
          }
        ],
      };

      final order = Order.fromJson(json);
      expect(order.status, OrderStatus.pendingConfirmation);
      expect(order.statusHistory.first.toStatus, OrderStatus.pendingConfirmation);

      // Verify delivery_failed snake_case deserialization
      final failedOrder = Order.fromJson({...json, 'status': 'delivery_failed'});
      expect(failedOrder.status, OrderStatus.deliveryFailed);
    });

    test('OrderStatus.fromString parses database status strings accurately', () {
      expect(OrderStatus.fromString('pending_confirmation'), OrderStatus.pendingConfirmation);
      expect(OrderStatus.fromString('shipping'), OrderStatus.shipping);
      expect(OrderStatus.fromString('delivered'), OrderStatus.delivered);
      expect(OrderStatus.fromString('delivery_failed'), OrderStatus.deliveryFailed);
      expect(OrderStatus.fromString('cancelled'), OrderStatus.cancelled);
      expect(OrderStatus.fromString('returned'), OrderStatus.returned);

      // Backward compatibility aliases
      expect(OrderStatus.fromString('pending'), OrderStatus.pendingConfirmation);
      expect(OrderStatus.fromString('confirmed'), OrderStatus.pendingConfirmation);
      expect(OrderStatus.fromString('preparing'), OrderStatus.pendingConfirmation);

      // Unknown fallback
      expect(OrderStatus.fromString('unknown_status'), OrderStatus.pendingConfirmation);
      expect(OrderStatus.fromString(null), OrderStatus.pendingConfirmation);
    });

    test('canCustomerCancel returns true strictly for pendingConfirmation', () {
      expect(OrderStatus.pendingConfirmation.canCustomerCancel, isTrue);
      expect(OrderStatus.shipping.canCustomerCancel, isFalse);
      expect(OrderStatus.delivered.canCustomerCancel, isFalse);
      expect(OrderStatus.deliveryFailed.canCustomerCancel, isFalse);
      expect(OrderStatus.cancelled.canCustomerCancel, isFalse);
      expect(OrderStatus.returned.canCustomerCancel, isFalse);
    });

    test('validNextStatusesAdmin enforces State Machine per ADR-0001', () {
      // From pendingConfirmation -> shipping, cancelled
      expect(
        OrderStatus.pendingConfirmation.validNextStatusesAdmin,
        containsAll([OrderStatus.shipping, OrderStatus.cancelled]),
      );

      // From shipping -> delivered, deliveryFailed
      expect(
        OrderStatus.shipping.validNextStatusesAdmin,
        containsAll([OrderStatus.delivered, OrderStatus.deliveryFailed]),
      );

      // From deliveryFailed -> shipping (retry delivery), returned (restock on receipt)
      expect(
        OrderStatus.deliveryFailed.validNextStatusesAdmin,
        containsAll([OrderStatus.shipping, OrderStatus.returned]),
      );

      // Terminal states cannot transition further
      expect(OrderStatus.delivered.validNextStatusesAdmin, isEmpty);
      expect(OrderStatus.cancelled.validNextStatusesAdmin, isEmpty);
      expect(OrderStatus.returned.validNextStatusesAdmin, isEmpty);
    });

    test('displayName returns clear Vietnamese names', () {
      expect(OrderStatus.pendingConfirmation.displayName, 'Chờ xác nhận');
      expect(OrderStatus.shipping.displayName, 'Đang giao hàng');
      expect(OrderStatus.delivered.displayName, 'Giao thành công');
      expect(OrderStatus.deliveryFailed.displayName, 'Giao thất bại');
      expect(OrderStatus.cancelled.displayName, 'Đã hủy');
      expect(OrderStatus.returned.displayName, 'Đã trả hàng hoàn');
    });
  });
}
