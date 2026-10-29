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

/// Provider tính tổng tiền tạm tính của giỏ hàng (Subtotal cho tất cả sản phẩm)
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

/// StateNotifier quản lý danh sách ID các mặt hàng được chọn để thanh toán (Shopee style)
class SelectedCartItemIdsNotifier extends StateNotifier<Set<String>> {
  bool _hasInitialized = false;
  Set<String> _knownItemIds = <String>{};

  SelectedCartItemIdsNotifier([Set<String>? initial])
      : _hasInitialized = initial != null,
        super(initial ?? <String>{}) {
    if (initial != null) {
      _knownItemIds = Set<String>.from(initial);
    }
  }

  bool get hasInitialized => _hasInitialized;

  /// Đồng bộ danh sách chọn với các mặt hàng hiện tại trong giỏ hàng
  void syncWithCart(List<CartItemModel> items) {
    final validInStockIds =
        items.where((i) => i.inStock).map((i) => i.id).toSet();
    final allCurrentIds = items.map((i) => i.id).toSet();

    if (!_hasInitialized) {
      _hasInitialized = true;
      _knownItemIds = allCurrentIds;
      // Lần đầu vào giỏ: Mặc định chọn tất cả các sản phẩm còn hàng
      state = validInStockIds;
    } else {
      // Nhận diện sản phẩm mới vừa được thêm vào giỏ để tự động tick chọn
      final newlyAddedIds = validInStockIds.difference(_knownItemIds);
      _knownItemIds = allCurrentIds;
      // Giữ lại các mục người dùng đã chọn trước đó (nếu còn hàng) + mục mới thêm
      state = state.intersection(validInStockIds).union(newlyAddedIds);
    }
  }

  /// Đảo trạng thái chọn của một sản phẩm
  void toggle(String itemId) {
    _hasInitialized = true;
    if (state.contains(itemId)) {
      state = Set<String>.from(state)..remove(itemId);
    } else {
      state = Set<String>.from(state)..add(itemId);
    }
  }

  /// Chọn tất cả các sản phẩm còn hàng
  void selectAll(List<CartItemModel> items) {
    _hasInitialized = true;
    state = items.where((i) => i.inStock).map((i) => i.id).toSet();
  }

  /// Bỏ chọn tất cả các sản phẩm
  void deselectAll() {
    _hasInitialized = true;
    state = <String>{};
  }

  /// Loại bỏ các mục đã hoàn tất đặt hàng khỏi danh sách chọn
  void removeItems(Iterable<String> itemIds) {
    final set = Set<String>.from(state)..removeAll(itemIds);
    _knownItemIds.removeAll(itemIds);
    state = set;
  }

  /// Đặt lại trạng thái ban đầu
  void reset() {
    _hasInitialized = false;
    _knownItemIds = <String>{};
    state = <String>{};
  }
}

/// Provider cung cấp StateNotifier của danh sách ID sản phẩm được chọn
final selectedCartItemIdsProvider =
    StateNotifierProvider<SelectedCartItemIdsNotifier, Set<String>>((ref) {
  final notifier = SelectedCartItemIdsNotifier();

  // Khởi tạo ngay nếu cartNotifierProvider đã có sẵn dữ liệu
  final initialCart = ref.read(cartNotifierProvider);
  initialCart.whenData((items) {
    notifier.syncWithCart(items);
  });

  // Lắng nghe các thay đổi tiếp theo của giỏ hàng
  ref.listen<AsyncValue<List<CartItemModel>>>(cartNotifierProvider,
      (previous, next) {
    next.whenData((items) {
      notifier.syncWithCart(items);
    });
  });

  return notifier;
});

/// Provider trả về danh sách các sản phẩm đang được chọn và còn hàng hợp lệ
final selectedCartItemsProvider = Provider<List<CartItemModel>>((ref) {
  final cartState = ref.watch(cartNotifierProvider);
  final selectedIds = ref.watch(selectedCartItemIdsProvider);

  return cartState.maybeWhen(
    data: (items) {
      return items
          .where((item) => selectedIds.contains(item.id) && item.inStock)
          .toList();
    },
    orElse: () => [],
  );
});

/// Provider tính tổng tiền tạm tính cho các sản phẩm ĐƯỢC CHỌN (Subtotal for Selected Items)
final selectedCartSubtotalProvider = Provider<int>((ref) {
  final selectedItems = ref.watch(selectedCartItemsProvider);
  return selectedItems.fold<int>(0, (sum, item) => sum + item.lineTotal);
});

/// Provider đếm số lượng mặt hàng đang được chọn
final selectedCartItemCountProvider = Provider<int>((ref) {
  final selectedItems = ref.watch(selectedCartItemsProvider);
  return selectedItems.length;
});

/// Provider kiểm tra xem toàn bộ các sản phẩm còn hàng trong giỏ đã được chọn hay chưa
final isAllCartItemsSelectedProvider = Provider<bool>((ref) {
  final cartState = ref.watch(cartNotifierProvider);
  final selectedIds = ref.watch(selectedCartItemIdsProvider);

  return cartState.maybeWhen(
    data: (items) {
      final inStockItems = items.where((i) => i.inStock).toList();
      if (inStockItems.isEmpty) return false;
      return inStockItems.every((item) => selectedIds.contains(item.id));
    },
    orElse: () => false,
  );
});
