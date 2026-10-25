import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/network/supabase_client.dart';
import '../domain/models/address.dart';

/// Provider cung cấp AddressRepository với fallback an toàn khi chưa cấu hình Supabase
final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  try {
    final client = ref.watch(supabaseClientProvider);
    return AddressRepository(client);
  } catch (_) {
    return const AddressRepository();
  }
});

/// Repository xử lý sổ địa chỉ giao hàng trong bảng `public.addresses`
class AddressRepository {
  final SupabaseClient? _client;

  const AddressRepository([this._client]);

  SupabaseClient get _safeClient {
    final client = _client;
    if (client != null) return client;
    throw StateError('Supabase chưa được cấu hình.');
  }

  /// Lấy danh sách địa chỉ của người dùng
  Future<List<Address>> getAddresses(String userId) async {
    final response = await _safeClient
        .from('addresses')
        .select()
        .eq('user_id', userId)
        .order('is_default', ascending: false)
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => Address.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Thêm địa chỉ mới
  Future<Address> addAddress(Address address) async {
    // Nếu địa chỉ mới là mặc định, gỡ cờ mặc định của các địa chỉ cũ
    if (address.isDefault) {
      await _safeClient
          .from('addresses')
          .update({'is_default': false})
          .eq('user_id', address.userId);
    }

    final response = await _safeClient
        .from('addresses')
        .insert(address.toInsertJson())
        .select()
        .single();

    return Address.fromJson(response);
  }

  /// Cập nhật địa chỉ hiện có
  Future<Address> updateAddress(Address address) async {
    // Nếu cập nhật thành mặc định, gỡ cờ mặc định của các địa chỉ khác
    if (address.isDefault) {
      await _safeClient
          .from('addresses')
          .update({'is_default': false})
          .eq('user_id', address.userId)
          .neq('id', address.id);
    }

    final response = await _safeClient
        .from('addresses')
        .update(address.toUpdateJson())
        .eq('id', address.id)
        .select()
        .single();

    return Address.fromJson(response);
  }

  /// Xóa địa chỉ theo ID
  Future<void> deleteAddress(String addressId) async {
    await _safeClient.from('addresses').delete().eq('id', addressId);
  }

  /// Đặt làm địa chỉ mặc định
  Future<void> setDefaultAddress({
    required String userId,
    required String addressId,
  }) async {
    // Gỡ tất cả mặc định
    await _safeClient
        .from('addresses')
        .update({'is_default': false})
        .eq('user_id', userId);

    // Bật mặc định cho địa chỉ được chọn
    await _safeClient
        .from('addresses')
        .update({'is_default': true})
        .eq('id', addressId);
  }
}
