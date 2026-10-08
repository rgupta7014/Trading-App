import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_app/core/theme/app_theme.dart';
import 'package:trading_app/data/local_storage_provider.dart';
import 'package:trading_app/domain/models/order_model.dart';
import 'package:trading_app/features/holdings/screens/holdings_screen.dart';
import 'package:trading_app/features/market/screens/market_overview_screen.dart';
import 'package:trading_app/features/ticket/screens/buy_sell_ticket_screen.dart';
import 'package:trading_app/features/watchlist/screens/watchlist_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.darkBackground,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const TradingApp(),
    ),
  );
}

class TradingApp extends StatelessWidget {
  const TradingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '021 Trading App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  final List<int> _tabHistory = [0];
  DateTime? _lastBackPressTime;
  String _selectedStockForTicket = 'RELIANCE';
  OrderSide _selectedSideForTicket = OrderSide.buy;

  void _selectTab(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
        _tabHistory.add(index);
      });
    }
  }

  void _openTicketFromRow(String symbol, {OrderSide side = OrderSide.buy}) {
    setState(() {
      _selectedStockForTicket = symbol;
      _selectedSideForTicket = side;
    });

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BuySellTicketScreen(
          initialSymbol: symbol,
          initialSide: side,
          isModalRoute: true,
          onNavigateToHoldings: () {
            Navigator.of(context).pop();
            _selectTab(3);
          },
        ),
      ),
    );
  }

  void _navigateToHoldings() {
    _selectTab(3);
  }

  void _navigateToMarket() {
    _selectTab(1);
  }

  void _navigateToWatchlist() {
    _selectTab(0);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (_tabHistory.length > 1) {
          setState(() {
            _tabHistory.removeLast();
            _currentIndex = _tabHistory.last;
          });
          return;
        }

        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
            _tabHistory.clear();
            _tabHistory.add(0);
          });
          return;
        }

        final now = DateTime.now();
        if (_lastBackPressTime == null ||
            now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
          _lastBackPressTime = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        SystemNavigator.pop();
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            WatchlistScreen(
              onStockSelected: (sym) => _openTicketFromRow(sym),
            ),
            MarketOverviewScreen(
              onStockSelected: (sym) => _openTicketFromRow(sym),
            ),
            BuySellTicketScreen(
              key: ValueKey('$_selectedStockForTicket-$_selectedSideForTicket'),
              initialSymbol: _selectedStockForTicket,
              initialSide: _selectedSideForTicket,
              onNavigateToHoldings: _navigateToHoldings,
              onBackToWatchlist: _navigateToWatchlist,
            ),
            HoldingsScreen(
              onStockSelected: (sym) => _openTicketFromRow(sym),
              onExploreMarket: _navigateToMarket,
            ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.darkCardBorder, width: 0.8),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _selectTab,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt_rounded),
                activeIcon: Icon(Icons.list_alt_rounded, color: AppColors.primary),
                label: 'Watchlist',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.candlestick_chart_rounded),
                activeIcon: Icon(Icons.candlestick_chart_rounded, color: AppColors.accent),
                label: 'Live Market',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.swap_horiz_rounded),
                activeIcon: Icon(Icons.swap_horiz_rounded, color: AppColors.bullish),
                label: 'Trade Ticket',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.pie_chart_outline_rounded),
                activeIcon: Icon(Icons.pie_chart_rounded, color: AppColors.primary),
                label: 'Holdings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
