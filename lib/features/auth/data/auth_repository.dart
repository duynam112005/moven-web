import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/network/supabase_client.dart';

/// Provider cung cấp AuthRepository với fallback an toàn khi chưa cấu hình Supabase
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  try {
    final client = ref.watch(supabaseClientProvider);
    return AuthRepository(client);
  } catch (_) {
    return const AuthRepository();
  }
});

/// Repository xử lý nghiệp vụ xác thực người dùng qua Supabase Auth
class AuthRepository {
  final SupabaseClient? _client;

  const AuthRepository([this._client]);

  SupabaseClient get _safeClient {
    final client = _client;
    if (client != null) return client;
    throw StateError('Supabase chưa được cấu hình.');
  }

  /// Người dùng hiện tại
  User? get currentUser {
    try {
      return _client?.auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  /// Stream lắng nghe thay đổi trạng thái xác thực
  Stream<AuthState> get authStateChanges {
    try {
      return _client?.auth.onAuthStateChange ?? const Stream.empty();
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Đăng ký tài khoản mới bằng email và mật khẩu.
  ///
  /// Chỉ truyền `full_name` và `phone` vào metadata — tuyệt đối không truyền `role`.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    final response = await _safeClient.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        if (fullName != null && fullName.trim().isNotEmpty)
          'full_name': fullName.trim(),
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
      },
    );

    // Xử lý cơ chế Email Enumeration Protection của Supabase:
    // Khi email đã tồn tại trong hệ thống, Supabase trả về User với `identities: []` thay vì ném ngoại lệ.
    final identities = response.user?.identities;
    if (response.user != null && identities != null && identities.isEmpty) {
      throw const AuthException('User already registered');
    }

    // Nếu Supabase cấp session ngay (Confirm Email = OFF), tự động đảm bảo tạo profile
    if (response.user != null && response.session != null) {
      try {
        await _safeClient.from('profiles').upsert({
          'id': response.user!.id,
          'full_name': (fullName ?? '').trim(),
          if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
          'role': 'customer',
        });
      } catch (_) {
        // Trigger DB có thể đã chạy hoặc network chậm; không cản trở signup
      }
    }

    return response;
  }


  /// Đăng nhập bằng email và mật khẩu
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    return await _safeClient.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Đăng xuất khỏi hệ thống
  Future<void> signOut() async {
    await _safeClient.auth.signOut();
  }

  /// Gửi email khôi phục mật khẩu.
  ///
  /// Nhận `redirectTo` tuỳ chọn để chỉ định URL quay lại sau khi người dùng nhấn xác nhận trong email.
  Future<void> resetPasswordForEmail(
    String email, {
    String? redirectTo,
  }) async {
    await _safeClient.auth.resetPasswordForEmail(
      email.trim(),
      redirectTo: redirectTo,
    );
  }

  /// Cập nhật mật khẩu mới cho phiên hiện tại
  Future<UserResponse> updatePassword(String newPassword) async {
    return await _safeClient.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }
}
