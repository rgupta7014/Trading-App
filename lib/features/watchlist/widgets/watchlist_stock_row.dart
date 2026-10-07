import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trading_app/core/theme/app_theme.dart';
import 'package:trading_app/features/market/providers/market_feed_provider.dart';
import 'package:trading_app/features/market/widgets/stock_flash_cell.dart';

/// Reorderable and dismissible stock row for a watchlist.
///
/// MUST listen strictly to its own symbol quote for granular updates.
class WatchlistStockRow extends ConsumerWidget {
  final String symbol;
  final int index;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const WatchlistStockRow({
    super.key,
    required this.symbol,
    required this.index,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quote = ref.watch(stockQuoteFamily(symbol));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.primary.withAlpha(20),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.darkCardBorder, width: 0.8),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Drag Handle
              ReorderableDragStartListener(
                index: index,
                child: const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(
                    Icons.drag_indicator_rounded,
                    color: AppColors.darkTextMuted,
                    size: 20,
                  ),
                ),
              ),
              // Symbol Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      quote.symbol,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      quote.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Live Price Cell with Green/Red Flash
              StockFlashCell(quote: quote),
              const SizedBox(width: 4),
              // Remove button
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                color: AppColors.darkTextMuted,
                tooltip: 'Remove from watchlist',
                onPressed: onRemove,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
