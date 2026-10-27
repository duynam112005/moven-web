import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:moven/features/settings/domain/models/store_settings.dart';

/// Repository quản lý cấu hình cửa hàng MOVEN (Singleton)
class SettingsRepository {
  final SupabaseClient? _client;

  SettingsRepository([this._client]);

  bool get _isSupabaseConfigured => _client != null;

  static StoreSettings _mockSettings = const StoreSettings(
    storeName: 'MOVEN CLOTHING',
    contactEmail: 'support@moven.vn',
    contactPhone: '0901234567',
    defaultShippingFee: 20000,
    lowStockThreshold: 5,
  );

  /// Lấy cấu hình cửa hàng hiện hành
  Future<StoreSettings> getStoreSettings() async {
    if (!_isSupabaseConfigured) {
      return _mockSettings;
    }

    try {
      final response = await _client!
          .from('store_settings')
          .select()
          .limit(1)
          .maybeSingle();

      if (response == null) {
        return _mockSettings;
      }

      return StoreSettings.fromJson(response);
    } catch (e) {
      if (kDebugMode) debugPrint('[SettingsRepository] getStoreSettings error: $e');
      return _mockSettings;
    }
  }

  /// Admin cập nhật cấu hình cửa hàng qua RPC bảo mật
  Future<Map<String, dynamic>> updateStoreSettings({
    required int defaultShippingFee,
    required int lowStockThreshold,
    String? storeName,
    String? contactEmail,
    String? contactPhone,
  }) async {
    if (!_isSupabaseConfigured) {
      _mockSettings = _mockSettings.copyWith(
        defaultShippingFee: defaultShippingFee,
        lowStockThreshold: lowStockThreshold,
        storeName: storeName?.trim().isNotEmpty == true ? storeName!.trim() : _mockSettings.storeName,
        contactEmail: contactEmail?.trim().isNotEmpty == true ? contactEmail!.trim() : _mockSettings.contactEmail,
        contactPhone: contactPhone?.trim().isNotEmpty == true ? contactPhone!.trim() : _mockSettings.contactPhone,
        updatedAt: DateTime.now(),
      );
      return {
        'success': true,
        'message': 'Đã lưu cấu hình cửa hàng thành công.',
      };
    }

    final res = await _client!.rpc(
      'admin_update_store_settings',
      params: {
        'p_default_shipping_fee': defaultShippingFee,
        'p_low_stock_threshold': lowStockThreshold,
        'p_store_name': storeName,
        'p_contact_email': contactEmail,
        'p_contact_phone': contactPhone,
      },
    );

    return res as Map<String, dynamic>;
  }
}
