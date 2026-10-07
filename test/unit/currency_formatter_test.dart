import 'package:flutter_test/flutter_test.dart';
import 'package:trading_app/core/utils/currency_formatter.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('CurrencyFormatter tests', () {
    test('formats paise to Indian Rupee notation correctly', () {
      expect(
        CurrencyFormatter.formatPaise(100000000),
        equals('₹10,00,000.00'),
      );

      expect(
        CurrencyFormatter.formatPaise(12345678),
        equals('₹1,23,456.78'),
      );

      expect(
        CurrencyFormatter.formatPaise(50),
        equals('₹0.50'),
      );
      expect(
        CurrencyFormatter.formatPaise(105),
        equals('₹1.05'),
      );

      expect(
        CurrencyFormatter.formatPaise(100),
        equals('₹1.00'),
      );

      expect(
        CurrencyFormatter.formatPaise(-25050),
        equals('-₹250.50'),
      );
      expect(
        CurrencyFormatter.formatPaise(-12345678),
        equals('-₹1,23,456.78'),
      );
    });

    test('formats with showSign correctly', () {
      expect(
        CurrencyFormatter.formatPaise(25000, showSign: true),
        equals('+₹250.00'),
      );
      expect(
        CurrencyFormatter.formatPaise(-25000, showSign: true),
        equals('-₹250.00'),
      );
      expect(
        CurrencyFormatter.formatPaise(0, showSign: true),
        equals('₹0.00'),
      );
    });

    test('formats Decimal rupees with high precision and Indian grouping', () {
      final dec1 = Decimal.parse('2950.50');
      expect(
        CurrencyFormatter.formatDecimalRupees(dec1),
        equals('₹2,950.50'),
      );

      final dec2 = Decimal.parse('123456.789');
      expect(
        CurrencyFormatter.formatDecimalRupees(dec2),
        equals('₹1,23,456.79'),
      );
    });

    test('formats percentages correctly', () {
      expect(CurrencyFormatter.formatPercent(1.25), equals('+1.25%'));
      expect(CurrencyFormatter.formatPercent(-0.5), equals('-0.50%'));
      expect(CurrencyFormatter.formatPercent(0.0), equals('0.00%'));
    });
  });
}
