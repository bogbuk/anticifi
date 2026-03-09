import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extension.dart';

class DebtProgressBar extends StatelessWidget {
  final double percentage;
  final double height;

  const DebtProgressBar({
    super.key,
    required this.percentage,
    this.height = 8,
  });

  Color get _progressColor {
    if (percentage >= 100) return AppColors.success;
    if (percentage >= 70) return AppColors.primary;
    if (percentage >= 40) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final clampedPercent = percentage.clamp(0, 100) / 100;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: context.appColors.border,
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
