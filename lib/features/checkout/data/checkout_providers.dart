import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/supabase_client.dart';
import '../../cart/data/cart_providers.dart';
import '../domain/models/checkout_result.dart';
import 'checkout_repository.dart';

/// Provider cung cấp CheckoutRepository an toàn
final checkoutRepositoryProvider = Provider<CheckoutRepository?>((ref) {
  try {
    final client = ref.watch(supabaseClientProvider);
    return CheckoutRepository(client);
  } catch (_) {
    return null;
  }
});

/// Provider nạp mức phí vận chuyển mặc định (20,000 VND)
final defaultShippingFeeProvider = FutureProvider<int>((ref) async {
  try {
    final repo = ref.watch(checkoutRepositoryProvider);
    if (repo == null) return 20000;
    return await repo.getDefaultShippingFee();
  } catch (_) {
    return 20000;
  }
});

/// State quản lý quá trình thực hiện thanh toán COD
class CheckoutController extends StateNotifier<AsyncValue<CheckoutResult?>> {
  final CheckoutRepository? _repository;
  final Ref _ref;

  CheckoutController(this._repository, this._ref)
      : super(const AsyncValue.data(null));

  /// Thực hiện đặt hàng COD với cơ chế bảo vệ duplicate click
  Future<CheckoutResult?> submitOrder({
    required Map<String, dynamic> shippingAddress,
    required List<Map<String, dynamic>> items,
    String? customerNote,
  }) async {
    // Tránh duplicate submit nếu đang xử lý
    if (state.isLoading) return null;

    if (_repository == null) {
      throw StateError('Chưa cấu hình kết nối Supabase cho thanh toán.');
    }

    try {
      state = const AsyncValue.loading();

      final result = await _repository.createOrderCheckout(
        shippingAddress: shippingAddress,
        items: items,
        customerNote: customerNote,
      );

      state = AsyncValue.data(result);

      // Cập nhật lại giỏ hàng sau khi đặt thành công (các món đã đặt đã bị RPC xóa)
      await _ref.read(cartNotifierProvider.notifier).loadCart();

      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Reset trạng thái sau khi đã điều hướng thành công
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// Provider quản lý CheckoutController
final checkoutControllerProvider =
    StateNotifierProvider<CheckoutController, AsyncValue<CheckoutResult?>>((ref) {
  final repo = ref.watch(checkoutRepositoryProvider);
  return CheckoutController(repo, ref);
});
