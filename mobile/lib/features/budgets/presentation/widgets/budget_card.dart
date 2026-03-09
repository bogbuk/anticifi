import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/budget_entity.dart';
import 'budget_progress_bar.dart';

class BudgetCard extends StatelessWidget {
  final BudgetEntity budget;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const BudgetCard({
    super.key,
    required this.budget,
    this.onTap,
    this.onDelete,
  });

  String _periodLabel(AppLocalizations l10n) {
    switch (budget.period) {
      case 'weekly':
        return l10n.weekly;
      case 'monthly':
        return l10n.monthly;
      case 'yearly':
        return l10n.yearly;
      default:
        return budget.period;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.appColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: budget.isOverBudget
                ? AppColors.error.withOpacity(0.3)
                : context.appColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: name + period badge
            Row(
              children: [
                // Category icon
                if (budget.categoryColor != null)
                  Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: _parseColor(budget.categoryColor!)
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        budget.categoryIcon ?? '💰',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text('💰', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        budget.name,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (budget.categoryName != null)
                        Text(
                          budget.categoryName!,
                          style: TextStyle(
                            color: context.appColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _periodLabel(l10n),
                    style: const TextStyle(
                      color: AppColors.primaryLight,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: context.appColors.textMuted,
                      size: 20,
                    ),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress bar
            BudgetProgressBar(percentage: budget.progressPercent),
            const SizedBox(height: 8),

            // Spent / Limit row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${budget.spentAmount.toStringAsFixed(2)} spent',
                  style: TextStyle(
                    color: budget.isOverBudget
                        ? AppColors.error
                        : context.appColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '\$${budget.amount.toStringAsFixed(2)} limit',
                  style: TextStyle(
                    color: context.appColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${budget.progressPercent.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: budget.isOverBudget
                        ? AppColors.error
                        : context.appColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '\$${budget.remainingAmount.toStringAsFixed(2)} remaining',
                  style: TextStyle(
                    color: context.appColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      final hexColor = hex.replaceFirst('#', '');
      return Color(int.parse('FF$hexColor', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }
}
