import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trading_app/core/theme/app_theme.dart';
import 'package:trading_app/features/market/providers/market_feed_provider.dart';
import 'package:trading_app/features/market/widgets/stock_flash_cell.dart';

class MarketStockRow extends ConsumerWidget {
  final String symbol;
  final VoidCallback? onTap;

  const MarketStockRow({
    super.key,
    required this.symbol,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quote = ref.watch(stockQuoteFamily(symbol));

    return InkWell(
      onTap: onTap,
      splashColor: AppColors.primary.withAlpha(25),
      highlightColor: AppColors.primary.withAlpha(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.darkCardHover,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.darkCardBorder,
                  width: 0.8,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                symbol.substring(0, symbol.length >= 3 ? 3 : symbol.length),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent,
                ),
              ),
            ),
            const SizedBox(width: 14),
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
                      letterSpacing: 0.1,
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
            const SizedBox(width: 10),
            StockFlashCell(quote: quote),
          ],
        ),
      ),
    );
  }
}
