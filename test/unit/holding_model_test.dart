import 'package:flutter_test/flutter_test.dart';
import 'package:trading_app/domain/models/holding_model.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('HoldingModel tests', () {
    test('computes average cost with Decimal package without floating drift', () {
      // Bought 3 shares of RELIANCE for ₹2,950.00 each = 3 * 295000 = 885000 paise
      const holding = HoldingModel(
        symbol: 'RELIANCE',
        quantity: 3,
        totalCostPaise: 885000,
      );

      expect(holding.avgCostRupeesDecimal, equals(Decimal.parse('2950.0000')));
      expect(holding.avgCostPaise, equals(295000));
    });

    test('weighted average cost updates correctly on multiple buys', () {
      // Lot 1: Buy 10 shares @ ₹100.00 (10,000 paise) -> cost: 100,000 paise
      var holding = const HoldingModel(
        symbol: 'INFY',
        quantity: 10,
        totalCostPaise: 100000,
      );

      // Lot 2: Buy 10 shares @ ₹200.00 (20,000 paise) -> cost: 200,000 paise
      holding = holding.withBuy(buyQty: 10, buyPricePaise: 20000);

      expect(holding.quantity, equals(20));
      expect(holding.totalCostPaise, equals(300000));
      // Avg cost should be exactly 150.00 Rs
      expect(holding.avgCostRupeesDecimal, equals(Decimal.parse('150.0000')));
      expect(holding.avgCostPaise, equals(15000));
    });

    test('partial sell keeps same average cost per share', () {
      // 20 shares with total cost 300,000 paise (150.00 Rs per share)
      var holding = const HoldingModel(
        symbol: 'INFY',
        quantity: 20,
        totalCostPaise: 300000,
      );

      // Sell 5 shares
      final updatedHolding = holding.withSell(sellQty: 5);
      expect(updatedHolding, isNotNull);
      expect(updatedHolding!.quantity, equals(15));
      expect(updatedHolding.totalCostPaise, equals(225000));
      expect(updatedHolding.avgCostRupeesDecimal, equals(Decimal.parse('150.0000')));
    });

    test('complete sell returns null to signal holding removal', () {
      const holding = HoldingModel(
        symbol: 'INFY',
        quantity: 10,
        totalCostPaise: 100000,
      );

      // Sell all 10 shares
      final updatedHolding = holding.withSell(sellQty: 10);
      expect(updatedHolding, isNull);
    });

    test('computes dynamic P&L correctly without storing it', () {
      // 10 shares @ ₹100.00 = 100,000 paise
      const holding = HoldingModel(
        symbol: 'TCS',
        quantity: 10,
        totalCostPaise: 100000,
      );

      // Price rises to ₹120.00 (12,000 paise)
      expect(holding.currentValuePaise(12000), equals(120000));
      expect(holding.pnlPaise(12000), equals(20000)); // +₹200.00
      expect(holding.pnlPercent(12000), equals(20.0)); // +20%

      // Price falls to ₹90.00 (9,000 paise)
      expect(holding.currentValuePaise(9000), equals(90000));
      expect(holding.pnlPaise(9000), equals(-10000)); // -₹100.00
      expect(holding.pnlPercent(9000), equals(-10.0)); // -10%
    });
  });
}
