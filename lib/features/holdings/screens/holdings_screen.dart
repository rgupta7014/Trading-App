import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trading_app/core/theme/app_theme.dart';
import 'package:trading_app/domain/models/holding_model.dart';
import 'package:trading_app/features/holdings/widgets/holding_stock_row.dart';
import 'package:trading_app/features/holdings/widgets/holdings_summary_card.dart';
import 'package:trading_app/features/market/providers/market_feed_provider.dart';
import 'package:trading_app/features/ticket/providers/portfolio_provider.dart';

enum HoldingSortType { pnl, symbol, currentValue }
enum SortOrder { ascending, descending }

/// Holdings Portfolio Screen with live P&L, sorting, aggregate summary, and empty state.
class HoldingsScreen extends ConsumerStatefulWidget {
  final Function(String symbol)? onStockSelected;
  final VoidCallback? onExploreMarket;

  const HoldingsScreen({
    super.key,
    this.onStockSelected,
    this.onExploreMarket,
  });

  @override
  ConsumerState<HoldingsScreen> createState() => _HoldingsScreenState();
}

class _HoldingsScreenState extends ConsumerState<HoldingsScreen> {
  // Default sorting: P&L descending (as requested in assignment doc)
  HoldingSortType _sortType = HoldingSortType.pnl;
  SortOrder _sortOrder = SortOrder.descending;

  List<HoldingModel> _sortHoldings(
    List<HoldingModel> holdings,
    WidgetRef ref,
  ) {
    final feedService = ref.watch(marketFeedServiceProvider);
    final sorted = List<HoldingModel>.from(holdings);

    sorted.sort((a, b) {
      int cmp = 0;
      switch (_sortType) {
        case HoldingSortType.pnl:
          final ltpA = feedService.getQuote(a.symbol).currentPricePaise;
          final ltpB = feedService.getQuote(b.symbol).currentPricePaise;
          final pnlA = a.pnlPaise(ltpA);
          final pnlB = b.pnlPaise(ltpB);
          cmp = pnlA.compareTo(pnlB);
          break;
        case HoldingSortType.symbol:
          cmp = a.symbol.compareTo(b.symbol);
          break;
        case HoldingSortType.currentValue:
          final ltpA = feedService.getQuote(a.symbol).currentPricePaise;
          final ltpB = feedService.getQuote(b.symbol).currentPricePaise;
          final valA = a.currentValuePaise(ltpA);
          final valB = b.currentValuePaise(ltpB);
          cmp = valA.compareTo(valB);
          break;
      }

      return _sortOrder == SortOrder.descending ? -cmp : cmp;
    });

    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final rawHoldings = ref.watch(holdingsListProvider);
    final sortedHoldings = _sortHoldings(rawHoldings, ref);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.pie_chart_rounded, color: AppColors.accent, size: 24),
            SizedBox(width: 8),
            Text('Portfolio Holdings'),
          ],
        ),
      ),
      body: rawHoldings.isEmpty
          ? _buildEmptyState(context)
          : Column(
              children: [
                // Top Aggregate Summary
                const HoldingsSummaryCard(),

                // Filter & Sort Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        'HOLDINGS (${rawHoldings.length})',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: AppColors.darkTextSecondary,
                        ),
                      ),
                      const Spacer(),
                      // Sort Type Selector Menu
                      PopupMenuButton<HoldingSortType>(
                        initialValue: _sortType,
                        color: AppColors.darkCard,
                        onSelected: (val) => setState(() => _sortType = val),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.darkCard,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.darkCardBorder),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.sort_rounded, size: 14, color: AppColors.accent),
                              const SizedBox(width: 4),
                              Text(
                                _sortLabel(_sortType),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(
                            value: HoldingSortType.pnl,
                            child: Text('Sort by P&L'),
                          ),
                          const PopupMenuItem(
                            value: HoldingSortType.symbol,
                            child: Text('Sort by Symbol'),
                          ),
                          const PopupMenuItem(
                            value: HoldingSortType.currentValue,
                            child: Text('Sort by Current Value'),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      // Direction Toggle (Ascending / Descending)
                      IconButton.filledTonal(
                        onPressed: () {
                          setState(() {
                            _sortOrder = _sortOrder == SortOrder.descending
                                ? SortOrder.ascending
                                : SortOrder.descending;
                          });
                        },
                        icon: Icon(
                          _sortOrder == SortOrder.descending
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                          size: 16,
                          color: AppColors.accent,
                        ),
                        tooltip: _sortOrder == SortOrder.descending
                            ? 'Descending (High to Low)'
                            : 'Ascending (Low to High)',
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.darkCard,
                          minimumSize: const Size(36, 36),
                          padding: EdgeInsets.zero,
                          side: const BorderSide(color: AppColors.darkCardBorder),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 0.8, color: AppColors.darkCardBorder),

                // Holdings List
                Expanded(
                  child: ListView.builder(
                    itemCount: sortedHoldings.length,
                    itemBuilder: (context, index) {
                      final holding = sortedHoldings[index];
                      // ValueKey(holding.symbol) ensures proper identification
                      return HoldingStockRow(
                        key: ValueKey(holding.symbol),
                        holding: holding,
                        onTap: () {
                          if (widget.onStockSelected != null) {
                            widget.onStockSelected!(holding.symbol);
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

  String _sortLabel(HoldingSortType type) {
    switch (type) {
      case HoldingSortType.pnl:
        return 'P&L';
      case HoldingSortType.symbol:
        return 'Symbol';
      case HoldingSortType.currentValue:
        return 'Value';
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.darkCardBorder),
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                size: 40,
                color: AppColors.darkTextSecondary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Holdings in Portfolio',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.darkTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You currently hold zero shares. Start by executing a simulated BUY order from the Watchlist or Market Overview.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.darkTextSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            if (widget.onExploreMarket != null)
              ElevatedButton.icon(
                onPressed: widget.onExploreMarket,
                icon: const Icon(Icons.explore_outlined, size: 18),
                label: const Text('Explore Market'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
