import 'package:flutter_test/flutter_test.dart';
import 'package:moven/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    test('định dạng số nguyên dương VND chuẩn', () {
      expect(CurrencyFormatter.format(20000), '20.000\u00A0₫');
      expect(CurrencyFormatter.format(250000), '250.000\u00A0₫');
      expect(CurrencyFormatter.format(1200000), '1.200.000\u00A0₫');
    });

    test('định dạng giá trị 0 hoặc null', () {
      expect(CurrencyFormatter.format(0), '0\u00A0₫');
      expect(CurrencyFormatter.format(null), '0 ₫');
    });

    test('định dạng khoảng giá formatRange', () {
      expect(
        CurrencyFormatter.formatRange(150000, 250000),
        '150.000\u00A0₫ - 250.000\u00A0₫',
      );
      // Khi min == max
      expect(
        CurrencyFormatter.formatRange(200000, 200000),
        '200.000\u00A0₫',
      );
    });

    test('định dạng giá "từ..." formatStartingFrom', () {
      expect(
        CurrencyFormatter.formatStartingFrom(180000),
        'Từ 180.000\u00A0₫',
      );
    });
  });
}
