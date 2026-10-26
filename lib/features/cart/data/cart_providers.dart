import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/supabase_client.dart';
import '../domain/models/cart_item_model.dart';
import 'cart_repository.dart';

/// Provider cung cấp CartRepository an toàn
final cartRepositoryProvider = Provider<CartRepository?>((ref) {
  try {
    final client = ref.watch(supabaseClientProvider);
    return CartRepository(client);
  } catch (_) {
    return null;
  }
});

/// StateNotifier quản lý danh sách sản phẩm trong giỏ hàng và các thao tác tương tác
class CartNotifier extends StateNotifier<AsyncValue<List<CartItemModel>>> {
  final CartRepository? _repository;
  final Ref _ref;

  CartNotifier(this._repository, this._ref) : super(const AsyncValue.loading()) {
    loadCart();
  }

  /// Nạp giỏ hàng từ Supabase
  Future<void> loadCart() async {
    final user = _ref.read(currentUserProvider);
    if (user == null || _repository == null) {
      state = const AsyncValue.data([]);
      return;
    }

    try {
      state = const AsyncValue.loading();
      final items = await _repository.getCartItems(user.id);
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Thêm sản phẩm vào giỏ
  Future<void> addToCart({
    required String variantId,
    required int quantity,
  }) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) {
      throw StateError('Vui lòng đăng nhập để thêm sản phẩm vào giỏ hàng.');
    }

    if (_repository == null) {
      // Chế độ preview/mock local state
      final currentList = state.valueOrNull ?? [];
      final existingIndex = currentList.indexWhere((i) => i.variantId == variantId);
      if (existingIndex >= 0) {
        final existing = currentList[existingIndex];
        final updated = existing.copyWith(quantity: existing.quantity + quantity);
        final list = List<CartItemModel>.from(currentList)..[existingIndex] = updated;
        state = AsyncValue.data(list);
      }
      return;
    }

    await _repository.addToCart(
      userId: user.id,
      variantId: variantId,
      quantity: quantity,
    );

    await loadCart();
  }

  /// Cập nhật số lượng của mục trong giỏ
  Future<void> updateQuantity({
    required String itemId,
    required int quantity,
  }) async {
    final currentList = state.valueOrNull ?? [];
    if (quantity <= 0) {
      state = AsyncValue.data(
        currentList.where((item) => item.id != itemId).toList(),
      );
    } else {
      state = AsyncValue.data(
        currentList.map((item) {
          if (item.id == itemId) {
            return item.copyWith(quantity: quantity);
          }
          return item;
        }).toList(),
      );
    }

    if (_repository == null) return;

    try {
      await _repository.updateQuantity(itemId: itemId, quantity: quantity);
      final user = _ref.read(currentUserProvider);
      if (user != null) {
        final freshItems = await _repository.getCartItems(user.id);
        state = AsyncValue.data(freshItems);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      await loadCart();
    }
  }

  /// Xóa một mục khỏi giỏ
  Future<void> removeItem(String itemId) async {
    final currentList = state.valueOrNull ?? [];
    state = AsyncValue.data(
      currentList.where((item) => item.id != itemId).toList(),
    );

    if (_repository == null) return;

    try {
      await _repository.removeItem(itemId);
      final user = _ref.read(currentUserProvider);
      if (user != null) {
        final freshItems = await _repository.getCartItems(user.id);
        state = AsyncValue.data(freshItems);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      await loadCart();
    }
  }

  /// Dọn sạch giỏ
  Future<void> clearCart() async {
    state = const AsyncValue.data([]);
    final user = _ref.read(currentUserProvider);
    if (user == null || _repository == null) return;
    await _repository.clearCart(user.id);
  }
}

/// Provider cung cấp StateNotifier của giỏ hàng
final cartNotifierProvider =
    StateNotifierProvider<CartNotifier, AsyncValue<List<CartItemModel>>>((ref) {
  final repo = ref.watch(cartRepositoryProvider);
  return CartNotifier(repo, ref);
});

/// Provider tính tổng số lượng các mặt hàng trong giỏ (cho Badge trên Header)
final cartItemCountProvider = Provider<int>((ref) {
  try {
    final cartState = ref.watch(cartNotifierProvider);
    return cartState.maybeWhen(
      data: (items) => items.fold<int>(0, (sum, item) => sum + item.quantity),
      orElse: () => 0,
    );
  } catch (_) {
    return 0;
  }
});

/// Provider tính tổng tiền tạm tính của giỏ hàng (Subtotal)
final cartSubtotalProvider = Provider<int>((ref) {
  try {
    final cartState = ref.watch(cartNotifierProvider);
    return cartState.maybeWhen(
      data: (items) => items.fold<int>(0, (sum, item) => sum + item.lineTotal),
      orElse: () => 0,
    );
  } catch (_) {
    return 0;
  }
});
