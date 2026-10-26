import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/errors/app_exception.dart';
import '../domain/models/cart_item_model.dart';

/// Repository quản lý dữ liệu giỏ hàng trên Supabase
class CartRepository {
  final SupabaseClient _client;

  CartRepository(this._client);

  /// Lấy hoặc tự động tạo ID giỏ hàng gắn với tài khoản người dùng
  Future<String> getOrCreateCartId(String userId) async {
    try {
      final existing = await _client
          .from('carts')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        return existing['id'] as String;
      }

      // Tạo mới nếu chưa có
      final created = await _client
          .from('carts')
          .insert({'user_id': userId})
          .select('id')
          .single();

      return created['id'] as String;
    } on PostgrestException catch (e) {
      throw ServerException(
        'Lỗi nạp giỏ hàng: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Không thể khởi tạo giỏ hàng: $e');
    }
  }

  /// Nạp toàn bộ các mặt hàng trong giỏ kèm thông tin chi tiết biến thể và sản phẩm
  Future<List<CartItemModel>> getCartItems(String userId) async {
    try {
      final cartId = await getOrCreateCartId(userId);

      final response = await _client
          .from('cart_items')
          .select('''
            id,
            cart_id,
            variant_id,
            quantity,
            created_at,
            updated_at,
            product_variants (
              id,
              sku,
              size,
              color_name,
              price,
              compare_at_price,
              stock_quantity,
              is_active,
              products (
                id,
                name,
                slug,
                is_active,
                product_images (
                  id,
                  variant_id,
                  image_path,
                  is_primary,
                  sort_order
                )
              )
            )
          ''')
          .eq('cart_id', cartId)
          .order('created_at', ascending: false);

      final list = (response as List<dynamic>).map((item) {
        return CartItemModel.fromJson(item as Map<String, dynamic>);
      }).toList();

      return list;
    } on PostgrestException catch (e) {
      throw ServerException(
        'Không thể nạp danh sách giỏ hàng: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Lỗi tải giỏ hàng: $e');
    }
  }

  /// Thêm biến thể sản phẩm vào giỏ hàng.
  /// Nếu biến thể đã có trong giỏ, tăng số lượng hiện có.
  Future<void> addToCart({
    required String userId,
    required String variantId,
    required int quantity,
  }) async {
    try {
      if (quantity <= 0) {
        throw const ValidationException('Số lượng phải lớn hơn 0');
      }

      final cartId = await getOrCreateCartId(userId);

      // Kiểm tra xem mục này đã có trong giỏ chưa
      final existing = await _client
          .from('cart_items')
          .select('id, quantity')
          .eq('cart_id', cartId)
          .eq('variant_id', variantId)
          .maybeSingle();

      if (existing != null) {
        final currentQty = (existing['quantity'] as num).toInt();
        final newQty = currentQty + quantity;

        await _client
            .from('cart_items')
            .update({
              'quantity': newQty,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', existing['id'] as String);
      } else {
        await _client.from('cart_items').insert({
          'cart_id': cartId,
          'variant_id': variantId,
          'quantity': quantity,
        });
      }
    } on PostgrestException catch (e) {
      throw ServerException(
        'Lỗi thêm sản phẩm vào giỏ: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Không thể thêm vào giỏ hàng: $e');
    }
  }

  /// Cập nhật số lượng của một mục trong giỏ
  Future<void> updateQuantity({
    required String itemId,
    required int quantity,
  }) async {
    try {
      if (quantity <= 0) {
        // Nếu số lượng <= 0, xóa mục khỏi giỏ
        await removeItem(itemId);
        return;
      }

      await _client
          .from('cart_items')
          .update({
            'quantity': quantity,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', itemId);
    } on PostgrestException catch (e) {
      throw ServerException(
        'Lỗi cập nhật số lượng: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Không thể cập nhật số lượng: $e');
    }
  }

  /// Xóa một mục khỏi giỏ hàng
  Future<void> removeItem(String itemId) async {
    try {
      await _client.from('cart_items').delete().eq('id', itemId);
    } on PostgrestException catch (e) {
      throw ServerException(
        'Lỗi xóa khỏi giỏ hàng: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Không thể xóa mục: $e');
    }
  }

  /// Dọn sạch toàn bộ giỏ hàng của người dùng
  Future<void> clearCart(String userId) async {
    try {
      final cartId = await getOrCreateCartId(userId);
      await _client.from('cart_items').delete().eq('cart_id', cartId);
    } on PostgrestException catch (e) {
      throw ServerException(
        'Lỗi dọn giỏ hàng: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Không thể dọn sạch giỏ: $e');
    }
  }
}
