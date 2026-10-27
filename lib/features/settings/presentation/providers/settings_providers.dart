import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moven/core/network/supabase_client.dart';
import 'package:moven/features/settings/data/settings_repository.dart';
import 'package:moven/features/settings/domain/models/store_settings.dart';

/// Provider cung cấp SettingsRepository
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  try {
    final client = ref.watch(supabaseClientProvider);
    return SettingsRepository(client);
  } catch (_) {
    return SettingsRepository();
  }
});

/// Provider cấu hình cửa hàng toàn cục
final storeSettingsProvider = FutureProvider<StoreSettings>((ref) async {
  final repo = ref.watch(settingsRepositoryProvider);
  return repo.getStoreSettings();
});

/// Controller xử lý lưu cấu hình cửa hàng
class AdminSettingsController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  AdminSettingsController(this._ref) : super(const AsyncValue.data(null));

  Future<bool> updateSettings({
    required int defaultShippingFee,
    required int lowStockThreshold,
    String? storeName,
    String? contactEmail,
    String? contactPhone,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repo = _ref.read(settingsRepositoryProvider);
      await repo.updateStoreSettings(
        defaultShippingFee: defaultShippingFee,
        lowStockThreshold: lowStockThreshold,
        storeName: storeName,
        contactEmail: contactEmail,
        contactPhone: contactPhone,
      );

      // Invalidate settings provider
      _ref.invalidate(storeSettingsProvider);

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final adminSettingsControllerProvider =
    StateNotifierProvider<AdminSettingsController, AsyncValue<void>>((ref) {
  return AdminSettingsController(ref);
});
