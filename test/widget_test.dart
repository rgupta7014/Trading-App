import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_app/data/local_storage_provider.dart';
import 'package:trading_app/data/mock_market_feed_service.dart';
import 'package:trading_app/features/market/providers/market_feed_provider.dart';
import 'package:trading_app/main.dart';

void main() {
  testWidgets('TradingApp smoke and navigation test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final testFeed = MockMarketFeedService();
    // Keep feed stopped during test so timer doesn't interfere with frame pumps
    testFeed.stop();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          marketFeedServiceProvider.overrideWithValue(testFeed),
        ],
        child: const TradingApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify Watchlist screen is displayed initially
    expect(find.text('Watchlists'), findsOneWidget);

    // Verify bottom navigation items exist
    expect(find.text('Watchlist'), findsOneWidget);
    expect(find.text('Live Market'), findsOneWidget);
    expect(find.text('Trade Ticket'), findsOneWidget);
    expect(find.text('Holdings'), findsOneWidget);

    // Tap Live Market tab
    await tester.tap(find.text('Live Market'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Live Market'), findsWidgets);

    // Tap Holdings tab
    await tester.tap(find.text('Holdings'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Portfolio Holdings'), findsOneWidget);

    // Tap Trade Ticket tab
    await tester.tap(find.text('Trade Ticket'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Order Ticket'), findsOneWidget);

    testFeed.dispose();
  });
}
