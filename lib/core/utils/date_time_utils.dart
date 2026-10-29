import 'package:intl/intl.dart';

/// Tiện ích xử lý và hiển thị ngày giờ chuẩn cho MOVEN.
///
/// Quy ước dự án:
/// - Dữ liệu thời gian lưu ở UTC (PostgreSQL TIMESTAMPTZ).
/// - Giao diện hiển thị theo múi giờ Việt Nam (UTC+7, Asia/Ho_Chi_Minh).
class DateTimeUtils {
  DateTimeUtils._();

  static const Duration _vietnamOffset = Duration(hours: 7);

  /// Chuyển đổi DateTime UTC sang giờ Việt Nam
  static DateTime toVietnamTime(DateTime utcTime) {
    final utc = utcTime.isUtc ? utcTime : utcTime.toUtc();
    return utc.add(_vietnamOffset);
  }

  /// Định dạng ngày giờ chuẩn: "22/10/2026 18:30"
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '--/--/----';
    final vnTime = toVietnamTime(dateTime);
    return DateFormat('dd/MM/yyyy HH:mm').format(vnTime);
  }

  /// Định dạng ngày: "22/10/2026"
  static String formatDate(DateTime? dateTime) {
    if (dateTime == null) return '--/--/----';
    final vnTime = toVietnamTime(dateTime);
    return DateFormat('dd/MM/yyyy').format(vnTime);
  }

  /// Định dạng ngày giờ có dấu gạch ngang (dùng cho đơn hàng): "22/10/2026 - 18:30"
  static String formatDateTimeWithDash(DateTime? dateTime) {
    if (dateTime == null) return '--/--/----';
    final vnTime = toVietnamTime(dateTime);
    return DateFormat('dd/MM/yyyy - HH:mm').format(vnTime);
  }

  /// Định dạng ngày giờ rút gọn (dùng cho bảng biểu admin/dashboard): "22/10 18:30"
  static String formatShortDateTime(DateTime? dateTime) {
    if (dateTime == null) return '--/--';
    final vnTime = toVietnamTime(dateTime);
    return DateFormat('dd/MM HH:mm').format(vnTime);
  }

  /// Định dạng ngày giờ kèm giây (dùng cho nhật ký/audit trail admin): "22/10/2026 18:30:45"
  static String formatDateTimeWithSeconds(DateTime? dateTime) {
    if (dateTime == null) return '--/--/----';
    final vnTime = toVietnamTime(dateTime);
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(vnTime);
  }

  /// Định dạng ngày giờ theo mẫu tùy chỉnh
  static String formatCustom(DateTime? dateTime, String pattern) {
    if (dateTime == null) return '--/--/----';
    final vnTime = toVietnamTime(dateTime);
    return DateFormat(pattern).format(vnTime);
  }
}
