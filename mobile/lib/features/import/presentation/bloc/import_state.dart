import 'package:equatable/equatable.dart';

import '../../domain/entities/import_job_entity.dart';

abstract class ImportState extends Equatable {
  const ImportState();

  @override
  List<Object?> get props => [];
}

class ImportInitial extends ImportState {
  const ImportInitial();
}

class ImportPicking extends ImportState {
  const ImportPicking();
}

class ImportUploading extends ImportState {
  final double progress;

  const ImportUploading(this.progress);

  @override
  List<Object?> get props => [progress];
}

class ImportCompleted extends ImportState {
  final ImportJobEntity job;

  const ImportCompleted(this.job);

  @override
  List<Object?> get props => [job];
}

class ImportError extends ImportState {
  final String message;

  const ImportError(this.message);

  @override
  List<Object?> get props => [message];
}
