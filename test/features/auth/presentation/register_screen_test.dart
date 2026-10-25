import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moven/features/auth/presentation/register_screen.dart';

void main() {
  group('RegisterScreen Widget Tests', () {
    testWidgets('1. Renders registration form fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: RegisterScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tạo tài khoản MOVEN'), findsOneWidget);
      expect(find.text('Họ và tên *'), findsOneWidget);
      expect(find.text('Email *'), findsOneWidget);
      expect(find.text('Số điện thoại'), findsOneWidget);
      expect(find.text('Mật khẩu *'), findsOneWidget);
      expect(find.text('Xác nhận mật khẩu *'), findsOneWidget);
      expect(find.text('Đăng ký'), findsOneWidget);
      expect(find.text('Đã có tài khoản? '), findsOneWidget);
    });

    testWidgets('2. Validates empty required fields', (
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
              body: RegisterScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Đăng ký'));
      await tester.tap(find.text('Đăng ký'));
      await tester.pumpAndSettle();

      expect(find.text('Vui lòng nhập họ và tên'), findsOneWidget);
      expect(find.text('Vui lòng nhập địa chỉ email'), findsOneWidget);
      expect(find.text('Mật khẩu tối thiểu 6 ký tự'), findsOneWidget);
    });

    testWidgets('3. Validates password mismatch', (
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
              body: RegisterScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter valid name, email, password, but mismatched confirmation
      final textFields = find.byType(EditableText);
      await tester.enterText(textFields.at(0), 'Nguyễn Văn A');
      await tester.enterText(textFields.at(1), 'nguyenvana@example.com');
      await tester.enterText(textFields.at(3), '123456');
      await tester.enterText(textFields.at(4), '654321');

      await tester.tap(find.text('Đăng ký'));
      await tester.pumpAndSettle();

      expect(find.text('Mật khẩu xác nhận không khớp'), findsOneWidget);
    });
  });
}
