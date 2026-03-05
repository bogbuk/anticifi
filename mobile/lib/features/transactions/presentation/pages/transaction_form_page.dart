import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../auth/presentation/widgets/gradient_button.dart';
import '../../../accounts/domain/repositories/accounts_repository.dart';
import '../../../accounts/domain/entities/account_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../bloc/transactions_bloc.dart';
import '../bloc/transactions_event.dart';
import '../bloc/transactions_state.dart';

class TransactionFormPage extends StatefulWidget {
  final TransactionEntity? transaction;

  const TransactionFormPage({super.key, this.transaction});

  @override
  State<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  late String _selectedType;
  late DateTime _selectedDate;
  bool _isSaving = false;
  List<AccountEntity> _accounts = [];
  String? _selectedAccountId;
  List<Map<String, dynamic>> _categorySuggestions = [];
  String? _selectedCategoryId;

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.transaction?.amount.toStringAsFixed(2) ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.transaction?.description ?? '',
    );
    _selectedType = widget.transaction?.type ?? 'expense';
    _selectedDate = widget.transaction?.date ?? DateTime.now();
    _selectedAccountId = widget.transaction?.accountId;
    _selectedCategoryId = widget.transaction?.categoryId;
    _loadAccounts();
    _descriptionController.addListener(_onDescriptionChanged);
  }

  void _onDescriptionChanged() {
    final text = _descriptionController.text.trim();
    if (text.length >= 3 && !_isEditing) {
      context.read<TransactionsBloc>().add(SuggestCategory(
            description: text,
            type: _selectedType,
          ));
    }
  }

  Future<void> _loadAccounts() async {
    try {
      final accounts = await getIt<AccountsRepository>().getAccounts();
      if (mounted) {
        setState(() {
          _accounts = accounts;
          _selectedAccountId ??= accounts.isNotEmpty ? accounts.first.id : null;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _descriptionController.removeListener(_onDescriptionChanged);
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.card,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please create an account first'),
          backgroundColor: AppColors.error,
        ),
      );
      setState(() => _isSaving = false);
      return;
    }

    final params = {
      'accountId': _selectedAccountId,
      'amount': double.parse(_amountController.text.trim()),
      'type': _selectedType,
      'description': _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      'date': _selectedDate.toIso8601String().split('T').first,
      if (_selectedCategoryId != null) 'categoryId': _selectedCategoryId,
    };

    try {
      if (_isEditing) {
        context
            .read<TransactionsBloc>()
            .add(UpdateTransaction(widget.transaction!.id, params));
      } else {
        context.read<TransactionsBloc>().add(CreateTransaction(params));
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
    return BlocListener<TransactionsBloc, TransactionsState>(
      listener: (context, state) {
        if (state is TransactionsError) {
          setState(() => _isSaving = false);
        }
        if (state is CategorySuggestionsLoaded) {
          setState(() => _categorySuggestions = state.suggestions);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit Transaction' : 'New Transaction'),
          actions: [
            if (_isEditing)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppColors.card,
                      title: const Text('Delete Transaction',
                          style: TextStyle(color: AppColors.textPrimary)),
                      content: const Text(
                          'Are you sure you want to delete this transaction?',
                          style: TextStyle(color: AppColors.textSecondary)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('Delete',
                              style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && mounted) {
                    context.read<TransactionsBloc>().add(
                          DeleteTransaction(widget.transaction!.id),
                        );
                    context.pop(true);
                  }
                },
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Type toggle
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedType = 'expense'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _selectedType == 'expense'
                                ? AppColors.error.withOpacity(0.2)
                                : AppColors.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedType == 'expense'
                                  ? AppColors.error
                                  : AppColors.border,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_downward,
                                size: 18,
                                color: _selectedType == 'expense'
                                    ? AppColors.error
                                    : AppColors.textMuted,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Expense',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _selectedType == 'expense'
                                      ? AppColors.error
                                      : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedType = 'income'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _selectedType == 'income'
                                ? AppColors.success.withOpacity(0.2)
                                : AppColors.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedType == 'income'
                                  ? AppColors.success
                                  : AppColors.border,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_upward,
                                size: 18,
                                color: _selectedType == 'income'
                                    ? AppColors.success
                                    : AppColors.textMuted,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Income',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _selectedType == 'income'
                                      ? AppColors.success
                                      : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Account selector
                if (_accounts.isNotEmpty)
                  DropdownButtonFormField<String>(
                    value: _selectedAccountId,
                    items: _accounts.map((a) {
                      return DropdownMenuItem(
                        value: a.id,
                        child: Text(
                          '${a.name} (${a.currency})',
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedAccountId = value);
                    },
                    decoration: const InputDecoration(
                      labelText: 'Account',
                      prefixIcon: Icon(Icons.account_balance, color: AppColors.textMuted),
                    ),
                    dropdownColor: AppColors.card,
                  ),
                const SizedBox(height: 16),

                // Amount
                TextFormField(
                  controller: _amountController,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixIcon: Icon(Icons.attach_money, color: AppColors.textMuted),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value.trim()) == null) {
                      return 'Please enter a valid number';
                    }
                    if (double.parse(value.trim()) <= 0) {
                      return 'Amount must be greater than 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon:
                        Icon(Icons.notes_outlined, color: AppColors.textMuted),
                  ),
                ),
                // Category suggestions
                if (_categorySuggestions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _categorySuggestions.map((s) {
                      final catId = s['categoryId'] as String;
                      final catName = s['categoryName'] as String;
                      final confidence = (s['confidence'] as num).toDouble();
                      final isSelected = _selectedCategoryId == catId;
                      return ActionChip(
                        label: Text(
                          '$catName (${(confidence * 100).toInt()}%)',
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: isSelected
                            ? AppColors.primary
                            : AppColors.card,
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                        onPressed: () {
                          setState(() {
                            if (isSelected) {
                              _selectedCategoryId = null;
                            } else {
                              _selectedCategoryId = catId;
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 16),

                // Date picker
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            color: AppColors.textMuted, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          _formatDate(_selectedDate),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.chevron_right,
                            color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Save button
                GradientButton(
                  text: _isEditing ? 'Update Transaction' : 'Add Transaction',
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
