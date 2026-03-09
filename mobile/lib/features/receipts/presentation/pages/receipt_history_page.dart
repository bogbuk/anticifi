import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../domain/entities/receipt_scan_entity.dart';
import '../bloc/receipt_cubit.dart';
import '../bloc/receipt_state.dart';

class ReceiptHistoryPage extends StatefulWidget {
  const ReceiptHistoryPage({super.key});

  @override
  State<ReceiptHistoryPage> createState() => _ReceiptHistoryPageState();
}

class _ReceiptHistoryPageState extends State<ReceiptHistoryPage> {
  @override
  void initState() {
    super.initState();
    context.read<ReceiptCubit>().loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt History'),
      ),
      body: BlocConsumer<ReceiptCubit, ReceiptState>(
        listener: (context, state) {
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
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (state is ReceiptHistoryLoaded) {
            if (state.scans.isEmpty) {
              return _buildEmptyState(theme);
            }
            return _buildScansList(state.scans, theme);
          }

          if (state is ReceiptError) {
            return _buildEmptyState(theme);
          }

          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No receipt scans yet',
            style: TextStyle(
              fontSize: 18,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scan a receipt to get started',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScansList(List<ReceiptScanEntity> scans, ThemeData theme) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        context.read<ReceiptCubit>().loadHistory();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: scans.length,
        itemBuilder: (context, index) {
          final scan = scans[index];
          return _ReceiptScanTile(
            scan: scan,
            onTap: () => context.push('/receipts/scan'),
          ).animate().fadeIn(
                duration: 400.ms,
                delay: (index.clamp(0, 10) * 50).ms,
              ).slideX(begin: 0.05, end: 0);
        },
      ),
    );
  }
}

class _ReceiptScanTile extends StatelessWidget {
  final ReceiptScanEntity scan;
  final VoidCallback onTap;

  const _ReceiptScanTile({
    required this.scan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy  HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: context.appColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.appColors.border),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _buildStatusIcon(),
        title: Text(
          scan.originalFilename,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              dateFormat.format(scan.createdAt),
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                fontSize: 13,
              ),
            ),
            if (scan.parsedData?.merchant != null) ...[
              const SizedBox(height: 2),
              Text(
                scan.parsedData!.merchant!,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
        trailing: _buildConfidenceBadge(theme),
        onTap: onTap,
      ),
    );
  }

  Widget _buildStatusIcon() {
    if (scan.isCompleted) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.check_circle,
          color: AppColors.success,
          size: 22,
        ),
      );
    }

    if (scan.isFailed) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.cancel,
          color: AppColors.error,
          size: 22,
        ),
      );
    }

    // Processing
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const SizedBox(
        width: 20,
        height: 20,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: AppColors.warning,
              strokeWidth: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfidenceBadge(ThemeData theme) {
    final percent = (scan.confidence * 100).toStringAsFixed(0);
    final color = scan.confidence >= 0.8
        ? AppColors.success
        : scan.confidence >= 0.5
            ? AppColors.warning
            : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$percent%',
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
