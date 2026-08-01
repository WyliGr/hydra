import 'package:flutter/material.dart';
import '../models/drink_ratio.dart';
import '../utils/theme.dart';
import '../utils/format.dart';

/// Shows today's logged drinks with their water debt and compensation status.
/// Nothing OS: text chips, no emojis, no filled backgrounds, hairline borders.
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
      decoration: BoxDecoration(
        color: HydraTheme.surface,
        border: Border.all(color: HydraTheme.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('REGULATOR', style: HydraTheme.titleUpper),
                if (totalDebt > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: HydraTheme.accent,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '+${FormatUtil.ml(totalDebt)} DEBT',
                      style: HydraTheme.dataRed.copyWith(fontSize: 10),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: HydraTheme.border),

          // Quick log drink buttons
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: DrinkPresets.all.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final drink = DrinkPresets.all[i];
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onLogDrink(drink),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: HydraTheme.borderStrong,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      drink.name.toUpperCase(),
                      style: HydraTheme.body.copyWith(
                        fontSize: 11,
                        letterSpacing: 1.2,
                        color: HydraTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, thickness: 1, color: HydraTheme.border),

          // Today's drink log list
          if (todayDrinks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 18),
              child: Text(
                'NO LOGGED DRINKS TODAY',
                style: HydraTheme.label.copyWith(
                  color: HydraTheme.textTertiary,
                ),
              ),
            )
          else
            ...List.generate(todayDrinks.length, (i) {
              final d = todayDrinks[i];
              final drinkType = DrinkPresets.byId(d.drinkTypeId);
              return Column(
                children: [
                  _DrinkLogTile(
                    drinkLog: d,
                    name: drinkType?.name ?? d.drinkTypeId,
                    onCompensate: () => onCompensate(d.id),
                  ),
                  if (i < todayDrinks.length - 1)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: HydraTheme.border,
                    ),
                ],
              );
            }),
        ],
      ),
    );
  }
}

class _DrinkLogTile extends StatelessWidget {
  final DrinkLog drinkLog;
  final String name;
  final VoidCallback onCompensate;

  const _DrinkLogTile({
    required this.drinkLog,
    required this.name,
    required this.onCompensate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.toUpperCase(),
                  style: HydraTheme.body.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.8,
                    color: HydraTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${FormatUtil.ml(drinkLog.volumeMl)} · '
                  '${drinkLog.waterRatio.toStringAsFixed(1)}:1 → '
                  '${FormatUtil.ml(drinkLog.requiredWaterMl)}',
                  style: HydraTheme.bodySecondary.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          if (drinkLog.compensated)
            Text(
              'DONE',
              style: HydraTheme.dataRed.copyWith(
                color: HydraTheme.textPrimary,
                fontSize: 11,
              ),
            )
          else
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onCompensate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: HydraTheme.accent, width: 1),
                ),
                child: Text(
                  'COMPENSATE',
                  style: HydraTheme.dataRed.copyWith(fontSize: 10),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
