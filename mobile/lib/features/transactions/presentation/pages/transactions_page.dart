import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/transactions_bloc.dart';
import '../bloc/transactions_event.dart';
import '../bloc/transactions_state.dart';
import '../widgets/transaction_tile.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final ScrollController _scrollController = ScrollController();
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<TransactionsBloc>().add(const LoadTransactions());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<TransactionsBloc>().add(const LoadMoreTransactions());
    }
  }

  void _onFilterChanged(String? filter) {
    setState(() => _selectedFilter = filter);
    context.read<TransactionsBloc>().add(LoadTransactions(typeFilter: filter));
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => child!,
    );

    if (picked != null && mounted) {
      context.read<TransactionsBloc>().add(LoadTransactions(
            typeFilter: _selectedFilter,
            dateFrom: picked.start,
            dateTo: picked.end,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: Icon(Icons.date_range, color: context.appColors.textSecondary),
            onPressed: _pickDateRange,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _FilterChip(
                  label: l10n.all,
                  isSelected: _selectedFilter == null,
                  onTap: () => _onFilterChanged(null),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: l10n.income,
                  isSelected: _selectedFilter == 'income',
                  onTap: () => _onFilterChanged('income'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: l10n.expense,
                  isSelected: _selectedFilter == 'expense',
                  onTap: () => _onFilterChanged('expense'),
                ),
              ],
            ),
          ),

          // Transactions list
          Expanded(
            child: BlocConsumer<TransactionsBloc, TransactionsState>(
              listener: (context, state) {
                if (state is TransactionsError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is TransactionsLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }

                if (state is TransactionsLoaded) {
                  if (state.transactions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: context.appColors.textMuted,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noTransactionsYet,
                            style: TextStyle(
                              fontSize: 18,
                              color: context.appColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.tapPlusToAddTransaction,
                            style: TextStyle(
                              fontSize: 14,
                              color: context.appColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    backgroundColor: context.appColors.card,
                    onRefresh: () async {
                      context.read<TransactionsBloc>().add(
                            LoadTransactions(typeFilter: _selectedFilter),
                          );
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: state.transactions.length +
                          (state.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == state.transactions.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        }

                        final transaction = state.transactions[index];
                        return Dismissible(
                          key: Key(transaction.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            color: AppColors.error,
                            child: const Icon(Icons.delete_outline,
                                color: Colors.white),
                          ),
                          confirmDismiss: (_) async {
                            return await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: context.appColors.card,
                                title: Text(l10n.deleteTransaction,
                                    style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface)),
                                content: Text(
                                    l10n.deleteTransactionConfirm,
                                    style: TextStyle(
                                        color: context.appColors.textSecondary)),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(false),
                                    child: Text(l10n.cancel),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(true),
                                    child: Text(l10n.delete,
                                        style:
                                            TextStyle(color: AppColors.error)),
                                  ),
                                ],
                              ),
                            );
                          },
                          onDismissed: (_) {
                            context.read<TransactionsBloc>().add(
                                  DeleteTransaction(transaction.id),
                                );
                          },
                          child: TransactionTile(
                            transaction: transaction,
                            onDelete: () {
                              context.read<TransactionsBloc>().add(
                                    DeleteTransaction(transaction.id),
                                  );
                            },
                            onTap: () async {
                              final result = await context.push(
                                '/transactions/${transaction.id}/edit',
                                extra: transaction,
                              );
                              if (result == true && context.mounted) {
                                context.read<TransactionsBloc>().add(
                                      LoadTransactions(
                                          typeFilter: _selectedFilter),
                                    );
                              }
                            },
                          ),
                        ).animate().fadeIn(duration: 400.ms, delay: (min(index, 10) * 50).ms).slideX(begin: 0.05, end: 0);
                      },
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
          final result = await context.push('/transactions/add');
          if (result == true && mounted) {
            context.read<TransactionsBloc>().add(
                  LoadTransactions(typeFilter: _selectedFilter),
                );
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.2)
              : context.appColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : context.appColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? AppColors.primary : context.appColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
