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

  // Set system UI style for immersive dark theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.darkBackground,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize SharedPreferences
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
  String _selectedStockForTicket = 'RELIANCE';
  OrderSide _selectedSideForTicket = OrderSide.buy;

  void _openTicket(String symbol, {OrderSide side = OrderSide.buy}) {
    setState(() {
      _selectedStockForTicket = symbol;
      _selectedSideForTicket = side;
      _currentIndex = 2; // Trade ticket tab
    });
  }

  void _navigateToHoldings() {
    setState(() {
      _currentIndex = 3; // Holdings tab
    });
  }

  void _navigateToMarket() {
    setState(() {
      _currentIndex = 1; // Market overview tab
    });
  }

  @override
  Widget build(BuildContext context) {
    // IndexedStack preserves screen state across navigation tabs
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // 0: Watchlists
          WatchlistScreen(
            onStockSelected: (sym) => _openTicket(sym),
          ),
          // 1: Live Market Overview
          MarketOverviewScreen(
            onStockSelected: (sym) => _openTicket(sym),
          ),
          // 2: Buy/Sell Ticket
          BuySellTicketScreen(
            key: ValueKey('$_selectedStockForTicket-$_selectedSideForTicket'),
            initialSymbol: _selectedStockForTicket,
            initialSide: _selectedSideForTicket,
            onNavigateToHoldings: _navigateToHoldings,
          ),
          // 3: Holdings Portfolio
          HoldingsScreen(
            onStockSelected: (sym) => _openTicket(sym),
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
          onTap: (index) => setState(() => _currentIndex = index),
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
    );
  }
}
