import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:plaid_flutter/plaid_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/widgets/gradient_button.dart';
import '../bloc/accounts_cubit.dart';
import '../bloc/accounts_state.dart';

class LinkBankPage extends StatefulWidget {
  const LinkBankPage({super.key});

  @override
  State<LinkBankPage> createState() => _LinkBankPageState();
}

class _LinkBankPageState extends State<LinkBankPage> {
  bool _isLoading = false;
  StreamSubscription<LinkSuccess>? _successSubscription;
  StreamSubscription<LinkExit>? _exitSubscription;

  @override
  void initState() {
    super.initState();
    _successSubscription = PlaidLink.onSuccess.listen(_onPlaidSuccess);
    _exitSubscription = PlaidLink.onExit.listen(_onPlaidExit);
  }

  @override
  void dispose() {
    _successSubscription?.cancel();
    _exitSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startPlaidLink() async {
    setState(() => _isLoading = true);

    try {
      final cubit = context.read<AccountsCubit>();
      final linkToken = await cubit.getLinkToken();

      final config = LinkTokenConfiguration(token: linkToken);
      await PlaidLink.open(configuration: config);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start bank connection: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _onPlaidSuccess(LinkSuccess success) {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final publicToken = success.publicToken;
    final institution = success.metadata.institution;

    context.read<AccountsCubit>().exchangePlaidToken(
          publicToken: publicToken,
          institutionId: institution?.id,
          institutionName: institution?.name,
        );
  }

  void _onPlaidExit(LinkExit exit) {
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (exit.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Connection cancelled: ${exit.error?.displayMessage ?? "Unknown error"}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Connect Bank'),
      ),
      body: BlocListener<AccountsCubit, AccountsState>(
        listener: (context, state) {
          if (state is PlaidLinkSuccess) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Successfully linked ${state.linkedAccounts.length} account(s)',
                ),
                backgroundColor: AppColors.success,
              ),
            );
            context.pop(true);
          } else if (state is PlaidLinkError) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.account_balance,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Connect your bank account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Securely link your bank to automatically import transactions and keep your balances up to date.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.lock_outline,
                      size: 16, color: AppColors.textMuted),
                  SizedBox(width: 6),
                  Text(
                    'Bank-level encryption powered by Plaid',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              GradientButton(
                text: 'Connect Bank',
                isLoading: _isLoading,
                onPressed: _startPlaidLink,
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
