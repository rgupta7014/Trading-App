import 'package:decimal/decimal.dart';

/// Represents a held stock position.
///
/// CRITICAL:
/// 1. Money is strictly stored in integer paise ([totalCostPaise]).
/// 2. Quantity is strictly positive integer ([quantity]).
/// 3. Average cost for display is calculated using the [Decimal] package.
/// 4. P&L is NEVER stored statically; it is always computed dynamically
///    from the holding and the live market LTP.
class HoldingModel {
  final String symbol;
  final int quantity; // Positive integer
  final int totalCostPaise; // Total cost basis in integer paise

  const HoldingModel({
    required this.symbol,
    required this.quantity,
    required this.totalCostPaise,
  })  : assert(quantity > 0, 'Quantity must be strictly positive'),
        assert(totalCostPaise >= 0, 'Total cost must be non-negative');

  /// Average cost per share in Rupees, calculated precisely with [Decimal].
  ///
  /// totalCostPaise / (quantity * 100) gives Rupee value with decimal precision.
  Decimal get avgCostRupeesDecimal {
    if (quantity == 0) return Decimal.zero;
    return (Decimal.fromInt(totalCostPaise) /
            Decimal.fromInt(quantity * 100))
        .toDecimal(scaleOnInfinitePrecision: 4);
  }

  /// Average cost in paise (approximate integer for quick checks).
  int get avgCostPaise => quantity > 0 ? totalCostPaise ~/ quantity : 0;

  /// Current portfolio market value given the live LTP in paise.
  int currentValuePaise(int ltpPaise) => quantity * ltpPaise;

  /// Real-time Unrealized P&L in integer paise.
  int pnlPaise(int ltpPaise) => currentValuePaise(ltpPaise) - totalCostPaise;

  /// Real-time Unrealized P&L percentage.
  double pnlPercent(int ltpPaise) {
    if (totalCostPaise == 0) return 0.0;
    return (pnlPaise(ltpPaise) / totalCostPaise) * 100;
  }

  /// Creates a new holding updated with an additional BUY lot.
  HoldingModel withBuy({
    required int buyQty,
    required int buyPricePaise,
  }) {
    final int newQty = quantity + buyQty;
    final int additionalCost = buyQty * buyPricePaise;
    return HoldingModel(
      symbol: symbol,
      quantity: newQty,
      totalCostPaise: totalCostPaise + additionalCost,
    );
  }

  /// Creates an updated holding after a SELL order.
  ///
  /// Returns null if quantity is reduced to zero (holding should be removed).
  HoldingModel? withSell({
    required int sellQty,
  }) {
    if (sellQty >= quantity) {
      return null; // Position completely closed
    }
    final int newQty = quantity - sellQty;
    // Maintain identical average cost basis per share
    final int newTotalCost = (totalCostPaise * newQty) ~/ quantity;
    return HoldingModel(
      symbol: symbol,
      quantity: newQty,
      totalCostPaise: newTotalCost,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'quantity': quantity,
      'totalCostPaise': totalCostPaise,
    };
  }

  factory HoldingModel.fromJson(Map<String, dynamic> json) {
    return HoldingModel(
      symbol: json['symbol'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      totalCostPaise: (json['totalCostPaise'] as num?)?.toInt() ?? 0,
    );
  }
}
