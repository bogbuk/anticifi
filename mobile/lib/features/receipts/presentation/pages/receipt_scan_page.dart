import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../l10n/app_localizations.dart';
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

  File? _selectedImage;
  File? _previewImage;
  List<AccountEntity> _accounts = [];
  List<Map<String, dynamic>> _categories = [];
  String? _selectedAccountId;
  String? _selectedCategoryId;
  String _selectedType = 'expense';
  DateTime _selectedDate = DateTime.now();
  String? _accountsError;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
    _loadCategories();
  }

  Future<void> _loadAccounts() async {
    try {
      setState(() => _accountsError = null);
      final accounts = await getIt<AccountsRepository>().getAccounts();
      if (mounted) {
        setState(() {
          _accounts = accounts;
          _selectedAccountId =
              accounts.isNotEmpty ? accounts.first.id : null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _accountsError = AppLocalizations.of(context)!.failedToLoadAccounts;
        });
      }
    }
  }

  Future<void> _loadCategories() async {
    try {
      final response =
          await getIt<DioClient>().dio.get(ApiEndpoints.categories);
      final list = response.data as List<dynamic>;
      if (mounted) {
        setState(() {
          _categories = list
              .map((e) => e as Map<String, dynamic>)
              .toList();
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
      setState(() => _previewImage = File(picked.path));
    }
  }

  void _startScan() {
    if (_previewImage == null) return;
    final file = _previewImage!;
    setState(() {
      _selectedImage = file;
      _previewImage = null;
    });
    context.read<ReceiptCubit>().scanReceipt(file);
  }

  void _cancelPreview() {
    setState(() => _previewImage = null);
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
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseFillRequiredFields),
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
          categoryId: _selectedCategoryId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scanReceipt),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: BlocConsumer<ReceiptCubit, ReceiptState>(
        listener: (context, state) {
          if (state is ReceiptScanned) {
            _fillFromScan(state.scan);
          }
          if (state is ReceiptConfirmed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.transactionCreatedFromReceipt),
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
          if (state is ReceiptInitial && _previewImage != null) {
            return _buildImagePreview();
          }
          if (state is ReceiptInitial) {
            return _buildImagePicker();
          }
          if (state is ReceiptScanning) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_selectedImage != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _selectedImage!,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  const CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(
                    l10n.processingReceipt,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
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
          if (state is ReceiptError && _previewImage != null) {
            return _buildImagePreview();
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
    final l10n = AppLocalizations.of(context)!;
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
            Text(
              l10n.scanReceiptAutoFill,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.appColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            GradientButton(
              text: l10n.takePhoto,
              onPressed: () => _pickImage(ImageSource.camera),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.photo_library, color: AppColors.primary),
              label: Text(
                l10n.chooseFromGallery,
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

  Widget _buildImagePreview() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                _previewImage!,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 24),
          GradientButton(
            text: l10n.scanReceipt,
            onPressed: _startScan,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: _cancelPreview,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: context.appColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.cancel,
                style: TextStyle(color: context.appColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmForm(ReceiptScanEntity scan, {bool isLoading = false}) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_selectedImage != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                _selectedImage!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (scan.parsedData != null) ...[
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
                  Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: AppColors.success, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        l10n.confidencePercent((scan.confidence).toStringAsFixed(0)),
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
                child: _buildTypeButton('expense', l10n.expense,
                    Icons.arrow_downward, AppColors.error),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTypeButton('income', l10n.income,
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
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedAccountId = value),
              decoration: InputDecoration(
                labelText: l10n.account,
                prefixIcon:
                    Icon(Icons.account_balance, color: context.appColors.textMuted),
              ),
              dropdownColor: context.appColors.card,
            )
          else if (_accountsError != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.5),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _accountsError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: Icon(Icons.refresh, color: Theme.of(context).colorScheme.primary),
                    label: Text(
                      l10n.retry,
                      style: TextStyle(color: Theme.of(context).colorScheme.primary),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Theme.of(context).colorScheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _loadAccounts,
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.5),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.account_balance_outlined,
                    color: Theme.of(context).colorScheme.error,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.pleaseCreateAccountFirst,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
                    label: Text(
                      l10n.addAccount,
                      style: TextStyle(color: Theme.of(context).colorScheme.primary),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Theme.of(context).colorScheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      final result = await context.push('/accounts/add');
                      if (result == true) _loadAccounts();
                    },
                  ),
                ],
              ),
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
              prefixIcon:
                  Icon(Icons.attach_money, color: context.appColors.textMuted),
            ),
          ),
          const SizedBox(height: 16),
          // Merchant
          TextFormField(
            controller: _merchantController,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            decoration: InputDecoration(
              labelText: l10n.merchant,
              prefixIcon:
                  Icon(Icons.store_outlined, color: context.appColors.textMuted),
            ),
          ),
          const SizedBox(height: 16),
          // Category
          if (_categories.isNotEmpty)
            DropdownButtonFormField<String>(
              value: _selectedCategoryId,
              items: [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text(
                    l10n.noCategory,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ),
                ..._categories.map((c) {
                  return DropdownMenuItem<String>(
                    value: c['id'] as String,
                    child: Text(
                      c['name'] as String,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    ),
                  );
                }),
              ],
              onChanged: (value) => setState(() => _selectedCategoryId = value),
              decoration: InputDecoration(
                labelText: l10n.category,
                prefixIcon:
                    Icon(Icons.category_outlined, color: context.appColors.textMuted),
              ),
              dropdownColor: context.appColors.card,
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
                      colorScheme: Theme.of(context).colorScheme.copyWith(
                        primary: AppColors.primary,
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
                color: Theme.of(context).inputDecorationTheme.fillColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).inputDecorationTheme.enabledBorder?.borderSide.color ?? context.appColors.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      color: Theme.of(context).inputDecorationTheme.labelStyle?.color, size: 20),
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
                      color: Theme.of(context).inputDecorationTheme.labelStyle?.color),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          GradientButton(
            text: l10n.createTransaction,
            isLoading: isLoading,
            onPressed: _accounts.isEmpty ? null : () => _confirm(scan),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.read<ReceiptCubit>().reset(),
            child: Text(
              l10n.scanAnotherReceipt,
              style: TextStyle(color: context.appColors.textSecondary),
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
          color: isSelected ? color.withOpacity(0.2) : context.appColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : context.appColors.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? color : context.appColors.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? color : context.appColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
