import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extension.dart';
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

  static const _accountTypes = [
    {'value': 'checking', 'label': 'Checking'},
    {'value': 'savings', 'label': 'Savings'},
    {'value': 'credit', 'label': 'Credit Card'},
    {'value': 'cash', 'label': 'Cash'},
  ];

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
    return BlocListener<AccountsCubit, AccountsState>(
      listener: (context, state) {
        if (state is AccountsError) {
          setState(() => _isSaving = false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit Account' : 'New Account'),
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
                    labelText: 'Account Name',
                    prefixIcon:
                        Icon(Icons.label_outline, color: context.appColors.textMuted),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter account name';
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
                    labelText: 'Account Type',
                    prefixIcon: Icon(Icons.category_outlined,
                        color: context.appColors.textMuted),
                  ),
                  items: _accountTypes
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
                    labelText: 'Bank (optional)',
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
                    labelText: 'Currency',
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
                    labelText: 'Initial Balance',
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
                  text: _isEditing ? 'Update Account' : 'Create Account',
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
