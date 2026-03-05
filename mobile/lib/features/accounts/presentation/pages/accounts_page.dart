import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/accounts_cubit.dart';
import '../bloc/accounts_state.dart';
import '../widgets/account_card.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  @override
  void initState() {
    super.initState();
    context.read<AccountsCubit>().loadAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Accounts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance),
            tooltip: 'Connect Bank',
            onPressed: () async {
              final result = await context.push('/accounts/link-bank');
              if (result == true && mounted) {
                context.read<AccountsCubit>().loadAccounts();
              }
            },
          ),
        ],
      ),
      body: BlocConsumer<AccountsCubit, AccountsState>(
        listener: (context, state) {
          if (state is AccountsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AccountsLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (state is AccountsLoaded) {
            if (state.accounts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 64,
                      color: AppColors.textMuted,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No accounts yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap + to add your first account',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.card,
              onRefresh: () => context.read<AccountsCubit>().loadAccounts(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.accounts.length,
                itemBuilder: (context, index) {
                  final account = state.accounts[index];
                  return AccountCard(
                    account: account,
                    onTap: () async {
                      final result = await context.push(
                        '/accounts/${account.id}/edit',
                        extra: account,
                      );
                      if (result == true && context.mounted) {
                        context.read<AccountsCubit>().loadAccounts();
                      }
                    },
                    onDelete: () {
                      context.read<AccountsCubit>().deleteAccount(account.id);
                    },
                  ).animate().fadeIn(duration: 400.ms, delay: (min(index, 10) * 50).ms).slideY(begin: 0.05, end: 0);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          final result = await context.push('/accounts/add');
          if (result == true && mounted) {
            context.read<AccountsCubit>().loadAccounts();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
