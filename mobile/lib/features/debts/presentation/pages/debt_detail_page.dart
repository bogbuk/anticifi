import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/debt_entity.dart';
import '../bloc/debts_cubit.dart';
import '../bloc/debts_state.dart';
import '../widgets/debt_progress_bar.dart';
import '../widgets/payment_history_list.dart';

class DebtDetailPage extends StatefulWidget {
  final String debtId;

  const DebtDetailPage({super.key, required this.debtId});

  @override
  State<DebtDetailPage> createState() => _DebtDetailPageState();
}

class _DebtDetailPageState extends State<DebtDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<DebtsCubit>().loadDebtDetail(widget.debtId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('MMM d, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.debtDetails),
        actions: [
          BlocBuilder<DebtsCubit, DebtsState>(
            builder: (context, state) {
              if (state is DebtDetailLoaded) {
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () async {
                        final result = await context.push(
                          '/debts/${widget.debtId}/edit',
                          extra: state.debt,
                        );
                        if (result == true && context.mounted) {
                          context.read<DebtsCubit>().loadDebtDetail(widget.debtId);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      onPressed: () => _showDeleteConfirmation(context, state.debt),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<DebtsCubit, DebtsState>(
        listener: (context, state) {
          if (state is DebtsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          if (state is DebtsLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is DebtDetailLoaded) {
            final debt = state.debt;
            return RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: context.appColors.card,
              onRefresh: () => context.read<DebtsCubit>().loadDebtDetail(widget.debtId),
              child: ListView(
                children: [
                  // Main info card
                  Container(
                    margin: const EdgeInsets.all(16),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                debt.name,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (debt.isPaidOff)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(l10n.paidOff,
                                    style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(debt.typeLabel,
                            style: TextStyle(color: context.appColors.textMuted, fontSize: 14)),
                        if (debt.creditorName != null) ...[
                          const SizedBox(height: 2),
                          Text(debt.creditorName!,
                              style: TextStyle(color: context.appColors.textMuted, fontSize: 13)),
                        ],
                        const SizedBox(height: 16),
                        DebtProgressBar(percentage: debt.progressPercent, height: 12),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('\$${debt.totalPaid.toStringAsFixed(2)} paid',
                                style: const TextStyle(color: AppColors.success, fontSize: 14, fontWeight: FontWeight.w500)),
                            Text('${debt.progressPercent.toStringAsFixed(0)}%',
                                style: TextStyle(color: context.appColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Details grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildInfoTile(l10n.original, '\$${debt.originalAmount.toStringAsFixed(2)}'),
                        _buildInfoTile(l10n.remaining, '\$${debt.currentBalance.toStringAsFixed(2)}'),
                        _buildInfoTile(l10n.interest, '${debt.interestRate.toStringAsFixed(1)}%'),
                        _buildInfoTile(l10n.minPayment, '\$${debt.minimumPayment.toStringAsFixed(2)}'),
                        if (debt.dueDay != null)
                          _buildInfoTile('Due Day', '${debt.dueDay}'),
                        _buildInfoTile(l10n.start, dateFormat.format(debt.startDate)),
                        if (debt.expectedPayoffDate != null)
                          _buildInfoTile(l10n.expectedPayoff, dateFormat.format(debt.expectedPayoffDate!)),
                      ],
                    ),
                  ),

                  if (debt.notes != null && debt.notes!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.appColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.appColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.notes,
                              style: TextStyle(color: context.appColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(debt.notes!,
                              style: TextStyle(color: context.appColors.textSecondary, fontSize: 14)),
                        ],
                      ),
                    ),

                  // Payment history
                  PaymentHistoryList(payments: state.payments),

                  const SizedBox(height: 80),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: BlocBuilder<DebtsCubit, DebtsState>(
        builder: (context, state) {
          if (state is DebtDetailLoaded && !state.debt.isPaidOff) {
            return FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              onPressed: () async {
                final result = await context.push(
                  '/debts/${widget.debtId}/pay',
                  extra: state.debt,
                );
                if (result == true && context.mounted) {
                  context.read<DebtsCubit>().loadDebtDetail(widget.debtId);
                }
              },
              icon: Icon(Icons.payment, color: Theme.of(context).colorScheme.onSurface),
              label: Text(l10n.recordPayment, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 48) / 2,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.appColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.appColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: context.appColors.textMuted, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, DebtEntity debt) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(l10n.delete, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Text(l10n.deleteBudgetConfirm(debt.name),
            style: TextStyle(color: context.appColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel, style: TextStyle(color: context.appColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<DebtsCubit>().deleteDebt(debt.id);
              context.pop(true);
            },
            child: Text(l10n.delete, style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
