import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trading_app/core/constants/stock_constants.dart';
import 'package:trading_app/core/theme/app_theme.dart';
import 'package:trading_app/features/market/providers/market_feed_provider.dart';

/// Modal bottom sheet providing granular and stress-test control over the mock feed.
class TickRateControlSheet extends ConsumerWidget {
  const TickRateControlSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const TickRateControlSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRate = ref.watch(tickRateProvider);
    final isRunning = ref.watch(isTickerRunningProvider);
    final totalTicksPerSec = (currentRate * AppConstants.stocks.length).round();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.darkCardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Feed Speed Controller',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkTextPrimary,
                    ),
                  ),
                  Text(
                    'Configure mock market tick rate',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.darkTextSecondary,
                    ),
                  ),
                ],
              ),
              IconButton.filledTonal(
                onPressed: () {
                  ref.read(tickRateProvider.notifier).togglePlayback(!isRunning);
                },
                icon: Icon(
                  isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: isRunning ? AppColors.bearish : AppColors.bullish,
                ),
                tooltip: isRunning ? 'Pause Feed' : 'Resume Feed',
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Active rate highlight
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.darkBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.darkCardBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rate per Stock',
                      style: TextStyle(fontSize: 12, color: AppColors.darkTextSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${currentRate.toStringAsFixed(1)} ticks/sec',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: AppColors.darkCardBorder,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Total App Load (10 stocks)',
                      style: TextStyle(fontSize: 12, color: AppColors.darkTextSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$totalTicksPerSec ticks/sec',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: currentRate >= 10.0
                            ? AppColors.bearish
                            : AppColors.bullish,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.darkCardBorder,
              thumbColor: AppColors.accent,
              overlayColor: AppColors.accent.withAlpha(30),
              trackHeight: 6,
            ),
            child: Slider(
              value: currentRate,
              min: AppConstants.minTicksPerSecond,
              max: AppConstants.maxTicksPerSecond,
              divisions: 99,
              label: '${currentRate.toStringAsFixed(1)} ticks/s',
              onChanged: (val) {
                ref.read(tickRateProvider.notifier).setRate(val);
              },
            ),
          ),
          const SizedBox(height: 10),
          // Preset Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => ref.read(tickRateProvider.notifier).setRate(1.0),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: currentRate == 1.0 ? AppColors.primary : AppColors.darkCardBorder,
                    ),
                  ),
                  child: const Text('1/sec (Norm)', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => ref.read(tickRateProvider.notifier).setRate(5.0),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: currentRate == 5.0 ? AppColors.primary : AppColors.darkCardBorder,
                    ),
                  ),
                  child: const Text('5/sec (Fast)', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => ref.read(tickRateProvider.notifier).setRate(20.0),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: currentRate == 20.0 ? AppColors.bearish : AppColors.darkCardBorder,
                    ),
                  ),
                  child: const Text('20/sec 🔥', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
