import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class ExportState extends Equatable {
  const ExportState();

  @override
  List<Object?> get props => [];
}

class ExportInitial extends ExportState {
  const ExportInitial();
}

class ExportLoading extends ExportState {
  const ExportLoading();
}

class ExportSuccess extends ExportState {
  final File file;

  const ExportSuccess(this.file);

  @override
  List<Object?> get props => [file];
}

class ExportError extends ExportState {
  final String message;

  const ExportError(this.message);

  @override
  List<Object?> get props => [message];
}
