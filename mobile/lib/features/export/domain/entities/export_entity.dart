enum ExportFormat { csv, pdf }

extension ExportFormatExtension on ExportFormat {
  String get label {
    switch (this) {
      case ExportFormat.csv:
        return 'CSV';
      case ExportFormat.pdf:
        return 'PDF';
    }
  }

  String get mimeType {
    switch (this) {
      case ExportFormat.csv:
        return 'text/csv';
      case ExportFormat.pdf:
        return 'application/pdf';
    }
  }

  String get extension {
    switch (this) {
      case ExportFormat.csv:
        return 'csv';
      case ExportFormat.pdf:
        return 'pdf';
    }
  }
}
