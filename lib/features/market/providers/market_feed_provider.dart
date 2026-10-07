import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trading_app/data/mock_market_feed_service.dart';
import 'package:trading_app/domain/models/stock_quote.dart';

/// Singleton mock market feed service.
final marketFeedServiceProvider = Provider<MockMarketFeedService>((ref) {
  final service = MockMarketFeedService();
  service.start();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

/// Current tick rate controller provider.
final tickRateProvider = StateNotifierProvider<TickRateNotifier, double>((ref) {
  final service = ref.watch(marketFeedServiceProvider);
  return TickRateNotifier(service);
});

class TickRateNotifier extends StateNotifier<double> {
  final MockMarketFeedService _service;

  TickRateNotifier(this._service) : super(_service.ticksPerSecondPerStock);

  void setRate(double rate) {
    state = rate;
    _service.setTickRate(rate);
  }

  void togglePlayback(bool play) {
    if (play) {
      _service.start();
    } else {
      _service.stop();
    }
  }
}

/// Provider for ticker active status.
final isTickerRunningProvider = Provider<bool>((ref) {
  final service = ref.watch(marketFeedServiceProvider);
  return service.isRunning;
});

/// Granular stock quote provider for an individual symbol.
///
/// Guaranteed zero-flicker synchronous start with instant reactive stream updates.
/// Only widgets subscribed to this specific symbol rebuild when its price ticks.
final stockQuoteFamily =
    StateNotifierProvider.autoDispose.family<StockQuoteNotifier, StockQuote, String>(
  (ref, symbol) {
    final feedService = ref.watch(marketFeedServiceProvider);
    return StockQuoteNotifier(feedService, symbol);
  },
);

class StockQuoteNotifier extends StateNotifier<StockQuote> {
  final String symbol;
  StreamSubscription<StockQuote>? _subscription;

  StockQuoteNotifier(MockMarketFeedService feedService, this.symbol)
      : super(feedService.getQuote(symbol)) {
    _subscription = feedService.streamForSymbol(symbol).listen((quote) {
      state = quote;
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
