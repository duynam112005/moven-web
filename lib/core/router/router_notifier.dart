import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../network/supabase_client.dart';

/// Provider đánh dấu trạng thái người dùng đang trong luồng đặt lại mật khẩu từ email khôi phục
final isPasswordRecoveryProvider = StateProvider<bool>((ref) => false);

/// Provider cung cấp RouterNotifier để đồng bộ trạng thái đăng nhập với GoRouter
final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

/// Lớp lắng nghe thay đổi trạng thái xác thực và quyền người dùng để trigger làm mới GoRouter
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<AuthState>>(authStateChangesProvider, (_, next) {
      final event = next.value?.event;
      if (event == AuthChangeEvent.passwordRecovery) {
        _ref.read(isPasswordRecoveryProvider.notifier).state = true;
      } else if (event == AuthChangeEvent.signedOut) {
        _ref.read(isPasswordRecoveryProvider.notifier).state = false;
      }
      scheduleMicrotask(notifyListeners);
    });
    _ref.listen(userRoleProvider, (_, __) {
      scheduleMicrotask(notifyListeners);
    });
  }
}
