import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moven/core/network/supabase_client.dart';
import 'package:moven/core/router/router_notifier.dart';
import 'package:moven/features/auth/data/auth_repository.dart';
import 'package:moven/features/auth/presentation/controllers/auth_controller.dart';
import 'package:moven/features/auth/presentation/reset_password_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeResetAuthRepository implements AuthRepository {
  bool updatePasswordCalled = false;
  bool signOutCalled = false;

  @override
  User? get currentUser => null;

  @override
  Stream<AuthState> get authStateChanges => const Stream.empty();

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) async =>
      AuthResponse();

  @override
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async =>
      AuthResponse();

  @override
  Future<void> signOut() async {
    signOutCalled = true;
  }

  @override
  Future<void> resetPasswordForEmail(String email, {String? redirectTo}) async {}

  @override
  Future<UserResponse> updatePassword(String newPassword) async {
    updatePasswordCalled = true;
    return UserResponse.fromJson({});
  }
}

void main() {
  group('ResetPasswordScreen Widget Tests', () {
    late FakeResetAuthRepository fakeRepo;

    setUp(() {
      fakeRepo = FakeResetAuthRepository();
    });

    testWidgets('1. Shows invalid or expired link view when unauthenticated and not in recovery', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeRepo),
            currentUserProvider.overrideWithValue(null),
            isPasswordRecoveryProvider.overrideWith((ref) => false),
            authStateChangesProvider.overrideWith(
              (ref) => Stream.value(
                AuthState(AuthChangeEvent.initialSession, null),
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ResetPasswordScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Liên kết không hợp lệ hoặc đã hết hạn'), findsOneWidget);
      expect(find.text('Yêu cầu liên kết mới'), findsOneWidget);
      expect(find.text('Quay lại đăng nhập'), findsOneWidget);
    });

    testWidgets('2. Shows reset form when in recovery mode', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeRepo),
            currentUserProvider.overrideWithValue(null),
            isPasswordRecoveryProvider.overrideWith((ref) => true),
            authStateChangesProvider.overrideWith(
              (ref) => Stream.value(
                AuthState(AuthChangeEvent.initialSession, null),
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ResetPasswordScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Đặt mật khẩu mới'), findsOneWidget);
      expect(find.text('Mật khẩu mới'), findsOneWidget);
      expect(find.text('Xác nhận mật khẩu mới'), findsOneWidget);
      expect(find.text('Cập nhật mật khẩu'), findsOneWidget);
    });

    testWidgets('3. Validates password mismatch and min length', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeRepo),
            currentUserProvider.overrideWithValue(null),
            isPasswordRecoveryProvider.overrideWith((ref) => true),
            authStateChangesProvider.overrideWith(
              (ref) => Stream.value(
                AuthState(AuthChangeEvent.initialSession, null),
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ResetPasswordScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter short password
      await tester.enterText(find.byType(TextFormField).first, '123');
      await tester.enterText(find.byType(TextFormField).last, '123');
      await tester.tap(find.text('Cập nhật mật khẩu'));
      await tester.pumpAndSettle();

      expect(find.text('Mật khẩu tối thiểu 6 ký tự'), findsOneWidget);

      // Enter mismatched password
      await tester.enterText(find.byType(TextFormField).first, 'password123');
      await tester.enterText(find.byType(TextFormField).last, 'mismatch456');
      await tester.tap(find.text('Cập nhật mật khẩu'));
      await tester.pumpAndSettle();

      expect(find.text('Mật khẩu xác nhận không khớp'), findsOneWidget);
    });

    testWidgets('4. Submits successfully and displays success view', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeRepo),
            currentUserProvider.overrideWithValue(null),
            isPasswordRecoveryProvider.overrideWith((ref) => true),
            authStateChangesProvider.overrideWith(
              (ref) => Stream.value(
                AuthState(AuthChangeEvent.initialSession, null),
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ResetPasswordScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'newpassword123');
      await tester.enterText(find.byType(TextFormField).last, 'newpassword123');
      await tester.tap(find.text('Cập nhật mật khẩu'));
      await tester.pumpAndSettle();

      expect(fakeRepo.updatePasswordCalled, isTrue);
      expect(fakeRepo.signOutCalled, isTrue);
      expect(find.text('Mật khẩu đã được cập nhật'), findsOneWidget);
      expect(find.text('Đăng nhập'), findsOneWidget);
    });
  });
}
