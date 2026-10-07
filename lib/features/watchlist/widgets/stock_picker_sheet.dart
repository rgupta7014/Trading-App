import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trading_app/core/constants/stock_constants.dart';
import 'package:trading_app/core/theme/app_theme.dart';
import 'package:trading_app/features/watchlist/providers/watchlist_provider.dart';

/// Modal sheet to pick and add stocks to the current watchlist from the 10 stocks.
class StockPickerSheet extends ConsumerStatefulWidget {
  final String watchlistId;

  const StockPickerSheet({
    super.key,
    required this.watchlistId,
  });

  static void show(BuildContext context, String watchlistId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StockPickerSheet(watchlistId: watchlistId),
    );
  }

  @override
  ConsumerState<StockPickerSheet> createState() => _StockPickerSheetState();
}

class _StockPickerSheetState extends ConsumerState<StockPickerSheet> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final watchlists = ref.watch(watchlistProvider);
    final watchlist = watchlists.firstWhere(
      (w) => w.id == widget.watchlistId,
      orElse: () => watchlists.isNotEmpty ? watchlists.first : watchlists.first,
    );
    final existingSymbols = watchlist.symbols.toSet();

    final filteredStocks = AppConstants.stocks.where((s) {
      final query = _searchQuery.toLowerCase();
      return s.symbol.toLowerCase().contains(query) ||
          s.name.toLowerCase().contains(query) ||
          s.sector.toLowerCase().contains(query);
    }).toList();

    return Padding(
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.darkCardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add to "${watchlist.name}"',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkTextPrimary,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: AppColors.darkTextSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Search input
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search 10 stocks by name or symbol...',
              prefixIcon: Icon(Icons.search_rounded, color: AppColors.darkTextSecondary),
            ),
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
          ),
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.45,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: filteredStocks.length,
              separatorBuilder: (_, index) => const Divider(
                height: 1,
                thickness: 0.8,
                color: AppColors.darkCardBorder,
              ),
              itemBuilder: (context, index) {
                final stock = filteredStocks[index];
                final isAdded = existingSymbols.contains(stock.symbol);

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.darkCardHover,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      stock.symbol.substring(0, stock.symbol.length >= 3 ? 3 : stock.symbol.length),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                  title: Text(
                    stock.symbol,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkTextPrimary,
                    ),
                  ),
                  subtitle: Text(
                    stock.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.darkTextSecondary),
                  ),
                  trailing: isAdded
                      ? const Chip(
                          label: Text('Added', style: TextStyle(fontSize: 11)),
                          avatar: Icon(Icons.check, size: 14, color: AppColors.bullish),
                          backgroundColor: AppColors.bullishBackground,
                          side: BorderSide.none,
                          padding: EdgeInsets.zero,
                        )
                      : FilledButton.tonal(
                          onPressed: () {
                            ref
                                .read(watchlistProvider.notifier)
                                .addStock(watchlist.id, stock.symbol);
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary.withAlpha(40),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            minimumSize: Size.zero,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, size: 14, color: AppColors.primary),
                              SizedBox(width: 4),
                              Text('Add', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                            ],
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
