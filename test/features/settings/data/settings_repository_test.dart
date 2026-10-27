import 'package:flutter_test/flutter_test.dart';
import 'package:moven/features/settings/data/settings_repository.dart';

void main() {
  group('SettingsRepository Tests (Mock Mode)', () {
    late SettingsRepository repo;

    setUp(() {
      repo = SettingsRepository();
    });

    test('getStoreSettings returns valid default configuration', () async {
      final settings = await repo.getStoreSettings();

      expect(settings.defaultShippingFee, greaterThanOrEqualTo(0));
      expect(settings.lowStockThreshold, greaterThanOrEqualTo(0));
      expect(settings.storeName, isNotEmpty);
      expect(settings.contactEmail, isNotEmpty);
    });

    test('updateStoreSettings updates in-memory mock settings', () async {
      final res = await repo.updateStoreSettings(
        defaultShippingFee: 30000,
        lowStockThreshold: 8,
        storeName: 'MOVEN PREMIUM',
        contactEmail: 'contact@moven.vn',
        contactPhone: '0987654321',
      );

      expect(res['success'], isTrue);

      final updated = await repo.getStoreSettings();
      expect(updated.defaultShippingFee, 30000);
      expect(updated.lowStockThreshold, 8);
      expect(updated.storeName, 'MOVEN PREMIUM');
      expect(updated.contactPhone, '0987654321');
    });
  });
}
