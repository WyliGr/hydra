import 'package:flutter/material.dart';
import '../services/hydra_state.dart';
import '../models/water_log.dart';
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
    // Push to widget
    WidgetService.updateWidget(
      todayMl: widget.state.todayWaterMl,
      goalMl: widget.state.dailyGoalMl,
      debtMl: widget.state.waterDebtMl,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;

    return ListenableBuilder(
      listenable: s,
      builder: (context, _) {
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hydra',
                            style: TextStyle(
                              color: HydraTheme.textPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Bois. Compense. Répète.',
                            style: TextStyle(
                              color: HydraTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      if (s.baseProgress >= 1.0)
                        const Icon(Icons.emoji_events, color: HydraTheme.success, size: 32)
                      else if (s.waterDebtMl > 0)
                        const Icon(Icons.warning_amber_rounded, color: HydraTheme.warning, size: 32)
                      else
                        const Icon(Icons.water_drop, color: HydraTheme.primary, size: 32),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Bottle
                  WaterBottle(
                    progress: s.progress,
                    currentMl: s.todayWaterMl,
                    goalMl: s.dailyGoalMl,
                    debtMl: s.waterDebtMl,
                  ),
                  const SizedBox(height: 16),

                  // Remaining / status message
                  _StatusMessage(
                    progress: s.baseProgress,
                    remainingMl: s.remainingMl,
                    debtMl: s.waterDebtMl,
                  ),
                  const SizedBox(height: 24),

                  // Quick add
                  QuickAddButtons(onAdd: (ml) => s.addWater(ml)),
                  const SizedBox(height: 12),

                  // Undo last
                  if (s.todayWaterMl > 0)
                    TextButton.icon(
                      onPressed: s.removeLastWaterLog,
                      icon: const Icon(Icons.undo, size: 16, color: HydraTheme.textSecondary),
                      label: const Text(
                        'Annuler le dernier',
                        style: TextStyle(color: HydraTheme.textSecondary, fontSize: 13),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Drink Regulator
                  DrinkRegulatorCard(
                    todayDrinks: s.todayDrinks,
                    onLogDrink: (drink) async {
                      await s.logDrink(drink);
                      NotificationService.showInstant(
                        title: '⚡ Régulateur',
                        body:
                            '${drink.name} loggué ! Bois ${FormatUtil.ml(drink.requiredWaterMl)} d\'eau pour compenser.',
                      );
                    },
                    onCompensate: s.compensateDrink,
                  ),

                  const SizedBox(height: 100), // bottom nav padding
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatusMessage extends StatelessWidget {
  final double progress;
  final int remainingMl;
  final int debtMl;

  const _StatusMessage({
    required this.progress,
    required this.remainingMl,
    required this.debtMl,
  });

  @override
  Widget build(BuildContext context) {
    String message;
    Color color;

    if (progress >= 1.0) {
      message = 'Objectif atteint ! 🎉';
      color = HydraTheme.success;
    } else if (debtMl > 0 && progress < 0.5) {
      message = 'Plus que ${FormatUtil.ml(remainingMl)} (dont ${FormatUtil.ml(debtMl)} de dette)';
      color = HydraTheme.warning;
    } else if (debtMl > 0) {
      message = 'Plus que ${FormatUtil.ml(remainingMl)} — n\'oublie pas la dette d\'eau';
      color = HydraTheme.warning;
    } else if (progress >= 0.75) {
      message = 'Presque ! Plus que ${FormatUtil.ml(remainingMl)}';
      color = HydraTheme.primary;
    } else if (progress >= 0.5) {
      message = 'Bon rythme ! ${FormatUtil.ml(remainingMl)} restants';
      color = HydraTheme.primary;
    } else {
      message = 'Plus que ${FormatUtil.ml(remainingMl)} à boire';
      color = HydraTheme.textSecondary;
    }

    return Text(
      message,
      style: TextStyle(
        color: color,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      textAlign: TextAlign.center,
    );
  }
}