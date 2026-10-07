import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trading_app/core/theme/app_theme.dart';
import 'package:trading_app/core/utils/currency_formatter.dart';
import 'package:trading_app/domain/models/holding_model.dart';
import 'package:trading_app/features/market/providers/market_feed_provider.dart';
import 'package:trading_app/features/market/widgets/stock_flash_cell.dart';

/// Individual holding item row with granular live price and dynamic P&L calculation.
class HoldingStockRow extends ConsumerWidget {
  final HoldingModel holding;
  final VoidCallback? onTap;

  const HoldingStockRow({
    super.key,
    required this.holding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listens strictly to its own symbol price ticks
    final quote = ref.watch(stockQuoteFamily(holding.symbol));

    final int ltpPaise = quote.currentPricePaise;
    final int currentValuePaise = holding.currentValuePaise(ltpPaise);
    final int pnlPaise = holding.pnlPaise(ltpPaise);
    final double pnlPercent = holding.pnlPercent(ltpPaise);

    final bool isPositive = pnlPaise >= 0;
    final Color pnlColor = isPositive ? AppColors.bullish : AppColors.bearish;

    return InkWell(
      onTap: onTap,
      splashColor: AppColors.primary.withAlpha(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.darkCardBorder, width: 0.8),
          ),
        ),
        child: Column(
          children: [
            // Row 1: Symbol & LTP
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      holding.symbol,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkTextPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.darkCardHover,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.darkCardBorder),
                      ),
                      child: Text(
                        'Qty: ${holding.quantity}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                StockFlashCell(quote: quote, compact: true),
              ],
            ),
            const SizedBox(height: 8),
            // Row 2: Avg Cost, Current Value, and Live P&L
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Avg Cost (using Decimal precision)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Avg. Cost',
                      style: TextStyle(fontSize: 11, color: AppColors.darkTextSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.formatDecimalRupees(holding.avgCostRupeesDecimal),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkTextPrimary,
                      ),
                    ),
                  ],
                ),
                // Current Value
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Current Value',
                      style: TextStyle(fontSize: 11, color: AppColors.darkTextSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.formatPaise(currentValuePaise),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkTextPrimary,
                      ),
                    ),
                  ],
                ),
                // Live P&L
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Unrealized P&L',
                      style: TextStyle(fontSize: 11, color: AppColors.darkTextSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${CurrencyFormatter.formatPaise(pnlPaise, showSign: true)} (${CurrencyFormatter.formatPercent(pnlPercent)})',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: pnlColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
