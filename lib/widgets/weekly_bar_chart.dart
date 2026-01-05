import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../utils/currency_utils.dart';

class WeeklyBarChart extends StatefulWidget {
  final List<double> weeklyData;

  const WeeklyBarChart({super.key, required this.weeklyData});

  @override
  State<WeeklyBarChart> createState() => _WeeklyBarChartState();
}

class _WeeklyBarChartState extends State<WeeklyBarChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final maxY = widget.weeklyData.isEmpty
        ? 100.0
        : widget.weeklyData.reduce((a, b) => a > b ? a : b) * 1.3;

    return AspectRatio(
      aspectRatio: 1.5,
      child: BarChart(
        BarChartData(
          barTouchData: BarTouchData(
            touchCallback: (event, response) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    response == null ||
                    response.spot == null) {
                  touchedIndex = -1;
                  return;
                }
                touchedIndex = response.spot!.touchedBarGroupIndex;
              });
            },
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppTheme.darkCard,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  CurrencyUtils.formatCompact(rod.toY),
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, meta) {
                  final day = now.subtract(Duration(days: 6 - value.toInt()));
                  final isToday = value.toInt() == 6;
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      children: [
                        Text(
                          DateFormat.E().format(day).substring(0, 2),
                          style: TextStyle(
                            color: isToday
                                ? AppTheme.primaryGradientStart
                                : Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                            fontWeight: isToday
                                ? FontWeight.bold
                                : FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: widget.weeklyData.asMap().entries.map((entry) {
            final isTouched = entry.key == touchedIndex;
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value == 0 ? 0.5 : entry.value,
                  gradient: isTouched
                      ? LinearGradient(
                          colors: [
                            AppTheme.accentColor,
                            AppTheme.primaryGradientStart,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        )
                      : LinearGradient(
                          colors: [
                            AppTheme.primaryGradientStart.withValues(
                              alpha: 0.6,
                            ),
                            AppTheme.primaryGradientEnd.withValues(alpha: 0.6),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                  width: isTouched ? 20 : 16,
                  borderRadius: BorderRadius.circular(8),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.05),
                  ),
                ),
              ],
            );
          }).toList(),
          gridData: const FlGridData(show: false),
          maxY: maxY,
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      ),
    );
  }
}
