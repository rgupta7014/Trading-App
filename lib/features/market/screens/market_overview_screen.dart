import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trading_app/core/constants/stock_constants.dart';
import 'package:trading_app/core/theme/app_theme.dart';
import 'package:trading_app/features/market/providers/market_feed_provider.dart';
import 'package:trading_app/features/market/widgets/market_stock_row.dart';
import 'package:trading_app/features/market/widgets/tick_rate_control_sheet.dart';

/// Screen displaying the live market overview for all 10 stocks.
class MarketOverviewScreen extends ConsumerWidget {
  final Function(String symbol)? onStockSelected;

  const MarketOverviewScreen({
    super.key,
    this.onStockSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tickRate = ref.watch(tickRateProvider);
    final isRunning = ref.watch(isTickerRunningProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.candlestick_chart_rounded, color: AppColors.accent, size: 24),
            SizedBox(width: 8),
            Text('Live Market'),
          ],
        ),
        actions: [
          // Feed speed indicator / quick launcher
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ActionChip(
              avatar: Icon(
                isRunning ? Icons.speed_rounded : Icons.pause_circle_outline,
                size: 16,
                color: tickRate >= 10.0 ? AppColors.bearish : AppColors.accent,
              ),
              label: Text(
                '${tickRate.toStringAsFixed(1)}/s',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              backgroundColor: AppColors.darkCard,
              side: const BorderSide(color: AppColors.darkCardBorder),
              onPressed: () => TickRateControlSheet.show(context),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Market Info Banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withAlpha(40),
                  AppColors.accent.withAlpha(20),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.darkCardBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NSE / BSE MOCK FEED',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '10 Bluechip Stocks',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkTextPrimary,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => TickRateControlSheet.show(context),
                  icon: const Icon(Icons.tune_rounded, size: 16),
                  label: const Text('Adjust Rate', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkCard,
                    foregroundColor: AppColors.darkTextPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
          // Stock List with strictly isolated row listeners
          Expanded(
            child: ListView.separated(
              itemCount: AppConstants.stocks.length,
              separatorBuilder: (_, index) => const Divider(
                height: 1,
                thickness: 0.8,
                color: AppColors.darkCardBorder,
              ),
              itemBuilder: (context, index) {
                final symbol = AppConstants.stocks[index].symbol;
                // Keyed by ValueKey(symbol) for optimal Flutter diffing
                return MarketStockRow(
                  key: ValueKey(symbol),
                  symbol: symbol,
                  onTap: () {
                    if (onStockSelected != null) {
                      onStockSelected!(symbol);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
