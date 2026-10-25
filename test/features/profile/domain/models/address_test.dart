import 'package:flutter_test/flutter_test.dart';
import 'package:moven/features/profile/domain/models/address.dart';

void main() {
  group('Address Model Tests', () {
    final now = DateTime.parse('2026-10-25T10:00:00.000Z');

    final sampleJson = {
      'id': 'addr-001',
      'user_id': 'usr-12345',
      'recipient_name': 'Nguyễn Văn A',
      'phone': '0901234567',
      'province': 'TP. Hồ Chí Minh',
      'district': 'Quận 1',
      'ward': 'Phường Bến Nghé',
      'address_line': '123 Đường Lê Lợi',
      'is_default': true,
      'created_at': '2026-10-25T10:00:00.000Z',
      'updated_at': '2026-10-25T10:00:00.000Z',
    };

    test('1. fromJson maps all fields correctly', () {
      final address = Address.fromJson(sampleJson);

      expect(address.id, 'addr-001');
      expect(address.userId, 'usr-12345');
      expect(address.recipientName, 'Nguyễn Văn A');
      expect(address.phone, '0901234567');
      expect(address.province, 'TP. Hồ Chí Minh');
      expect(address.district, 'Quận 1');
      expect(address.ward, 'Phường Bến Nghé');
      expect(address.addressLine, '123 Đường Lê Lợi');
      expect(address.isDefault, isTrue);
      expect(address.createdAt, now);
      expect(address.updatedAt, now);
    });

    test('2. formattedAddress concatenates all address levels in order', () {
      final address = Address.fromJson(sampleJson);

      expect(
        address.formattedAddress,
        '123 Đường Lê Lợi, Phường Bến Nghé, Quận 1, TP. Hồ Chí Minh',
      );
    });

    test('3. toInsertJson contains user_id and address fields', () {
      final address = Address.fromJson(sampleJson);
      final insertJson = address.toInsertJson();

      expect(insertJson['user_id'], 'usr-12345');
      expect(insertJson['recipient_name'], 'Nguyễn Văn A');
      expect(insertJson['phone'], '0901234567');
      expect(insertJson['province'], 'TP. Hồ Chí Minh');
      expect(insertJson['district'], 'Quận 1');
      expect(insertJson['ward'], 'Phường Bến Nghé');
      expect(insertJson['address_line'], '123 Đường Lê Lợi');
      expect(insertJson['is_default'], isTrue);
      // toInsertJson should not include id, created_at, updated_at
      expect(insertJson.containsKey('id'), isFalse);
    });

    test('4. toUpdateJson excludes user_id and id', () {
      final address = Address.fromJson(sampleJson);
      final updateJson = address.toUpdateJson();

      expect(updateJson.containsKey('user_id'), isFalse);
      expect(updateJson.containsKey('id'), isFalse);
      expect(updateJson['recipient_name'], 'Nguyễn Văn A');
      expect(updateJson['is_default'], isTrue);
    });

    test('5. copyWith updates fields correctly', () {
      final address = Address.fromJson(sampleJson);
      final updated = address.copyWith(
        recipientName: 'Trần Thị B',
        isDefault: false,
      );

      expect(updated.id, address.id);
      expect(updated.recipientName, 'Trần Thị B');
      expect(updated.isDefault, isFalse);
      expect(updated.phone, address.phone);
    });

    test('6. Equality and hashCode work as expected', () {
      final a1 = Address.fromJson(sampleJson);
      final a2 = Address.fromJson(sampleJson);

      expect(a1, equals(a2));
      expect(a1.hashCode, equals(a2.hashCode));
    });
  });
}
