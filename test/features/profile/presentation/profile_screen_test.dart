import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moven/core/network/supabase_client.dart';
import 'package:moven/features/auth/domain/models/user_profile.dart';
import 'package:moven/features/profile/domain/models/address.dart';
import 'package:moven/features/profile/presentation/profile_screen.dart';

void main() {
  group('ProfileScreen Widget Tests', () {
    final mockProfile = UserProfile(
      id: 'usr-test-123',
      fullName: 'Nguyễn Văn Test',
      phone: '0901234567',
      role: 'customer',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final mockAddresses = [
      Address(
        id: 'addr-1',
        userId: 'usr-test-123',
        recipientName: 'Nguyễn Văn Test',
        phone: '0901234567',
        province: 'TP. Hồ Chí Minh',
        district: 'Quận 1',
        ward: 'Phường Bến Nghé',
        addressLine: '123 Đường Lê Lợi',
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    testWidgets('1. Renders profile info and addresses when loaded', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userProfileProvider.overrideWith((ref) => Future.value(mockProfile)),
            userAddressesProvider.overrideWith((ref) => Future.value(mockAddresses)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ProfileScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nguyễn Văn Test'), findsWidgets);
      expect(find.text('0901234567'), findsWidgets);
      expect(find.text('Sổ địa chỉ'), findsOneWidget);
      expect(find.text('Thêm địa chỉ'), findsOneWidget);
      expect(find.text('Mặc định'), findsOneWidget);
      expect(find.text('Đăng xuất'), findsOneWidget);
    });

    testWidgets('2. Renders empty address state when user has no addresses', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userProfileProvider.overrideWith((ref) => Future.value(mockProfile)),
            userAddressesProvider.overrideWith((ref) => Future.value([])),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ProfileScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Chưa có địa chỉ giao hàng nào. Thêm địa chỉ để mua hàng nhanh hơn.',
        ),
        findsOneWidget,
      );
    });
  });
}
