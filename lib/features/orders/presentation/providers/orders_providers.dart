import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../admin/presentation/providers/dashboard_providers.dart';
import '../../data/orders_repository.dart';
import '../../domain/models/order.dart';
import '../../domain/models/order_status.dart';

/// Provider cung cấp OrdersRepository an toàn
final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  SupabaseClient? client;
  if (AppConfig.isSupabaseConfigured) {
    try {
      client = ref.watch(supabaseClientProvider);
    } catch (_) {
      client = null;
    }
  }
  return OrdersRepository(client);
});

// ==========================================
// CUSTOMER ORDER PROVIDERS
// ==========================================

/// Bộ lọc trạng thái đơn hàng của khách hàng (null: Tất cả)
final customerOrdersFilterProvider = StateProvider.autoDispose<OrderStatus?>((ref) => null);

/// Provider tải danh sách đơn hàng của khách hàng theo bộ lọc hiện tại
final customerOrdersProvider = FutureProvider.autoDispose<List<Order>>((ref) async {
  final repository = ref.watch(ordersRepositoryProvider);
  final filter = ref.watch(customerOrdersFilterProvider);
  return repository.getCustomerOrders(statusFilter: filter);
});

/// Provider tải thông tin chi tiết một đơn hàng theo orderCode
final orderDetailProvider = FutureProvider.autoDispose.family<Order, String>((ref, orderCode) async {
  final repository = ref.watch(ordersRepositoryProvider);
  return repository.getOrderByCode(orderCode);
});

// ==========================================
// ADMIN ORDER PROVIDERS
// ==========================================

/// Bộ lọc trạng thái đơn hàng cho Quản trị viên
final adminOrdersFilterProvider = StateProvider.autoDispose<OrderStatus?>((ref) => null);

/// Từ khóa tìm kiếm đơn hàng cho Quản trị viên (mã đơn hoặc SĐT)
final adminOrdersSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

/// Provider tải danh sách đơn hàng cho Quản trị viên
final adminOrdersProvider = FutureProvider.autoDispose<List<Order>>((ref) async {
  final repository = ref.watch(ordersRepositoryProvider);
  final filter = ref.watch(adminOrdersFilterProvider);
  final query = ref.watch(adminOrdersSearchQueryProvider);

  return repository.getAdminOrders(
    statusFilter: filter,
    searchQuery: query,
  );
});

// ==========================================
// ACTION CONTROLLER (MUTATIONS)
// ==========================================

/// Controller xử lý các tác vụ thay đổi đơn hàng (Hủy đơn, Cập nhật trạng thái, Đối soát COD)
final orderActionControllerProvider =
    StateNotifierProvider<OrderActionController, AsyncValue<String?>>((ref) {
  final repo = ref.watch(ordersRepositoryProvider);
  return OrderActionController(ref, repo);
});

class OrderActionController extends StateNotifier<AsyncValue<String?>> {
  final Ref _ref;
  final OrdersRepository _repository;

  OrderActionController(this._ref, this._repository)
      : super(const AsyncValue.data(null));

  /// Khách hàng hủy đơn hàng khi ở trạng thái chờ xác nhận
  Future<bool> cancelOrder({
    required String orderCode,
    required String reason,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.customerCancelOrder(
        orderCode: orderCode,
        reason: reason,
      );
      // Tự động làm mới dữ liệu
      _ref.invalidate(customerOrdersProvider);
      _ref.invalidate(orderDetailProvider(orderCode));
      _ref.invalidate(adminOrdersProvider);
      _ref.invalidate(dashboardMetricsProvider);

      state = const AsyncValue.data('Hủy đơn hàng thành công.');
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Admin cập nhật trạng thái đơn hàng theo máy trạng thái ADR-0001
  Future<bool> adminUpdateStatus({
    required String orderId,
    required String orderCode,
    required OrderStatus newStatus,
    String? note,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.adminUpdateOrderStatus(
        orderId: orderId,
        newStatus: newStatus,
        note: note,
      );
      _ref.invalidate(adminOrdersProvider);
      _ref.invalidate(orderDetailProvider(orderCode));
      _ref.invalidate(customerOrdersProvider);
      _ref.invalidate(dashboardMetricsProvider);

      state = AsyncValue.data(
        'Đã cập nhật đơn hàng $orderCode sang trạng thái: ${newStatus.displayName}',
      );
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Admin cập nhật trạng thái thu tiền COD độc lập (ADR-0002)
  Future<bool> adminUpdatePayment({
    required String orderId,
    required String orderCode,
    required String paymentStatus,
    String? note,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.adminUpdatePaymentStatus(
        orderId: orderId,
        paymentStatus: paymentStatus,
        note: note,
      );
      _ref.invalidate(adminOrdersProvider);
      _ref.invalidate(orderDetailProvider(orderCode));
      _ref.invalidate(customerOrdersProvider);
      _ref.invalidate(dashboardMetricsProvider);

      state = const AsyncValue.data('Cập nhật trạng thái thanh toán thành công.');
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}
