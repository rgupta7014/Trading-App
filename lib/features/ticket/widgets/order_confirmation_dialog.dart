import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trading_app/core/theme/app_theme.dart';
import 'package:trading_app/core/utils/currency_formatter.dart';
import 'package:trading_app/domain/models/order_model.dart';

/// Modal dialog showing the order execution confirmation details.
class OrderConfirmationDialog extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onViewHoldings;

  const OrderConfirmationDialog({
    super.key,
    required this.order,
    this.onViewHoldings,
  });

  static Future<void> show(
    BuildContext context, {
    required OrderModel order,
    VoidCallback? onViewHoldings,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => OrderConfirmationDialog(
        order: order,
        onViewHoldings: onViewHoldings,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isBuy = order.side == OrderSide.buy;
    final Color sideColor = isBuy ? AppColors.bullish : AppColors.bearish;
    final timeStr = DateFormat('dd MMM yyyy, hh:mm:ss a').format(order.timestamp);

    return Dialog(
      backgroundColor: AppColors.darkCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.darkCardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: sideColor.withAlpha(35),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle_rounded, color: sideColor, size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              'Order Executed!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.darkTextPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Market ${isBuy ? "BUY" : "SELL"} order completed successfully',
              style: const TextStyle(fontSize: 13, color: AppColors.darkTextSecondary),
            ),
            const SizedBox(height: 20),
            // Order Receipt Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.darkCardBorder),
              ),
              child: Column(
                children: [
                  _receiptRow(
                    'Symbol',
                    order.symbol,
                    isHighlight: true,
                    highlightColor: AppColors.accent,
                  ),
                  const Divider(height: 16, thickness: 0.8, color: AppColors.darkCardBorder),
                  _receiptRow(
                    'Side',
                    isBuy ? 'BUY' : 'SELL',
                    isHighlight: true,
                    highlightColor: sideColor,
                  ),
                  const Divider(height: 16, thickness: 0.8, color: AppColors.darkCardBorder),
                  _receiptRow('Quantity', '${order.quantity} shares'),
                  const Divider(height: 16, thickness: 0.8, color: AppColors.darkCardBorder),
                  _receiptRow(
                    'Executed Price (LTP)',
                    CurrencyFormatter.formatPaise(order.pricePaise),
                  ),
                  const Divider(height: 16, thickness: 0.8, color: AppColors.darkCardBorder),
                  _receiptRow(
                    'Total Value',
                    CurrencyFormatter.formatPaise(order.totalValuePaise),
                    isHighlight: true,
                  ),
                  const Divider(height: 16, thickness: 0.8, color: AppColors.darkCardBorder),
                  _receiptRow('Time', timeStr),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.darkCardBorder),
                    ),
                    child: const Text('Close'),
                  ),
                ),
                if (onViewHoldings != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onViewHoldings!();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('View Holdings'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _receiptRow(
    String label,
    String value, {
    bool isHighlight = false,
    Color? highlightColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.darkTextSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight ? 14 : 13,
            fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
            color: highlightColor ?? AppColors.darkTextPrimary,
          ),
        ),
      ],
    );
  }
}
