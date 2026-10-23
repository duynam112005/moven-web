import 'package:intl/intl.dart';

/// Tiện ích xử lý và hiển thị ngày giờ chuẩn cho MOVEN.
///
/// Quy ước dự án:
/// - Dữ liệu thời gian lưu ở UTC.
/// - Giao diện hiển thị theo múi giờ Việt Nam (UTC+7, Asia/Ho_Chi_Minh).
class DateTimeUtils {
  DateTimeUtils._();

  static const Duration _vietnamOffset = Duration(hours: 7);

  /// Chuyển đổi DateTime UTC sang giờ Việt Nam
  static DateTime toVietnamTime(DateTime utcTime) {
    final utc = utcTime.isUtc ? utcTime : utcTime.toUtc();
    return utc.add(_vietnamOffset);
  }

  /// Định dạng ngày giờ: "22/10/2026 18:30"
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
}
