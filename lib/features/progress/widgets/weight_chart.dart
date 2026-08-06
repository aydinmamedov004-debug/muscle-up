import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/progress/exercise_weight_point.dart';

class WeightChart extends StatelessWidget {
  final List<ExerciseWeightPoint> points;

  const WeightChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            "Complete this exercise at least twice, logging a weight "
            "each time, to see a trend.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    final weights = points.map((point) => point.maxWeight);
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final padding = ((maxWeight - minWeight) * 0.2).clamp(2.0, double.infinity);

    final spots = [
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].maxWeight),
    ];

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minY: (minWeight - padding).clamp(0.0, double.infinity),
          maxY: maxWeight + padding,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppTheme.surfaceLight,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final point = points[spot.spotIndex];

                  return LineTooltipItem(
                    "${point.maxWeight.toStringAsFixed(1)} kg\n"
                    "${DateFormat('d MMM').format(point.date)}",
                    const TextStyle(
                      color: AppTheme.text,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.secondaryText,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval:
                    (points.length / 4).clamp(1, double.infinity).ceilToDouble(),
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();

                  if (index < 0 || index >= points.length) {
                    return const SizedBox.shrink();
                  }

                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      DateFormat('d/M').format(points[index].date),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppTheme.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.primary.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
