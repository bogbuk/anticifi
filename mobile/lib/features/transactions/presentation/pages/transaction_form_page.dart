import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/speech_service.dart';
import '../../../../core/utils/voice_input_parser.dart';
import '../../../auth/presentation/widgets/gradient_button.dart';
import '../../../accounts/domain/repositories/accounts_repository.dart';
import '../../../accounts/domain/entities/account_entity.dart';
import '../../../subscription/presentation/bloc/subscription_cubit.dart';
import '../../../subscription/presentation/bloc/subscription_state.dart';
import '../../../../l10n/app_localizations.dart';
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
  bool _isListening = false;
  String _partialText = '';
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

  Future<void> _startVoiceInput() async {
    final speechService = getIt<SpeechService>();
    final l10n = AppLocalizations.of(context)!;

    // Check premium status
    final subCubit = getIt<SubscriptionCubit>();
    await subCubit.loadSubscription();
    final state = subCubit.state;
    final isPremium =
        state is SubscriptionLoaded && state.subscription.isPremium;

    final canUse = await speechService.canUseVoiceInput(isPremium);
    if (!canUse) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.voiceLimitReached),
            backgroundColor: AppColors.warning,
            action: SnackBarAction(
              label: l10n.upgrade,
              textColor: Colors.white,
              onPressed: () => context.push('/subscription'),
            ),
          ),
        );
      }
      return;
    }

    final available = await speechService.initialize();
    if (!available) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.speechNotAvailable),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    setState(() {
      _isListening = true;
      _partialText = '';
    });

    await speechService.startListening(
      onResult: (text, isFinal) {
        if (!mounted) return;
        if (isFinal) {
          _processVoiceResult(text);
        } else {
          setState(() => _partialText = text);
        }
      },
    );
  }

  Future<void> _stopVoiceInput() async {
    await getIt<SpeechService>().stopListening();
    if (mounted) {
      setState(() {
        _isListening = false;
        _partialText = '';
      });
    }
  }

  Future<void> _processVoiceResult(String text) async {
    final result = VoiceInputParser.parse(text);

    setState(() {
      _isListening = false;
      _partialText = '';
    });

    if (result.amount != null) {
      _amountController.text = result.amount!.toStringAsFixed(
        result.amount! == result.amount!.roundToDouble() ? 0 : 2,
      );
    }
    if (result.description != null && result.description!.isNotEmpty) {
      _descriptionController.text = result.description!;
    }

    await getIt<SpeechService>().incrementUsageCount();
  }

  @override
  void dispose() {
    getIt<SpeechService>().stopListening();
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
      builder: (context, child) => child!,
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
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseCreateAccountFirst),
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
    final l10n = AppLocalizations.of(context)!;
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
        appBar: AppBar(
          title: Text(_isEditing ? l10n.editTransaction : l10n.newTransaction),
          actions: [
            if (_isEditing)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: context.appColors.card,
                      title: Text(l10n.deleteTransaction,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                      content: Text(
                          l10n.deleteTransactionConfirm,
                          style: TextStyle(color: context.appColors.textSecondary)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: Text(l10n.cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: Text(l10n.delete,
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
                                : context.appColors.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedType == 'expense'
                                  ? AppColors.error
                                  : context.appColors.border,
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
                                    : context.appColors.textMuted,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.expense,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _selectedType == 'expense'
                                      ? AppColors.error
                                      : context.appColors.textMuted,
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
                                : context.appColors.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedType == 'income'
                                  ? AppColors.success
                                  : context.appColors.border,
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
                                    : context.appColors.textMuted,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.income,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _selectedType == 'income'
                                      ? AppColors.success
                                      : context.appColors.textMuted,
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
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedAccountId = value);
                    },
                    decoration: InputDecoration(
                      labelText: l10n.account,
                      prefixIcon: Icon(Icons.account_balance, color: context.appColors.textMuted),
                    ),
                    dropdownColor: context.appColors.card,
                  ),
                const SizedBox(height: 16),

                // Amount
                TextFormField(
                  controller: _amountController,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: l10n.amount,
                    prefixIcon: Icon(Icons.attach_money, color: context.appColors.textMuted),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.pleaseEnterAmount;
                    }
                    if (double.tryParse(value.trim()) == null) {
                      return l10n.pleaseEnterValidNumber;
                    }
                    if (double.parse(value.trim()) <= 0) {
                      return l10n.amountMustBeGreaterThanZero;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description + mic button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _descriptionController,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: l10n.description,
                          prefixIcon:
                              Icon(Icons.notes_outlined, color: context.appColors.textMuted),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _isListening ? _stopVoiceInput : _startVoiceInput,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 48,
                        height: 48,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: _isListening
                              ? AppColors.error.withOpacity(0.2)
                              : AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isListening
                                ? AppColors.error
                                : AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Icon(
                          _isListening ? Icons.stop : Icons.mic,
                          color: _isListening ? AppColors.error : AppColors.primary,
                          size: 24,
                        ),
                      ).animate(target: _isListening ? 1 : 0).shimmer(
                        duration: 1200.ms,
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
                if (_isListening && _partialText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _partialText,
                      style: TextStyle(
                        color: context.appColors.textMuted,
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                      ),
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
                                : context.appColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: isSelected
                            ? AppColors.primary
                            : context.appColors.card,
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : context.appColors.border,
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
                      color: context.appColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.appColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            color: context.appColors.textMuted, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          _formatDate(_selectedDate),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 15,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.chevron_right,
                            color: context.appColors.textMuted),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Save button
                GradientButton(
                  text: _isEditing ? l10n.updateTransaction : l10n.addTransaction,
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
