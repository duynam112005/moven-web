import 'package:flutter_test/flutter_test.dart';
import 'package:moven/core/utils/date_time_utils.dart';

void main() {
  group('DateTimeUtils', () {
    test('chuyển đổi UTC sang giờ Việt Nam (+7 giờ)', () {
      final utc = DateTime.utc(2026, 10, 22, 10, 30);
      final vn = DateTimeUtils.toVietnamTime(utc);

      expect(vn.year, 2026);
      expect(vn.month, 10);
      expect(vn.day, 22);
      expect(vn.hour, 17);
      expect(vn.minute, 30);
    });

    test('định dạng ngày giờ formatDateTime', () {
      final utc = DateTime.utc(2026, 10, 22, 10, 30);
      expect(DateTimeUtils.formatDateTime(utc), '22/10/2026 17:30');
      expect(DateTimeUtils.formatDateTime(null), '--/--/----');
    });

    test('định dạng ngày formatDate', () {
      final utc = DateTime.utc(2026, 10, 22, 10, 30);
      expect(DateTimeUtils.formatDate(utc), '22/10/2026');
      expect(DateTimeUtils.formatDate(null), '--/--/----');
    });

    test('định dạng ngày giờ có gạch ngang formatDateTimeWithDash cho đơn hàng', () {
      // Đơn hàng đặt lúc 23:16 giờ Việt Nam, lưu trong DB Supabase là 16:16 UTC
      final orderCreatedAtUtc = DateTime.parse('2026-10-29T16:16:00Z');
      expect(
        DateTimeUtils.formatDateTimeWithDash(orderCreatedAtUtc),
        '29/10/2026 - 23:16',
      );
      expect(DateTimeUtils.formatDateTimeWithDash(null), '--/--/----');
    });

    test('định dạng rút gọn formatShortDateTime cho bảng admin & dashboard', () {
      final orderCreatedAtUtc = DateTime.parse('2026-10-29T16:16:00Z');
      expect(DateTimeUtils.formatShortDateTime(orderCreatedAtUtc), '29/10 23:16');
      expect(DateTimeUtils.formatShortDateTime(null), '--/--');
    });

    test('định dạng đầy đủ kèm giây formatDateTimeWithSeconds cho nhật ký trạng thái', () {
      final orderCreatedAtUtc = DateTime.parse('2026-10-29T16:16:45Z');
      expect(
        DateTimeUtils.formatDateTimeWithSeconds(orderCreatedAtUtc),
        '29/10/2026 23:16:45',
      );
      expect(DateTimeUtils.formatDateTimeWithSeconds(null), '--/--/----');
    });

    test('định dạng tùy biến formatCustom', () {
      final orderCreatedAtUtc = DateTime.parse('2026-10-29T16:16:00Z');
      expect(
        DateTimeUtils.formatCustom(orderCreatedAtUtc, 'HH:mm (dd/MM)'),
        '23:16 (29/10)',
      );
      expect(DateTimeUtils.formatCustom(null, 'HH:mm'), '--/--/----');
    });
  });
}
