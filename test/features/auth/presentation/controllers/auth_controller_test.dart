import 'package:flutter_test/flutter_test.dart';
import 'package:moven/features/auth/data/auth_repository.dart';
import 'package:moven/features/auth/presentation/controllers/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Fake implementation of AuthRepository to test AuthController in isolation
class FakeAuthRepository implements AuthRepository {
  bool shouldThrow = false;
  String? exceptionMessage;

  @override
  User? get currentUser => null;

  Session? returnSession;
  User? returnUser;

  @override
  Stream<AuthState> get authStateChanges => const Stream.empty();

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    if (shouldThrow) {
      throw AuthException(exceptionMessage ?? 'User already registered');
    }
    return AuthResponse(user: returnUser, session: returnSession);
  }

  @override
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    if (shouldThrow) {
      throw AuthException(exceptionMessage ?? 'Invalid login credentials');
    }
    return AuthResponse();
  }

  @override
  Future<void> signOut() async {
    if (shouldThrow) {
      throw const AuthException('Sign out error');
    }
  }

  @override
  Future<void> resetPasswordForEmail(String email) async {
    if (shouldThrow) {
      throw AuthException(exceptionMessage ?? 'Rate limit exceeded');
    }
  }

  @override
  Future<UserResponse> updatePassword(String newPassword) async {
    if (shouldThrow) {
      throw AuthException(exceptionMessage ?? 'Password too short');
    }
    return UserResponse.fromJson({});
  }
}

void main() {
  group('AuthController Tests', () {
    late FakeAuthRepository fakeRepo;
    late AuthController controller;

    setUp(() {
      fakeRepo = FakeAuthRepository();
      controller = AuthController(fakeRepo);
    });

    test('1. Initial state is not loading with no messages', () {
      expect(controller.state.isLoading, isFalse);
      expect(controller.state.errorMessage, isNull);
      expect(controller.state.successMessage, isNull);
    });

    test('2. login succeeds with correct credentials', () async {
      final success = await controller.login(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(success, isTrue);
      expect(controller.state.isLoading, isFalse);
      expect(controller.state.errorMessage, isNull);
    });

    test('3. login maps invalid credentials error to friendly Vietnamese', () async {
      fakeRepo.shouldThrow = true;
      fakeRepo.exceptionMessage = 'Invalid login credentials';

      final success = await controller.login(
        email: 'wrong@example.com',
        password: 'badpassword',
      );

      expect(success, isFalse);
      expect(controller.state.isLoading, isFalse);
      expect(
        controller.state.errorMessage,
        'Email hoặc mật khẩu không đúng.',
      );
    });

    test('4. register maps existing email error correctly', () async {
      fakeRepo.shouldThrow = true;
      fakeRepo.exceptionMessage = 'User already registered';

      final success = await controller.register(
        email: 'existing@example.com',
        password: 'password123',
        fullName: 'Nguyễn Văn A',
      );

      expect(success, isFalse);
      expect(controller.state.isLoading, isFalse);
      expect(
        controller.state.errorMessage,
        'Email này đã được đăng ký. Vui lòng đăng nhập.',
      );
    });

    test('5. register success shows confirmation message', () async {
      final success = await controller.register(
        email: 'newuser@example.com',
        password: 'password123',
        fullName: 'Người Mới',
      );

      expect(success, isTrue);
      expect(controller.state.isLoading, isFalse);
      expect(controller.state.hasSession, isFalse);
      expect(
        controller.state.successMessage,
        contains('Vui lòng kiểm tra email'),
      );
    });

    test('5b. register success with auto-confirmed session sets hasSession = true', () async {
      fakeRepo.returnSession = Session(
        accessToken: 'mock-access-token',
        tokenType: 'bearer',
        user: const User(
          id: 'usr-auto-123',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: '2026-10-25T12:00:00Z',
        ),
      );

      final success = await controller.register(
        email: 'autoconfirm@example.com',
        password: 'password123',
        fullName: 'Người Tự Động',
      );

      expect(success, isTrue);
      expect(controller.state.isLoading, isFalse);
      expect(controller.state.hasSession, isTrue);
      expect(
        controller.state.successMessage,
        contains('Đăng ký thành công!'),
      );
    });

    test('5c. register with empty identities detects duplicate email due to enumeration protection', () async {
      fakeRepo.returnUser = const User(
        id: 'usr-existing-123',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: '2026-10-25T12:00:00Z',
        identities: [],
      );

      final success = await controller.register(
        email: 'duynamd33@gmail.com',
        password: 'password123',
        fullName: 'Duy Nam',
      );

      expect(success, isFalse);
      expect(controller.state.isLoading, isFalse);
      expect(
        controller.state.errorMessage,
        'Email này đã được đăng ký. Vui lòng đăng nhập.',
      );
    });

    test('6. sendPasswordResetEmail success and error handling', () async {
      // Success
      final ok = await controller.sendPasswordResetEmail('user@example.com');
      expect(ok, isTrue);
      expect(
        controller.state.successMessage,
        contains('Email khôi phục đã được gửi'),
      );

      // Error
      fakeRepo.shouldThrow = true;
      fakeRepo.exceptionMessage = 'Too many requests';
      final fail = await controller.sendPasswordResetEmail('user@example.com');
      expect(fail, isFalse);
      expect(
        controller.state.errorMessage,
        'Quá nhiều yêu cầu. Vui lòng thử lại sau.',
      );
    });

    test('7. updatePassword updates password and maps success message', () async {
      final ok = await controller.updatePassword('newsecurepass123');
      expect(ok, isTrue);
      expect(
        controller.state.successMessage,
        contains('Mật khẩu đã được cập nhật thành công'),
      );
    });

    test('8. clearMessages resets error and success messages', () {
      controller.clearMessages();
      expect(controller.state.errorMessage, isNull);
      expect(controller.state.successMessage, isNull);
    });
  });
}
