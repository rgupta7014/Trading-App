import 'package:flutter_test/flutter_test.dart';
import 'package:trading_app/domain/models/holding_model.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('HoldingModel tests', () {
    test('computes average cost with Decimal package without floating drift', () {
      const holding = HoldingModel(
        symbol: 'RELIANCE',
        quantity: 3,
        totalCostPaise: 885000,
      );

      expect(holding.avgCostRupeesDecimal, equals(Decimal.parse('2950.0000')));
      expect(holding.avgCostPaise, equals(295000));
    });

    test('weighted average cost updates correctly on multiple buys', () {
      var holding = const HoldingModel(
        symbol: 'INFY',
        quantity: 10,
        totalCostPaise: 100000,
      );

      holding = holding.withBuy(buyQty: 10, buyPricePaise: 20000);

      expect(holding.quantity, equals(20));
      expect(holding.totalCostPaise, equals(300000));
      expect(holding.avgCostRupeesDecimal, equals(Decimal.parse('150.0000')));
      expect(holding.avgCostPaise, equals(15000));
    });

    test('partial sell keeps same average cost per share', () {
      var holding = const HoldingModel(
        symbol: 'INFY',
        quantity: 20,
        totalCostPaise: 300000,
      );

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

      final updatedHolding = holding.withSell(sellQty: 10);
      expect(updatedHolding, isNull);
    });

    test('computes dynamic P&L correctly without storing it', () {
      const holding = HoldingModel(
        symbol: 'TCS',
        quantity: 10,
        totalCostPaise: 100000,
      );

      expect(holding.currentValuePaise(12000), equals(120000));
      expect(holding.pnlPaise(12000), equals(20000));
      expect(holding.pnlPercent(12000), equals(20.0));

      expect(holding.currentValuePaise(9000), equals(90000));
      expect(holding.pnlPaise(9000), equals(-10000));
      expect(holding.pnlPercent(9000), equals(-10.0));
    });
  });
}
