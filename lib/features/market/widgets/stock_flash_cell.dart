import 'package:flutter/material.dart';
import 'package:trading_app/core/theme/app_theme.dart';
import 'package:trading_app/core/utils/currency_formatter.dart';
import 'package:trading_app/domain/models/stock_quote.dart';

/// Clean stock price cell without distracting background flash boxes.
class StockFlashCell extends StatelessWidget {
  final StockQuote quote;
  final bool compact;

  const StockFlashCell({
    super.key,
    required this.quote,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUp = quote.isBullish;
    final bool isDown = quote.isBearish;

    final Color badgeColor = isUp
        ? AppColors.bullish
        : isDown
            ? AppColors.bearish
            : AppColors.neutral;

    final Color badgeBg = isUp
        ? AppColors.bullishBackground
        : isDown
            ? AppColors.bearishBackground
            : Colors.white10;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            CurrencyFormatter.formatPaise(quote.currentPricePaise),
            style: TextStyle(
              fontSize: compact ? 14 : 16,
              fontWeight: FontWeight.w700,
              color: AppColors.darkTextPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isUp
                      ? Icons.arrow_drop_up_rounded
                      : isDown
                          ? Icons.arrow_drop_down_rounded
                          : Icons.remove_rounded,
                  size: 14,
                  color: badgeColor,
                ),
                const SizedBox(width: 2),
                Text(
                  '${CurrencyFormatter.formatPaise(quote.changePaise, includeSymbol: false, showSign: true)} (${CurrencyFormatter.formatPercent(quote.changePercent)})',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: badgeColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
