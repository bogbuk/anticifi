import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../auth/presentation/widgets/gradient_button.dart';
import '../../domain/entities/debt_entity.dart';
import '../bloc/debts_cubit.dart';
import '../bloc/debts_state.dart';

class DebtFormPage extends StatefulWidget {
  final DebtEntity? debt;

  const DebtFormPage({super.key, this.debt});

  @override
  State<DebtFormPage> createState() => _DebtFormPageState();
}

class _DebtFormPageState extends State<DebtFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _originalAmountController;
  late final TextEditingController _currentBalanceController;
  late final TextEditingController _interestRateController;
  late final TextEditingController _minimumPaymentController;
  late final TextEditingController _creditorController;
  late final TextEditingController _notesController;
  late final TextEditingController _dueDayController;
  late String _selectedType;
  late DateTime _startDate;
  DateTime? _expectedPayoffDate;
  bool _isSaving = false;

  bool get _isEditing => widget.debt != null;

  static const _debtTypes = [
    {'value': 'credit_card', 'label': 'Credit Card'},
    {'value': 'personal_loan', 'label': 'Personal Loan'},
    {'value': 'mortgage', 'label': 'Mortgage'},
    {'value': 'auto_loan', 'label': 'Auto Loan'},
    {'value': 'student_loan', 'label': 'Student Loan'},
    {'value': 'personal', 'label': 'Personal'},
    {'value': 'other', 'label': 'Other'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.debt?.name ?? '');
    _originalAmountController = TextEditingController(
      text: widget.debt?.originalAmount.toStringAsFixed(2) ?? '',
    );
    _currentBalanceController = TextEditingController(
      text: widget.debt?.currentBalance.toStringAsFixed(2) ?? '',
    );
    _interestRateController = TextEditingController(
      text: widget.debt?.interestRate.toStringAsFixed(2) ?? '',
    );
    _minimumPaymentController = TextEditingController(
      text: widget.debt?.minimumPayment.toStringAsFixed(2) ?? '',
    );
    _creditorController = TextEditingController(text: widget.debt?.creditorName ?? '');
    _notesController = TextEditingController(text: widget.debt?.notes ?? '');
    _dueDayController = TextEditingController(
      text: widget.debt?.dueDay?.toString() ?? '',
    );
    _selectedType = widget.debt?.type ?? 'credit_card';
    _startDate = widget.debt?.startDate ?? DateTime.now();
    _expectedPayoffDate = widget.debt?.expectedPayoffDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _originalAmountController.dispose();
    _currentBalanceController.dispose();
    _interestRateController.dispose();
    _minimumPaymentController.dispose();
    _creditorController.dispose();
    _notesController.dispose();
    _dueDayController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _startDate : (_expectedPayoffDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
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
          _expectedPayoffDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final params = <String, dynamic>{
      'name': _nameController.text.trim(),
      'type': _selectedType,
      'originalAmount': double.tryParse(_originalAmountController.text.trim()) ?? 0.0,
      'currentBalance': double.tryParse(_currentBalanceController.text.trim()) ?? 0.0,
      'interestRate': double.tryParse(_interestRateController.text.trim()) ?? 0.0,
      'minimumPayment': double.tryParse(_minimumPaymentController.text.trim()) ?? 0.0,
      'startDate': _startDate.toIso8601String().split('T')[0],
    };

    final dueDay = int.tryParse(_dueDayController.text.trim());
    if (dueDay != null) params['dueDay'] = dueDay;

    if (_expectedPayoffDate != null) {
      params['expectedPayoffDate'] = _expectedPayoffDate!.toIso8601String().split('T')[0];
    }

    final creditor = _creditorController.text.trim();
    if (creditor.isNotEmpty) params['creditorName'] = creditor;

    final notes = _notesController.text.trim();
    if (notes.isNotEmpty) params['notes'] = notes;

    try {
      if (_isEditing) {
        await context.read<DebtsCubit>().updateDebt(widget.debt!.id, params);
      } else {
        await context.read<DebtsCubit>().createDebt(params);
      }
      if (mounted) context.pop(true);
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return BlocListener<DebtsCubit, DebtsState>(
      listener: (context, state) {
        if (state is DebtsError) setState(() => _isSaving = false);
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_isEditing ? 'Edit Debt' : 'New Debt')),
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
                    labelText: 'Debt Name',
                    prefixIcon: Icon(Icons.label_outline, color: context.appColors.textMuted),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Please enter debt name';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Type
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  dropdownColor: context.appColors.card,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Debt Type',
                    prefixIcon: Icon(Icons.category_outlined, color: context.appColors.textMuted),
                  ),
                  items: _debtTypes
                      .map((t) => DropdownMenuItem(value: t['value'], child: Text(t['label']!)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedType = value);
                  },
                ),
                const SizedBox(height: 16),
                // Original Amount
                TextFormField(
                  controller: _originalAmountController,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Original Amount',
                    prefixIcon: Icon(Icons.attach_money, color: context.appColors.textMuted),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Please enter original amount';
                    final parsed = double.tryParse(value.trim());
                    if (parsed == null || parsed <= 0) return 'Please enter a valid positive number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Current Balance
                TextFormField(
                  controller: _currentBalanceController,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Current Balance',
                    prefixIcon: Icon(Icons.account_balance, color: context.appColors.textMuted),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Please enter current balance';
                    final parsed = double.tryParse(value.trim());
                    if (parsed == null || parsed < 0) return 'Please enter a valid number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Interest Rate
                TextFormField(
                  controller: _interestRateController,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Interest Rate (%)',
                    prefixIcon: Icon(Icons.percent, color: context.appColors.textMuted),
                  ),
                ),
                const SizedBox(height: 16),
                // Minimum Payment
                TextFormField(
                  controller: _minimumPaymentController,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Minimum Payment',
                    prefixIcon: Icon(Icons.payment, color: context.appColors.textMuted),
                  ),
                ),
                const SizedBox(height: 16),
                // Due Day
                TextFormField(
                  controller: _dueDayController,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Due Day (1-31)',
                    prefixIcon: Icon(Icons.calendar_today, color: context.appColors.textMuted),
                  ),
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      final parsed = int.tryParse(value.trim());
                      if (parsed == null || parsed < 1 || parsed > 31) {
                        return 'Please enter a day between 1 and 31';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Creditor
                TextFormField(
                  controller: _creditorController,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Creditor Name (optional)',
                    prefixIcon: Icon(Icons.business, color: context.appColors.textMuted),
                  ),
                ),
                const SizedBox(height: 16),
                // Start Date
                GestureDetector(
                  onTap: () => _pickDate(isStart: true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: context.appColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.appColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: context.appColors.textMuted, size: 20),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Start Date', style: TextStyle(fontSize: 12, color: context.appColors.textMuted)),
                            const SizedBox(height: 2),
                            Text(dateFormat.format(_startDate),
                                style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurface)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Expected Payoff Date (optional)
                GestureDetector(
                  onTap: () => _pickDate(isStart: false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: context.appColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.appColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.event, color: context.appColors.textMuted, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Expected Payoff Date (optional)',
                                  style: TextStyle(fontSize: 12, color: context.appColors.textMuted)),
                              const SizedBox(height: 2),
                              Text(
                                _expectedPayoffDate != null
                                    ? dateFormat.format(_expectedPayoffDate!)
                                    : 'No date set',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: _expectedPayoffDate != null ? Theme.of(context).colorScheme.onSurface : context.appColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_expectedPayoffDate != null)
                          GestureDetector(
                            onTap: () => setState(() => _expectedPayoffDate = null),
                            child: Icon(Icons.close, color: context.appColors.textMuted, size: 20),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Notes
                TextFormField(
                  controller: _notesController,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Notes (optional)',
                    prefixIcon: Icon(Icons.notes, color: context.appColors.textMuted),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),
                // Save button
                GradientButton(
                  text: _isEditing ? 'Update Debt' : 'Add Debt',
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
