import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

/// Provider cung cấp SupabaseClient toàn cục
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  if (!AppConfig.isSupabaseConfigured) {
    // Nếu chưa cấu hình credentials thực tế, ném state rõ ràng để UI biết
    throw StateError(
      'Supabase chưa được cấu hình. Vui lòng cung cấp SUPABASE_URL và SUPABASE_ANON_KEY.',
    );
  }
  try {
    return Supabase.instance.client;
  } catch (e) {
    throw StateError('Supabase chưa được khởi tạo: $e');
  }
});

/// Provider lắng nghe thay đổi trạng thái xác thực (Auth State Changes)
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  if (!AppConfig.isSupabaseConfigured) {
    return const Stream.empty();
  }
  try {
    final client = Supabase.instance.client;
    return client.auth.onAuthStateChange;
  } catch (_) {
    return const Stream.empty();
  }
});

/// Provider cung cấp thông tin người dùng hiện tại (nếu đã đăng nhập)
final currentUserProvider = Provider<User?>((ref) {
  if (!AppConfig.isSupabaseConfigured) return null;
  try {
    // Lắng nghe thay đổi auth để tự động cập nhật user
    ref.watch(authStateChangesProvider);
    final client = Supabase.instance.client;
    return client.auth.currentUser;
  } catch (_) {
    return null;
  }
});

/// Provider kiểm tra trạng thái đăng nhập
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

/// Provider lưu giữ role người dùng hiện hành ('customer' hoặc 'admin').
/// Mặc định 'customer'; được đồng bộ khi fetch profile tin cậy từ database.
final userRoleProvider = StateProvider<String>((ref) {
  return 'customer';
});

/// Provider kiểm tra quyền Admin đáng tin cậy
final isAdminProvider = Provider<bool>((ref) {
  final isAuth = ref.watch(isAuthenticatedProvider);
  final role = ref.watch(userRoleProvider);
  return isAuth && role == 'admin';
});
