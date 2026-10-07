class StockMetadata {
  final String symbol;
  final String name;
  final String sector;
  final int basePricePaise;

  const StockMetadata({
    required this.symbol,
    required this.name,
    required this.sector,
    required this.basePricePaise,
  });
}

class AppConstants {
  AppConstants._();

  static const int initialWalletBalancePaise = 100000000;
  static const double defaultTicksPerSecond = 1.0;
  static const double maxTicksPerSecond = 20.0;
  static const double minTicksPerSecond = 0.2;

  static const List<StockMetadata> stocks = [
    StockMetadata(
      symbol: 'RELIANCE',
      name: 'Reliance Industries Ltd.',
      sector: 'Energy & Oil',
      basePricePaise: 295000,
    ),
    StockMetadata(
      symbol: 'TCS',
      name: 'Tata Consultancy Services Ltd.',
      sector: 'Information Tech',
      basePricePaise: 412000,
    ),
    StockMetadata(
      symbol: 'INFY',
      name: 'Infosys Ltd.',
      sector: 'Information Tech',
      basePricePaise: 187500,
    ),
    StockMetadata(
      symbol: 'HDFCBANK',
      name: 'HDFC Bank Ltd.',
      sector: 'Banking & Finance',
      basePricePaise: 164000,
    ),
    StockMetadata(
      symbol: 'ICICIBANK',
      name: 'ICICI Bank Ltd.',
      sector: 'Banking & Finance',
      basePricePaise: 121500,
    ),
    StockMetadata(
      symbol: 'SBIN',
      name: 'State Bank of India',
      sector: 'Banking & PSU',
      basePricePaise: 81500,
    ),
    StockMetadata(
      symbol: 'ITC',
      name: 'ITC Ltd.',
      sector: 'FMCG & Conglomerate',
      basePricePaise: 49500,
    ),
    StockMetadata(
      symbol: 'LT',
      name: 'Larsen & Toubro Ltd.',
      sector: 'Infrastructure',
      basePricePaise: 362000,
    ),
    StockMetadata(
      symbol: 'BHARTIARTL',
      name: 'Bharti Airtel Ltd.',
      sector: 'Telecommunications',
      basePricePaise: 156000,
    ),
    StockMetadata(
      symbol: 'AXISBANK',
      name: 'Axis Bank Ltd.',
      sector: 'Banking & Finance',
      basePricePaise: 118000,
    ),
  ];

  static final Map<String, StockMetadata> stockMap = {
    for (final s in stocks) s.symbol: s,
  };
}
