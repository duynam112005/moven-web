import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/network/supabase_client.dart';
import '../../auth/domain/models/user_profile.dart';

/// Provider cung cấp ProfileRepository với fallback an toàn khi chưa cấu hình Supabase
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  try {
    final client = ref.watch(supabaseClientProvider);
    return ProfileRepository(client);
  } catch (_) {
    return const ProfileRepository();
  }
});

/// Repository xử lý đọc và cập nhật hồ sơ người dùng trong bảng `public.profiles`
class ProfileRepository {
  final SupabaseClient? _client;

  const ProfileRepository([this._client]);

  SupabaseClient get _safeClient {
    final client = _client;
    if (client != null) return client;
    throw StateError('Supabase chưa được cấu hình.');
  }

  /// Lấy thông tin hồ sơ của người dùng theo user ID
  Future<UserProfile?> getProfile(String userId) async {
    final response = await _safeClient
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return UserProfile.fromJson(response);
  }

  /// Cập nhật thông tin hồ sơ người dùng.
  /// LƯU Ý: Tuyệt đối không cho phép client gửi `role` để bảo đảm an toàn.
  Future<UserProfile> updateProfile({
    required String userId,
    required String fullName,
    String? phone,
    String? avatarPath,
  }) async {
    final updateData = {
      'id': userId,
      'full_name': fullName.trim(),
      'phone': phone?.trim(),
      if (avatarPath != null) 'avatar_path': avatarPath,
    };

    final response = await _safeClient
        .from('profiles')
        .upsert(updateData)
        .select()
        .single();

    return UserProfile.fromJson(response);
  }

}
