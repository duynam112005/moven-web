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
  });
}
