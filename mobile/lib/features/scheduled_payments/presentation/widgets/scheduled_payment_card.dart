import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../domain/entities/scheduled_payment_entity.dart';

class ScheduledPaymentCard extends StatelessWidget {
  final ScheduledPaymentEntity payment;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onExecute;

  const ScheduledPaymentCard({
    super.key,
    required this.payment,
    this.onTap,
    this.onDelete,
    this.onExecute,
  });

  String _frequencyLabel(String frequency) {
    switch (frequency) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'biweekly':
        return 'Biweekly';
      case 'monthly':
        return 'Monthly';
      case 'quarterly':
        return 'Quarterly';
      case 'yearly':
        return 'Yearly';
      default:
        return frequency;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = payment.type == 'income';
    final amountColor = isIncome ? AppColors.success : AppColors.error;
    final amountPrefix = isIncome ? '+' : '-';
    final dateFormat = DateFormat('MMM d, yyyy');
    final opacity = payment.isActive ? 1.0 : 0.5;

    return Opacity(
      opacity: opacity,
      child: Dismissible(
        key: Key(payment.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.delete_outline,
            color: AppColors.error,
            size: 28,
          ),
        ),
        confirmDismiss: (direction) async {
          return await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: context.appColors.card,
              title: Text(
                'Delete Scheduled Payment',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
              content: Text(
                'Are you sure you want to delete "${payment.name}"?',
                style: TextStyle(color: context.appColors.textSecondary),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            ),
          );
        },
        onDismissed: (_) => onDelete?.call(),
        child: GestureDetector(
          onTap: onTap,
          onLongPress: () {
            if (payment.isActive && onExecute != null) {
              _showExecuteDialog(context);
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.appColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.appColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: amountColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isIncome
                            ? Icons.arrow_downward_rounded
                            : Icons.arrow_upward_rounded,
                        color: amountColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Name and account
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            payment.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            payment.accountName,
                            style: TextStyle(
                              fontSize: 13,
                              color: context.appColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Amount
                    Text(
                      '$amountPrefix\$${payment.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: amountColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Bottom row: frequency badge + next execution date
                Row(
                  children: [
                    // Frequency badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _frequencyLabel(payment.frequency),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Next execution
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: context.appColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Next: ${dateFormat.format(payment.nextExecutionDate)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.appColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    // Execute button
                    if (payment.isActive && onExecute != null) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _showExecuteDialog(context),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: AppColors.success,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showExecuteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.appColors.card,
        title: Text(
          'Execute Payment',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Text(
          'Execute "${payment.name}" now?',
          style: TextStyle(color: context.appColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onExecute?.call();
            },
            child: const Text(
              'Execute',
              style: TextStyle(color: AppColors.success),
            ),
          ),
        ],
      ),
    );
  }
}
