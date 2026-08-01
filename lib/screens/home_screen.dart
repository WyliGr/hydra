import 'package:flutter/material.dart';
import '../services/hydra_state.dart';
import '../models/drink_ratio.dart';
import '../utils/theme.dart';
import '../utils/format.dart';
import '../widgets/water_bottle.dart';
import '../widgets/quick_add_buttons.dart';
import '../widgets/drink_regulator_card.dart';
import '../services/widget_service.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  final HydraState state;
  const HomeScreen({super.key, required this.state});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    widget.state.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    widget.state.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (!mounted) return;
    WidgetService.updateWidget(
      todayMl: widget.state.todayWaterMl,
      goalMl: widget.state.dailyGoalMl,
      debtMl: widget.state.waterDebtMl,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;

    return Scaffold(
      backgroundColor: HydraTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header — HYDRA + thin line
              Text('HYDRA', style: HydraTheme.displayMedium),
              const SizedBox(height: 8),
              const Divider(
                height: 1,
                thickness: 1,
                color: HydraTheme.border,
              ),
              const SizedBox(height: 8),
              Text(
                'TRACK WATER. COMPENSATE DRINKS.',
                style: HydraTheme.label,
              ),
              const SizedBox(height: 16),

              // Streak badge (red Space Mono, no emoji)
              if (s.currentStreak > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: HydraTheme.accent,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'STREAK ${s.currentStreak}',
                          style: HydraTheme.dataRed.copyWith(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),

              // Bottle
              Center(
                child: WaterBottle(
                  progress: s.progress,
                  currentMl: s.todayWaterMl,
                  goalMl: s.dailyGoalMl,
                  debtMl: s.waterDebtMl,
                ),
              ),
              const SizedBox(height: 16),

              // Debt indicator (thin red box)
              if (s.waterDebtMl > 0)
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: HydraTheme.accent, width: 1),
                    ),
                    child: Text(
                      '+${_fmtMl(s.waterDebtMl)} DEBT',
                      style: HydraTheme.dataRed.copyWith(fontSize: 11),
                    ),
                  ),
                ),

              // Status text (grey, no emoji)
              _StatusMessage(
                progress: s.baseProgress,
                remainingMl: s.remainingMl,
                debtMl: s.waterDebtMl,
                currentMl: s.todayWaterMl,
                goalMl: s.dailyGoalMl,
              ),
              const SizedBox(height: 24),

              // Quick add
              QuickAddButtons(onAdd: (ml) => s.addWater(ml)),
              const SizedBox(height: 12),

              // Undo last
              if (s.todayWaterMl > 0)
                TextButton(
                  onPressed: s.removeLastWaterLog,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'UNDO LAST',
                    style: HydraTheme.label,
                  ),
                ),

              const SizedBox(height: 28),

              // Regulator
              DrinkRegulatorCard(
                todayDrinks: s.todayDrinks,
                onLogDrink: (drink) async {
                  await s.logDrink(drink);
                  if (!mounted) return;
                  NotificationService.showInstant(
                    title: 'REGULATOR',
                    body:
                        '${drink.name} logged. Drink ${FormatUtil.ml(drink.requiredWaterMl)} to compensate.',
                  );
                },
                onCompensate: s.compensateDrink,
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  static String _fmtMl(int ml) {
    if (ml >= 1000) {
      return '${(ml / 1000).toStringAsFixed(1)}L';
    }
    return '${ml}ML';
  }
}

class _StatusMessage extends StatelessWidget {
  final double progress;
  final int remainingMl;
  final int debtMl;
  final int currentMl;
  final int goalMl;

  const _StatusMessage({
    required this.progress,
    required this.remainingMl,
    required this.debtMl,
    required this.currentMl,
    required this.goalMl,
  });

  @override
  Widget build(BuildContext context) {
    String message;
    Color color;

    if (progress >= 1.0) {
      message = 'GOAL COMPLETE';
      color = HydraTheme.textPrimary;
    } else if (debtMl > 0 && progress < 0.5) {
      message =
          '${_fmtMl(remainingMl)} REMAINING (${_fmtMl(debtMl)} DEBT)';
      color = HydraTheme.textSecondary;
    } else if (debtMl > 0) {
      message = '${_fmtMl(remainingMl)} REMAINING — INCL. DEBT';
      color = HydraTheme.textSecondary;
    } else if (progress >= 0.75) {
      message = '${_fmtMl(remainingMl)} REMAINING';
      color = HydraTheme.textSecondary;
    } else if (progress >= 0.5) {
      message = '${_fmtMl(remainingMl)} REMAINING';
      color = HydraTheme.textSecondary;
    } else {
      message = '${_fmtMl(remainingMl)} REMAINING';
      color = HydraTheme.textSecondary;
    }

    return Text(
      message,
      style: HydraTheme.label.copyWith(
        color: color,
        fontSize: 12,
        letterSpacing: 2.0,
      ),
    );
  }

  static String _fmtMl(int ml) {
    if (ml >= 1000) {
      return '${(ml / 1000).toStringAsFixed(1)}L';
    }
    return '${ml}ML';
  }
}
