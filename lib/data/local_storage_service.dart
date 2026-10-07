import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_app/core/constants/stock_constants.dart';
import 'package:trading_app/domain/models/holding_model.dart';
import 'package:trading_app/domain/models/order_model.dart';
import 'package:trading_app/domain/models/watchlist_model.dart';

class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static const String _keyWallet = 'wallet_balance_paise';
  static const String _keyOrders = 'order_history';
  static const String _keyHoldings = 'holdings';
  static const String _keyWatchlists = 'watchlists';

  int getWalletBalance() {
    try {
      final val = _prefs.getInt(_keyWallet);
      return val ?? AppConstants.initialWalletBalancePaise;
    } catch (e) {
      return AppConstants.initialWalletBalancePaise;
    }
  }

  Future<void> saveWalletBalance(int paise) async {
    await _prefs.setInt(_keyWallet, paise);
  }

  List<OrderModel> getOrders() {
    try {
      final raw = _prefs.getStringList(_keyOrders);
      if (raw == null) return [];
      return raw.map((item) {
        final Map<String, dynamic> map = jsonDecode(item) as Map<String, dynamic>;
        return OrderModel.fromJson(map);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveOrders(List<OrderModel> orders) async {
    final list = orders.map((o) => jsonEncode(o.toJson())).toList();
    await _prefs.setStringList(_keyOrders, list);
  }

  List<HoldingModel> getHoldings() {
    try {
      final raw = _prefs.getStringList(_keyHoldings);
      if (raw == null) return [];
      return raw.map((item) {
        final Map<String, dynamic> map = jsonDecode(item) as Map<String, dynamic>;
        return HoldingModel.fromJson(map);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveHoldings(List<HoldingModel> holdings) async {
    final list = holdings.map((h) => jsonEncode(h.toJson())).toList();
    await _prefs.setStringList(_keyHoldings, list);
  }

  List<Watchlist> getWatchlists() {
    try {
      final raw = _prefs.getStringList(_keyWatchlists);
      if (raw == null || raw.isEmpty) {
        return _defaultWatchlists();
      }
      final list = raw.map((item) {
        final Map<String, dynamic> map = jsonDecode(item) as Map<String, dynamic>;
        return Watchlist.fromJson(map);
      }).toList();
      return list.isEmpty ? _defaultWatchlists() : list;
    } catch (e) {
      return _defaultWatchlists();
    }
  }

  Future<void> saveWatchlists(List<Watchlist> watchlists) async {
    final list = watchlists.map((w) => jsonEncode(w.toJson())).toList();
    await _prefs.setStringList(_keyWatchlists, list);
  }

  List<Watchlist> _defaultWatchlists() {
    return [
      Watchlist(
        name: 'Nifty Heavyweights',
        symbols: ['RELIANCE', 'TCS', 'HDFCBANK', 'INFY', 'ICICIBANK'],
      ),
      Watchlist(
        name: 'Banking & PSU',
        symbols: ['HDFCBANK', 'ICICIBANK', 'SBIN', 'AXISBANK'],
      ),
      Watchlist(
        name: 'Growth & Tech',
        symbols: ['TCS', 'INFY', 'BHARTIARTL', 'LT', 'ITC'],
      ),
    ];
  }
}
