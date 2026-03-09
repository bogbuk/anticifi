import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/widgets/gradient_button.dart';
import '../../domain/entities/account_entity.dart';
import '../bloc/accounts_cubit.dart';
import '../bloc/accounts_state.dart';

class AccountFormPage extends StatefulWidget {
  final AccountEntity? account;

  const AccountFormPage({super.key, this.account});

  @override
  State<AccountFormPage> createState() => _AccountFormPageState();
}

class _AccountFormPageState extends State<AccountFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _bankController;
  late final TextEditingController _initialBalanceController;
  late String _selectedType;
  late String _selectedCurrency;
  bool _isSaving = false;

  bool get _isEditing => widget.account != null;

  static const _currencies = [
    {'value': 'USD', 'label': 'USD (\$)'},
    {'value': 'EUR', 'label': 'EUR (\u20AC)'},
    {'value': 'GBP', 'label': 'GBP (\u00A3)'},
    {'value': 'RUB', 'label': 'RUB (\u20BD)'},
    {'value': 'MDL', 'label': 'MDL (L)'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account?.name ?? '');
    _bankController = TextEditingController(text: widget.account?.bank ?? '');
    _initialBalanceController = TextEditingController(
      text: widget.account?.initialBalance.toStringAsFixed(2) ?? '',
    );
    _selectedType = widget.account?.type ?? 'checking';
    _selectedCurrency = widget.account?.currency ?? 'USD';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bankController.dispose();
    _initialBalanceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final params = {
      'name': _nameController.text.trim(),
      'type': _selectedType,
      'bank': _bankController.text.trim().isEmpty
          ? null
          : _bankController.text.trim(),
      'currency': _selectedCurrency,
      'initialBalance':
          double.tryParse(_initialBalanceController.text.trim()) ?? 0.0,
    };

    try {
      if (_isEditing) {
        await context
            .read<AccountsCubit>()
            .updateAccount(widget.account!.id, params);
      } else {
        await context.read<AccountsCubit>().createAccount(params);
      }

      if (mounted) {
        context.pop(true);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accountTypes = [
      {'value': 'checking', 'label': l10n.checking},
      {'value': 'savings', 'label': l10n.savings},
      {'value': 'credit', 'label': l10n.creditCard},
      {'value': 'cash', 'label': l10n.cash},
    ];
    return BlocListener<AccountsCubit, AccountsState>(
      listener: (context, state) {
        if (state is AccountsError) {
          setState(() => _isSaving = false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? l10n.editAccount : l10n.newAccount),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Name
                TextFormField(
                  controller: _nameController,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: l10n.accountName,
                    prefixIcon:
                        Icon(Icons.label_outline, color: context.appColors.textMuted),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.pleaseEnterAccountName;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Type dropdown
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  dropdownColor: context.appColors.card,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: l10n.accountType,
                    prefixIcon: Icon(Icons.category_outlined,
                        color: context.appColors.textMuted),
                  ),
                  items: accountTypes
                      .map((t) => DropdownMenuItem(
                            value: t['value'],
                            child: Text(t['label']!),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Bank (optional)
                TextFormField(
                  controller: _bankController,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: l10n.bankOptional,
                    prefixIcon: Icon(Icons.account_balance_outlined,
                        color: context.appColors.textMuted),
                  ),
                ),
                const SizedBox(height: 16),

                // Currency dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCurrency,
                  dropdownColor: context.appColors.card,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: l10n.currency,
                    prefixIcon: Icon(Icons.attach_money_outlined,
                        color: context.appColors.textMuted),
                  ),
                  items: _currencies
                      .map((c) => DropdownMenuItem(
                            value: c['value'],
                            child: Text(c['label']!),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCurrency = value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Initial balance
                TextFormField(
                  controller: _initialBalanceController,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: l10n.initialBalance,
                    prefixIcon:
                        Icon(Icons.money_outlined, color: context.appColors.textMuted),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Save button
                GradientButton(
                  text: _isEditing ? l10n.updateAccount : l10n.createAccount,
                  isLoading: _isSaving,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
