import 'dart:io' show Platform;

class ApiEndpoints {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://localhost:3000/api';
  }

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String profile = '/auth/profile';

  // Accounts
  static const String accounts = '/accounts';

  // Transactions
  static const String transactions = '/transactions';

  // Categories
  static const String categories = '/categories';

  // Dashboard
  static const String dashboard = '/dashboard';

  // Import
  static const String importCsv = '/import/csv';
  static const String importJobs = '/import/jobs';

  // Scheduled Payments
  static const String scheduledPayments = '/scheduled-payments';
}
