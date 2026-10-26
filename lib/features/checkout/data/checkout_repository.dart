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

  /// Thực thi đặt hàng COD nguyên tử thông qua PostgreSQL RPC `create_order_checkout`
  Future<CheckoutResult> createOrderCheckout({
    required Map<String, dynamic> shippingAddress,
    required List<Map<String, dynamic>> items,
    String? customerNote,
  }) async {
    try {
      final response = await _client.rpc(
        'create_order_checkout',
        params: {
          'p_shipping_address': shippingAddress,
          'p_items': items,
          'p_customer_note': (customerNote != null && customerNote.trim().isNotEmpty)
              ? customerNote.trim()
              : null,
        },
      );

      final resultMap = response as Map<String, dynamic>;
      return CheckoutResult.fromJson(resultMap);
    } on PostgrestException catch (e) {
      // Phân tách mã lỗi nghiệp vụ từ RPC
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
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Không thể hoàn tất đặt hàng: $e');
    }
  }
}
