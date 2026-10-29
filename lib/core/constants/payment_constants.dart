/// Thông số cấu hình thanh toán và tạo VietQR qua SePay cho MOVEN
class PaymentConstants {
  PaymentConstants._();

  /// Ngân hàng nhận thanh toán mặc định (Mã BIN hoặc Short Name chuẩn Napas)
  /// Ví dụ: MBBank, Vietcombank, ACB, TPBank, VPBank...
  static const String defaultBankCode = 'MBBank';
  static const String defaultBankName = 'MB (Ngân hàng Quân Đội)';

  /// Số tài khoản nhận thanh toán mặc định (Sandbox hoặc cấu hình cửa hàng)
  static const String defaultAccountNumber = '0325599936';

  /// Tên chủ tài khoản thụ hưởng
  static const String defaultAccountHolder = 'NGUYEN VAN HAI';

  /// Thời gian chờ thanh toán trước khi đơn hết hạn (phút)
  static const int paymentTimeoutMinutes = 15;

  /// Tạo link hình ảnh VietQR tự động qua SePay QuickLink API
  /// Chuẩn VietQR tự động điền số tài khoản, số tiền và nội dung chuyển khoản khi quét bằng App ngân hàng
  static String buildVietQrImageUrl({
    String bankCode = defaultBankCode,
    String accountNumber = defaultAccountNumber,
    required int amount,
    required String orderCode,
    String template = 'compact',
  }) {
    final encBank = Uri.encodeComponent(bankCode);
    final encAcc = Uri.encodeComponent(accountNumber);
    final encDes = Uri.encodeComponent(orderCode);
    return 'https://qr.sepay.vn/img?acc=$encAcc&bank=$encBank&amount=$amount&des=$encDes&template=$template';
  }

  /// Chuỗi dữ liệu QR văn bản dự phòng (Fallback Text Payload)
  static String buildFallbackQrPayload({
    required String orderCode,
    required int amount,
    String recipientName = '',
    String recipientPhone = '',
    String bankName = defaultBankName,
    String accountNumber = defaultAccountNumber,
    String accountHolder = defaultAccountHolder,
  }) {
    return '[MOVEN CLOTHING]\n'
        'NGÂN HÀNG: $bankName\n'
        'SỐ TÀI KHOẢN: $accountNumber\n'
        'CHỦ TÀI KHOẢN: $accountHolder\n'
        'SỐ TIỀN: $amount VND\n'
        'NỘI DUNG CK: $orderCode';
  }
}
