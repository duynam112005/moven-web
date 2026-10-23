import 'app_exception.dart';

/// Đại diện cho lỗi được ánh xạ thân thiện với người dùng để hiển thị trên UI.
class Failure {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  factory Failure.fromException(Object exception) {
    if (exception is AppAuthException) {
      return Failure(
        message: exception.message.isNotEmpty
            ? exception.message
            : 'Xác thực không thành công. Vui lòng đăng nhập lại.',
        code: exception.code,
      );
    } else if (exception is ValidationException) {
      return Failure(
        message: exception.message.isNotEmpty
            ? exception.message
            : 'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại thông tin.',
        code: exception.code,
      );
    } else if (exception is OutOfStockException) {
      return Failure(
        message: exception.message.isNotEmpty
            ? exception.message
            : 'Sản phẩm đã hết hàng hoặc không đủ số lượng tồn khả dụng.',
        code: exception.code,
      );
    } else if (exception is NotFoundException) {
      return Failure(
        message: exception.message.isNotEmpty
            ? exception.message
            : 'Không tìm thấy thông tin được yêu cầu.',
        code: exception.code,
      );
    } else if (exception is PermissionDeniedException) {
      return Failure(
        message: exception.message.isNotEmpty
            ? exception.message
            : 'Bạn không có quyền thực hiện thao tác này.',
        code: exception.code,
      );
    } else if (exception is NetworkException) {
      return Failure(
        message: 'Lỗi kết nối mạng. Vui lòng kiểm tra lại đường truyền internet.',
        code: exception.code,
      );
    } else if (exception is ServerException) {
      return Failure(
        message: exception.message.isNotEmpty
            ? exception.message
            : 'Hệ thống đang bận. Vui lòng thử lại sau giây lát.',
        code: exception.code,
      );
    }

    return const Failure(
      message: 'Đã xảy ra lỗi không xác định. Vui lòng thử lại sau.',
    );
  }

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}
