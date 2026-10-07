import 'package:decimal/decimal.dart';

class HoldingModel {
  final String symbol;
  final int quantity;
  final int totalCostPaise;

  const HoldingModel({
    required this.symbol,
    required this.quantity,
    required this.totalCostPaise,
  })  : assert(quantity > 0, 'Quantity must be strictly positive'),
        assert(totalCostPaise >= 0, 'Total cost must be non-negative');

  Decimal get avgCostRupeesDecimal {
    if (quantity == 0) return Decimal.zero;
    return (Decimal.fromInt(totalCostPaise) /
            Decimal.fromInt(quantity * 100))
        .toDecimal(scaleOnInfinitePrecision: 4);
  }

  int get avgCostPaise => quantity > 0 ? totalCostPaise ~/ quantity : 0;

  int currentValuePaise(int ltpPaise) => quantity * ltpPaise;

  int pnlPaise(int ltpPaise) => currentValuePaise(ltpPaise) - totalCostPaise;

  double pnlPercent(int ltpPaise) {
    if (totalCostPaise == 0) return 0.0;
    return (pnlPaise(ltpPaise) / totalCostPaise) * 100;
  }

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

  HoldingModel? withSell({
    required int sellQty,
  }) {
    if (sellQty >= quantity) {
      return null;
    }
    final int newQty = quantity - sellQty;
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
