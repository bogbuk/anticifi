import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/widgets/gradient_button.dart';
import '../../domain/entities/debt_entity.dart';
import '../bloc/debts_cubit.dart';
import '../bloc/debts_state.dart';

class DebtPaymentFormPage extends StatefulWidget {
  final DebtEntity debt;

  const DebtPaymentFormPage({super.key, required this.debt});

  @override
  State<DebtPaymentFormPage> createState() => _DebtPaymentFormPageState();
}

class _DebtPaymentFormPageState extends State<DebtPaymentFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;
  late DateTime _paymentDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.debt.minimumPayment > 0
          ? widget.debt.minimumPayment.toStringAsFixed(2)
          : '',
    );
    _notesController = TextEditingController();
    _paymentDate = DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
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
      setState(() => _paymentDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final params = <String, dynamic>{
      'amount': double.tryParse(_amountController.text.trim()) ?? 0.0,
      'paymentDate': _paymentDate.toIso8601String().split('T')[0],
    };

    final notes = _notesController.text.trim();
    if (notes.isNotEmpty) params['notes'] = notes;

    try {
      await context.read<DebtsCubit>().recordPayment(widget.debt.id, params);
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
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('MMM d, yyyy');

    return BlocListener<DebtsCubit, DebtsState>(
      listener: (context, state) {
        if (state is DebtsError) setState(() => _isSaving = false);
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.recordPayment)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Debt info summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.appColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.appColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.debt.name,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('Balance: \$${widget.debt.currentBalance.toStringAsFixed(2)}',
                          style: TextStyle(color: context.appColors.textSecondary, fontSize: 14)),
                      if (widget.debt.minimumPayment > 0)
                        Text('Min Payment: \$${widget.debt.minimumPayment.toStringAsFixed(2)}',
                            style: TextStyle(color: context.appColors.textMuted, fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Amount
                TextFormField(
                  controller: _amountController,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: l10n.paymentAmount,
                    prefixIcon: Icon(Icons.attach_money, color: context.appColors.textMuted),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return l10n.pleaseEnterPaymentAmount;
                    final parsed = double.tryParse(value.trim());
                    if (parsed == null || parsed <= 0) return l10n.pleaseEnterValidPositiveNumber;
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Payment Date
                GestureDetector(
                  onTap: _pickDate,
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
                            Text(l10n.paymentDate, style: TextStyle(fontSize: 12, color: context.appColors.textMuted)),
                            const SizedBox(height: 2),
                            Text(dateFormat.format(_paymentDate),
                                style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurface)),
                          ],
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
                    labelText: l10n.notesOptional,
                    prefixIcon: Icon(Icons.notes, color: context.appColors.textMuted),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),
                // Save button
                GradientButton(
                  text: l10n.recordPayment,
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
