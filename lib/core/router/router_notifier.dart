import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/supabase_client.dart';

/// Provider cung cấp RouterNotifier để đồng bộ trạng thái đăng nhập với GoRouter
final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

/// Lớp lắng nghe thay đổi trạng thái xác thực và quyền người dùng để trigger làm mới GoRouter
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authStateChangesProvider, (_, __) => notifyListeners());
    _ref.listen(userRoleProvider, (_, __) => notifyListeners());
  }
}
