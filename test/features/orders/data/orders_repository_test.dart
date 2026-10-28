import 'package:flutter_test/flutter_test.dart';
import 'package:moven/core/errors/app_exception.dart';
import 'package:moven/features/orders/data/orders_repository.dart';
import 'package:moven/features/orders/domain/models/order_status.dart';

void main() {
  group('OrdersRepository Tests (Mock & Invariant Verification)', () {
    late OrdersRepository repository;

    setUp(() {
      repository = OrdersRepository(null);
    });

    test('getCustomerOrders returns list of orders', () async {
      final orders = await repository.getCustomerOrders();
      expect(orders, isNotEmpty);
      expect(orders.first.orderCode, startsWith('MVN-'));
    });

    test('getCustomerOrders filters by OrderStatus correctly', () async {
      final shippingOrders = await repository.getCustomerOrders(
        statusFilter: OrderStatus.shipping,
      );
      for (final order in shippingOrders) {
        expect(order.status, OrderStatus.shipping);
      }
    });

    test('getOrderByCode finds specific order', () async {
      final order = await repository.getOrderByCode('MVN-8A9F1B2C');
      expect(order.orderCode, 'MVN-8A9F1B2C');
      expect(order.recipientName, 'Nguyễn Văn An');
      expect(order.items, isNotEmpty);
      expect(order.subtotal + order.shippingFee, order.totalAmount);
    });

    test('customerCancelOrder succeeds on pendingConfirmation order', () async {
      const targetCode = 'MVN-8A9F1B2C';
      final initialOrder = await repository.getOrderByCode(targetCode);
      expect(initialOrder.status, OrderStatus.pendingConfirmation);

      await repository.customerCancelOrder(
        orderCode: targetCode,
        reason: 'Đổi ý không mua nữa',
      );

      final updatedOrder = await repository.getOrderByCode(targetCode);
      expect(updatedOrder.status, OrderStatus.cancelled);
      expect(updatedOrder.cancellationReason, 'Đổi ý không mua nữa');
      expect(updatedOrder.statusHistory.last.toStatus, OrderStatus.cancelled);
    });

    test('customerCancelOrder throws ValidationException on shipping order', () async {
      const targetCode = 'MVN-5E2D3C4B'; // Order with status 'shipping'
      final order = await repository.getOrderByCode(targetCode);
      expect(order.status, OrderStatus.shipping);

      expect(
        () => repository.customerCancelOrder(
          orderCode: targetCode,
          reason: 'Muốn hủy',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('adminUpdateOrderStatus updates order to delivered and marks payment paid per ADR-0002', () async {
      const targetCode = 'MVN-5E2D3C4B'; // Order with status 'shipping'
      final initialOrder = await repository.getOrderByCode(targetCode);
      expect(initialOrder.status, OrderStatus.shipping);
      expect(initialOrder.paymentStatus, 'unpaid');

      await repository.adminUpdateOrderStatus(
        orderId: initialOrder.id,
        newStatus: OrderStatus.delivered,
        note: 'Admin xác nhận shipper đã phát thành công và thu đủ COD',
      );

      final updatedOrder = await repository.getOrderByCode(targetCode);
      expect(updatedOrder.status, OrderStatus.delivered);
      expect(updatedOrder.paymentStatus, 'paid');
      expect(updatedOrder.deliveredAt, isNotNull);
      expect(updatedOrder.statusHistory.last.toStatus, OrderStatus.delivered);
    });

    test('getAdminOrders filters and searches by order code or phone', () async {
      final searchByCode = await repository.getAdminOrders(searchQuery: '8A9F');
      expect(searchByCode, hasLength(1));
      expect(searchByCode.first.orderCode, 'MVN-8A9F1B2C');

      final searchByPhone = await repository.getAdminOrders(searchQuery: '0987654321');
      expect(searchByPhone, hasLength(1));
      expect(searchByPhone.first.recipientName, 'Trần Thị Bình');

      final filterDelivered = await repository.getAdminOrders(
        statusFilter: OrderStatus.delivered,
      );
      for (final order in filterDelivered) {
        expect(order.status, OrderStatus.delivered);
      }
    });

    test('adminUpdateOrderStatus transitions order and records history', () async {
      final targetId = 'ord-mock-001';
      await repository.adminUpdateOrderStatus(
        orderId: targetId,
        newStatus: OrderStatus.shipping,
        note: 'Đã xuất kho cho shipper',
      );

      final orders = await repository.getAdminOrders();
      final updated = orders.firstWhere((o) => o.id == targetId);
      expect(updated.status, OrderStatus.shipping);
      expect(updated.statusHistory.last.toStatus, OrderStatus.shipping);
      expect(updated.statusHistory.last.note, 'Đã xuất kho cho shipper');
    });

    test('adminUpdatePaymentStatus reconciles payment_status per ADR-0002', () async {
      final targetId = 'ord-mock-001';
      final ordersBefore = await repository.getAdminOrders();
      final orderBefore = ordersBefore.firstWhere((o) => o.id == targetId);
      expect(orderBefore.isPaid, isFalse);

      await repository.adminUpdatePaymentStatus(
        orderId: targetId,
        paymentStatus: 'paid',
        note: 'Shipper đã chuyển khoản nộp tiền COD',
      );

      final ordersAfter = await repository.getAdminOrders();
      final orderAfter = ordersAfter.firstWhere((o) => o.id == targetId);
      expect(orderAfter.isPaid, isTrue);
      expect(orderAfter.paymentStatus, 'paid');
    });
  });
}
