import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class BudgetProgressBar extends StatelessWidget {
  final double percentage;
  final double height;

  const BudgetProgressBar({
    super.key,
    required this.percentage,
    this.height = 8,
  });

  Color get _progressColor {
    if (percentage > 90) return AppColors.error;
    if (percentage > 70) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final clampedPercent = percentage.clamp(0, 100) / 100;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                width: constraints.maxWidth * clampedPercent,
                height: height,
                decoration: BoxDecoration(
                  color: _progressColor,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
