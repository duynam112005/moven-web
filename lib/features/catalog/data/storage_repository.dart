import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/app_config.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/supabase_client.dart';

/// Repository quản lý Supabase Storage cho ảnh sản phẩm và banner.
///
/// Tuân thủ quy tắc bảo mật:
/// - Database chỉ lưu object path/key (ví dụ: "products/123-abc.webp").
/// - Sinh URL công khai qua getPublicUrl().
/// - Chỉ admin mới được phép upload/delete.
class StorageRepository {
  final SupabaseClient? _client;

  static const String productBucket = 'product-media';
  static const String bannerBucket = 'banners';

  StorageRepository(this._client);

  /// Suy đoán MIME type từ đuôi tệp tin (tương thích whitelist Supabase Storage: jpeg, png, webp, gif)
  static String inferContentType(String fileName) {
    final parts = fileName.split('.');
    if (parts.length > 1) {
      final ext = parts.last.toLowerCase();
      switch (ext) {
        case 'png':
          return 'image/png';
        case 'webp':
          return 'image/webp';
        case 'gif':
          return 'image/gif';
        case 'jpg':
        case 'jpeg':
        case 'jfif':
        case 'pjpeg':
        case 'pjp':
          return 'image/jpeg';
        default:
          return 'image/jpeg';
      }
    }
    return 'image/jpeg';
  }

  /// Lấy URL công khai để hiển thị ảnh
  String getPublicUrl({
    required String bucket,
    required String path,
  }) {
    if (path.isEmpty) return '';
    // Nếu path đã là full URL http/https thì trả về nguyên bản
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    if (_client == null) return '';
    return _client.storage.from(bucket).getPublicUrl(path);
  }

  /// URL công khai cho ảnh sản phẩm
  String getProductImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    return getPublicUrl(bucket: productBucket, path: path);
  }

  /// URL công khai cho banner
  String getBannerImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    return getPublicUrl(bucket: bannerBucket, path: path);
  }

  /// Tải lên ảnh sản phẩm từ bytes (Hỗ trợ tốt nhất cho Flutter Web)
  Future<String> uploadProductImage({
    required Uint8List bytes,
    required String fileName,
    String? folder,
    String contentType = 'image/jpeg',
  }) async {
    try {
      final sanitizedName = _sanitizeFileName(fileName);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uploadPath = folder != null && folder.isNotEmpty
          ? '$folder/${timestamp}_$sanitizedName'
          : '${timestamp}_$sanitizedName';

      if (_client == null) {
        throw const ServerException('Supabase chưa được cấu hình');
      }

      final resolvedContentType = contentType == 'image/jpeg'
          ? inferContentType(fileName)
          : contentType;

      await _client.storage.from(productBucket).uploadBinary(
            uploadPath,
            bytes,
            fileOptions: FileOptions(
              contentType: resolvedContentType,
              upsert: true,
            ),
          );

      return uploadPath;
    } on StorageException catch (e) {
      throw ServerException(
        'Lỗi khi tải ảnh sản phẩm lên Storage: ${e.message}',
        code: e.statusCode,
        details: e,
      );
    } catch (e) {
      throw ServerException('Lỗi không xác định khi tải ảnh sản phẩm: $e');
    }
  }

  /// Tải lên ảnh banner từ bytes
  Future<String> uploadBannerImage({
    required Uint8List bytes,
    required String fileName,
    String contentType = 'image/jpeg',
  }) async {
    try {
      final sanitizedName = _sanitizeFileName(fileName);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uploadPath = '${timestamp}_$sanitizedName';

      if (_client == null) {
        throw const ServerException('Supabase chưa được cấu hình');
      }

      final resolvedContentType = contentType == 'image/jpeg'
          ? inferContentType(fileName)
          : contentType;

      await _client.storage.from(bannerBucket).uploadBinary(
            uploadPath,
            bytes,
            fileOptions: FileOptions(
              contentType: resolvedContentType,
              upsert: true,
            ),
          );

      return uploadPath;
    } on StorageException catch (e) {
      throw ServerException(
        'Lỗi khi tải banner lên Storage: ${e.message}',
        code: e.statusCode,
        details: e,
      );
    } catch (e) {
      throw ServerException('Lỗi không xác định khi tải banner: $e');
    }
  }

  /// Xóa file trên Storage
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      if (_client == null) {
        throw const ServerException('Supabase chưa được cấu hình');
      }

      await _client.storage.from(bucket).remove([path]);
    } on StorageException catch (e) {
      throw ServerException(
        'Lỗi khi xóa file trên Storage: ${e.message}',
        code: e.statusCode,
        details: e,
      );
    } catch (e) {
      throw ServerException('Lỗi khi xóa file: $e');
    }
  }

  /// Chuẩn hóa tên file, loại bỏ ký tự đặc biệt
  String _sanitizeFileName(String name) {
    final clean = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9._-]'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    if (!clean.contains('.')) {
      return '$clean.jpg';
    }
    return clean;
  }
}

/// Provider toàn cục cho StorageRepository
final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  if (!AppConfig.isSupabaseConfigured) {
    return StorageRepository(null);
  }
  try {
    final client = ref.watch(supabaseClientProvider);
    return StorageRepository(client);
  } catch (_) {
    return StorageRepository(null);
  }
});
