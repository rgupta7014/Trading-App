import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trading_app/core/constants/stock_constants.dart';
import 'package:trading_app/core/theme/app_theme.dart';
import 'package:trading_app/core/utils/currency_formatter.dart';
import 'package:trading_app/domain/models/order_model.dart';
import 'package:trading_app/features/market/providers/market_feed_provider.dart';
import 'package:trading_app/features/market/widgets/stock_flash_cell.dart';
import 'package:trading_app/features/ticket/providers/portfolio_provider.dart';
import 'package:trading_app/features/ticket/widgets/order_confirmation_dialog.dart';

class BuySellTicketScreen extends ConsumerStatefulWidget {
  final String initialSymbol;
  final OrderSide initialSide;
  final VoidCallback? onNavigateToHoldings;
  final VoidCallback? onBackToWatchlist;
  final bool isModalRoute;

  const BuySellTicketScreen({
    super.key,
    this.initialSymbol = 'RELIANCE',
    this.initialSide = OrderSide.buy,
    this.onNavigateToHoldings,
    this.onBackToWatchlist,
    this.isModalRoute = false,
  });

  @override
  ConsumerState<BuySellTicketScreen> createState() => _BuySellTicketScreenState();
}

class _BuySellTicketScreenState extends ConsumerState<BuySellTicketScreen> {
  late String _selectedSymbol;
  late OrderSide _side;
  final TextEditingController _qtyController = TextEditingController(text: '1');
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _selectedSymbol = widget.initialSymbol;
    _side = widget.initialSide;
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  void _onQtyChanged(String value) {
    final parsed = int.tryParse(value.trim());
    setState(() {
      _quantity = parsed ?? 0;
    });
  }

  void _adjustQty(int delta) {
    final current = _quantity;
    final next = (current + delta).clamp(1, 100000);
    _qtyController.text = next.toString();
    setState(() {
      _quantity = next;
    });
  }

