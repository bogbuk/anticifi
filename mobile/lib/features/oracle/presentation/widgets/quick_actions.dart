import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class QuickActions extends StatelessWidget {
  final void Function(String question) onQuickAction;

  const QuickActions({
    super.key,
    required this.onQuickAction,
  });

  static const List<String> _actions = [
    '30-day forecast',
    'Can I afford \$500?',
    'When will I run out?',
    'Monthly spending prediction',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return _buildChip(_actions[index]);
        },
      ),
    );
  }

  Widget _buildChip(String label) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onQuickAction(label),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.auto_awesome,
                color: AppColors.accent,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
