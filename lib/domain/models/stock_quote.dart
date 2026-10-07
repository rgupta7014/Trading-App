enum PriceDirection { up, down, none }

/// Represents a real-time price quote for a single stock.
///
/// All monetary values are strictly stored in integer paise.
class StockQuote {
  final String symbol;
  final String name;
  final String sector;
  final int basePricePaise;
  final int currentPricePaise;
  final PriceDirection lastTickDirection;
  final DateTime lastUpdated;

  const StockQuote({
    required this.symbol,
    required this.name,
    required this.sector,
    required this.basePricePaise,
    required this.currentPricePaise,
    this.lastTickDirection = PriceDirection.none,
    required this.lastUpdated,
  });

  /// Absolute price difference in integer paise from the previous close.
  int get changePaise => currentPricePaise - basePricePaise;

  /// Percentage change relative to the previous close.
  double get changePercent {
    if (basePricePaise == 0) return 0.0;
    return (changePaise / basePricePaise) * 100;
  }

  bool get isBullish => changePaise > 0;
  bool get isBearish => changePaise < 0;

  StockQuote copyWith({
    String? symbol,
    String? name,
    String? sector,
    int? basePricePaise,
    int? currentPricePaise,
    PriceDirection? lastTickDirection,
    DateTime? lastUpdated,
  }) {
    return StockQuote(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      sector: sector ?? this.sector,
      basePricePaise: basePricePaise ?? this.basePricePaise,
      currentPricePaise: currentPricePaise ?? this.currentPricePaise,
      lastTickDirection: lastTickDirection ?? this.lastTickDirection,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockQuote &&
          runtimeType == other.runtimeType &&
          symbol == other.symbol &&
          currentPricePaise == other.currentPricePaise &&
          lastTickDirection == other.lastTickDirection;

  @override
  int get hashCode =>
      symbol.hashCode ^
      currentPricePaise.hashCode ^
      lastTickDirection.hashCode;
}
