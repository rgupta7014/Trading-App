import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_app/data/local_storage_service.dart';
import 'package:trading_app/features/watchlist/providers/watchlist_provider.dart';

void main() {
  group('WatchlistNotifier tests', () {
    late LocalStorageService storage;
    late WatchlistNotifier notifier;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storage = LocalStorageService(prefs);
      notifier = WatchlistNotifier(storage);
    });

    test('initializes with default watchlists', () {
      expect(notifier.state.length, greaterThanOrEqualTo(1));
    });

    test('creates and persists a new watchlist', () {
      final initialCount = notifier.state.length;
      notifier.createWatchlist('Tech Focus');

      expect(notifier.state.length, equals(initialCount + 1));
      expect(notifier.state.last.name, equals('Tech Focus'));
      expect(notifier.state.last.symbols, isEmpty);

      final saved = storage.getWatchlists();
      expect(saved.any((w) => w.name == 'Tech Focus'), isTrue);
    });

    test('renames an existing watchlist', () {
      final id = notifier.state.first.id;
      notifier.renameWatchlist(id, 'Renamed Portfolio');

      expect(notifier.state.first.name, equals('Renamed Portfolio'));
      final saved = storage.getWatchlists();
      expect(saved.first.name, equals('Renamed Portfolio'));
    });

    test('adds stocks to a watchlist without duplicates', () {
      final id = notifier.state.first.id;
      notifier.addStock(id, 'RELIANCE');
      notifier.addStock(id, 'RELIANCE');

      final watchlist = notifier.state.firstWhere((w) => w.id == id);
      expect(watchlist.symbols.where((s) => s == 'RELIANCE').length, equals(1));
    });

    test('removes stock from a watchlist', () {
      final id = notifier.state.first.id;
      notifier.addStock(id, 'SBIN');
      expect(notifier.state.firstWhere((w) => w.id == id).symbols.contains('SBIN'), isTrue);

      notifier.removeStock(id, 'SBIN');
      expect(notifier.state.firstWhere((w) => w.id == id).symbols.contains('SBIN'), isFalse);
    });

    test('reorders stocks correctly within a watchlist', () {
      notifier.createWatchlist('Test Reorder');
      final target = notifier.state.last;

      notifier.addStock(target.id, 'RELIANCE');
      notifier.addStock(target.id, 'TCS');
      notifier.addStock(target.id, 'INFY');

      notifier.reorderStocks(target.id, 2, 0);

      final updated = notifier.state.firstWhere((w) => w.id == target.id);
      expect(updated.symbols.first, equals('INFY'));
    });

    test('deleting a watchlist preserves at least one fallback list', () {
      while (notifier.state.length > 1) {
        notifier.deleteWatchlist(notifier.state.first.id);
      }
      expect(notifier.state.length, equals(1));

      notifier.deleteWatchlist(notifier.state.first.id);
      expect(notifier.state.length, equals(1));
    });
  });
}
