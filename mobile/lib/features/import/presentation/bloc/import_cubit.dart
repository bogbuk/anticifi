import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/import_job_entity.dart';
import 'import_state.dart';

class ImportCubit extends Cubit<ImportState> {
  final DioClient _dioClient;

  ImportCubit(this._dioClient) : super(const ImportInitial());

  String? _selectedFilePath;
  String? _selectedFileName;

  String? get selectedFileName => _selectedFileName;

  Future<void> pickCSVFile() async {
    emit(const ImportPicking());
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.path != null) {
        _selectedFilePath = result.files.single.path;
        _selectedFileName = result.files.single.name;
        emit(const ImportInitial());
      } else {
        _selectedFilePath = null;
        _selectedFileName = null;
        emit(const ImportInitial());
      }
    } catch (e) {
      emit(ImportError(e.toString()));
    }
  }

  Future<void> uploadCSV(String accountId) async {
    if (_selectedFilePath == null) {
      emit(const ImportError('No file selected'));
      return;
    }

    emit(const ImportUploading(0.0));

    try {
      final formData = FormData.fromMap({
        'accountId': accountId,
        'file': await MultipartFile.fromFile(
          _selectedFilePath!,
          filename: _selectedFileName,
        ),
      });

      final response = await _dioClient.dio.post(
        ApiEndpoints.importCsv,
        data: formData,
        onSendProgress: (sent, total) {
          if (total > 0) {
            emit(ImportUploading(sent / total));
          }
        },
      );

      final data = response.data as Map<String, dynamic>;
      final job = ImportJobEntity(
        id: data['id'] as String? ?? '',
        accountId: accountId,
        status: data['status'] as String? ?? 'completed',
        format: 'csv',
        importedCount: data['importedCount'] as int? ?? 0,
        skippedCount: data['skippedCount'] as int? ?? 0,
        errorCount: data['errorCount'] as int? ?? 0,
        createdAt: data['createdAt'] != null
            ? DateTime.parse(data['createdAt'] as String)
            : DateTime.now(),
        completedAt: data['completedAt'] != null
            ? DateTime.parse(data['completedAt'] as String)
            : null,
      );

      _selectedFilePath = null;
      _selectedFileName = null;
      emit(ImportCompleted(job));
    } catch (e) {
      emit(ImportError(e.toString()));
    }
  }

  void reset() {
    _selectedFilePath = null;
    _selectedFileName = null;
    emit(const ImportInitial());
  }
}
