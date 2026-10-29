import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

import '../../data/auth_repository.dart';

/// State cho các form xác thực: loading, error, success message, và trạng thái session
class AuthFormState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final bool hasSession;

  const AuthFormState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.hasSession = false,
  });

  AuthFormState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool? hasSession,
  }) {
    return AuthFormState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      hasSession: hasSession ?? this.hasSession,
    );
  }
}

/// Riverpod Notifier quản lý trạng thái Auth (login/register/forgot password)
class AuthController extends StateNotifier<AuthFormState> {
  final AuthRepository _authRepository;

  AuthController(this._authRepository) : super(const AuthFormState());

  /// Đăng ký tài khoản mới.
  ///
  /// Trả về `true` nếu thành công.
  /// Cập nhật `hasSession = true` nếu Supabase tự động cấp phiên đăng nhập ngay.
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    state = const AuthFormState(isLoading: true);
    try {
      final response = await _authRepository.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );

      final identities = response.user?.identities;
      if (response.user != null && identities != null && identities.isEmpty) {
        state = const AuthFormState(
          errorMessage: 'Email này đã được đăng ký. Vui lòng đăng nhập.',
        );
        return false;
      }

      final hasSession = response.session != null;
      state = AuthFormState(
        hasSession: hasSession,
        successMessage: hasSession
            ? 'Đăng ký thành công! Chào mừng bạn đến với MOVEN.'
            : 'Đăng ký thành công! Vui lòng kiểm tra email để xác thực tài khoản.',
      );
      return true;
    } on AuthException catch (e) {
      state = AuthFormState(errorMessage: _mapAuthError(e.message));
      return false;
    } catch (_) {
      state = const AuthFormState(
        errorMessage: 'Đã xảy ra lỗi. Vui lòng thử lại.',
      );
      return false;
    }
  }

  /// Đăng nhập bằng email và mật khẩu.
  ///
  /// Trả về `true` nếu đăng nhập thành công.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = const AuthFormState(isLoading: true);
    try {
      await _authRepository.signInWithPassword(
        email: email,
        password: password,
      );
      state = const AuthFormState();
      return true;
    } on AuthException catch (e) {
      state = AuthFormState(errorMessage: _mapAuthError(e.message));
      return false;
    } catch (_) {
      state = const AuthFormState(
        errorMessage: 'Đăng nhập không thành công. Vui lòng kiểm tra lại thông tin.',
      );
      return false;
    }
  }

  /// Gửi email khôi phục mật khẩu.
  ///
  /// Nhận `redirectTo` tuỳ chọn để định hướng lại người dùng sau khi xác nhận trong email.
  /// Trả về `true` nếu email được gửi thành công.
  Future<bool> sendPasswordResetEmail(
    String email, {
    String? redirectTo,
  }) async {
    state = const AuthFormState(isLoading: true);
    try {
      await _authRepository.resetPasswordForEmail(
        email,
        redirectTo: redirectTo,
      );
      state = const AuthFormState(
        successMessage:
            'Email khôi phục đã được gửi. Vui lòng kiểm tra hộp thư của bạn.',
      );
      return true;
    } on AuthException catch (e) {
      state = AuthFormState(errorMessage: _mapAuthError(e.message));
      return false;
    } catch (_) {
      state = const AuthFormState(
        errorMessage: 'Không thể gửi email khôi phục. Vui lòng thử lại.',
      );
      return false;
    }
  }

  /// Đặt lại mật khẩu mới (sau khi nhấn link trong email).
  ///
  /// Sau khi cập nhật thành công, tự động đăng xuất phiên tạm để dọn sạch recovery session.
  /// Trả về `true` nếu cập nhật mật khẩu thành công.
  Future<bool> updatePassword(String newPassword) async {
    state = const AuthFormState(isLoading: true);
    try {
      await _authRepository.updatePassword(newPassword);
      try {
        await _authRepository.signOut();
      } catch (_) {
        // Đảm bảo không để lỗi signOut làm gián đoạn trạng thái thành công
      }
      state = const AuthFormState(
        successMessage: 'Mật khẩu đã được cập nhật thành công.',
      );
      return true;
    } on AuthException catch (e) {
      state = AuthFormState(errorMessage: _mapAuthError(e.message));
      return false;
    } catch (_) {
      state = const AuthFormState(
        errorMessage: 'Không thể cập nhật mật khẩu. Vui lòng thử lại.',
      );
      return false;
    }
  }

  /// Xóa thông báo lỗi/thành công hiện tại
  void clearMessages() {
    state = const AuthFormState();
  }

  /// Ánh xạ thông báo lỗi Supabase Auth sang tiếng Việt thân thiện
  String _mapAuthError(String? message) {
    final msg = message?.toLowerCase() ?? '';
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid email or password')) {
      return 'Email hoặc mật khẩu không đúng.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Tài khoản chưa được xác thực. Vui lòng kiểm tra email.';
    }
    if (msg.contains('user already registered') ||
        msg.contains('already registered')) {
      return 'Email này đã được đăng ký. Vui lòng đăng nhập.';
    }
    if (msg.contains('password should be at least')) {
      return 'Mật khẩu phải có ít nhất 6 ký tự.';
    }
    if (msg.contains('rate limit') || msg.contains('too many requests')) {
      return 'Quá nhiều yêu cầu. Vui lòng thử lại sau.';
    }
    return message ?? 'Đã xảy ra lỗi. Vui lòng thử lại.';
  }
}

/// Provider cho AuthController
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthFormState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository);
});
