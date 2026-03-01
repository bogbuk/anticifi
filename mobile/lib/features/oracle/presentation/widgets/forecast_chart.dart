import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/prediction_entity.dart';

class ForecastChart extends StatelessWidget {
  final List<PredictionEntity> predictions;

  const ForecastChart({
    super.key,
    required this.predictions,
  });

  @override
  Widget build(BuildContext context) {
    if (predictions.isEmpty) {
      return const SizedBox.shrink();
    }

    final sorted = List<PredictionEntity>.from(predictions)
      ..sort((a, b) => a.date.compareTo(b.date));

    final spots = <FlSpot>[];
    final lowerSpots = <FlSpot>[];
    final upperSpots = <FlSpot>[];

    for (int i = 0; i < sorted.length; i++) {
      spots.add(FlSpot(i.toDouble(), sorted[i].predictedBalance));
      lowerSpots.add(FlSpot(i.toDouble(), sorted[i].lowerBound));
      upperSpots.add(FlSpot(i.toDouble(), sorted[i].upperBound));
    }

    double minY = double.infinity;
    double maxY = double.negativeInfinity;
    for (final p in sorted) {
      if (p.lowerBound < minY) minY = p.lowerBound;
      if (p.upperBound > maxY) maxY = p.upperBound;
    }

    final yPadding = (maxY - minY) * 0.1;
    minY = minY - yPadding;
    maxY = maxY + yPadding;

    return Container(
      height: 180,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(4, 16, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY - minY) / 4,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.border,
                strokeWidth: 0.5,
              );
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      '\$${value.toInt()}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: _calculateInterval(sorted.length),
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= sorted.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat('M/d').format(sorted[index].date),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            // Upper bound (invisible, for fill area)
            LineChartBarData(
              spots: upperSpots,
              isCurved: true,
              color: Colors.transparent,
              barWidth: 0,
              dotData: FlDotData(show: false),
            ),
            // Main prediction line
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
            // Lower bound (invisible, for fill area)
            LineChartBarData(
              spots: lowerSpots,
              isCurved: true,
              color: Colors.transparent,
              barWidth: 0,
              dotData: FlDotData(show: false),
            ),
          ],
          betweenBarsData: [
            BetweenBarsData(
              fromIndex: 2, // lower
              toIndex: 0, // upper
              color: AppColors.primary.withOpacity(0.1),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: AppColors.card,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  if (spot.barIndex != 1) return null;
                  final index = spot.x.toInt();
                  if (index < 0 || index >= sorted.length) return null;
                  final p = sorted[index];
                  return LineTooltipItem(
                    '\$${p.predictedBalance.toStringAsFixed(0)}\n${DateFormat('MMM d').format(p.date)}',
                    const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  double _calculateInterval(int length) {
    if (length <= 7) return 1;
    if (length <= 14) return 2;
    if (length <= 30) return 5;
    return (length / 6).roundToDouble();
  }
}
