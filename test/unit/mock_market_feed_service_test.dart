import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:trading_app/core/constants/stock_constants.dart';
import 'package:trading_app/data/mock_market_feed_service.dart';
import 'package:trading_app/domain/models/stock_quote.dart';

void main() {
  group('MockMarketFeedService tests', () {
    late MockMarketFeedService feed;

    setUp(() {
      feed = MockMarketFeedService(random: Random(42));
    });

    tearDown(() {
      feed.dispose();
    });

    test('initializes with all 10 stocks at their base prices', () {
      expect(feed.currentQuotes.length, equals(10));
      for (final meta in AppConstants.stocks) {
        final quote = feed.getQuote(meta.symbol);
        expect(quote.symbol, equals(meta.symbol));
        expect(quote.basePricePaise, equals(meta.basePricePaise));
        expect(quote.currentPricePaise, equals(meta.basePricePaise));
        expect(quote.changePaise, equals(0));
      }
    });

    test('random walk ticks within bounds and updates direction', () {
      final initialQuote = feed.getQuote('RELIANCE');
      final updatedQuote = feed.tickStock('RELIANCE');

      expect(updatedQuote.symbol, equals('RELIANCE'));
      expect(updatedQuote.currentPricePaise, isNot(equals(0)));

      if (updatedQuote.currentPricePaise > initialQuote.currentPricePaise) {
        expect(updatedQuote.lastTickDirection, equals(PriceDirection.up));
      } else {
        expect(updatedQuote.lastTickDirection, equals(PriceDirection.down));
      }

      final diff = (updatedQuote.currentPricePaise - initialQuote.currentPricePaise).abs();
      expect(diff, lessThanOrEqualTo(500));
    });

    test('clamps tick rate between configured bounds', () {
      feed.setTickRate(0.01);
      expect(feed.ticksPerSecondPerStock, equals(AppConstants.minTicksPerSecond));

      feed.setTickRate(100.0);
      expect(feed.ticksPerSecondPerStock, equals(AppConstants.maxTicksPerSecond));

      feed.setTickRate(5.0);
      expect(feed.ticksPerSecondPerStock, equals(5.0));
    });

    test('quoteStream emits updated quotes on tick', () async {
      expectLater(
        feed.quoteStream,
        emits(predicate<StockQuote>((q) => q.symbol == 'TCS')),
      );

      feed.tickStock('TCS');
    });

    test('streamForSymbol only emits ticks for the requested symbol', () async {
      final events = <StockQuote>[];
      final sub = feed.streamForSymbol('INFY').listen(events.add);

      feed.tickStock('RELIANCE');
      feed.tickStock('INFY');
      feed.tickStock('ITC');

      await pumpEventQueue();
      expect(events.length, equals(1));
      expect(events.first.symbol, equals('INFY'));
      await sub.cancel();
    });
  });
}
