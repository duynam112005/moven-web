import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/domain/models/user_profile.dart';
import '../config/app_config.dart';

/// Provider cung cấp SupabaseClient toàn cục
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  if (!AppConfig.isSupabaseConfigured) {
    // Nếu chưa cấu hình credentials thực tế, ném state rõ ràng để UI biết
    throw StateError(
      'Supabase chưa được cấu hình. Vui lòng cung cấp SUPABASE_URL và SUPABASE_ANON_KEY.',
    );
  }
  try {
    return Supabase.instance.client;
  } catch (e) {
    throw StateError('Supabase chưa được khởi tạo: $e');
  }
});

/// Provider lắng nghe thay đổi trạng thái xác thực (Auth State Changes)
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  if (!AppConfig.isSupabaseConfigured) {
    return const Stream.empty();
  }
  try {
    final client = Supabase.instance.client;
    return client.auth.onAuthStateChange;
  } catch (_) {
    return const Stream.empty();
  }
});

/// Provider cung cấp thông tin người dùng hiện tại (nếu đã đăng nhập)
final currentUserProvider = Provider<User?>((ref) {
  if (!AppConfig.isSupabaseConfigured) return null;
  try {
    // Lắng nghe thay đổi auth để tự động cập nhật user
    ref.watch(authStateChangesProvider);
    final client = Supabase.instance.client;
    return client.auth.currentUser;
  } catch (_) {
    return null;
  }
});

/// Provider kiểm tra trạng thái đăng nhập
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

/// Provider nạp thông tin hồ sơ người dùng tin cậy từ bảng `profiles`.
/// Có cơ chế tự phục hồi (self-healing) nếu bảng profiles chưa có bản ghi cho user đã xác thực.
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  try {
    final client = Supabase.instance.client;
    final response = await client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (response != null) {
      return UserProfile.fromJson(response);
    }

    // Nếu chưa có trong DB (do trigger DB chưa kích hoạt), tự động upsert bản ghi ban đầu
    try {
      final metaName = (user.userMetadata?['full_name'] as String?)?.trim();
      final metaPhone = (user.userMetadata?['phone'] as String?)?.trim();
      final newProfileMap = {
        'id': user.id,
        'full_name': (metaName != null && metaName.isNotEmpty)
            ? metaName
            : (user.email?.split('@').first ?? 'Khách hàng'),
        if (metaPhone != null && metaPhone.isNotEmpty) 'phone': metaPhone,
        'role': 'customer',
      };
      final created = await client
          .from('profiles')
          .upsert(newProfileMap)
          .select()
          .single();
      return UserProfile.fromJson(created);
    } catch (_) {
      // Fallback từ Auth user metadata nếu DB tạm thời không phản hồi
      return UserProfile(
        id: user.id,
        fullName: (user.userMetadata?['full_name'] as String?) ??
            user.email?.split('@').first ??
            'Khách hàng',
        phone: user.userMetadata?['phone'] as String?,
        role: 'customer',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  } catch (_) {
    // Fallback an toàn nếu có lỗi kết nối Supabase
    return UserProfile(
      id: user.id,
      fullName: (user.userMetadata?['full_name'] as String?) ??
          user.email?.split('@').first ??
          'Khách hàng',
      phone: user.userMetadata?['phone'] as String?,
      role: 'customer',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
});

/// Provider lưu giữ role người dùng hiện hành ('customer' hoặc 'admin').
/// Đồng bộ tin cậy từ bảng profiles trong database, mặc định 'customer'.
final userRoleProvider = Provider<String>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  return profileAsync.value?.role ?? 'customer';
});

/// Provider kiểm tra quyền Admin đáng tin cậy
final isAdminProvider = Provider<bool>((ref) {
  final isAuth = ref.watch(isAuthenticatedProvider);
  final role = ref.watch(userRoleProvider);
  return isAuth && role == 'admin';
});
