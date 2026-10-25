import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moven/features/auth/presentation/login_screen.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    setUp(() {
      // Common setup if needed
    });

    testWidgets('1. Renders login form with email and password fields', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LoginScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Đăng nhập tài khoản'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Mật khẩu'), findsOneWidget);
      expect(find.text('Đăng nhập'), findsOneWidget);
      expect(find.text('Quên mật khẩu?'), findsOneWidget);
      expect(find.text('Đăng ký ngay'), findsOneWidget);
    });

    testWidgets('2. Validates empty inputs on submit', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LoginScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap "Đăng nhập" without filling inputs
      await tester.ensureVisible(find.text('Đăng nhập'));
      await tester.tap(find.text('Đăng nhập'));
      await tester.pumpAndSettle();

      expect(find.text('Vui lòng nhập địa chỉ email'), findsOneWidget);
      expect(find.text('Mật khẩu tối thiểu 6 ký tự'), findsOneWidget);
    });

    testWidgets('3. Validates invalid email format', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LoginScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).first,
        'not-an-email',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        '123456',
      );

      await tester.ensureVisible(find.text('Đăng nhập'));
      await tester.tap(find.text('Đăng nhập'));
      await tester.pumpAndSettle();

      expect(find.text('Email không đúng định dạng'), findsOneWidget);
    });
  });
}
