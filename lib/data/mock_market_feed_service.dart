import 'dart:async';
import 'dart:math';
import 'package:trading_app/core/constants/stock_constants.dart';
import 'package:trading_app/domain/models/stock_quote.dart';

class MockMarketFeedService {
  final Random _random;
  final Map<String, StockQuote> _currentQuotes = {};
  final StreamController<StockQuote> _tickStreamController =
      StreamController<StockQuote>.broadcast();

  Timer? _timer;
  double _ticksPerSecondPerStock = AppConstants.defaultTicksPerSecond;
  int _currentStockIndex = 0;
  bool _isRunning = false;

  MockMarketFeedService({Random? random}) : _random = random ?? Random() {
    _initQuotes();
  }

  void _initQuotes() {
    final now = DateTime.now();
    for (final meta in AppConstants.stocks) {
      _currentQuotes[meta.symbol] = StockQuote(
        symbol: meta.symbol,
        name: meta.name,
        sector: meta.sector,
        basePricePaise: meta.basePricePaise,
        currentPricePaise: meta.basePricePaise,
        lastTickDirection: PriceDirection.none,
        lastUpdated: now,
      );
    }
  }

  Map<String, StockQuote> get currentQuotes => Map.unmodifiable(_currentQuotes);

  StockQuote getQuote(String symbol) {
    final quote = _currentQuotes[symbol];
    if (quote != null) return quote;
    final meta = AppConstants.stockMap[symbol];
    if (meta != null) {
      return StockQuote(
        symbol: meta.symbol,
        name: meta.name,
        sector: meta.sector,
        basePricePaise: meta.basePricePaise,
        currentPricePaise: meta.basePricePaise,
        lastUpdated: DateTime.now(),
      );
    }
    throw ArgumentError('Unknown stock symbol: $symbol');
  }

  Stream<StockQuote> get quoteStream => _tickStreamController.stream;

  Stream<StockQuote> streamForSymbol(String symbol) {
    return _tickStreamController.stream.where((q) => q.symbol == symbol);
  }

  double get ticksPerSecondPerStock => _ticksPerSecondPerStock;

  bool get isRunning => _isRunning;

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _scheduleTimer();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }

  void setTickRate(double ticksPerSec) {
    _ticksPerSecondPerStock = ticksPerSec.clamp(
      AppConstants.minTicksPerSecond,
      AppConstants.maxTicksPerSecond,
    );
    if (_isRunning) {
      _scheduleTimer();
    }
  }

  void _scheduleTimer() {
    _timer?.cancel();
    final totalTicksPerSecond = _ticksPerSecondPerStock * AppConstants.stocks.length;
    final intervalMs = (1000.0 / totalTicksPerSecond).round().clamp(5, 5000);

    _timer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
      _tickNextStock();
    });
  }

  StockQuote _tickNextStock() {
    final stockList = AppConstants.stocks;
    final meta = stockList[_currentStockIndex];
    _currentStockIndex = (_currentStockIndex + 1) % stockList.length;

    return tickStock(meta.symbol);
  }

  StockQuote tickStock(String symbol) {
    final prevQuote = getQuote(symbol);
    final currentPrice = prevQuote.currentPricePaise;

    final double pctChange = (_random.nextDouble() * 0.002) - 0.001;
    int deltaPaise = (currentPrice * pctChange).round();

    if (deltaPaise == 0) {
      deltaPaise = _random.nextBool() ? 5 : -5;
    }

    int nextPrice = currentPrice + deltaPaise;
    if (nextPrice < 100) nextPrice = 100;

    final PriceDirection direction = nextPrice > currentPrice
        ? PriceDirection.up
        : nextPrice < currentPrice
            ? PriceDirection.down
            : PriceDirection.none;

    final updatedQuote = prevQuote.copyWith(
      currentPricePaise: nextPrice,
      lastTickDirection: direction,
      lastUpdated: DateTime.now(),
    );

    _currentQuotes[symbol] = updatedQuote;
    if (!_tickStreamController.isClosed) {
      _tickStreamController.add(updatedQuote);
    }
    return updatedQuote;
  }

  void dispose() {
    stop();
    _tickStreamController.close();
  }
}
