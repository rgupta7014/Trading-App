import 'package:decimal/decimal.dart';

/// Utility class for formatting currency and percentages.
///
/// CRITICAL: In this application, money is ALWAYS represented internally as
/// integer paise (1 Rupee = 100 Paise) to avoid any IEEE-754 floating point issues.
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Formats an integer amount of paise into Indian Rupee format.
  ///
  /// Examples:
  /// - `100000000` (10 Lakh Rs) -> `"₹10,00,000.00"`
  /// - `12345678` -> `"₹1,23,456.78"`
  /// - `50` -> `"₹0.50"`
  /// - `-25000` -> `"-₹250.00"`
  static String formatPaise(
    int paise, {
    bool includeSymbol = true,
    bool showSign = false,
  }) {
    final bool isNegative = paise < 0;
    final int absPaise = paise.abs();
    final int rupees = absPaise ~/ 100;
    final int remainderPaise = absPaise % 100;

    final String rupeeStr = _formatIndianGrouping(rupees);
    final String paiseStr = remainderPaise.toString().padLeft(2, '0');

    final String sign;
    if (isNegative) {
      sign = '-';
    } else if (showSign && paise > 0) {
      sign = '+';
    } else {
      sign = '';
    }

    final String symbol = includeSymbol ? '₹' : '';
    return '$sign$symbol$rupeeStr.$paiseStr';
  }

  /// Formats a [Decimal] rupee value (used for fractional average purchase costs).
  ///
  /// E.g. `Decimal.parse("1234.567")` -> `"₹1,234.57"`
  static String formatDecimalRupees(
    Decimal rupees, {
    bool includeSymbol = true,
    int decimalPlaces = 2,
  }) {
    final bool isNegative = rupees < Decimal.zero;
    final Decimal absRupees = isNegative ? -rupees : rupees;

    // Split integer and fractional parts
    final BigInt integerPart = absRupees.toBigInt();
    final Decimal fractionalPart = absRupees - Decimal.fromBigInt(integerPart);

    // Round fraction to desired decimal places
    final num multiplier = _pow10(decimalPlaces);
    final double fractionVal = fractionalPart.toDouble() * multiplier;
    final int roundedFraction = fractionVal.round();

    final String rupeeStr = _formatIndianGrouping(integerPart.toInt());
    final String fractionStr =
        roundedFraction.toString().padLeft(decimalPlaces, '0');

    final String sign = isNegative ? '-' : '';
    final String symbol = includeSymbol ? '₹' : '';

    return '$sign$symbol$rupeeStr.$fractionStr';
  }

  /// Formats a percentage change.
  ///
  /// E.g. `1.25` -> `"+1.25%"`, `-0.5` -> `"-0.50%"`
  static String formatPercent(double percent, {bool showSign = true}) {
    final String sign = percent > 0 && showSign
        ? '+'
        : percent < 0
            ? ''
            : '';
    return '$sign${percent.toStringAsFixed(2)}%';
  }

  /// Converts Indian rupee grouping for whole numbers.
  ///
  /// Indian system:
  /// Last 3 digits together, preceded by pairs of 2 digits.
  /// E.g. 1000000 -> 10,00,000
  static String _formatIndianGrouping(int amount) {
    final String s = amount.toString();
    if (s.length <= 3) return s;

    final String lastThree = s.substring(s.length - 3);
    final String remaining = s.substring(0, s.length - 3);

    final List<String> pairs = [];
    int end = remaining.length;
    while (end > 0) {
      final int start = (end >= 2) ? end - 2 : 0;
      pairs.insert(0, remaining.substring(start, end));
      end = start;
    }

    return '${pairs.join(',')},$lastThree';
  }

  static num _pow10(int exp) {
    num res = 1;
    for (int i = 0; i < exp; i++) {
      res *= 10;
    }
    return res;
  }
}
