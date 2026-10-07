import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_app/core/constants/stock_constants.dart';
import 'package:trading_app/data/local_storage_service.dart';
import 'package:trading_app/domain/models/holding_model.dart';
import 'package:trading_app/domain/models/order_model.dart';

void main() {
  group('LocalStorageService tests', () {
    late LocalStorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storage = LocalStorageService(prefs);
    });

    test('returns default 10 Lakh balance when nothing is saved', () {
      expect(storage.getWalletBalance(), equals(AppConstants.initialWalletBalancePaise));
    });

    test('persists and retrieves wallet balance accurately', () async {
      await storage.saveWalletBalance(85000000); // 8.5 Lakhs
      expect(storage.getWalletBalance(), equals(85000000));
    });

    test('persists and retrieves orders correctly', () async {
      final order = OrderModel(
        symbol: 'RELIANCE',
        side: OrderSide.buy,
        quantity: 5,
        pricePaise: 295000,
      );

      await storage.saveOrders([order]);
      final retrieved = storage.getOrders();
      expect(retrieved.length, equals(1));
      expect(retrieved.first.symbol, equals('RELIANCE'));
      expect(retrieved.first.quantity, equals(5));
      expect(retrieved.first.pricePaise, equals(295000));
    });

    test('persists and retrieves holdings correctly', () async {
      final holding = const HoldingModel(
        symbol: 'TCS',
        quantity: 10,
        totalCostPaise: 4120000,
      );

      await storage.saveHoldings([holding]);
      final retrieved = storage.getHoldings();
      expect(retrieved.length, equals(1));
      expect(retrieved.first.symbol, equals('TCS'));
      expect(retrieved.first.quantity, equals(10));
    });

    test('handles corrupt storage gracefully without throwing', () async {
      // Intentionally insert corrupted JSON data in preferences
      SharedPreferences.setMockInitialValues({
        'order_history': ['{invalid_json_content}'],
        'holdings': ['{broken_holding:'],
        'watchlists': ['corrupt_watchlist_data'],
      });
      final prefs = await SharedPreferences.getInstance();
      final corruptStorage = LocalStorageService(prefs);

      // Should not throw, but safely return empty or default fallbacks
      expect(corruptStorage.getOrders(), isEmpty);
      expect(corruptStorage.getHoldings(), isEmpty);
      expect(corruptStorage.getWatchlists(), isNotEmpty); // Returns default watchlists!
    });
  });
}
