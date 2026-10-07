import 'package:flutter/material.dart';
import 'package:trading_app/core/theme/app_theme.dart';
import 'package:trading_app/core/utils/currency_formatter.dart';
import 'package:trading_app/domain/models/stock_quote.dart';

/// Reusable widget for displaying a live price quote with brief up/down flash animations.
class StockFlashCell extends StatefulWidget {
  final StockQuote quote;
  final bool compact;

  const StockFlashCell({
    super.key,
    required this.quote,
    this.compact = false,
  });

  @override
  State<StockFlashCell> createState() => _StockFlashCellState();
}

class _StockFlashCellState extends State<StockFlashCell>
    with SingleTickerProviderStateMixin {
  late AnimationController _flashController;
  late Animation<Color?> _flashAnimation;
  int _lastPrice = 0;

  @override
  void initState() {
    super.initState();
    _lastPrice = widget.quote.currentPricePaise;

    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _flashAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.transparent,
    ).animate(_flashController);
  }

  @override
  void didUpdateWidget(covariant StockFlashCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.quote.currentPricePaise != _lastPrice) {
      final direction = widget.quote.currentPricePaise > _lastPrice
          ? PriceDirection.up
          : PriceDirection.down;
      _lastPrice = widget.quote.currentPricePaise;

      final Color flashColor = direction == PriceDirection.up
          ? AppColors.bullishFlash
          : AppColors.bearishFlash;

      _flashAnimation = ColorTween(
        begin: flashColor,
        end: Colors.transparent,
      ).animate(
        CurvedAnimation(parent: _flashController, curve: Curves.easeOut),
      );

      _flashController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quote = widget.quote;
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

    return AnimatedBuilder(
      animation: _flashController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _flashAnimation.value ?? Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                CurrencyFormatter.formatPaise(quote.currentPricePaise),
                style: TextStyle(
                  fontSize: widget.compact ? 14 : 16,
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
      },
    );
  }
}