  void _setMaxQuantity(int maxAvailable) {
    final qty = maxAvailable.clamp(1, 100000);
    _qtyController.text = qty.toString();
    setState(() {
      _quantity = qty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final quote = ref.watch(stockQuoteFamily(_selectedSymbol));

    final walletBalance = ref.watch(walletBalanceProvider);
    final portfolioNotifier = ref.read(portfolioProvider.notifier);
    final quantityHeld = portfolioNotifier.getQuantityHeld(_selectedSymbol);

    final int ltpPaise = quote.currentPricePaise;
    final int projectedOrderValuePaise = _quantity > 0 ? _quantity * ltpPaise : 0;
    final bool isBuy = _side == OrderSide.buy;

    String? validationError;
    if (_quantity <= 0) {
      validationError = 'Quantity must be a positive whole number';
    } else if (isBuy) {
      if (projectedOrderValuePaise > walletBalance) {
        final shortBy = projectedOrderValuePaise - walletBalance;
        validationError =
            'Insufficient balance. Need ${CurrencyFormatter.formatPaise(shortBy)} more';
      }
    } else {
      if (quantityHeld <= 0) {
        validationError = 'You do not own any shares of $_selectedSymbol to sell';
      } else if (_quantity > quantityHeld) {
        validationError =
            'Cannot sell $_quantity shares. Maximum available: $quantityHeld shares';
      }
    }

    final bool canSubmit = validationError == null && _quantity > 0 && ltpPaise > 0;
    final Color sideColor = isBuy ? AppColors.bullish : AppColors.bearish;

    return Scaffold(
      appBar: AppBar(
        leading: widget.isModalRoute || Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.maybePop(context),
              )
            : (widget.onBackToWatchlist != null
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: widget.onBackToWatchlist,
                  )
                : null),
        title: const Text('Order Ticket'),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.darkCardBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined,
                    size: 16, color: AppColors.accent),
                const SizedBox(width: 6),
                Text(
                  CurrencyFormatter.formatPaise(walletBalance),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkTextPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.darkCardBorder),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedSymbol,
                            isExpanded: true,
                            dropdownColor: AppColors.darkCard,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                                color: AppColors.darkTextSecondary),
                            items: AppConstants.stocks.map((meta) {
                              return DropdownMenuItem<String>(
                                value: meta.symbol,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      meta.symbol,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.darkTextPrimary,
                                      ),
                                    ),
                                    Text(
                                      meta.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.darkTextSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (newSymbol) {
                              if (newSymbol != null) {
                                setState(() {
                                  _selectedSymbol = newSymbol;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      StockFlashCell(quote: quote),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.darkCardBorder),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Shares currently held in portfolio:',
                        style: TextStyle(fontSize: 12, color: AppColors.darkTextSecondary),
                      ),
                      Text(
                        '$quantityHeld shares',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: quantityHeld > 0 ? AppColors.accent : AppColors.darkTextMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.darkCardBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _side = OrderSide.buy),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isBuy ? AppColors.bullish : Colors.transparent,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'BUY',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: isBuy ? Colors.white : AppColors.darkTextSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _side = OrderSide.sell),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !isBuy ? AppColors.bearish : Colors.transparent,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'SELL',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: !isBuy ? Colors.white : AppColors.darkTextSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Quantity (Shares)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.darkTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _qtyController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.darkTextPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Enter quantity',
                prefixIcon: const Icon(Icons.numbers_rounded, color: AppColors.darkTextSecondary),
                suffixText: 'Shares',
                suffixStyle: const TextStyle(color: AppColors.darkTextSecondary),
                errorText: validationError,
                errorMaxLines: 2,
              ),
              onChanged: _onQtyChanged,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  label: const Text('+1'),
                  backgroundColor: AppColors.darkCard,
                  side: const BorderSide(color: AppColors.darkCardBorder),
                  onPressed: () => _adjustQty(1),
                ),
                ActionChip(
                  label: const Text('+5'),
                  backgroundColor: AppColors.darkCard,
                  side: const BorderSide(color: AppColors.darkCardBorder),
                  onPressed: () => _adjustQty(5),
                ),
                ActionChip(
                  label: const Text('+10'),
                  backgroundColor: AppColors.darkCard,
                  side: const BorderSide(color: AppColors.darkCardBorder),
                  onPressed: () => _adjustQty(10),
                ),
                ActionChip(
                  label: const Text('+50'),
                  backgroundColor: AppColors.darkCard,
                  side: const BorderSide(color: AppColors.darkCardBorder),
                  onPressed: () => _adjustQty(50),
                ),
                if (!isBuy && quantityHeld > 0)
                  ActionChip(
                    label: Text('All ($quantityHeld)'),
                    backgroundColor: AppColors.bearish.withAlpha(30),
                    side: const BorderSide(color: AppColors.bearish),
                    onPressed: () => _setMaxQuantity(quantityHeld),
                  ),
                if (isBuy && ltpPaise > 0)
                  ActionChip(
                    label: const Text('Max Affordable'),
                    backgroundColor: AppColors.primary.withAlpha(30),
                    side: const BorderSide(color: AppColors.primary),
                    onPressed: () {
                      final maxAffordable = walletBalance ~/ ltpPaise;
                      if (maxAffordable > 0) {
                        _setMaxQuantity(maxAffordable);
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.darkCardBorder),
              ),
              child: Column(
                children: [
                  _summaryRow(
                    'Order Type',
                    'Market Order (Instant)',
                  ),
                  const SizedBox(height: 10),
                  _summaryRow(
                    'Execution Price',
                    'Live LTP: ${CurrencyFormatter.formatPaise(ltpPaise)}',
                  ),
                  const SizedBox(height: 10),
                  _summaryRow(
                    isBuy ? 'Required Margin' : 'Estimated Credit',
                    CurrencyFormatter.formatPaise(projectedOrderValuePaise),
                    isBold: true,
                    highlightColor: sideColor,
                  ),
                  const SizedBox(height: 10),
                  _summaryRow(
                    isBuy ? 'Available Wallet Balance' : 'Shares to Remain',
                    isBuy
                        ? CurrencyFormatter.formatPaise(walletBalance)
                        : '${(quantityHeld - _quantity).clamp(0, 999999)} shares',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: canSubmit
                    ? () {
                        final currentQuote =
                            ref.read(marketFeedServiceProvider).getQuote(_selectedSymbol);
                        final result = ref
                            .read(portfolioProvider.notifier)
                            .executeOrder(
                              symbol: _selectedSymbol,
                              side: _side,
                              quantity: _quantity,
                              submitLtpPaise: currentQuote.currentPricePaise,
                            );

                        if (result.success && result.order != null) {
                          OrderConfirmationDialog.show(
                            context,
                            order: result.order!,
                            onViewHoldings: widget.onNavigateToHoldings,
                          );
                        } else if (result.errorMessage != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result.errorMessage!),
                              backgroundColor: AppColors.bearish,
                            ),
                          );
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: sideColor,
                  disabledBackgroundColor: sideColor.withAlpha(70),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  '${isBuy ? "BUY" : "SELL"} $_selectedSymbol',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? highlightColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.darkTextSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: highlightColor ?? AppColors.darkTextPrimary,
          ),
        ),
      ],
    );
  }
}
