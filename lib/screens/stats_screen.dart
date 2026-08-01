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
            : (days.fold(0, (sum, d) => sum + d.totalMl) / days.length).round();
        final bestDay = days.isEmpty
            ? 0
            : days.map((d) => d.totalMl).reduce((a, b) => a > b ? a : b);
        final daysHitGoal = days.where((d) => d.totalMl >= goal).length;

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Stats',
                    style: TextStyle(
                      color: HydraTheme.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Summary cards
                  Row(
                    children: [
                      _StatCard(
                        label: 'Moyenne',
                        value: FormatUtil.ml(avg),
                        icon: Icons.trending_up,
                        color: HydraTheme.primary,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        label: 'Meilleur',
                        value: FormatUtil.ml(bestDay),
                        icon: Icons.emoji_events,
                        color: HydraTheme.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _StatCard(
                        label: 'Jours atteints',
                        value: '$daysHitGoal/7',
                        icon: Icons.check_circle,
                        color: HydraTheme.accent,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        label: 'Objectif',
                        value: FormatUtil.ml(goal),
                        icon: Icons.flag,
                        color: HydraTheme.warning,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Bar chart
                  const Text(
                    '7 derniers jours',
                    style: TextStyle(
                      color: HydraTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: (bestDay > goal ? bestDay : goal).toDouble() * 1.2,
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, gsum, rod, rsum) {
                              return BarTooltipItem(
                                FormatUtil.ml(rod.toY.toInt()),
                                const TextStyle(
                                  color: HydraTheme.textPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final i = value.toInt();
                                if (i < 0 || i >= days.length) return const SizedBox();
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    FormatUtil.dayLabel(days[i].date),
                                    style: const TextStyle(
                                      color: HydraTheme.textSecondary,
                                      fontSize: 12,
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
                              return const FlLine(
                                color: HydraTheme.warning,
                                strokeWidth: 1.5,
                                dashArray: [5, 5],
                              );
                            }
                            return const FlLine(color: Colors.transparent, strokeWidth: 0);
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
                                color: reached ? HydraTheme.success : HydraTheme.primary,
                                width: 28,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _LegendDot(color: HydraTheme.success, label: 'Objectif atteint'),
                      const SizedBox(width: 16),
                      _LegendDot(color: HydraTheme.primary, label: 'En dessous'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Today's log timeline
                  const Text(
                    'Aujourd\'hui',
                    style: TextStyle(
                      color: HydraTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...state.todayDrinks.map((d) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.water_drop, color: HydraTheme.primary, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              '+${FormatUtil.ml(d.volumeMl * d.waterRatio.round())} (dette)',
                              style: const TextStyle(color: HydraTheme.textSecondary, fontSize: 13),
                            ),
                          ],
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
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: HydraTheme.surfaceLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: HydraTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: HydraTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: HydraTheme.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}