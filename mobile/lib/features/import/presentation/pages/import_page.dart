import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../accounts/domain/entities/account_entity.dart';
import '../../../accounts/presentation/bloc/accounts_cubit.dart';
import '../../../accounts/presentation/bloc/accounts_state.dart';
import '../../../auth/presentation/widgets/gradient_button.dart';
import '../bloc/import_cubit.dart';
import '../bloc/import_state.dart';

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  String? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    context.read<AccountsCubit>().loadAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Import CSV'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: const [
                  Icon(
                    Icons.upload_file,
                    size: 48,
                    color: AppColors.primary,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Import Transactions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Upload a CSV file to import transactions into your account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Account selector
            BlocBuilder<AccountsCubit, AccountsState>(
              builder: (context, state) {
                List<AccountEntity> accounts = [];
                if (state is AccountsLoaded) {
                  accounts = state.accounts;
                }

                return DropdownButtonFormField<String>(
                  value: _selectedAccountId,
                  dropdownColor: AppColors.card,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Select Account',
                    prefixIcon: Icon(Icons.account_balance_wallet_outlined,
                        color: AppColors.textMuted),
                  ),
                  items: accounts
                      .map((a) => DropdownMenuItem(
                            value: a.id,
                            child: Text(a.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedAccountId = value);
                  },
                  hint: const Text(
                    'Choose an account',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // File picker & status
            BlocConsumer<ImportCubit, ImportState>(
              listener: (context, state) {
                if (state is ImportError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                final cubit = context.read<ImportCubit>();
                final fileName = cubit.selectedFileName;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Pick file button
                    OutlinedButton.icon(
                      onPressed: state is ImportUploading
                          ? null
                          : () => cubit.pickCSVFile(),
                      icon: const Icon(Icons.attach_file),
                      label: Text(
                        fileName ?? 'Pick CSV File',
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Upload progress
                    if (state is ImportUploading) ...[
                      LinearProgressIndicator(
                        value: state.progress,
                        backgroundColor: AppColors.card,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(state.progress * 100).toInt()}% uploaded',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Result summary
                    if (state is ImportCompleted) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppColors.success.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              size: 48,
                              color: AppColors.success,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Import Complete!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _ResultRow(
                              label: 'Imported',
                              value: '${state.job.importedCount}',
                              color: AppColors.success,
                            ),
                            const SizedBox(height: 8),
                            _ResultRow(
                              label: 'Skipped',
                              value: '${state.job.skippedCount}',
                              color: AppColors.warning,
                            ),
                            const SizedBox(height: 8),
                            _ResultRow(
                              label: 'Errors',
                              value: '${state.job.errorCount}',
                              color: AppColors.error,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton(
                        onPressed: () => cubit.reset(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Import Another File'),
                      ),
                    ],

                    // Upload button
                    if (state is! ImportCompleted &&
                        state is! ImportUploading) ...[
                      GradientButton(
                        text: 'Upload & Import',
                        isLoading: state is ImportPicking,
                        onPressed: (fileName != null &&
                                _selectedAccountId != null)
                            ? () => cubit.uploadCSV(_selectedAccountId!)
                            : null,
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ResultRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
