import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trading_app/core/theme/app_theme.dart';
import 'package:trading_app/core/utils/currency_formatter.dart';
import 'package:trading_app/features/market/providers/market_feed_provider.dart';
import 'package:trading_app/features/ticket/providers/portfolio_provider.dart';

class HoldingsSummaryCard extends ConsumerWidget {
  const HoldingsSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holdings = ref.watch(holdingsListProvider);
    final walletCash = ref.watch(walletBalanceProvider);
    final feedService = ref.watch(marketFeedServiceProvider);

    for (final h in holdings) {
      ref.watch(stockQuoteFamily(h.symbol));
    }

    int totalInvestedPaise = 0;
    int currentMarketValuePaise = 0;

    for (final holding in holdings) {
      final currentLtp = feedService.getQuote(holding.symbol).currentPricePaise;
      totalInvestedPaise += holding.totalCostPaise;
      currentMarketValuePaise += holding.quantity * currentLtp;
    }

    final int totalPnlPaise = currentMarketValuePaise - totalInvestedPaise;
    final double totalPnlPercent = totalInvestedPaise > 0
        ? (totalPnlPaise / totalInvestedPaise) * 100
        : 0.0;

    final bool isPositive = totalPnlPaise >= 0;
    final Color pnlColor = isPositive ? AppColors.bullish : AppColors.bearish;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.darkCard,
            AppColors.darkCardHover,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.darkCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PORTFOLIO VALUE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: AppColors.darkTextSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accent.withAlpha(25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${holdings.length} stocks held',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.formatPaise(currentMarketValuePaise),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: AppColors.darkTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isPositive
                  ? AppColors.bullishBackground
                  : AppColors.bearishBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                  color: pnlColor,
                  size: 18,
                ),
                const SizedBox(width: 6),
                const Text(
                  'Total P&L: ',
                  style: TextStyle(fontSize: 12, color: AppColors.darkTextSecondary),
                ),
                Text(
                  '${CurrencyFormatter.formatPaise(totalPnlPaise, showSign: true)} (${CurrencyFormatter.formatPercent(totalPnlPercent)})',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: pnlColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 0.8, color: AppColors.darkCardBorder),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Invested',
                    style: TextStyle(fontSize: 12, color: AppColors.darkTextSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.formatPaise(totalInvestedPaise),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkTextPrimary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Wallet Cash',
                    style: TextStyle(fontSize: 12, color: AppColors.darkTextSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.formatPaise(walletCash),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
