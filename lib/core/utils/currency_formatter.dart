import 'package:decimal/decimal.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

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

  static String formatDecimalRupees(
    Decimal rupees, {
    bool includeSymbol = true,
    int decimalPlaces = 2,
  }) {
    final bool isNegative = rupees < Decimal.zero;
    final Decimal absRupees = isNegative ? -rupees : rupees;

    final BigInt integerPart = absRupees.toBigInt();
    final Decimal fractionalPart = absRupees - Decimal.fromBigInt(integerPart);

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

  static String formatPercent(double percent, {bool showSign = true}) {
    final String sign = percent > 0 && showSign
        ? '+'
        : percent < 0
            ? ''
            : '';
    return '$sign${percent.toStringAsFixed(2)}%';
  }

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
