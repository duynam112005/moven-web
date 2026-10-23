/// Lớp ngoại lệ cơ sở cho toàn ứng dụng MOVEN.
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => '$runtimeType: $message (code: $code)';
}

/// Lỗi liên quan đến xác thực và phiên làm việc
class AppAuthException extends AppException {
  const AppAuthException(
    super.message, {
    super.code,
    super.details,
  });
}

/// Lỗi do dữ liệu nhập vào không hợp lệ
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException(
    super.message, {
    super.code,
    super.details,
    this.fieldErrors,
  });
}

/// Lỗi hết hàng hoặc không đủ tồn khả dụng
class OutOfStockException extends AppException {
  const OutOfStockException(
    super.message, {
    super.code,
    super.details,
  });
}

/// Lỗi không tìm thấy tài nguyên (sản phẩm, đơn hàng, v.v.)
class NotFoundException extends AppException {
  const NotFoundException(
    super.message, {
    super.code,
    super.details,
  });
}

/// Lỗi không đủ quyền truy cập (vd: khách vào admin)
class PermissionDeniedException extends AppException {
  const PermissionDeniedException(
    super.message, {
    super.code,
    super.details,
  });
}

/// Lỗi kết nối mạng
class NetworkException extends AppException {
  const NetworkException(
    super.message, {
    super.code,
    super.details,
  });
}

/// Lỗi xử lý phía máy chủ hoặc PostgreSQL RPC
class ServerException extends AppException {
  const ServerException(
    super.message, {
    super.code,
    super.details,
  });
}
