import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/errors/app_exception.dart';
import '../domain/models/order.dart';
import '../domain/models/order_item.dart';
import '../domain/models/order_status.dart';
import '../domain/models/order_status_history.dart';

/// Repository quản lý đơn hàng cho Khách hàng & Quản trị viên (Phase 6)
class OrdersRepository {
  final SupabaseClient? _client;

  // Bộ nhớ đệm Mock Data khi chạy ở chế độ UI Preview hoặc Supabase chưa kết nối
  final List<Order> _mockOrders = [];

  /// Danh sách đơn hàng giả lập (chỉ đọc) dùng cho preview/fallback
  List<Order> get mockOrders => List.unmodifiable(_mockOrders);

  OrdersRepository(this._client) {
    _initMockOrders();
  }

  void _initMockOrders() {
    final now = DateTime.now();
    _mockOrders.addAll([
      Order(
        id: 'ord-mock-001',
        orderCode: 'MVN-8A9F1B2C',
        userId: 'usr-customer-01',
        status: OrderStatus.pendingConfirmation,
        paymentMethod: 'cod',
        paymentStatus: 'unpaid',
        recipientName: 'Nguyễn Văn An',
        recipientPhone: '0901234567',
        shippingAddress: {
          'recipient_name': 'Nguyễn Văn An',
          'phone': '0901234567',
          'street': 'Số 123 Đường Nguyễn Huệ',
          'ward': 'Phường Bến Nghé',
          'district': 'Quận 1',
          'province': 'TP. Hồ Chí Minh',
        },
        subtotal: 798000,
        shippingFee: 20000,
        discountAmount: 0,
        totalAmount: 818000,
        customerNote: 'Giao trong giờ hành chính giúp mình',
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        items: [
          const OrderItem(
            id: 'item-001',
            orderId: 'ord-mock-001',
            variantId: 'var-001',
            productId: 'prod-001',
            productName: 'Áo Thun Cotton Compact Cao Cấp',
            sku: 'MVN-TSHIRT-BLK-L',
            size: 'L',
            colorName: 'Đen',
            unitPrice: 299000,
            quantity: 2,
            lineTotal: 598000,
          ),
          const OrderItem(
            id: 'item-002',
            orderId: 'ord-mock-001',
            variantId: 'var-002',
            productId: 'prod-002',
            productName: 'Quần Short Thể Thao Co Giãn',
            sku: 'MVN-SHORT-NVY-XL',
            size: 'XL',
            colorName: 'Xanh Navy',
            unitPrice: 200000,
            quantity: 1,
            lineTotal: 200000,
          ),
        ],
        statusHistory: [
          OrderStatusHistory(
            id: 'hist-001',
            orderId: 'ord-mock-001',
            fromStatus: null,
            toStatus: OrderStatus.pendingConfirmation,
            actorId: 'usr-customer-01',
            note: 'Khách hàng đặt đơn hàng COD thành công',
            createdAt: now.subtract(const Duration(hours: 2)),
          ),
        ],
      ),
      Order(
        id: 'ord-mock-002',
        orderCode: 'MVN-5E2D3C4B',
        userId: 'usr-customer-01',
        status: OrderStatus.shipping,
        paymentMethod: 'cod',
        paymentStatus: 'unpaid',
        recipientName: 'Nguyễn Văn An',
        recipientPhone: '0901234567',
        shippingAddress: {
          'recipient_name': 'Nguyễn Văn An',
          'phone': '0901234567',
          'street': 'Số 123 Đường Nguyễn Huệ',
          'ward': 'Phường Bến Nghé',
          'district': 'Quận 1',
          'province': 'TP. Hồ Chí Minh',
        },
        subtotal: 450000,
        shippingFee: 20000,
        discountAmount: 0,
        totalAmount: 470000,
        createdAt: now.subtract(const Duration(days: 1, hours: 4)),
        updatedAt: now.subtract(const Duration(hours: 6)),
        items: [
          const OrderItem(
            id: 'item-003',
            orderId: 'ord-mock-002',
            variantId: 'var-003',
            productId: 'prod-001',
            productName: 'Áo Sơ Mi Oxford Dài Tay',
            sku: 'MVN-SHIRT-WHT-M',
            size: 'M',
            colorName: 'Trắng',
            unitPrice: 450000,
            quantity: 1,
            lineTotal: 450000,
          ),
        ],
        statusHistory: [
          OrderStatusHistory(
            id: 'hist-002',
            orderId: 'ord-mock-002',
            fromStatus: null,
            toStatus: OrderStatus.pendingConfirmation,
            actorId: 'usr-customer-01',
            note: 'Đặt hàng thành công',
            createdAt: now.subtract(const Duration(days: 1, hours: 4)),
          ),
          OrderStatusHistory(
            id: 'hist-003',
            orderId: 'ord-mock-002',
            fromStatus: OrderStatus.pendingConfirmation,
            toStatus: OrderStatus.shipping,
            actorId: 'adm-001',
            note: 'Đã đóng gói và bàn giao đối tác giao vận',
            createdAt: now.subtract(const Duration(hours: 6)),
          ),
        ],
      ),
      Order(
        id: 'ord-mock-003',
        orderCode: 'MVN-1A7F9D3E',
        userId: 'usr-customer-01',
        status: OrderStatus.delivered,
        paymentMethod: 'cod',
        paymentStatus: 'paid',
        recipientName: 'Nguyễn Văn An',
        recipientPhone: '0901234567',
        shippingAddress: {
          'recipient_name': 'Nguyễn Văn An',
          'phone': '0901234567',
          'street': 'Số 123 Đường Nguyễn Huệ',
          'ward': 'Phường Bến Nghé',
          'district': 'Quận 1',
          'province': 'TP. Hồ Chí Minh',
        },
        subtotal: 650000,
        shippingFee: 20000,
        discountAmount: 0,
        totalAmount: 670000,
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(days: 2)),
        deliveredAt: now.subtract(const Duration(days: 2)),
        items: [
          const OrderItem(
            id: 'item-004',
            orderId: 'ord-mock-003',
            variantId: 'var-004',
            productId: 'prod-002',
            productName: 'Quần Kaki Co Giãn Dáng Suông',
            sku: 'MVN-KAKI-BEI-32',
            size: '32',
            colorName: 'Be Khaki',
            unitPrice: 650000,
            quantity: 1,
            lineTotal: 650000,
          ),
        ],
        statusHistory: [
          OrderStatusHistory(
            id: 'hist-004',
            orderId: 'ord-mock-003',
            fromStatus: null,
            toStatus: OrderStatus.pendingConfirmation,
            actorId: 'usr-customer-01',
            note: 'Đặt hàng thành công',
            createdAt: now.subtract(const Duration(days: 4)),
          ),
          OrderStatusHistory(
            id: 'hist-005',
            orderId: 'ord-mock-003',
            fromStatus: OrderStatus.pendingConfirmation,
            toStatus: OrderStatus.shipping,
            actorId: 'adm-001',
            note: 'Đã xuất kho',
            createdAt: now.subtract(const Duration(days: 3)),
          ),
          OrderStatusHistory(
            id: 'hist-006',
            orderId: 'ord-mock-003',
            fromStatus: OrderStatus.shipping,
            toStatus: OrderStatus.delivered,
            actorId: 'adm-001',
            note: 'Khách đã nhận hàng và thanh toán đủ COD',
            createdAt: now.subtract(const Duration(days: 2)),
          ),
        ],
      ),
      Order(
        id: 'ord-mock-004',
        orderCode: 'MVN-3C8B2A1F',
        userId: 'usr-customer-02',
        status: OrderStatus.deliveryFailed,
        paymentMethod: 'cod',
        paymentStatus: 'unpaid',
        recipientName: 'Trần Thị Bình',
        recipientPhone: '0987654321',
        shippingAddress: {
          'recipient_name': 'Trần Thị Bình',
          'phone': '0987654321',
          'street': 'Số 45 Lê Lợi',
          'ward': 'Phường Thạch Thang',
          'district': 'Quận Hải Châu',
          'province': 'TP. Đà Nẵng',
        },
        subtotal: 580000,
        shippingFee: 20000,
        discountAmount: 0,
        totalAmount: 600000,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 1)),
        items: [
          const OrderItem(
            id: 'item-005',
            orderId: 'ord-mock-004',
            variantId: 'var-005',
            productName: 'Áo Khoác Gió Nam Thể Thao',
            sku: 'MVN-JACKET-GRY-L',
            size: 'L',
            colorName: 'Xám',
            unitPrice: 580000,
            quantity: 1,
            lineTotal: 580000,
          ),
        ],
        statusHistory: [
          OrderStatusHistory(
            id: 'hist-007',
            orderId: 'ord-mock-004',
            fromStatus: null,
            toStatus: OrderStatus.pendingConfirmation,
            actorId: 'usr-customer-02',
            note: 'Đặt hàng thành công',
            createdAt: now.subtract(const Duration(days: 3)),
          ),
          OrderStatusHistory(
            id: 'hist-008',
            orderId: 'ord-mock-004',
            fromStatus: OrderStatus.pendingConfirmation,
            toStatus: OrderStatus.shipping,
            actorId: 'adm-001',
            note: 'Đang vận chuyển',
            createdAt: now.subtract(const Duration(days: 2)),
          ),
          OrderStatusHistory(
            id: 'hist-009',
            orderId: 'ord-mock-004',
            fromStatus: OrderStatus.shipping,
            toStatus: OrderStatus.deliveryFailed,
            actorId: 'adm-001',
            note: 'Khách không bắt máy 3 lần, hẹn phát lại',
            createdAt: now.subtract(const Duration(days: 1)),
          ),
        ],
      ),
    ]);
  }

  // ==========================================
  // KHÁCH HÀNG (CUSTOMER APIS)
  // ==========================================

  /// Lấy danh sách đơn hàng của khách hàng hiện tại
  Future<List<Order>> getCustomerOrders({
    OrderStatus? statusFilter,
    int limit = 20,
    int offset = 0,
  }) async {
    final client = _client;
    if (client == null) {
      var list = List<Order>.from(_mockOrders);
      if (statusFilter != null) {
        list = list.where((o) => o.status == statusFilter).toList();
      }
      return list;
    }

    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) {
        throw const AppAuthException('Vui lòng đăng nhập để xem đơn hàng.');
      }

      var query = client
          .from('orders')
          .select('''
            *,
            order_items (
              *,
              product_variants (
                product_id
              )
            ),
            order_status_history (*)
          ''')
          .eq('user_id', userId);

      if (statusFilter != null) {
        query = query.eq('status', statusFilter.value);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final list = (response as List<dynamic>)
          .map((data) => Order.fromJson(_normalizeMap(data)))
          .toList();

      return list;
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Không thể tải danh sách đơn hàng: $e');
    }
  }

  /// Tra cứu chi tiết đơn hàng theo order_code
  Future<Order> getOrderByCode(String orderCode) async {
    final client = _client;
    if (client == null) {
      final found = _mockOrders.firstWhere(
        (o) => o.orderCode.toLowerCase() == orderCode.toLowerCase(),
        orElse: () => _mockOrders.first,
      );
      return found;
    }

    try {
      final response = await client
          .from('orders')
          .select('''
            *,
            order_items (
              *,
              product_variants (
                product_id
              )
            ),
            order_status_history (*)
          ''')
          .eq('order_code', orderCode)
          .maybeSingle();

      if (response == null) {
        throw NotFoundException('Không tìm thấy đơn hàng với mã $orderCode');
      }

      return Order.fromJson(_normalizeMap(response));
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Lỗi tải thông tin đơn hàng: $e');
    }
  }

  /// Khách hàng hủy đơn hàng (chỉ khi đang ở pending_confirmation)
  Future<void> customerCancelOrder({
    required String orderCode,
    required String reason,
  }) async {
    final client = _client;
    if (client == null) {
      final idx = _mockOrders.indexWhere(
        (o) => o.orderCode.toLowerCase() == orderCode.toLowerCase(),
      );
      if (idx != -1) {
        final current = _mockOrders[idx];
        if (current.isPaid) {
          throw const ValidationException(
            'Đơn hàng này đã được thanh toán thành công. Để hủy đơn và nhận lại tiền hoàn, vui lòng liên hệ Hotline/Zalo cửa hàng.',
          );
        }
        if (!current.status.canCustomerCancel) {
          throw const ValidationException(
            'Chỉ có thể hủy đơn hàng khi đang ở trạng thái Chờ xác nhận.',
          );
        }
        final updatedHist = List<OrderStatusHistory>.from(current.statusHistory)
          ..add(
            OrderStatusHistory(
              id: 'hist-${DateTime.now().millisecondsSinceEpoch}',
              orderId: current.id,
              fromStatus: current.status,
              toStatus: OrderStatus.cancelled,
              actorId: 'mock-user',
              note: 'Khách hủy đơn: $reason',
              createdAt: DateTime.now(),
            ),
          );

        _mockOrders[idx] = current.copyWith(
          status: OrderStatus.cancelled,
          cancellationReason: reason,
          cancelledAt: DateTime.now(),
          statusHistory: updatedHist,
        );
      }
      return;
    }

    try {
      await client.rpc(
        'customer_cancel_order',
        params: {
          'p_order_code': orderCode,
          'p_cancellation_reason': reason,
        },
      );
    } on PostgrestException catch (e) {
      if (e.code == 'P0004') {
        throw ValidationException(e.message);
      } else if (e.code == 'P0002') {
        throw ValidationException(e.message);
      } else if (e.code == 'P0001') {
        throw const AppAuthException('Bạn không có quyền hủy đơn hàng này.');
      }
      throw ServerException('Không thể hủy đơn hàng: ${e.message}');
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Không thể hủy đơn hàng: $e');
    }
  }

  // ==========================================
  // QUẢN TRỊ VIÊN (ADMIN APIS)
  // ==========================================

  /// Quản trị viên lấy danh sách đơn hàng toàn cửa hàng (hỗ trợ lọc & tìm kiếm)
  Future<List<Order>> getAdminOrders({
    OrderStatus? statusFilter,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  }) async {
    final client = _client;
    if (client == null) {
      var list = List<Order>.from(_mockOrders);
      if (statusFilter != null) {
        list = list.where((o) => o.status == statusFilter).toList();
      }
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final query = searchQuery.trim().toLowerCase();
        list = list.where((o) {
          return o.orderCode.toLowerCase().contains(query) ||
              o.recipientPhone.contains(query) ||
              o.recipientName.toLowerCase().contains(query);
        }).toList();
      }
      return list;
    }

    try {
      var query = client.from('orders').select('''
            *,
            order_items (*),
            order_status_history (*)
          ''');

      if (statusFilter != null) {
        query = query.eq('status', statusFilter.value);
      }

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final cleanSearch = searchQuery.trim();
        // Tìm theo mã đơn hoặc số điện thoại
        query = query.or('order_code.ilike.%$cleanSearch%,recipient_phone.ilike.%$cleanSearch%');
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final list = (response as List<dynamic>)
          .map((data) => Order.fromJson(_normalizeMap(data)))
          .toList();

      return list;
    } catch (e) {
      if (kDebugMode) debugPrint('[OrdersRepository] getAdminOrders error: $e');
      return const [];
    }
  }

  /// Quản trị viên cập nhật trạng thái vận chuyển qua RPC server-side an toàn
  Future<void> adminUpdateOrderStatus({
    required String orderId,
    required OrderStatus newStatus,
    String? note,
  }) async {
    final client = _client;
    if (client == null) {
      final idx = _mockOrders.indexWhere((o) => o.id == orderId);
      if (idx != -1) {
        final current = _mockOrders[idx];
        final updatedHist = List<OrderStatusHistory>.from(current.statusHistory)
          ..add(
            OrderStatusHistory(
              id: 'hist-${DateTime.now().millisecondsSinceEpoch}',
              orderId: current.id,
              fromStatus: current.status,
              toStatus: newStatus,
              actorId: 'admin-mock',
              note: note ?? 'Admin cập nhật: ${newStatus.displayName}',
              createdAt: DateTime.now(),
            ),
          );

        _mockOrders[idx] = current.copyWith(
          status: newStatus,
          paymentStatus: newStatus == OrderStatus.delivered ? 'paid' : current.paymentStatus,
          updatedAt: DateTime.now(),
          deliveredAt: newStatus == OrderStatus.delivered ? DateTime.now() : null,
          cancelledAt: newStatus == OrderStatus.cancelled ? DateTime.now() : null,
          statusHistory: updatedHist,
        );
      }
      return;
    }

    try {
      await client.rpc(
        'admin_update_order_status',
        params: {
          'p_order_id': orderId,
          'p_new_status': newStatus.value,
          'p_note': (note != null && note.trim().isNotEmpty) ? note.trim() : null,
        },
      );
    } on PostgrestException catch (e) {
      if (e.code == 'P0004') {
        throw ValidationException(e.message);
      } else if (e.code == 'P0001') {
        throw const AppAuthException('Chỉ Quản trị viên mới có quyền cập nhật trạng thái đơn.');
      }
      throw ServerException('Cập nhật trạng thái thất bại: ${e.message}');
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Không thể cập nhật trạng thái đơn hàng: $e');
    }
  }

  /// Quản trị viên đối soát cập nhật trạng thái thanh toán COD hoặc Quét mã QR (ADR-0002 & ADR-0007)
  Future<void> adminUpdatePaymentStatus({
    required String orderId,
    required String paymentStatus,
    String? note,
  }) async {
    final client = _client;
    if (client == null) {
      final idx = _mockOrders.indexWhere((o) => o.id == orderId);
      if (idx != -1) {
        final current = _mockOrders[idx];
        _mockOrders[idx] = current.copyWith(
          paymentStatus: paymentStatus,
          status: current.status,
          updatedAt: DateTime.now(),
        );
      }
      return;
    }

    try {
      await client.rpc(
        'admin_update_payment_status',
        params: {
          'p_order_id': orderId,
          'p_payment_status': paymentStatus,
          'p_note': (note != null && note.trim().isNotEmpty) ? note.trim() : null,
        },
      );
    } on PostgrestException catch (e) {
      throw ServerException('Cập nhật thanh toán thất bại: ${e.message}');
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Không thể cập nhật thanh toán: $e');
    }
  }

  /// Tự động hủy các đơn hàng quét mã QR quá hạn 15 phút và hoàn kho nguyên tử
  Future<int> cancelExpiredQrOrders() async {
    final client = _client;
    if (client == null) return 0;
    try {
      final res = await client.rpc('cancel_expired_qr_orders');
      if (res is Map && res['cancelled_count'] != null) {
        return (res['cancelled_count'] as num).toInt();
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  /// Chuẩn hoá đệ quy dữ liệu JSON từ Supabase (tránh lỗi TypeError trên Flutter Web)
  static Map<String, dynamic> _normalizeMap(dynamic map) {
    if (map is! Map) return <String, dynamic>{};
    final normalized = map.map((key, value) {
      if (value is Map) {
        return MapEntry(key.toString(), _normalizeMap(value));
      } else if (value is List) {
        return MapEntry(
          key.toString(),
          value.map((e) => e is Map ? _normalizeMap(e) : e).toList(),
        );
      }
      return MapEntry(key.toString(), value);
    });

    // Trích xuất product_id từ product_variants nếu có trong order_item
    if (normalized.containsKey('product_variants') &&
        normalized['product_variants'] is Map &&
        normalized['product_id'] == null) {
      final pv = normalized['product_variants'] as Map<String, dynamic>;
      if (pv.containsKey('product_id')) {
        normalized['product_id'] = pv['product_id'];
      }
    }

    // Tương thích ngược các trạng thái cũ sang pending_confirmation
    for (final statusKey in const ['status', 'from_status', 'to_status']) {
      if (normalized.containsKey(statusKey) && normalized[statusKey] is String) {
        final val = (normalized[statusKey] as String).trim().toLowerCase();
        if (val == 'pending' || val == 'confirmed' || val == 'preparing') {
          normalized[statusKey] = 'pending_confirmation';
        }
      }
    }

    return normalized;
  }
}
