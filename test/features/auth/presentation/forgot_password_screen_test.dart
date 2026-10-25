import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moven/features/auth/presentation/forgot_password_screen.dart';

void main() {
  group('ForgotPasswordScreen Widget Tests', () {
    testWidgets('1. Renders forgot password form with email field', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ForgotPasswordScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Khôi phục mật khẩu'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Gửi email khôi phục'), findsOneWidget);
      expect(find.text('Quay lại đăng nhập'), findsOneWidget);
    });

    testWidgets('2. Validates empty email field', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ForgotPasswordScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Gửi email khôi phục'));
      await tester.pumpAndSettle();

      expect(find.text('Vui lòng nhập địa chỉ email'), findsOneWidget);
    });

    testWidgets('3. Validates email without @ symbol', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ForgotPasswordScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'plainaddress');
      await tester.tap(find.text('Gửi email khôi phục'));
      await tester.pumpAndSettle();

      expect(find.text('Email không đúng định dạng'), findsOneWidget);
    });
  });
}
