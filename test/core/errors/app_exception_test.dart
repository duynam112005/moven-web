import 'package:flutter_test/flutter_test.dart';
import 'package:moven/core/errors/app_exception.dart';
import 'package:moven/core/errors/failure.dart';

void main() {
  group('Failure.fromException', () {
    test('ánh xạ AppAuthException chính xác', () {
      const ex = AppAuthException('Tài khoản hoặc mật khẩu không chính xác');
      final failure = Failure.fromException(ex);
      expect(failure.message, 'Tài khoản hoặc mật khẩu không chính xác');
    });

    test('ánh xạ OutOfStockException chính xác', () {
      const ex = OutOfStockException('Size L đã hết hàng');
      final failure = Failure.fromException(ex);
      expect(failure.message, 'Size L đã hết hàng');
    });

    test('ánh xạ ValidationException chính xác', () {
      const ex = ValidationException('Vui lòng chọn size');
      final failure = Failure.fromException(ex);
      expect(failure.message, 'Vui lòng chọn size');
    });

    test('ánh xạ PermissionDeniedException chính xác', () {
      const ex = PermissionDeniedException('Yêu cầu quyền admin');
      final failure = Failure.fromException(ex);
      expect(failure.message, 'Yêu cầu quyền admin');
    });

    test('ánh xạ NetworkException chính xác', () {
      const ex = NetworkException('Lost connection');
      final failure = Failure.fromException(ex);
      expect(
        failure.message,
        'Lỗi kết nối mạng. Vui lòng kiểm tra lại đường truyền internet.',
      );
    });

    test('ánh xạ Exception không xác định', () {
      final failure = Failure.fromException(Exception('Unknown'));
      expect(
        failure.message,
        'Đã xảy ra lỗi không xác định. Vui lòng thử lại sau.',
      );
    });
  });
}
