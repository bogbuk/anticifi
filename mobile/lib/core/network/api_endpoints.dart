import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class ApiEndpoints {
  static String get baseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
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

  // Predictions / Oracle
  static const String predictions = '/predictions';
  static const String predictionChat = '/predictions/chat';
  static const String predictionForecast = '/predictions/forecast';

  // User Profile
  static const String userProfile = '/users/profile';
  static const String userAccount = '/users/account';

  // Plaid
  static const String plaidLinkToken = '/plaid/link-token';
  static const String plaidExchangeToken = '/plaid/exchange-token';
  static const String plaidItems = '/plaid/items';
  static const String plaidSync = '/plaid/sync';

  // Budgets
  static const String budgets = '/budgets';
  static const String budgetsSummary = '/budgets/summary';

  // Debts
  static const String debts = '/debts';
  static const String debtsSummary = '/debts/summary';

  // Notifications
  static const String notifications = '/notifications';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static const String notificationsReadAll = '/notifications/read-all';
  static const String fcmToken = '/notifications/fcm-token';

  // Receipts
  static const String receipts = '/receipts';
  static const String receiptsScan = '/receipts/scan';

  // Currency
  static const String currencyRates = '/currencies/rates';
  static const String currencyConvert = '/currencies/convert';

  // Export
  static const String exportCsv = '/export/csv';
  static const String exportPdf = '/export/pdf';

  // Categorization
  static const String transactionsCategorize = '/transactions/categorize';

  // Subscriptions
  static const String subscriptionStatus = '/subscriptions/status';
  static const String subscriptionSync = '/subscriptions/sync';
}
