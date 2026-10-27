/// Cấu hình môi trường cho MOVEN.
///
/// Các giá trị được nạp an toàn tại thời điểm biên dịch thông qua `--dart-define`.
/// Tuyệt đối không nhúng `service_role` key hay database secret vào client Flutter Web.
class AppConfig {
  AppConfig._();

  static const String appTitle = 'MOVEN';
  static const String storeName = 'MOVEN Clothing';

  /// URL dự án Supabase (vd: https://xyzcompany.supabase.co)
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://yutcybbyawjlzqplbndq.supabase.co',
  );

  /// Anon Key công khai của Supabase (an toàn trên client khi kết hợp RLS)
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl1dGN5YmJ5YXdqbHpxcGxibmRxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTI4NDk2OTYsImV4cCI6MjEwODQyNTY5Nn0.BRLebpX2ieICP5RwkbjFEzT4UG7VMjyEWPkjBpeh7bc',
  );

  /// Môi trường thực thi: 'development', 'staging', 'production'
  static const String environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static bool get isProduction => environment == 'production';
  static bool get isStaging => environment == 'staging';
  static bool get isDevelopment => environment == 'development';

  /// Kiểm tra xem cấu hình Supabase đã được cung cấp đầy đủ chưa
  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Xác thực tính hợp lệ của cấu hình
  static void validate() {
    if (!isSupabaseConfigured) {
      // Trong môi trường development, cho phép cảnh báo để developer biết cần truyền cờ
      // Nhưng không ném exception làm sập app ngay nếu đang preview UI
    }
  }
}
