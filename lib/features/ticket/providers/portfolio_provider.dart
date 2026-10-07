import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trading_app/core/constants/stock_constants.dart';
import 'package:trading_app/data/local_storage_provider.dart';
import 'package:trading_app/data/local_storage_service.dart';
import 'package:trading_app/domain/models/holding_model.dart';
import 'package:trading_app/domain/models/order_model.dart';

/// Combined portfolio state containing wallet balance, holdings, and order history.
class PortfolioState {
  final int walletBalancePaise;
  final Map<String, HoldingModel> holdings; // Keyed by symbol
  final List<OrderModel> orders;

  const PortfolioState({
    required this.walletBalancePaise,
    required this.holdings,
    required this.orders,
  });

  PortfolioState copyWith({
    int? walletBalancePaise,
    Map<String, HoldingModel>? holdings,
    List<OrderModel>? orders,
  }) {
    return PortfolioState(
      walletBalancePaise: walletBalancePaise ?? this.walletBalancePaise,
      holdings: holdings ?? this.holdings,
      orders: orders ?? this.orders,
    );
  }
}

class OrderExecutionResult {
  final bool success;
  final String? errorMessage;
  final OrderModel? order;

  OrderExecutionResult.success(this.order)
      : success = true,
        errorMessage = null;

  OrderExecutionResult.failure(this.errorMessage)
      : success = false,
        order = null;
}

class PortfolioNotifier extends StateNotifier<PortfolioState> {
  final LocalStorageService _storage;

  PortfolioNotifier(this._storage)
      : super(PortfolioState(
          walletBalancePaise: _storage.getWalletBalance(),
          holdings: {
            for (final h in _storage.getHoldings()) h.symbol: h,
          },
          orders: _storage.getOrders(),
        ));

  void _persist() {
    _storage.saveWalletBalance(state.walletBalancePaise);
    _storage.saveHoldings(state.holdings.values.toList());
    _storage.saveOrders(state.orders);
  }

  /// Returns the number of shares currently held for a symbol.
  int getQuantityHeld(String symbol) {
    return state.holdings[symbol]?.quantity ?? 0;
  }

  /// Executes a market BUY or SELL order at the exact submit-time LTP.
  OrderExecutionResult executeOrder({
    required String symbol,
    required OrderSide side,
    required int quantity,
    required int submitLtpPaise,
  }) {
    if (quantity <= 0) {
      return OrderExecutionResult.failure('Quantity must be a positive integer greater than zero.');
    }
    if (submitLtpPaise <= 0) {
      return OrderExecutionResult.failure('Invalid stock price quote.');
    }

    final int totalOrderValuePaise = quantity * submitLtpPaise;

    if (side == OrderSide.buy) {
      // Validate available balance
      if (totalOrderValuePaise > state.walletBalancePaise) {
        return OrderExecutionResult.failure(
          'Insufficient wallet balance. Required: ₹${(totalOrderValuePaise / 100).toStringAsFixed(2)}, Available: ₹${(state.walletBalancePaise / 100).toStringAsFixed(2)}',
        );
      }

      final newBalance = state.walletBalancePaise - totalOrderValuePaise;
      final existingHolding = state.holdings[symbol];

      final HoldingModel updatedHolding = existingHolding != null
          ? existingHolding.withBuy(buyQty: quantity, buyPricePaise: submitLtpPaise)
          : HoldingModel(
              symbol: symbol,
              quantity: quantity,
              totalCostPaise: totalOrderValuePaise,
            );

      final newHoldings = Map<String, HoldingModel>.from(state.holdings);
      newHoldings[symbol] = updatedHolding;

      final order = OrderModel(
        symbol: symbol,
        side: OrderSide.buy,
        quantity: quantity,
        pricePaise: submitLtpPaise,
        totalValuePaise: totalOrderValuePaise,
      );

      state = state.copyWith(
        walletBalancePaise: newBalance,
        holdings: newHoldings,
        orders: [order, ...state.orders],
      );
      _persist();
      return OrderExecutionResult.success(order);
    } else {
      // SELL order
      final existingHolding = state.holdings[symbol];
      final int currentlyHeld = existingHolding?.quantity ?? 0;

      if (currentlyHeld <= 0) {
        return OrderExecutionResult.failure('You do not hold any shares of $symbol to sell.');
      }
      if (quantity > currentlyHeld) {
        return OrderExecutionResult.failure(
          'Cannot sell $quantity shares. You only hold $currentlyHeld shares of $symbol.',
        );
      }

      final newBalance = state.walletBalancePaise + totalOrderValuePaise;
      final newHoldings = Map<String, HoldingModel>.from(state.holdings);

      final updatedHolding = existingHolding!.withSell(sellQty: quantity);
      if (updatedHolding == null) {
        // Holding completely closed
        newHoldings.remove(symbol);
      } else {
        newHoldings[symbol] = updatedHolding;
      }

      final order = OrderModel(
        symbol: symbol,
        side: OrderSide.sell,
        quantity: quantity,
        pricePaise: submitLtpPaise,
        totalValuePaise: totalOrderValuePaise,
      );

      state = state.copyWith(
        walletBalancePaise: newBalance,
        holdings: newHoldings,
        orders: [order, ...state.orders],
      );
      _persist();
      return OrderExecutionResult.success(order);
    }
  }

  /// Resets the wallet balance back to initial ₹10,00,000 (useful for testing or demo reset).
  void resetWallet() {
    state = state.copyWith(
      walletBalancePaise: AppConstants.initialWalletBalancePaise,
      holdings: {},
      orders: [],
    );
    _persist();
  }
}

final portfolioProvider =
    StateNotifierProvider<PortfolioNotifier, PortfolioState>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return PortfolioNotifier(storage);
});

/// Individual selectors to minimize unnecessary widget rebuilds:
final walletBalanceProvider = Provider<int>((ref) {
  return ref.watch(portfolioProvider).walletBalancePaise;
});

final holdingsListProvider = Provider<List<HoldingModel>>((ref) {
  return ref.watch(portfolioProvider).holdings.values.toList();
});

final orderHistoryProvider = Provider<List<OrderModel>>((ref) {
  return ref.watch(portfolioProvider).orders;
});
