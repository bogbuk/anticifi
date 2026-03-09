import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../auth/presentation/widgets/gradient_button.dart';
import '../../domain/entities/budget_entity.dart';
import '../bloc/budgets_cubit.dart';
import '../bloc/budgets_state.dart';

class BudgetFormPage extends StatefulWidget {
  final BudgetEntity? budget;

  const BudgetFormPage({super.key, this.budget});

  @override
  State<BudgetFormPage> createState() => _BudgetFormPageState();
}

class _BudgetFormPageState extends State<BudgetFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late String _selectedPeriod;
  late DateTime _startDate;
  DateTime? _endDate;
  bool _isActive = true;
  bool _isSaving = false;

  bool get _isEditing => widget.budget != null;

  static const _periods = [
    {'value': 'weekly', 'label': 'Weekly'},
    {'value': 'monthly', 'label': 'Monthly'},
    {'value': 'yearly', 'label': 'Yearly'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.budget?.name ?? '');
    _amountController = TextEditingController(
      text: widget.budget?.amount.toStringAsFixed(2) ?? '',
    );
    _selectedPeriod = widget.budget?.period ?? 'monthly';
    _startDate = widget.budget?.startDate ?? DateTime.now();
    _endDate = widget.budget?.endDate;
    _isActive = widget.budget?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
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
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              surface: context.appColors.card,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
            dialogBackgroundColor: Theme.of(context).colorScheme.surface,
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

    setState(() => _isSaving = true);

    final params = {
      'name': _nameController.text.trim(),
      'amount': double.tryParse(_amountController.text.trim()) ?? 0.0,
      'period': _selectedPeriod,
      'startDate': _startDate.toIso8601String().split('T')[0],
      'isActive': _isActive,
    };

    if (_endDate != null) {
      params['endDate'] = _endDate!.toIso8601String().split('T')[0];
    }

    try {
      if (_isEditing) {
        await context
            .read<BudgetsCubit>()
            .updateBudget(widget.budget!.id, params);
      } else {
        await context.read<BudgetsCubit>().createBudget(params);
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

    return BlocListener<BudgetsCubit, BudgetsState>(
      listener: (context, state) {
        if (state is BudgetsError) {
          setState(() => _isSaving = false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit Budget' : 'New Budget'),
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
                    labelText: 'Budget Name',
                    prefixIcon: Icon(
                      Icons.label_outline,
                      color: context.appColors.textMuted,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter budget name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Amount
                TextFormField(
                  controller: _amountController,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Budget Limit',
                    prefixIcon: Icon(
                      Icons.attach_money,
                      color: context.appColors.textMuted,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter budget limit';
                    }
                    final parsed = double.tryParse(value.trim());
                    if (parsed == null || parsed <= 0) {
                      return 'Please enter a valid positive number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Period dropdown
                DropdownButtonFormField<String>(
                  value: _selectedPeriod,
                  dropdownColor: context.appColors.card,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Period',
                    prefixIcon: Icon(
                      Icons.calendar_view_month,
                      color: context.appColors.textMuted,
                    ),
                  ),
                  items: _periods
                      .map((p) => DropdownMenuItem(
                            value: p['value'],
                            child: Text(p['label']!),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedPeriod = value);
                    }
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
                      color: context.appColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.appColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: context.appColors.textMuted,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start Date',
                              style: TextStyle(
                                fontSize: 12,
                                color: context.appColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              dateFormat.format(_startDate),
                              style: TextStyle(
                                fontSize: 15,
                                color: Theme.of(context).colorScheme.onSurface,
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
                      color: context.appColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.appColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.event,
                          color: context.appColors.textMuted,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'End Date (optional)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.appColors.textMuted,
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
                                      ? Theme.of(context).colorScheme.onSurface
                                      : context.appColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_endDate != null)
                          GestureDetector(
                            onTap: () => setState(() => _endDate = null),
                            child: Icon(
                              Icons.close,
                              color: context.appColors.textMuted,
                              size: 20,
                            ),
                          ),
                      ],
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
                      color: context.appColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.appColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Active',
                          style: TextStyle(
                            fontSize: 15,
                            color: Theme.of(context).colorScheme.onSurface,
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
                  text: _isEditing ? 'Update Budget' : 'Create Budget',
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
