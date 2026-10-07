# 021 Trading App — Flutter Assignment

A high-performance, real-time simulated stock trading application built with **Flutter (stable channel)** and **Riverpod**.

Designed with a sleek, modern dark trading aesthetic (similar to Zerodha Kite and Robinhood), this app operates entirely offline with **zero external backend or API keys** required, driven by an autonomous **Mock Market-Data Feed**.

---

## 🚀 Quick Start Instructions

This project runs out of the box with standard Flutter commands:

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run the application (Desktop / Android / iOS / Web)
flutter run

# 3. Run all unit and widget tests
flutter test

# 4. Run static analysis
flutter analyze
```

---

## 🏛️ Architecture & Folder Structure

The project follows a clean, modular architecture separating business domain logic, real-time data streaming, local persistence, and presentation layers:

```
lib/
├── core/
│   ├── constants/
│   │   └── stock_constants.dart      # 10 bluechip stocks metadata, initial prices, limits
│   ├── theme/
│   │   └── app_theme.dart            # Modern trading color tokens, dark theme, styling
│   └── utils/
│       └── currency_formatter.dart   # Indian currency formatting (₹1,23,456.78) & Decimal formatter
├── data/
│   ├── local_storage_provider.dart   # Riverpod providers for SharedPreferences
│   ├── local_storage_service.dart    # Corrupt-safe JSON storage for wallet, orders, holdings, watchlists
│   └── mock_market_feed_service.dart # Real-time random walk feed (±0.1%), configurable ticker
├── domain/
│   └── models/
│       ├── holding_model.dart        # Holding position with Decimal avg cost & dynamic P&L
│       ├── order_model.dart          # Executed market buy/sell order records
│       ├── stock_quote.dart          # Live quote with integer paise & tick direction
│       └── watchlist_model.dart      # Watchlist entity with symbols
├── features/
│   ├── market/
│   │   ├── providers/
│   │   │   └── market_feed_provider.dart    # Riverpod ticker controller & stockQuoteFamily
│   │   ├── screens/
│   │   │   └── market_overview_screen.dart  # 10 stocks live overview & rate controller
│   │   └── widgets/
│   │       ├── market_stock_row.dart        # Granular row listening ONLY to its symbol
│   │       ├── stock_flash_cell.dart        # Micro-animation cell with green/red tick flash
│   │       └── tick_rate_control_sheet.dart # Speed slider (up to 20 ticks/sec per stock = 200/s total)
│   ├── watchlist/
│   │   ├── providers/
│   │   │   └── watchlist_provider.dart      # Multiple watchlists state notifier & reordering
│   │   ├── screens/
│   │   │   └── watchlist_screen.dart        # Tabs, ReorderableListView with ValueKey, empty states
│   │   └── widgets/
│   │       ├── stock_picker_sheet.dart      # Modal picker to add stocks from the 10 available
│   │       └── watchlist_stock_row.dart     # Drag handle, live LTP, and swipe/tap actions
│   ├── ticket/
│   │   ├── providers/
│   │   │   └── portfolio_provider.dart      # Wallet balance (₹10L), order execution, holdings sync
│   │   ├── screens/
│   │   │   └── buy_sell_ticket_screen.dart  # Live LTP, projected value, margin & holdings validation
│   │   └── widgets/
│   │       └── order_confirmation_dialog.dart # Execution receipt with full details
│   └── holdings/
│       ├── screens/
│       │   └── holdings_screen.dart         # Portfolio view, sorting (P&L/Symbol/Value), empty state
│       └── widgets/
│           ├── holding_stock_row.dart       # Individual holding row with live P&L and Decimal avg cost
│           └── holdings_summary_card.dart   # Exact aggregate sum (Invested, Value, P&L ₹ & %)
└── main.dart                                # App entrypoint, ProviderScope, bottom navigation shell
```

---

## 🎯 Key Design & Implementation Decisions

### 1. Money & Math Integrity (Zero Floating-Point Drift)
- **Integer Paise Representation**: In accordance with institutional trading standards, **money is never stored or computed as a floating-point `double`**.
- All stock prices, order prices, wallet balances, and portfolio values are strictly represented in **integer paise** (`int`, where ₹1 = 100 paise).
- **Decimal Package for Average Cost**: When multiple lots are purchased at varying prices, the weighted average cost can be fractional. The `decimal` package is used for exact arbitrary-precision division (`Rational -> Decimal`), ensuring zero IEEE-754 floating-point drift.
- **Indian Number Formatting**: The custom `CurrencyFormatter` formats amounts with the standard Indian grouping notation (`₹10,00,000.00`, `₹1,23,456.78`).

### 2. High-Performance Granular Rebuilds
- **Single Source of Truth**: `MockMarketFeedService` is the sole source of market pricing for the entire application.
- **Isolated Row Subscriptions**: Each stock row in Watchlists, Market Overview, and Holdings observes `stockQuoteFamily(symbol)` via Riverpod.
- When `RELIANCE` ticks, **only** the `RELIANCE` row updates. Neighboring rows (`TCS`, `INFY`, etc.) are not re-rendered.
- **`ValueKey(symbol)`**: Lists explicitly use `ValueKey(symbol)` rather than index-based keys, preventing stale ticks or incorrect bindings during reordering.

### 3. Stress-Tested Market Feed (Up to 200 ticks/sec)
- **Random Walk**: Each price tick follows a bounded random walk of $\pm 0.1\%$ from the current price.
- **Configurable Speed Slider**: Built-in modal sheet allows adjusting tick speed from `0.2` up to `20.0 ticks/sec per stock` (which generates **200 ticks/sec total load** across all 10 stocks).
- The UI maintains smooth scrolling and frame rates without dropping frames or freezing.

### 4. Dynamic P&L Calculation
- In compliance with the assignment rules, **P&L is never stored statically**.
- P&L is computed at runtime from the holding position and the live LTP:
  $$\text{Current Value} = \text{Quantity} \times \text{LTP}$$
  $$\text{Unrealized P\&L} = \text{Current Value} - \text{Total Cost Basis}$$
- The aggregate portfolio summary at the top dynamically matches the exact sum of all individual holding rows.

### 5. Resilient Local Storage
- Local storage uses `shared_preferences` with JSON serialization.
- Built-in fallback guards ensure that even if corrupted data is present, the app catches parsing errors gracefully and restores valid default state without crashing.

---

## 📋 Comprehensive Scenarios Verification

| Feature | Scenario | Implementation & Verification |
|---|---|---|
| **Watchlist** | App restarts & persistence | Watchlists and contained stocks are automatically restored from `LocalStorageService`. |
| **Watchlist** | Drag reordering price bindings | `ReorderableListView` uses `ValueKey(symbol)`. Live price stream bindings remain bound to the correct stock after reordering. |
| **Watchlist** | Stock removal | Removed stock is purged from the list, stops receiving listeners, and stays removed across restarts. |
| **Watchlist** | Multiple watchlists with identical stocks | Both watchlists read from the shared `MockMarketFeedService` and display identical live ticks. |
| **Watchlist** | Empty watchlist | Friendly empty-state illustration and "Add Stocks" button shown when list has 0 items. |
| **Watchlist** | Row tap | Navigates to the Trade Ticket with that stock pre-filled. |
| **Live Prices** | Granular updates | Only affected cells rebuild on ticks; green up / red down micro-flash animations triggered. |
| **Live Prices** | Stress testing | Tested at 20 ticks/sec per stock (200 ticks/sec total) with smooth rendering. |
| **Live Prices** | Return from navigation | Re-entering screens displays current LTPs without stale data. |
| **Buy/Sell Ticket** | Live LTP & projected value | Projected order value updates dynamically on screen with every market tick. |
| **Buy/Sell Ticket** | Insufficient balance (Buy) | Validation error blocks submission inline if order cost exceeds wallet balance. |
| **Buy/Sell Ticket** | Insufficient shares (Sell) | Validation error blocks submission inline if user sells more shares than held (or 0 held). |
| **Buy/Sell Ticket** | Invalid quantities | Blocks 0, negative, and non-integer quantities. |
| **Buy/Sell Ticket** | Execution at submit LTP | Order executes at the exact instant LTP; wallet balance is debited/credited, and order receipt is displayed. |
| **Holdings** | Weighted average cost | Buying multiple lots accurately computes weighted average cost using `Decimal`. |
| **Holdings** | Complete sell-off | Selling all shares removes the holding row completely. |
| **Holdings** | P&L sorting | Sorts dynamically by P&L descending (default), Symbol, or Current Value with Asc/Desc toggle. |
| **Holdings** | Summary equals row sum | Top summary is guaranteed to equal the mathematical sum of all holding rows. |

---

## 🧪 Testing

The codebase includes a comprehensive automated test suite covering 36 tests across all domain, utility, and UI layers:

- `test/unit/currency_formatter_test.dart`: Indian rupee formatting, sign display, negative values, and Decimal formatting.
- `test/unit/holding_model_test.dart`: Decimal average cost, multi-lot buys, partial sells, sell to zero, and dynamic P&L.
- `test/unit/mock_market_feed_service_test.dart`: $\pm 0.1\%$ random walk bounds, tick streams, and rate adjustments.
- `test/unit/local_storage_service_test.dart`: Persistence and corrupt JSON fallback handling.
- `test/unit/portfolio_order_test.dart`: Buy/Sell validations, wallet deductions/credits, and holding adjustments.
- `test/unit/watchlist_test.dart`: Watchlist creation, renaming, deletion fallback, stock addition/removal, and reordering.
- `test/widget_test.dart`: End-to-end navigation smoke test across all 4 screens.

Run all tests:
```bash
flutter test
```

Analyze code quality:
```bash
flutter analyze
```

---

## 📦 Submission Details
- **GitHub Repository**: [https://github.com/rgupta7014/Trading-App.git](https://github.com/rgupta7014/Trading-App.git)
- **Starting Wallet Balance**: ₹10,00,000.00
- **Supported Stocks**: `RELIANCE`, `TCS`, `INFY`, `HDFCBANK`, `ICICIBANK`, `SBIN`, `ITC`, `LT`, `BHARTIARTL`, `AXISBANK`
