/// Stock metadata definition for the initial list of 10 stocks.
class StockMetadata {
  final String symbol;
  final String name;
  final String sector;
  final int basePricePaise; // 1 Rupee = 100 Paise

  const StockMetadata({
    required this.symbol,
    required this.name,
    required this.sector,
    required this.basePricePaise,
  });
}

class AppConstants {
  AppConstants._();

  /// Starting wallet balance: ₹10,00,000 = 1,000,000 Rupees = 100,000,000 Paise
  static const int initialWalletBalancePaise = 100000000;

  /// Default tick rate in ticks per second per stock
  static const double defaultTicksPerSecond = 1.0;

  /// Maximum stress-test tick rate: 20 ticks/sec per stock
  static const double maxTicksPerSecond = 20.0;

  /// Minimum tick rate: 0.2 ticks/sec
  static const double minTicksPerSecond = 0.2;

  /// The 10 required stocks for the trading application
  static const List<StockMetadata> stocks = [
    StockMetadata(
      symbol: 'RELIANCE',
      name: 'Reliance Industries Ltd.',
      sector: 'Energy & Oil',
      basePricePaise: 295000, // ₹2,950.00
    ),
    StockMetadata(
      symbol: 'TCS',
      name: 'Tata Consultancy Services Ltd.',
      sector: 'Information Tech',
      basePricePaise: 412000, // ₹4,120.00
    ),
    StockMetadata(
      symbol: 'INFY',
      name: 'Infosys Ltd.',
      sector: 'Information Tech',
      basePricePaise: 187500, // ₹1,875.00
    ),
    StockMetadata(
      symbol: 'HDFCBANK',
      name: 'HDFC Bank Ltd.',
      sector: 'Banking & Finance',
      basePricePaise: 164000, // ₹1,640.00
    ),
    StockMetadata(
      symbol: 'ICICIBANK',
      name: 'ICICI Bank Ltd.',
      sector: 'Banking & Finance',
      basePricePaise: 121500, // ₹1,215.00
    ),
    StockMetadata(
      symbol: 'SBIN',
      name: 'State Bank of India',
      sector: 'Banking & PSU',
      basePricePaise: 81500, // ₹815.00
    ),
    StockMetadata(
      symbol: 'ITC',
      name: 'ITC Ltd.',
      sector: 'FMCG & Conglomerate',
      basePricePaise: 49500, // ₹495.00
    ),
    StockMetadata(
      symbol: 'LT',
      name: 'Larsen & Toubro Ltd.',
      sector: 'Infrastructure',
      basePricePaise: 362000, // ₹3,620.00
    ),
    StockMetadata(
      symbol: 'BHARTIARTL',
      name: 'Bharti Airtel Ltd.',
      sector: 'Telecommunications',
      basePricePaise: 156000, // ₹1,560.00
    ),
    StockMetadata(
      symbol: 'AXISBANK',
      name: 'Axis Bank Ltd.',
      sector: 'Banking & Finance',
      basePricePaise: 118000, // ₹1,180.00
    ),
  ];

  static final Map<String, StockMetadata> stockMap = {
    for (final s in stocks) s.symbol: s,
  };
}
