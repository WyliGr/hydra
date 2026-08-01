import 'package:flutter/material.dart';
import '../models/drink_ratio.dart';
import '../utils/theme.dart';
import '../utils/format.dart';

/// Shows today's logged drinks with their water debt and compensation status.
class DrinkRegulatorCard extends StatelessWidget {
  final List<DrinkLog> todayDrinks;
  final void Function(DrinkType drink) onLogDrink;
  final void Function(String drinkLogId) onCompensate;

  const DrinkRegulatorCard({
    super.key,
    required this.todayDrinks,
    required this.onLogDrink,
    required this.onCompensate,
  });

  @override
  Widget build(BuildContext context) {
    final totalDebt = todayDrinks
        .where((d) => !d.compensated)
        .fold(0, (sum, e) => sum + e.requiredWaterMl);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HydraTheme.surfaceLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.balance, color: HydraTheme.warning, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Régulateur',
                    style: TextStyle(
                      color: HydraTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              if (totalDebt > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: HydraTheme.warning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Dette: ${FormatUtil.ml(totalDebt)}',
                    style: const TextStyle(
                      color: HydraTheme.warning,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Quick drink log buttons
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: DrinkPresets.all.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final drink = DrinkPresets.all[i];
                return GestureDetector(
                  onTap: () => onLogDrink(drink),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: HydraTheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: HydraTheme.warning.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(drink.emoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 6),
                        Text(
                          drink.name,
                          style: const TextStyle(
                            color: HydraTheme.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Today's logged drinks
          if (todayDrinks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Aucune boisson sucrée/cafétinée aujourd\'hui. C\'est parfait ! 💪',
                style: TextStyle(color: HydraTheme.textSecondary, fontSize: 13),
              ),
            )
          else
            ...todayDrinks.map((d) {
              final drinkType = DrinkPresets.byId(d.drinkTypeId);
              return _DrinkLogTile(
                drinkLog: d,
                emoji: drinkType?.emoji ?? '🥤',
                name: drinkType?.name ?? d.drinkTypeId,
                onCompensate: () => onCompensate(d.id),
              );
            }),
        ],
      ),
    );
  }
}

class _DrinkLogTile extends StatelessWidget {
  final DrinkLog drinkLog;
  final String emoji;
  final String name;
  final VoidCallback onCompensate;

  const _DrinkLogTile({
    required this.drinkLog,
    required this.emoji,
    required this.name,
    required this.onCompensate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: HydraTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${FormatUtil.ml(drinkLog.volumeMl)} → ${FormatUtil.ml(drinkLog.requiredWaterMl)} d\'eau ${drinkLog.waterRatio.toStringAsFixed(1)}:1',
                  style: const TextStyle(
                    color: HydraTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (drinkLog.compensated)
            const Icon(Icons.check_circle, color: HydraTheme.success, size: 22)
          else
            GestureDetector(
              onTap: onCompensate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: HydraTheme.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Compenser',
                  style: TextStyle(
                    color: HydraTheme.warning,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}