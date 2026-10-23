import 'package:intl/intl.dart';

/// Tiện ích định dạng tiền tệ VND chuẩn cho MOVEN.
///
/// Quy ước dự án:
/// - Tiền tệ: VND.
/// - Lưu trữ dưới dạng số nguyên (integer), tuyệt đối không dùng số thực (floating point).
/// - Phân cách hàng nghìn bằng dấu chấm '.', hậu tố '₫'.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
    customPattern: '#,##0\u00A0¤',
  );

  /// Định dạng số nguyên thành chuỗi hiển thị VND (vd: 20000 -> "20.000 ₫")
  static String format(int? amount) {
    if (amount == null) return '0 ₫';
    return _formatter.format(amount).replaceAll(',', '.');
  }

  /// Định dạng khoảng giá hiển thị cho sản phẩm có nhiều biến thể
  static String formatRange(int minPrice, int maxPrice) {
    if (minPrice == maxPrice) {
      return format(minPrice);
    }
    return '${format(minPrice)} - ${format(maxPrice)}';
  }

  /// Định dạng giá "từ..." khi chưa chọn biến thể
  static String formatStartingFrom(int minPrice) {
    return 'Từ ${format(minPrice)}';
  }
}
