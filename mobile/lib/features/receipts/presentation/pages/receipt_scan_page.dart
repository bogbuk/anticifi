import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../accounts/domain/entities/account_entity.dart';
import '../../../accounts/domain/repositories/accounts_repository.dart';
import '../../../auth/presentation/widgets/gradient_button.dart';
import '../../domain/entities/receipt_scan_entity.dart';
import '../bloc/receipt_cubit.dart';
import '../bloc/receipt_state.dart';

class ReceiptScanPage extends StatefulWidget {
  const ReceiptScanPage({super.key});

  @override
  State<ReceiptScanPage> createState() => _ReceiptScanPageState();
}

class _ReceiptScanPageState extends State<ReceiptScanPage> {
  final _picker = ImagePicker();
  final _amountController = TextEditingController();
  final _merchantController = TextEditingController();

  List<AccountEntity> _accounts = [];
  String? _selectedAccountId;
  String _selectedType = 'expense';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    try {
      final accounts = await getIt<AccountsRepository>().getAccounts();
      if (mounted) {
        setState(() {
          _accounts = accounts;
          _selectedAccountId =
              accounts.isNotEmpty ? accounts.first.id : null;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1600,
      imageQuality: 70,
    );
    if (picked != null && mounted) {
      context.read<ReceiptCubit>().scanReceipt(File(picked.path));
    }
  }

  void _fillFromScan(ReceiptScanEntity scan) {
    if (scan.parsedData != null) {
      if (scan.parsedData!.amount != null) {
        _amountController.text = scan.parsedData!.amount!.toStringAsFixed(2);
      }
      if (scan.parsedData!.merchant != null) {
        _merchantController.text = scan.parsedData!.merchant!;
      }
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _confirm(ReceiptScanEntity scan) async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0 || _selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<ReceiptCubit>().confirmReceipt(
          scan.id,
          accountId: _selectedAccountId!,
          amount: amount,
          merchant: _merchantController.text.trim().isNotEmpty
              ? _merchantController.text.trim()
              : null,
          date: _selectedDate.toIso8601String().split('T').first,
          type: _selectedType,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Scan Receipt'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: BlocConsumer<ReceiptCubit, ReceiptState>(
        listener: (context, state) {
          if (state is ReceiptScanned) {
            _fillFromScan(state.scan);
          }
          if (state is ReceiptConfirmed) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Transaction created from receipt'),
                backgroundColor: AppColors.success,
              ),
            );
            context.pop(true);
          }
          if (state is ReceiptError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ReceiptInitial) {
            return _buildImagePicker();
          }
          if (state is ReceiptScanning) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text(
                    'Processing receipt...',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }
          if (state is ReceiptScanned) {
            return _buildConfirmForm(state.scan);
          }
          if (state is ReceiptConfirming) {
            return _buildConfirmForm(state.scan, isLoading: true);
          }
          if (state is ReceiptError) {
            return _buildImagePicker();
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long,
              size: 80,
              color: AppColors.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'Scan a receipt to auto-fill\ntransaction details',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            GradientButton(
              text: 'Take Photo',
              onPressed: () => _pickImage(ImageSource.camera),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.photo_library, color: AppColors.primary),
              label: const Text(
                'Choose from Gallery',
                style: TextStyle(color: AppColors.primary),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _pickImage(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmForm(ReceiptScanEntity scan, {bool isLoading = false}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (scan.parsedData != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: AppColors.success, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Confidence: ${(scan.confidence).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Type toggle
          Row(
            children: [
              Expanded(
                child: _buildTypeButton('expense', 'Expense',
                    Icons.arrow_downward, AppColors.error),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTypeButton('income', 'Income',
                    Icons.arrow_upward, AppColors.success),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Account
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
              onChanged: (value) => setState(() => _selectedAccountId = value),
              decoration: const InputDecoration(
                labelText: 'Account',
                prefixIcon:
                    Icon(Icons.account_balance, color: AppColors.textMuted),
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
              prefixIcon:
                  Icon(Icons.attach_money, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 16),
          // Merchant
          TextFormField(
            controller: _merchantController,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Merchant',
              prefixIcon:
                  Icon(Icons.store_outlined, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 16),
          // Date
          GestureDetector(
            onTap: () async {
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
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          GradientButton(
            text: 'Create Transaction',
            isLoading: isLoading,
            onPressed: () => _confirm(scan),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.read<ReceiptCubit>().reset(),
            child: const Text(
              'Scan Another Receipt',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton(
      String type, String label, IconData icon, Color color) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? color : AppColors.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? color : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
