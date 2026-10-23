import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Observer ghi nhật ký vòng đời các Provider phục vụ debug trong môi trường development.
/// Tuân thủ quy định: Không ghi log token, mật khẩu hoặc dữ liệu nhạy cảm.
class AppProviderObserver extends ProviderObserver {
  const AppProviderObserver();

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    if (kDebugMode) {
      debugPrint(
        '[Riverpod] ${provider.name ?? provider.runtimeType} updated: $previousValue -> $newValue',
      );
    }
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    if (kDebugMode) {
      debugPrint(
        '[Riverpod ERROR] ${provider.name ?? provider.runtimeType} failed: $error',
      );
    }
  }
}
