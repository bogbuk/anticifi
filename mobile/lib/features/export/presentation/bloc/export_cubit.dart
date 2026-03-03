import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/export_entity.dart';
import '../../domain/repositories/export_repository.dart';
import 'export_state.dart';

class ExportCubit extends Cubit<ExportState> {
  final ExportRepository _repository;

  ExportCubit(this._repository) : super(const ExportInitial());

  Future<void> exportData({
    required ExportFormat format,
    DateTime? startDate,
    DateTime? endDate,
    String? accountId,
    String? type,
  }) async {
    emit(const ExportLoading());
    try {
      final file = await _repository.exportData(
        format: format,
        startDate: startDate,
        endDate: endDate,
        accountId: accountId,
        type: type,
      );
      emit(ExportSuccess(file));
    } catch (e) {
      emit(ExportError(e.toString()));
    }
  }

  void reset() {
    emit(const ExportInitial());
  }
}
