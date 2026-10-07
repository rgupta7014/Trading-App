import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trading_app/data/local_storage_provider.dart';
import 'package:trading_app/data/local_storage_service.dart';
import 'package:trading_app/domain/models/watchlist_model.dart';

/// Notifier managing user watchlists, persisting to local storage.
class WatchlistNotifier extends StateNotifier<List<Watchlist>> {
  final LocalStorageService _storage;

  WatchlistNotifier(this._storage) : super(_storage.getWatchlists());

  void _persist() {
    _storage.saveWatchlists(state);
  }

  /// Creates a new watchlist and appends it.
  void createWatchlist(String name) {
    if (name.trim().isEmpty) return;
    final newWatchlist = Watchlist(
      name: name.trim(),
      symbols: [],
    );
    state = [...state, newWatchlist];
    _persist();
  }

  /// Renames an existing watchlist.
  void renameWatchlist(String id, String newName) {
    if (newName.trim().isEmpty) return;
    state = [
      for (final w in state)
        if (w.id == id) w.copyWith(name: newName.trim()) else w,
    ];
    _persist();
  }

  /// Deletes a watchlist.
  void deleteWatchlist(String id) {
    if (state.length <= 1) {
      // Keep at least one default watchlist
      state = [
        Watchlist(name: 'My Watchlist', symbols: []),
      ];
    } else {
      state = state.where((w) => w.id != id).toList();
    }
    _persist();
  }

  /// Adds a stock symbol to the target watchlist if not already present.
  void addStock(String id, String symbol) {
    state = [
      for (final w in state)
        if (w.id == id)
          w.symbols.contains(symbol)
              ? w
              : w.copyWith(symbols: [...w.symbols, symbol])
        else
          w,
    ];
    _persist();
  }

  /// Removes a stock symbol from the target watchlist.
  void removeStock(String id, String symbol) {
    state = [
      for (final w in state)
        if (w.id == id)
          w.copyWith(symbols: w.symbols.where((s) => s != symbol).toList())
        else
          w,
    ];
    _persist();
  }

  /// Reorders stocks within the target watchlist.
  void reorderStocks(String id, int oldIndex, int newIndex) {
    state = [
      for (final w in state)
        if (w.id == id) _reorderList(w, oldIndex, newIndex) else w,
    ];
    _persist();
  }

  Watchlist _reorderList(Watchlist watchlist, int oldIndex, int newIndex) {
    final list = List<String>.from(watchlist.symbols);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    return watchlist.copyWith(symbols: list);
  }
}

final watchlistProvider =
    StateNotifierProvider<WatchlistNotifier, List<Watchlist>>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return WatchlistNotifier(storage);
});

/// Currently selected watchlist index.
final selectedWatchlistIndexProvider = StateProvider<int>((ref) => 0);
