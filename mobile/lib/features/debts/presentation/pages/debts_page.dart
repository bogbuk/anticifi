import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/debt_entity.dart';
import '../bloc/debts_cubit.dart';
import '../bloc/debts_state.dart';
import '../widgets/debt_card.dart';
import '../widgets/debt_summary_header.dart';

class DebtsPage extends StatefulWidget {
  const DebtsPage({super.key});

  @override
  State<DebtsPage> createState() => _DebtsPageState();
}

class _DebtsPageState extends State<DebtsPage> {
  int _tabIndex = 0; // 0=Active, 1=Paid Off, 2=All

  @override
  void initState() {
    super.initState();
    context.read<DebtsCubit>().loadDebts();
  }

  List<DebtEntity> _filterDebts(List<DebtEntity> debts) {
    switch (_tabIndex) {
      case 0:
        return debts.where((d) => d.isActive && !d.isPaidOff).toList();
      case 1:
        return debts.where((d) => d.isPaidOff).toList();
      default:
        return debts;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.debts)),
      body: Column(
        children: [
          // Tabs
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Container(
              decoration: BoxDecoration(
                color: context.appColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.appColors.border),
              ),
              child: Row(
                children: List.generate(3, (index) {
                  final labels = [l10n.active, l10n.paidOff, l10n.all];
                  final isSelected = _tabIndex == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tabIndex = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          labels[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.primaryLight
                                : context.appColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          // Content
          Expanded(
            child: BlocConsumer<DebtsCubit, DebtsState>(
              listener: (context, state) {
                if (state is DebtsError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is DebtsLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                if (state is DebtsLoaded) {
                  final filtered = _filterDebts(state.debts);
                  return RefreshIndicator(
                    color: AppColors.primary,
                    backgroundColor: context.appColors.card,
                    onRefresh: () => context.read<DebtsCubit>().loadDebts(),
                    child: ListView(
                      children: [
                        DebtSummaryHeader(summary: state.summary),
                        if (filtered.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.money_off, size: 64, color: context.appColors.textMuted),
                                  const SizedBox(height: 16),
                                  Text(
                                    _tabIndex == 0
                                        ? l10n.noActiveDebts
                                        : _tabIndex == 1
                                            ? l10n.noPaidOffDebts
                                            : l10n.noDebts,
                                    style: TextStyle(fontSize: 18, color: context.appColors.textSecondary),
                                  ),
                                  if (_tabIndex == 0) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      l10n.tapPlusToAddDebt,
                                      style: TextStyle(fontSize: 14, color: context.appColors.textMuted),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: filtered
                                  .map((debt) => DebtCard(
                                        debt: debt,
                                        onTap: () async {
                                          final result = await context.push('/debts/${debt.id}');
                                          if (result == true && context.mounted) {
                                            context.read<DebtsCubit>().loadDebts();
                                          }
                                        },
                                      ))
                                  .toList(),
                            ),
                          ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          final result = await context.push('/debts/add');
          if (result == true && mounted) {
            context.read<DebtsCubit>().loadDebts();
          }
        },
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }
}
