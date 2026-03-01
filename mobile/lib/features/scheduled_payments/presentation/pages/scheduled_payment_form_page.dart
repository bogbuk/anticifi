import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/widgets/gradient_button.dart';
import '../../../accounts/presentation/bloc/accounts_cubit.dart';
import '../../../accounts/presentation/bloc/accounts_state.dart';
import '../../domain/entities/scheduled_payment_entity.dart';
import '../bloc/scheduled_payments_cubit.dart';
import '../bloc/scheduled_payments_state.dart';

class ScheduledPaymentFormPage extends StatefulWidget {
  final ScheduledPaymentEntity? payment;

  const ScheduledPaymentFormPage({super.key, this.payment});

  @override
  State<ScheduledPaymentFormPage> createState() =>
      _ScheduledPaymentFormPageState();
}

class _ScheduledPaymentFormPageState extends State<ScheduledPaymentFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  late String _selectedType;
  late String _selectedFrequency;
  String? _selectedAccountId;
  late DateTime _startDate;
  DateTime? _endDate;
  bool _isActive = true;
  bool _isSaving = false;

  bool get _isEditing => widget.payment != null;

  static const _frequencies = [
    {'value': 'daily', 'label': 'Daily'},
    {'value': 'weekly', 'label': 'Weekly'},
    {'value': 'biweekly', 'label': 'Biweekly'},
    {'value': 'monthly', 'label': 'Monthly'},
    {'value': 'quarterly', 'label': 'Quarterly'},
    {'value': 'yearly', 'label': 'Yearly'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.payment?.name ?? '');
    _amountController = TextEditingController(
      text: widget.payment?.amount.toStringAsFixed(2) ?? '',
    );
    _descriptionController =
        TextEditingController(text: widget.payment?.description ?? '');
    _selectedType = widget.payment?.type ?? 'expense';
    _selectedFrequency = widget.payment?.frequency ?? 'monthly';
    _selectedAccountId = widget.payment?.accountId;
    _startDate = widget.payment?.startDate ?? DateTime.now();
    _endDate = widget.payment?.endDate;
    _isActive = widget.payment?.isActive ?? true;

    context.read<AccountsCubit>().loadAccounts();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _startDate : (_endDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.card,
              onSurface: AppColors.textPrimary,
            ),
            dialogBackgroundColor: AppColors.surface,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an account'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final params = {
      'name': _nameController.text.trim(),
      'amount': double.tryParse(_amountController.text.trim()) ?? 0.0,
      'type': _selectedType,
      'frequency': _selectedFrequency,
      'accountId': _selectedAccountId,
      'startDate': _startDate.toIso8601String(),
      'isActive': _isActive,
    };

    if (_endDate != null) {
      params['endDate'] = _endDate!.toIso8601String();
    }

    final desc = _descriptionController.text.trim();
    if (desc.isNotEmpty) {
      params['description'] = desc;
    }

    try {
      if (_isEditing) {
        await context
            .read<ScheduledPaymentsCubit>()
            .updateScheduledPayment(widget.payment!.id, params);
      } else {
        await context
            .read<ScheduledPaymentsCubit>()
            .createScheduledPayment(params);
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
    final dateFormat = DateFormat('MMM d, yyyy');

    return BlocListener<ScheduledPaymentsCubit, ScheduledPaymentsState>(
      listener: (context, state) {
        if (state is ScheduledPaymentsError) {
          setState(() => _isSaving = false);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            _isEditing
                ? 'Edit Scheduled Payment'
                : 'New Scheduled Payment',
          ),
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
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Payment Name',
                    prefixIcon: Icon(
                      Icons.label_outline,
                      color: AppColors.textMuted,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter payment name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Amount
                TextFormField(
                  controller: _amountController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixIcon: Icon(
                      Icons.attach_money,
                      color: AppColors.textMuted,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter amount';
                    }
                    if (double.tryParse(value.trim()) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Type toggle (Income / Expense)
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedType = 'expense'),
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: _selectedType == 'expense'
                                  ? AppColors.error.withOpacity(0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Expense',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _selectedType == 'expense'
                                    ? AppColors.error
                                    : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedType = 'income'),
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: _selectedType == 'income'
                                  ? AppColors.success.withOpacity(0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Income',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _selectedType == 'income'
                                    ? AppColors.success
                                    : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Frequency dropdown
                DropdownButtonFormField<String>(
                  value: _selectedFrequency,
                  dropdownColor: AppColors.card,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Frequency',
                    prefixIcon: Icon(
                      Icons.event_repeat,
                      color: AppColors.textMuted,
                    ),
                  ),
                  items: _frequencies
                      .map((f) => DropdownMenuItem(
                            value: f['value'],
                            child: Text(f['label']!),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedFrequency = value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Account dropdown
                BlocBuilder<AccountsCubit, AccountsState>(
                  builder: (context, state) {
                    if (state is AccountsLoaded) {
                      final accounts = state.accounts;
                      // If no account selected yet and there are
                      // accounts, try to pick the one from payment
                      if (_selectedAccountId == null &&
                          accounts.isNotEmpty) {
                        _selectedAccountId = accounts.first.id;
                      }

                      // Validate that selected account still exists
                      final validId = accounts
                              .any((a) => a.id == _selectedAccountId)
                          ? _selectedAccountId
                          : (accounts.isNotEmpty
                              ? accounts.first.id
                              : null);

                      if (validId != _selectedAccountId) {
                        // Schedule a post-frame update to avoid
                        // setState during build
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() {
                              _selectedAccountId = validId;
                            });
                          }
                        });
                      }

                      return DropdownButtonFormField<String>(
                        value: validId,
                        dropdownColor: AppColors.card,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Account',
                          prefixIcon: Icon(
                            Icons.account_balance_wallet_outlined,
                            color: AppColors.textMuted,
                          ),
                        ),
                        items: accounts
                            .map((a) => DropdownMenuItem(
                                  value: a.id,
                                  child: Text(a.name),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(
                                () => _selectedAccountId = value);
                          }
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select an account';
                          }
                          return null;
                        },
                      );
                    }

                    if (state is AccountsLoading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 16),

                // Start Date
                GestureDetector(
                  onTap: () => _pickDate(isStart: true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Start Date',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              dateFormat.format(_startDate),
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // End Date (optional)
                GestureDetector(
                  onTap: () => _pickDate(isStart: false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.event,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'End Date (optional)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _endDate != null
                                    ? dateFormat.format(_endDate!)
                                    : 'No end date',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: _endDate != null
                                      ? AppColors.textPrimary
                                      : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_endDate != null)
                          GestureDetector(
                            onTap: () =>
                                setState(() => _endDate = null),
                            child: const Icon(
                              Icons.close,
                              color: AppColors.textMuted,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Description (optional)
                TextFormField(
                  controller: _descriptionController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    alignLabelWithHint: true,
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: Icon(
                        Icons.notes,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Active toggle (for editing only)
                if (_isEditing)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Active',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Switch(
                          value: _isActive,
                          activeColor: AppColors.primary,
                          onChanged: (value) =>
                              setState(() => _isActive = value),
                        ),
                      ],
                    ),
                  ),
                if (_isEditing) const SizedBox(height: 16),

                const SizedBox(height: 16),

                // Save button
                GradientButton(
                  text: _isEditing ? 'Update Payment' : 'Create Payment',
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
