import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors_extension.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/dashboard_entity.dart';

class SpendingChart extends StatefulWidget {
  final List<CategorySpending> spendingByCategory;

  const SpendingChart({
    super.key,
    required this.spendingByCategory,
  });

  @override
  State<SpendingChart> createState() => _SpendingChartState();
}

class _SpendingChartState extends State<SpendingChart> {
  int _touchedIndex = -1;

  static const List<Color> _chartColors = [
    Color(0xFF6366F1), // indigo
    Color(0xFFA855F7), // purple
    Color(0xFF3B82F6), // blue
    Color(0xFF22D3EE), // cyan
    Color(0xFF26C281), // green
    Color(0xFFFFB300), // amber
    Color(0xFFE53935), // red
    Color(0xFFF97316), // orange
    Color(0xFFEC4899), // pink
    Color(0xFF14B8A6), // teal
  ];

  Color _parseColor(String hex, int index) {
    try {
      final cleaned = hex.replaceAll('#', '');
      if (cleaned.length == 6) {
        return Color(int.parse('FF$cleaned', radix: 16));
      }
    } catch (_) {}
    return _chartColors[index % _chartColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (widget.spendingByCategory.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.appColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.appColors.border),
        ),
        child: Column(
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 48,
              color: context.appColors.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noSpendingDataYet,
              style: TextStyle(
                fontSize: 14,
                color: context.appColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final totalSpending =
        widget.spendingByCategory.fold<double>(0, (sum, c) => sum + c.amount);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.appColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.appColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.spendingByCategory,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        _touchedIndex = -1;
                        return;
                      }
                      _touchedIndex = pieTouchResponse
                          .touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: _buildSections(totalSpending),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ..._buildLegend(totalSpending),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections(double totalSpending) {
    return List.generate(widget.spendingByCategory.length, (index) {
      final category = widget.spendingByCategory[index];
      final isTouched = index == _touchedIndex;
      final color = _parseColor(category.color, index);
      final percentage = totalSpending > 0
          ? (category.amount / totalSpending) * 100
          : 0.0;

      return PieChartSectionData(
        color: color,
        value: category.amount,
        title: isTouched ? '${percentage.toStringAsFixed(1)}%' : '',
        radius: isTouched ? 55 : 45,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titlePositionPercentageOffset: 0.6,
      );
    });
  }

  List<Widget> _buildLegend(double totalSpending) {
    return widget.spendingByCategory.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final color = _parseColor(category.color, index);
      final percentage = totalSpending > 0
          ? (category.amount / totalSpending) * 100
          : 0.0;

      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                category.categoryName,
                style: TextStyle(
                  fontSize: 13,
                  color: context.appColors.textSecondary,
                ),
              ),
            ),
            Text(
              '\$${category.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                color: context.appColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
