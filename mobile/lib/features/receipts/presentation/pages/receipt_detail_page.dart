import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/receipt_scan_entity.dart';

class ReceiptDetailPage extends StatelessWidget {
  final ReceiptScanEntity receipt;

  const ReceiptDetailPage({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.receiptDetails),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(context, theme),
            const SizedBox(height: 16),
            _buildInfoCard(context, theme),
            if (receipt.parsedData != null) ...[
              const SizedBox(height: 16),
              _buildParsedDataCard(context, theme),
            ],
            if (receipt.parsedData?.items != null &&
                receipt.parsedData!.items!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildItemsCard(context, theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;

    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (receipt.isCompleted) {
      statusText = l10n.completed;
      statusColor = AppColors.success;
      statusIcon = Icons.check_circle;
    } else if (receipt.isFailed) {
      statusText = l10n.failed;
      statusColor = AppColors.error;
      statusIcon = Icons.cancel;
    } else {
      statusText = l10n.processing;
      statusColor = AppColors.warning;
      statusIcon = Icons.hourglass_top;
    }

    final confidencePercent = (receipt.confidence * 100).toStringAsFixed(0);
    final confidenceColor = receipt.confidence >= 0.8
        ? AppColors.success
        : receipt.confidence >= 0.6
            ? AppColors.warning
            : AppColors.error;

    return Card(
      color: context.appColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.appColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(statusIcon, color: statusColor, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    receipt.status.toUpperCase(),
                    style: TextStyle(
                      color: context.appColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: confidenceColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    '$confidencePercent%',
                    style: TextStyle(
                      color: confidenceColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    l10n.confidence,
                    style: TextStyle(
                      color: confidenceColor.withOpacity(0.8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('MMM d, yyyy  HH:mm');

    return Card(
      color: context.appColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.appColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.scanInfo,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              icon: Icons.insert_drive_file_outlined,
              label: l10n.filename,
              value: receipt.originalFilename,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              context,
              icon: Icons.calendar_today_outlined,
              label: l10n.scannedOn,
              value: dateFormat.format(receipt.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParsedDataCard(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    final parsed = receipt.parsedData!;

    return Card(
      color: context.appColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.appColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.receiptData,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            if (parsed.merchant != null)
              _buildInfoRow(
                context,
                icon: Icons.store_outlined,
                label: l10n.merchant,
                value: parsed.merchant!,
              ),
            if (parsed.merchant != null && (parsed.amount != null || parsed.date != null))
              const Divider(height: 24),
            if (parsed.amount != null)
              _buildInfoRow(
                context,
                icon: Icons.attach_money,
                label: l10n.totalAmount,
                value: _formatAmount(parsed.amount!, parsed.currency),
              ),
            if (parsed.amount != null && parsed.date != null)
              const Divider(height: 24),
            if (parsed.date != null)
              _buildInfoRow(
                context,
                icon: Icons.event_outlined,
                label: l10n.receiptDate,
                value: parsed.date!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsCard(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    final items = receipt.parsedData!.items!;
    final currency = receipt.parsedData?.currency;

    return Card(
      color: context.appColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.appColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  l10n.items,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${items.length}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  if (index > 0) const Divider(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.name,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        _formatAmount(item.price, currency),
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: context.appColors.textMuted),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: context.appColors.textMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatAmount(double amount, String? currency) {
    final curr = currency ?? 'USD';
    return '${amount.toStringAsFixed(2)} $curr';
  }
}
