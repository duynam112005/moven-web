import 'package:flutter_test/flutter_test.dart';
import 'package:moven/features/settings/domain/models/store_settings.dart';

void main() {
  group('StoreSettings Domain Model Tests', () {
    test('default values conform to ADR-0005 specifications', () {
      const settings = StoreSettings();

      expect(settings.storeName, 'MOVEN');
      expect(settings.defaultShippingFee, 20000);
      expect(settings.lowStockThreshold, 5);
      expect(settings.contactEmail, 'contact@moven.vn');
      expect(settings.contactPhone, '0901234567');
      expect(settings.logoPath, isNull);
      expect(settings.updatedAt, isNull);
    });

    test('fromJson and toJson deserialize and serialize correctly', () {
      final json = {
        'store_name': 'MOVEN STORE',
        'default_shipping_fee': 25000,
        'low_stock_threshold': 10,
        'contact_email': 'hello@moven.vn',
        'contact_phone': '0988776655',
        'logo_path': 'brand/logo.png',
        'updated_at': '2026-10-26T10:00:00Z',
      };

      final settings = StoreSettings.fromJson(json);

      expect(settings.storeName, 'MOVEN STORE');
      expect(settings.defaultShippingFee, 25000);
      expect(settings.lowStockThreshold, 10);
      expect(settings.contactEmail, 'hello@moven.vn');
      expect(settings.contactPhone, '0988776655');
      expect(settings.logoPath, 'brand/logo.png');
      expect(settings.updatedAt, DateTime.parse('2026-10-26T10:00:00Z'));

      final outJson = settings.toJson();
      expect(outJson['store_name'], 'MOVEN STORE');
      expect(outJson['default_shipping_fee'], 25000);
      expect(outJson['low_stock_threshold'], 10);
    });
  });
}
