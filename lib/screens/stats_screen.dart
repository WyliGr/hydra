import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/hydra_state.dart';
import '../utils/theme.dart';
import '../utils/format.dart';

class StatsScreen extends StatelessWidget {
  final HydraState state;
  const StatsScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final days = state.last7Days;
        final goal = state.dailyGoalMl;
        final avg = days.isEmpty
            ? 0
            : (days.fold(0, (sum, d) => sum + d.totalMl) / days.length)
                .round();
        final bestDay = days.isEmpty
            ? 0
            : days.map((d) => d.totalMl).reduce((a, b) => a > b ? a : b);
        final daysHitGoal = days.where((d) => d.totalMl >= goal).length;

        return Scaffold(
          backgroundColor: HydraTheme.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text('STATS', style: HydraTheme.displayMedium),
                  const SizedBox(height: 8),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: HydraTheme.border,
                  ),
                  const SizedBox(height: 8),
                  Text('7-DAY OVERVIEW', style: HydraTheme.label),
                  const SizedBox(height: 24),

                  // Summary cards — flat black tiles, 1px border
                  Row(
                    children: [
                      _StatCard(
                        label: 'AVG / DAY',
                        value: FormatUtil.ml(avg).toUpperCase(),
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        label: 'BEST',
                        value: FormatUtil.ml(bestDay).toUpperCase(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _StatCard(
                        label: 'DAYS HIT',
                        value: '$daysHitGoal/7',
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        label: 'GOAL',
                        value: FormatUtil.ml(goal).toUpperCase(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Streak section
                  NothingDecor.hairlineWithLabel('STREAK'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _StatCard(
                        label: 'CURRENT',
                        value: '${state.currentStreak}',
                        valueColor: state.currentStreak > 0
                            ? HydraTheme.accent
                            : HydraTheme.textPrimary,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        label: 'LONGEST',
                        value: '${state.longestStreak}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _StreakGrid(history: state.streakHistory),
                  const SizedBox(height: 32),

                  // Bar chart
                  NothingDecor.hairlineWithLabel('LAST 7 DAYS'),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY:
                            (bestDay > goal ? bestDay : goal).toDouble() * 1.2,
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, gsum, rod, rsum) {
                              return BarTooltipItem(
                                _ml(rod.toY.toInt()),
                                HydraTheme.dataSmall.copyWith(
                                  color: HydraTheme.textPrimary,
                                ),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final i = value.toInt();
                                if (i < 0 || i >= days.length) {
                                  return const SizedBox();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    FormatUtil.dayLabel(days[i].date)
                                        .toUpperCase(),
                                    style: HydraTheme.label.copyWith(
                                      fontSize: 10,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: goal.toDouble(),
                          getDrawingHorizontalLine: (value) {
                            if (value == goal.toDouble()) {
                              return FlLine(
                                color: HydraTheme.accent,
                                strokeWidth: 1,
                                dashArray: const [4, 4],
                              );
                            }
                            return const FlLine(
                              color: Colors.transparent,
                              strokeWidth: 0,
                            );
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: days.asMap().entries.map((e) {
                          final i = e.key;
                          final d = e.value;
                          final reached = d.totalMl >= goal;
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: d.totalMl.toDouble(),
                                color: reached
                                    ? HydraTheme.textPrimary
                                    : HydraTheme.textTertiary,
                                width: 4,
                                borderRadius: BorderRadius.zero,
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _LegendText(label: 'GOAL', isAccent: true),
                      const SizedBox(width: 24),
                      _LegendText(label: 'HIT', isAccent: false),
                      const SizedBox(width: 24),
                      _LegendText(label: 'MISS', isAccent: false),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Today's log
                  NothingDecor.hairlineWithLabel("TODAY'S DRINKS"),
                  const SizedBox(height: 12),
                  if (state.todayDrinks.isEmpty)
                    Text(
                      'NO ENTRIES',
                      style: HydraTheme.label.copyWith(
                        color: HydraTheme.textTertiary,
                      ),
                    )
                  else
                    ...state.todayDrinks.map((d) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            '+${FormatUtil.ml(d.volumeMl * d.waterRatio.round())}'
                            '  '
                            '${d.drinkTypeId.toUpperCase()}'
                            '${d.compensated ? '  · DONE' : '  · OPEN'}',
                            style: HydraTheme.bodySecondary.copyWith(
                              fontSize: 12,
                              color: d.compensated
                                  ? HydraTheme.textSecondary
                                  : HydraTheme.textPrimary,
                            ),
                          ),
                        )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static String _ml(int ml) {
    if (ml >= 1000) {
      return '${(ml / 1000).toStringAsFixed(1)}L';
    }
    return '${ml}ML';
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatCard({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: HydraTheme.background,
          border: Border.all(color: HydraTheme.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: HydraTheme.label),
            const SizedBox(height: 12),
            Text(
              value,
              style: HydraTheme.dataMedium.copyWith(
                color: valueColor ?? HydraTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendText extends StatelessWidget {
  final String label;
  final bool isAccent;
  const _LegendText({required this.label, required this.isAccent});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 1.5,
          color: isAccent ? HydraTheme.accent : HydraTheme.textTertiary,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: HydraTheme.label.copyWith(fontSize: 10),
        ),
      ],
    );
  }
}

class _StreakGrid extends StatelessWidget {
  final List<bool> history;
  const _StreakGrid({required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Text(
        'NO HISTORY',
        style: HydraTheme.label.copyWith(
          color: HydraTheme.textTertiary,
        ),
      );
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '30 DAYS',
          style: HydraTheme.label.copyWith(fontSize: 10),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            const cols = 10;
            const spacing = 6.0;
            final cellSize =
                (constraints.maxWidth - spacing * (cols - 1)) / cols;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: List.generate(history.length, (i) {
                final hit = history[i];
                final day =
                    today.subtract(Duration(days: history.length - 1 - i));
                return Tooltip(
                  message:
                      '${day.day}/${day.month} • ${hit ? 'HIT' : 'MISS'}',
                  child: Container(
                    width: cellSize,
                    height: cellSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: hit
                            ? HydraTheme.textPrimary
                            : HydraTheme.borderStrong,
                        width: 1,
                      ),
                    ),
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: hit
                            ? HydraTheme.textPrimary
                            : HydraTheme.textTertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _LegendText(label: 'HIT', isAccent: false),
            const SizedBox(width: 12),
            _LegendText(label: 'MISS', isAccent: false),
          ],
        ),
      ],
    );
  }
}
