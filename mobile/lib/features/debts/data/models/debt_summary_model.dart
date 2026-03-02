import '../../domain/entities/debt_summary_entity.dart';

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0.0;
}

class DebtSummaryModel extends DebtSummaryEntity {
  const DebtSummaryModel({
    required super.totalDebts,
    required super.activeDebts,
    required super.paidOffDebts,
    required super.totalOriginalAmount,
    required super.totalCurrentBalance,
    required super.totalPaid,
    required super.overallProgress,
  });

  factory DebtSummaryModel.fromJson(Map<String, dynamic> json) {
    return DebtSummaryModel(
      totalDebts: json['totalDebts'] as int? ?? 0,
      activeDebts: json['activeDebts'] as int? ?? 0,
      paidOffDebts: json['paidOffDebts'] as int? ?? 0,
      totalOriginalAmount: _toDouble(json['totalOriginalAmount']),
      totalCurrentBalance: _toDouble(json['totalCurrentBalance']),
      totalPaid: _toDouble(json['totalPaid']),
      overallProgress: _toDouble(json['overallProgress']),
    );
  }
}
