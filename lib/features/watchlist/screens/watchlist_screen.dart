import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trading_app/core/theme/app_theme.dart';
import 'package:trading_app/features/watchlist/providers/watchlist_provider.dart';
import 'package:trading_app/features/watchlist/widgets/stock_picker_sheet.dart';
import 'package:trading_app/features/watchlist/widgets/watchlist_stock_row.dart';

/// Screen supporting multiple watchlists, drag reordering, adding/removing stocks.
class WatchlistScreen extends ConsumerWidget {
  final Function(String symbol)? onStockSelected;

  const WatchlistScreen({
    super.key,
    this.onStockSelected,
  });

  void _showCreateWatchlistDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: const Text('Create New Watchlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Dividend Stocks, Tech Gems',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref.read(watchlistProvider.notifier).createWatchlist(name);
                final list = ref.read(watchlistProvider);
                ref.read(selectedWatchlistIndexProvider.notifier).state =
                    list.length - 1;
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showRenameWatchlistDialog(
    BuildContext context,
    WidgetRef ref,
    String id,
    String currentName,
  ) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: const Text('Rename Watchlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Watchlist Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref.read(watchlistProvider.notifier).renameWatchlist(id, name);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteWatchlist(BuildContext context, WidgetRef ref, String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: Text('Delete "$name"?'),
        content: const Text(
          'Are you sure you want to delete this watchlist? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.bearish),
            onPressed: () {
              ref.read(watchlistProvider.notifier).deleteWatchlist(id);
              ref.read(selectedWatchlistIndexProvider.notifier).state = 0;
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlists = ref.watch(watchlistProvider);
    var selectedIndex = ref.watch(selectedWatchlistIndexProvider);

    if (selectedIndex >= watchlists.length) {
      selectedIndex = (watchlists.length - 1).clamp(0, 9999);
    }

    final activeWatchlist =
        watchlists.isNotEmpty ? watchlists[selectedIndex] : null;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.remove_red_eye_outlined, color: AppColors.accent, size: 24),
            SizedBox(width: 8),
            Text('Watchlists'),
          ],
        ),
        actions: [
          if (activeWatchlist != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded),
              color: AppColors.darkCard,
              onSelected: (val) {
                if (val == 'rename') {
                  _showRenameWatchlistDialog(
                    context,
                    ref,
                    activeWatchlist.id,
                    activeWatchlist.name,
                  );
                } else if (val == 'delete') {
                  _confirmDeleteWatchlist(
                    context,
                    ref,
                    activeWatchlist.id,
                    activeWatchlist.name,
                  );
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'rename',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Rename Watchlist'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 18, color: AppColors.bearish),
                      SizedBox(width: 8),
                      Text('Delete Watchlist', style: TextStyle(color: AppColors.bearish)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: activeWatchlist != null
          ? FloatingActionButton.extended(
              onPressed: () => StockPickerSheet.show(context, activeWatchlist.id),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text(
                'Add Stock',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            )
          : null,
      body: Column(
        children: [
          // Watchlist Selector Tabs / Chips
          Container(
            height: 48,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: watchlists.length + 1,
              separatorBuilder: (_, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == watchlists.length) {
                  // Button to create a new watchlist
                  return ActionChip(
                    avatar: const Icon(Icons.add, size: 16, color: AppColors.primary),
                    label: const Text(
                      'New List',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    backgroundColor: AppColors.darkCard,
                    side: const BorderSide(color: AppColors.primary, width: 0.8),
                    onPressed: () => _showCreateWatchlistDialog(context, ref),
                  );
                }

                final watchlist = watchlists[index];
                final isSelected = index == selectedIndex;

                return ChoiceChip(
                  label: Text('${watchlist.name} (${watchlist.symbols.length})'),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.darkCard,
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.darkTextSecondary,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.darkCardBorder,
                  ),
                  onSelected: (_) {
                    ref.read(selectedWatchlistIndexProvider.notifier).state = index;
                  },
                );
              },
            ),
          ),
          const Divider(height: 1, thickness: 0.8, color: AppColors.darkCardBorder),
          // Content: Reorderable Stock List or Empty State
          Expanded(
            child: activeWatchlist == null || activeWatchlist.symbols.isEmpty
                ? _buildEmptyState(context, activeWatchlist)
                : ReorderableListView.builder(
                    buildDefaultDragHandles: false,
                    itemCount: activeWatchlist.symbols.length,
                    onReorder: (oldIndex, newIndex) {
                      ref.read(watchlistProvider.notifier).reorderStocks(
                            activeWatchlist.id,
                            oldIndex,
                            newIndex,
                          );
                    },
                    itemBuilder: (context, index) {
                      final symbol = activeWatchlist.symbols[index];
                      // CRITICAL: ValueKey(symbol) guarantees correct element binding across reordering
                      return WatchlistStockRow(
                        key: ValueKey(symbol),
                        symbol: symbol,
                        index: index,
                        onTap: () {
                          if (onStockSelected != null) {
                            onStockSelected!(symbol);
                          }
                        },
                        onRemove: () {
                          ref
                              .read(watchlistProvider.notifier)
                              .removeStock(activeWatchlist.id, symbol);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, dynamic activeWatchlist) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.darkCardBorder),
              ),
              child: const Icon(
                Icons.playlist_add_rounded,
                size: 36,
                color: AppColors.darkTextSecondary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No stocks in this watchlist',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.darkTextPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add stocks from the 10 available companies to track prices and trade directly.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.darkTextSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            if (activeWatchlist != null)
              ElevatedButton.icon(
                onPressed: () =>
                    StockPickerSheet.show(context, activeWatchlist.id),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Stocks'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
