import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/scheduled_payment_entity.dart';
import '../bloc/scheduled_payments_cubit.dart';
import '../bloc/scheduled_payments_state.dart';
import '../widgets/scheduled_payment_card.dart';

class ScheduledPaymentsPage extends StatefulWidget {
  const ScheduledPaymentsPage({super.key});

  @override
  State<ScheduledPaymentsPage> createState() => _ScheduledPaymentsPageState();
}

class _ScheduledPaymentsPageState extends State<ScheduledPaymentsPage> {
  bool _showActive = true;

  @override
  void initState() {
    super.initState();
    context.read<ScheduledPaymentsCubit>().loadScheduledPayments();
  }

  List<ScheduledPaymentEntity> _filterPayments(
      List<ScheduledPaymentEntity> payments) {
    return payments.where((p) => p.isActive == _showActive).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Scheduled Payments'),
      ),
      body: Column(
        children: [
          // Toggle Active / Inactive
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _showActive = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _showActive
                              ? AppColors.primary.withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Active',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _showActive
                                ? AppColors.primaryLight
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _showActive = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_showActive
                              ? AppColors.primary.withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Inactive',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: !_showActive
                                ? AppColors.primaryLight
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // List
          Expanded(
            child: BlocConsumer<ScheduledPaymentsCubit,
                ScheduledPaymentsState>(
              listener: (context, state) {
                if (state is ScheduledPaymentsError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is ScheduledPaymentsLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }

                if (state is ScheduledPaymentsLoaded) {
                  final filtered = _filterPayments(state.payments);

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.event_repeat_outlined,
                            size: 64,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _showActive
                                ? 'No active scheduled payments'
                                : 'No inactive scheduled payments',
                            style: const TextStyle(
                              fontSize: 18,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (_showActive) ...[
                            const SizedBox(height: 8),
                            const Text(
                              'Tap + to add your first scheduled payment',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    backgroundColor: AppColors.card,
                    onRefresh: () => context
                        .read<ScheduledPaymentsCubit>()
                        .loadScheduledPayments(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final payment = filtered[index];
                        return ScheduledPaymentCard(
                          payment: payment,
                          onTap: () async {
                            final result = await context.push(
                              '/scheduled-payments/${payment.id}/edit',
                              extra: payment,
                            );
                            if (result == true && context.mounted) {
                              context
                                  .read<ScheduledPaymentsCubit>()
                                  .loadScheduledPayments();
                            }
                          },
                          onDelete: () {
                            context
                                .read<ScheduledPaymentsCubit>()
                                .deleteScheduledPayment(payment.id);
                          },
                          onExecute: () {
                            context
                                .read<ScheduledPaymentsCubit>()
                                .executeScheduledPayment(payment.id);
                          },
                        );
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
          final result = await context.push('/scheduled-payments/add');
          if (result == true && mounted) {
            context
                .read<ScheduledPaymentsCubit>()
                .loadScheduledPayments();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
