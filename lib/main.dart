import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';
import 'app/observer.dart';
import 'core/config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bắt lỗi render toàn cục, ngăn chặn màn hình đỏ hoặc treo ứng dụng
  // Sử dụng layout có giới hạn an toàn (không dùng SingleChildScrollView để tránh lỗi unbounded height lồng nhau)
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.white,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEE2E2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Color(0xFFDC2626),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Đã xảy ra sự cố hiển thị',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  kDebugMode
                      ? details.exceptionAsString()
                      : 'Đã có lỗi bất ngờ xảy ra trong quá trình hiển thị. Bạn có thể thử tải lại trang hoặc quay về trang chủ.',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    try {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        runApp(
                          const ProviderScope(
                            observers: [AppProviderObserver()],
                            child: MovenApp(),
                          ),
                        );
                      });
                    } catch (_) {}
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Thử tải lại giao diện'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF111827),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  };

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      debugPrint('[MOVEN FlutterError] ${details.exceptionAsString()}');
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      debugPrint('[MOVEN AsyncError] $error\n$stack');
    }
    return true; // Ngăn chặn crash app
  };

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
