import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_app/core/constants/stock_constants.dart';
import 'package:trading_app/data/local_storage_service.dart';
import 'package:trading_app/domain/models/order_model.dart';
import 'package:trading_app/features/ticket/providers/portfolio_provider.dart';

void main() {
  group('Portfolio & Order Execution tests', () {
    late LocalStorageService storage;
    late PortfolioNotifier portfolio;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storage = LocalStorageService(prefs);
      portfolio = PortfolioNotifier(storage);
    });

    test('wallet starts at ₹10,00,000 (100,000,000 paise)', () {
      expect(portfolio.state.walletBalancePaise, equals(AppConstants.initialWalletBalancePaise));
      expect(portfolio.state.holdings, isEmpty);
      expect(portfolio.state.orders, isEmpty);
    });

    test('valid Buy order executes, deducts balance, and creates holding', () {
      final result = portfolio.executeOrder(
        symbol: 'RELIANCE',
        side: OrderSide.buy,
        quantity: 10,
        submitLtpPaise: 295000,
      );

      expect(result.success, isTrue);
      expect(result.order, isNotNull);
      expect(result.order!.quantity, equals(10));
      expect(result.order!.pricePaise, equals(295000));
      expect(result.order!.totalValuePaise, equals(2950000));

      final expectedBalance = AppConstants.initialWalletBalancePaise - 2950000;
      expect(portfolio.state.walletBalancePaise, equals(expectedBalance));

      final holding = portfolio.state.holdings['RELIANCE'];
      expect(holding, isNotNull);
      expect(holding!.quantity, equals(10));
      expect(holding.totalCostPaise, equals(2950000));

      expect(portfolio.state.orders.length, equals(1));
    });

    test('subsequent Buy updates holding quantity and weighted avg cost', () {
      portfolio.executeOrder(
        symbol: 'INFY',
        side: OrderSide.buy,
        quantity: 10,
        submitLtpPaise: 10000,
      );

      portfolio.executeOrder(
        symbol: 'INFY',
        side: OrderSide.buy,
        quantity: 10,
        submitLtpPaise: 20000,
      );

      final holding = portfolio.state.holdings['INFY']!;
      expect(holding.quantity, equals(20));
      expect(holding.totalCostPaise, equals(300000));
      expect(holding.avgCostPaise, equals(15000));
    });

    test('Buy order with insufficient wallet balance is blocked', () {
      final result = portfolio.executeOrder(
        symbol: 'TCS',
        side: OrderSide.buy,
        quantity: 1000,
        submitLtpPaise: 412000,
      );

      expect(result.success, isFalse);
      expect(result.errorMessage, contains('Insufficient wallet balance'));
      expect(portfolio.state.walletBalancePaise, equals(AppConstants.initialWalletBalancePaise));
      expect(portfolio.state.holdings, isEmpty);
    });

    test('Sell order increases wallet balance and reduces holding quantity', () {
      portfolio.executeOrder(
        symbol: 'ITC',
        side: OrderSide.buy,
        quantity: 20,
        submitLtpPaise: 50000,
      );
      final balanceAfterBuy = portfolio.state.walletBalancePaise;

      final sellResult = portfolio.executeOrder(
        symbol: 'ITC',
        side: OrderSide.sell,
        quantity: 10,
        submitLtpPaise: 60000,
      );

      expect(sellResult.success, isTrue);
      expect(portfolio.state.walletBalancePaise, equals(balanceAfterBuy + 600000));

      final remainingHolding = portfolio.state.holdings['ITC']!;
      expect(remainingHolding.quantity, equals(10));
    });

    test('Sell order exceeding held quantity is blocked', () {
      portfolio.executeOrder(
        symbol: 'LT',
        side: OrderSide.buy,
        quantity: 5,
        submitLtpPaise: 300000,
      );

      final sellResult = portfolio.executeOrder(
        symbol: 'LT',
        side: OrderSide.sell,
        quantity: 10,
        submitLtpPaise: 300000,
      );

      expect(sellResult.success, isFalse);
      expect(sellResult.errorMessage, contains('Cannot sell 10 shares. You only hold 5 shares'));
    });

    test('Selling complete position removes holding', () {
      portfolio.executeOrder(
        symbol: 'SBIN',
        side: OrderSide.buy,
        quantity: 15,
        submitLtpPaise: 80000,
      );
      expect(portfolio.state.holdings.containsKey('SBIN'), isTrue);

      final sellResult = portfolio.executeOrder(
        symbol: 'SBIN',
        side: OrderSide.sell,
        quantity: 15,
        submitLtpPaise: 85000,
      );

      expect(sellResult.success, isTrue);
      expect(portfolio.state.holdings.containsKey('SBIN'), isFalse);
    });

    test('Selling when zero shares are held is blocked', () {
      final sellResult = portfolio.executeOrder(
        symbol: 'AXISBANK',
        side: OrderSide.sell,
        quantity: 1,
        submitLtpPaise: 100000,
      );

      expect(sellResult.success, isFalse);
      expect(sellResult.errorMessage, contains('do not hold any shares'));
    });

    test('Zero or negative quantity is blocked', () {
      final zeroResult = portfolio.executeOrder(
        symbol: 'INFY',
        side: OrderSide.buy,
        quantity: 0,
        submitLtpPaise: 100000,
      );
      expect(zeroResult.success, isFalse);

      final negResult = portfolio.executeOrder(
        symbol: 'INFY',
        side: OrderSide.buy,
        quantity: -5,
        submitLtpPaise: 100000,
      );
      expect(negResult.success, isFalse);
    });
  });
}
