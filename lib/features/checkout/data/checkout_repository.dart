import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/errors/app_exception.dart';
import '../domain/models/checkout_result.dart';

/// Repository thực thi thanh toán đặt hàng COD qua RPC server-side tin cậy
class CheckoutRepository {
  final SupabaseClient _client;

  CheckoutRepository(this._client);

  /// Lấy mức phí giao hàng mặc định từ bảng singleton `store_settings`
  Future<int> getDefaultShippingFee() async {
    try {
      final response = await _client
          .from('store_settings')
          .select('default_shipping_fee')
          .maybeSingle();

      if (response != null && response['default_shipping_fee'] != null) {
        return (response['default_shipping_fee'] as num).toInt();
      }
      return 20000;
    } catch (_) {
      // Fallback mức phí mặc định theo đặc tả MOVEN
      return 20000;
    }
  }

  /// Thực thi đặt hàng (COD hoặc Quét mã QR) thông qua PostgreSQL RPC `create_order_checkout`
  Future<CheckoutResult> createOrderCheckout({
    required Map<String, dynamic> shippingAddress,
    required List<Map<String, dynamic>> items,
    String? customerNote,
    String paymentMethod = 'cod',
  }) async {
    final note = (customerNote != null && customerNote.trim().isNotEmpty)
        ? customerNote.trim()
        : null;

    dynamic response;
    try {
      response = await _client.rpc(
        'create_order_checkout',
        params: {
          'p_shipping_address': shippingAddress,
          'p_items': items,
          'p_customer_note': note,
          'p_payment_method': paymentMethod,
        },
      );
    } on PostgrestException catch (e) {
      final isSchemaCacheError = e.code == 'PGRST202' ||
          e.message.contains('schema cache') ||
          e.message.contains('Could not find the function');

      if (isSchemaCacheError && paymentMethod == 'cod') {
        // Tương thích ngược: Nếu database Supabase chưa nạp migration mới nhận 4 tham số,
        // tự động fallback gọi hàm 3 tham số để đơn hàng COD không bao giờ bị gián đoạn.
        try {
          response = await _client.rpc(
            'create_order_checkout',
            params: {
              'p_shipping_address': shippingAddress,
              'p_items': items,
              'p_customer_note': note,
            },
          );
        } catch (_) {
          _mapPostgrestException(e);
        }
      } else if (isSchemaCacheError && paymentMethod == 'qr_code') {
        throw const ServerException(
          'Hệ thống chưa chạy migration hỗ trợ Quét mã QR trên database Supabase. Vui lòng chạy file migration 20261029000002_qr_payment_and_expiration.sql trên Supabase SQL Editor hoặc chuyển sang thanh toán COD.',
          code: 'MIGRATION_REQUIRED',
        );
      } else {
        _mapPostgrestException(e);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Không thể hoàn tất đặt hàng: $e');
    }

    final Map<String, dynamic> resultMap;
    if (response is Map) {
      resultMap = Map<String, dynamic>.from(response);
    } else if (response is String) {
      resultMap = Map<String, dynamic>.from(jsonDecode(response) as Map);
    } else {
      throw const ServerException('Phản hồi từ máy chủ không hợp lệ.');
    }
    return CheckoutResult.fromJson(resultMap);
  }

  Never _mapPostgrestException(PostgrestException e) {
    if (e.code == 'P0005') {
      throw OutOfStockException(
        e.message,
        code: 'INSUFFICIENT_STOCK',
      );
    } else if (e.code == 'P0004') {
      throw NotFoundException(
        e.message,
        code: 'PRODUCT_INACTIVE',
      );
    } else if (e.code == 'P0002') {
      throw ValidationException(e.message);
    } else if (e.code == 'P0001') {
      throw const AppAuthException('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
    }

    throw ServerException(
      'Lỗi xử lý đơn hàng: ${e.message}',
      code: e.code,
    );
  }
}
