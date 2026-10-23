import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';
import 'app/observer.dart';
import 'core/config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Supabase Client nếu có cấu hình
  if (AppConfig.isSupabaseConfigured) {
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseAnonKey,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[MOVEN] Không thể kết nối Supabase: $e');
      }
    }
  } else {
    if (kDebugMode) {
      debugPrint(
        '[MOVEN CẢNH BÁO] Chưa cung cấp SUPABASE_URL và SUPABASE_ANON_KEY. '
        'Ứng dụng đang chạy ở chế độ UI Preview. '
        'Để kết nối đầy đủ, hãy chạy kèm cờ --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...',
      );
    }
  }

  runApp(
    const ProviderScope(
      observers: [
        AppProviderObserver(),
      ],
      child: MovenApp(),
    ),
  );
}
