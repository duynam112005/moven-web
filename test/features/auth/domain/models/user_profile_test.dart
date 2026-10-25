import 'package:flutter_test/flutter_test.dart';
import 'package:moven/features/auth/domain/models/user_profile.dart';

void main() {
  group('UserProfile Model Tests', () {
    final now = DateTime.parse('2026-10-25T10:00:00.000Z');

    final sampleJson = {
      'id': 'usr-12345',
      'full_name': 'Nguyễn Văn A',
      'phone': '0901234567',
      'role': 'customer',
      'avatar_path': 'avatars/usr-12345.png',
      'created_at': '2026-10-25T10:00:00.000Z',
      'updated_at': '2026-10-25T10:00:00.000Z',
    };

    test('1. fromJson maps all fields correctly', () {
      final profile = UserProfile.fromJson(sampleJson);

      expect(profile.id, 'usr-12345');
      expect(profile.fullName, 'Nguyễn Văn A');
      expect(profile.phone, '0901234567');
      expect(profile.role, 'customer');
      expect(profile.avatarPath, 'avatars/usr-12345.png');
      expect(profile.createdAt, now);
      expect(profile.updatedAt, now);
      expect(profile.isCustomer, isTrue);
      expect(profile.isAdmin, isFalse);
    });

    test('2. fromJson handles null/missing optional fields with defaults', () {
      final minimalJson = {
        'id': 'usr-99999',
      };

      final profile = UserProfile.fromJson(minimalJson);

      expect(profile.id, 'usr-99999');
      expect(profile.fullName, '');
      expect(profile.phone, isNull);
      expect(profile.role, 'customer');
      expect(profile.avatarPath, isNull);
      expect(profile.isCustomer, isTrue);
      expect(profile.isAdmin, isFalse);
    });

    test('3. isAdmin returns true when role is admin', () {
      final adminProfile = UserProfile(
        id: 'adm-001',
        fullName: 'Admin User',
        role: 'admin',
        createdAt: now,
        updatedAt: now,
      );

      expect(adminProfile.isAdmin, isTrue);
      expect(adminProfile.isCustomer, isFalse);
    });

    test(
      '4. Security invariant: toUpdateJson() strictly excludes "role" and "id"',
      () {
        final profile = UserProfile.fromJson(sampleJson);
        final updateJson = profile.toUpdateJson();

        // Must ONLY contain editable personal fields
        expect(updateJson.containsKey('full_name'), isTrue);
        expect(updateJson.containsKey('phone'), isTrue);
        expect(updateJson.containsKey('avatar_path'), isTrue);

        // MUST NOT contain role or id under any circumstances
        expect(updateJson.containsKey('role'), isFalse);
        expect(updateJson.containsKey('id'), isFalse);
        expect(updateJson.containsKey('created_at'), isFalse);
        expect(updateJson.containsKey('updated_at'), isFalse);
      },
    );

    test('5. copyWith creates an updated instance while preserving others', () {
      final profile = UserProfile.fromJson(sampleJson);
      final updated = profile.copyWith(fullName: 'Nguyễn Văn B');

      expect(updated.id, profile.id);
      expect(updated.fullName, 'Nguyễn Văn B');
      expect(updated.phone, profile.phone);
      expect(updated.role, profile.role);
    });

    test('6. Equality and hashCode work as expected', () {
      final p1 = UserProfile.fromJson(sampleJson);
      final p2 = UserProfile.fromJson(sampleJson);

      expect(p1, equals(p2));
      expect(p1.hashCode, equals(p2.hashCode));
    });
  });
}
