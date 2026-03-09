// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AnticiFi';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get transactions => 'Transactions';

  @override
  String get oracle => 'Oracle';

  @override
  String get settings => 'Settings';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInToContinue => 'Sign in to continue';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign In';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get signUp => 'Sign Up';

  @override
  String get enableBiometricTitle => 'Enable Biometric Login?';

  @override
  String get enableBiometricContent =>
      'Use Face ID or Touch ID for faster access next time.';

  @override
  String get notNow => 'Not Now';

  @override
  String get enable => 'Enable';

  @override
  String get createAccount => 'Create Account';

  @override
  String get signUpToGetStarted => 'Sign up to get started';

  @override
  String get fullName => 'Full Name';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get onboardingTitle1 => 'Welcome to AnticiFi';

  @override
  String get onboardingDesc1 =>
      'Your AI-powered financial assistant that helps you manage money smarter and plan for the future.';

  @override
  String get onboardingTitle2 => 'Smart Predictions';

  @override
  String get onboardingDesc2 =>
      'Our AI analyzes your spending patterns and forecasts upcoming expenses so you\'re never caught off guard.';

  @override
  String get onboardingTitle3 => 'Stay on Track';

  @override
  String get onboardingDesc3 =>
      'Set budgets, manage debts, and get timely notifications to keep your finances healthy and on target.';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get failedToLoadDashboard => 'Failed to load dashboard';

  @override
  String get failedToLoadAccounts => 'Failed to load accounts';

  @override
  String get retry => 'Retry';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get noRecentTransactions => 'No recent transactions';

  @override
  String get all => 'All';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get noTransactionsYet => 'No transactions yet';

  @override
  String get tapPlusToAddTransaction => 'Tap + to add your first transaction';

  @override
  String get deleteTransaction => 'Delete Transaction';

  @override
  String get deleteTransactionConfirm =>
      'Are you sure you want to delete this transaction?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get editTransaction => 'Edit Transaction';

  @override
  String get newTransaction => 'New Transaction';

  @override
  String get account => 'Account';

  @override
  String get amount => 'Amount';

  @override
  String get pleaseEnterAmount => 'Please enter an amount';

  @override
  String get pleaseEnterValidNumber => 'Please enter a valid number';

  @override
  String get amountMustBeGreaterThanZero => 'Amount must be greater than 0';

  @override
  String get description => 'Description';

  @override
  String get voiceLimitReached =>
      'Voice input limit reached. Upgrade to Pro for unlimited access';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get speechNotAvailable => 'Speech recognition is not available';

  @override
  String get pleaseEnterAccountFirst => 'Please enter account first';

  @override
  String get pleaseCreateAccountFirst => 'Please create an account first';

  @override
  String get updateTransaction => 'Update Transaction';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get accounts => 'Accounts';

  @override
  String get connectBank => 'Connect Bank';

  @override
  String get noAccountsYet => 'No accounts yet';

  @override
  String get tapPlusToAddAccount => 'Tap + to add your first account';

  @override
  String get editAccount => 'Edit Account';

  @override
  String get newAccount => 'New Account';

  @override
  String get accountName => 'Account Name';

  @override
  String get pleaseEnterAccountName => 'Please enter account name';

  @override
  String get accountType => 'Account Type';

  @override
  String get checking => 'Checking';

  @override
  String get savings => 'Savings';

  @override
  String get creditCard => 'Credit Card';

  @override
  String get cash => 'Cash';

  @override
  String get bankOptional => 'Bank (optional)';

  @override
  String get currency => 'Currency';

  @override
  String get initialBalance => 'Initial Balance';

  @override
  String get updateAccount => 'Update Account';

  @override
  String get connectYourBank => 'Connect your bank account';

  @override
  String get connectBankDescription =>
      'Securely link your bank to automatically import transactions and keep your balances up to date.';

  @override
  String get bankLevelEncryption => 'Bank-level encryption powered by Plaid';

  @override
  String failedToStartBankConnection(String error) {
    return 'Failed to start bank connection: $error';
  }

  @override
  String connectionCancelled(String message) {
    return 'Connection cancelled: $message';
  }

  @override
  String successfullyLinkedAccounts(int count) {
    return 'Successfully linked $count account(s)';
  }

  @override
  String get subscription => 'Subscription';

  @override
  String get manageSubscription => 'Manage Subscription';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get active => 'Active';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get manageAccounts => 'Manage Accounts';

  @override
  String get preferences => 'Preferences';

  @override
  String get theme => 'Theme';

  @override
  String get dark => 'Dark';

  @override
  String get light => 'Light';

  @override
  String get system => 'System';

  @override
  String get biometricLogin => 'Biometric Login';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get russian => 'Русский';

  @override
  String get romanian => 'Română';

  @override
  String get spanish => 'Español';

  @override
  String get french => 'Français';

  @override
  String get german => 'Deutsch';

  @override
  String get ukrainian => 'Українська';

  @override
  String get portuguese => 'Português';

  @override
  String get italian => 'Italiano';

  @override
  String get turkish => 'Türkçe';

  @override
  String get chinese => '中文';

  @override
  String get japanese => '日本語';

  @override
  String get notifications => 'Notifications';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get data => 'Data';

  @override
  String get scanReceipt => 'Scan Receipt';

  @override
  String get importTransactions => 'Import Transactions';

  @override
  String get exportData => 'Export Data';

  @override
  String get scheduledPayments => 'Scheduled Payments';

  @override
  String get budgets => 'Budgets';

  @override
  String get debts => 'Debts';

  @override
  String get about => 'About';

  @override
  String get appVersion => 'App Version';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get logout => 'Logout';

  @override
  String get premium => 'PREMIUM';

  @override
  String get free => 'FREE';

  @override
  String get selectCurrency => 'Select Currency';

  @override
  String get selectTheme => 'Select Theme';

  @override
  String get deleteAccountConfirm =>
      'Are you sure you want to delete your account? This action cannot be undone. All your data will be permanently removed.';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get name => 'Name';

  @override
  String get enterYourName => 'Enter your name';

  @override
  String get nameIsRequired => 'Name is required';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully';

  @override
  String get inactive => 'Inactive';

  @override
  String get noActiveBudgets => 'No active budgets';

  @override
  String get noInactiveBudgets => 'No inactive budgets';

  @override
  String get tapPlusToCreateBudget => 'Tap + to create your first budget';

  @override
  String get deleteBudget => 'Delete Budget';

  @override
  String deleteBudgetConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get editBudget => 'Edit Budget';

  @override
  String get newBudget => 'New Budget';

  @override
  String get budgetName => 'Budget Name';

  @override
  String get pleaseEnterBudgetName => 'Please enter budget name';

  @override
  String get budgetLimit => 'Budget Limit';

  @override
  String get pleaseEnterBudgetLimit => 'Please enter budget limit';

  @override
  String get pleaseEnterValidPositiveNumber =>
      'Please enter a valid positive number';

  @override
  String get period => 'Period';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDateOptional => 'End Date (optional)';

  @override
  String get noEndDate => 'No end date';

  @override
  String get updateBudget => 'Update Budget';

  @override
  String get createBudget => 'Create Budget';

  @override
  String get paidOff => 'Paid Off';

  @override
  String get noActiveDebts => 'No active debts';

  @override
  String get noPaidOffDebts => 'No paid off debts';

  @override
  String get noDebts => 'No debts';

  @override
  String get tapPlusToAddDebt => 'Tap + to add your first debt';

  @override
  String get editDebt => 'Edit Debt';

  @override
  String get newDebt => 'New Debt';

  @override
  String get debtName => 'Debt Name';

  @override
  String get pleaseEnterDebtName => 'Please enter debt name';

  @override
  String get debtType => 'Debt Type';

  @override
  String get personalLoan => 'Personal Loan';

  @override
  String get mortgage => 'Mortgage';

  @override
  String get autoLoan => 'Auto Loan';

  @override
  String get studentLoan => 'Student Loan';

  @override
  String get personal => 'Personal';

  @override
  String get other => 'Other';

  @override
  String get originalAmount => 'Original Amount';

  @override
  String get pleaseEnterOriginalAmount => 'Please enter original amount';

  @override
  String get currentBalance => 'Current Balance';

  @override
  String get pleaseEnterCurrentBalance => 'Please enter current balance';

  @override
  String get interestRate => 'Interest Rate (%)';

  @override
  String get minimumPayment => 'Minimum Payment';

  @override
  String get dueDay => 'Due Day (1-31)';

  @override
  String get pleaseEnterValidDay => 'Please enter a day between 1 and 31';

  @override
  String get creditorNameOptional => 'Creditor Name (optional)';

  @override
  String get expectedPayoffDateOptional => 'Expected Payoff Date (optional)';

  @override
  String get noDateSet => 'No date set';

  @override
  String get notesOptional => 'Notes (optional)';

  @override
  String get updateDebt => 'Update Debt';

  @override
  String get addDebt => 'Add Debt';

  @override
  String get debtDetails => 'Debt Details';

  @override
  String get original => 'Original';

  @override
  String get remaining => 'Remaining';

  @override
  String get interest => 'Interest';

  @override
  String get minPayment => 'Min Payment';

  @override
  String get start => 'Start';

  @override
  String get expectedPayoff => 'Expected Payoff';

  @override
  String get notes => 'Notes';

  @override
  String get recordPayment => 'Record Payment';

  @override
  String get paymentAmount => 'Payment Amount';

  @override
  String get pleaseEnterPaymentAmount => 'Please enter payment amount';

  @override
  String get paymentDate => 'Payment Date';

  @override
  String get aiFinancialAdvisor => 'AI Financial Advisor';

  @override
  String get oracleWelcome => 'Hi! I\'m Oracle, your AI financial advisor.';

  @override
  String get oracleAsk => 'Ask me anything about your future finances.';

  @override
  String get oracleHint => 'Ask Oracle about your finances...';

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get failedToLoadNotifications => 'Failed to load notifications';

  @override
  String get noNotificationsYet => 'No notifications yet';

  @override
  String get notificationsHint => 'You\'ll see your alerts and updates here';

  @override
  String get unlockFullPower => 'Unlock Full Power';

  @override
  String get unlockSubtitle => 'Get unlimited access to all premium features';

  @override
  String get premiumIncludes => 'Premium includes:';

  @override
  String get featureUnlimitedAccounts => 'Unlimited bank accounts';

  @override
  String get featureBankSync => 'Auto bank sync with Plaid';

  @override
  String get featureReceiptScanning => 'Receipt scanning (OCR)';

  @override
  String get featureAiPredictions => 'AI predictions & Oracle';

  @override
  String get featureSmartCategorization => 'Smart categorization';

  @override
  String get featureBudgetsDebts => 'Budgets & debt tracking';

  @override
  String get featureExport => 'Data export (CSV/PDF)';

  @override
  String get featureMultiCurrency => 'Multi-currency support';

  @override
  String get yearlyPrice => '\$34.99/year';

  @override
  String get monthlyPrice => '\$4.99/month';

  @override
  String get lifetimePrice => '\$99.99';

  @override
  String get yearlySaving => 'Save 42% - just \$2.92/month';

  @override
  String get cancelAnytime => 'Cancel anytime';

  @override
  String get lifetimeSubtitle => 'One-time payment, forever yours';

  @override
  String get bestValue => 'BEST VALUE';

  @override
  String get restorePurchases => 'Restore Purchases';

  @override
  String get processingPurchase => 'Processing purchase...';

  @override
  String get welcomeToPremium => 'Welcome to Premium!';

  @override
  String get noActiveScheduledPayments => 'No active scheduled payments';

  @override
  String get noInactiveScheduledPayments => 'No inactive scheduled payments';

  @override
  String get tapPlusToAddScheduledPayment =>
      'Tap + to add your first scheduled payment';

  @override
  String get importCsv => 'Import CSV';

  @override
  String get importTransactionsTitle => 'Import Transactions';

  @override
  String get importDescription =>
      'Upload a CSV file to import transactions into your account';

  @override
  String get selectAccount => 'Select Account';

  @override
  String get chooseAnAccount => 'Choose an account';

  @override
  String get pickCsvFile => 'Pick CSV File';

  @override
  String percentUploaded(int progress) {
    return '$progress% uploaded';
  }

  @override
  String get importComplete => 'Import Complete!';

  @override
  String get imported => 'Imported';

  @override
  String get skipped => 'Skipped';

  @override
  String get errors => 'Errors';

  @override
  String get importAnotherFile => 'Import Another File';

  @override
  String get uploadAndImport => 'Upload & Import';

  @override
  String get exportFormat => 'Export Format';

  @override
  String get csv => 'CSV';

  @override
  String get pdf => 'PDF';

  @override
  String get dateRangeOptional => 'Date Range (Optional)';

  @override
  String get endDate => 'End Date';

  @override
  String get clearDates => 'Clear dates';

  @override
  String get csvDescription =>
      'CSV file with columns: Date, Description, Amount, Type, Category, Account';

  @override
  String get pdfDescription => 'PDF report with summary and transaction table';

  @override
  String exportFormat2(String format) {
    return 'Export $format';
  }

  @override
  String get scanReceiptAutoFill =>
      'Scan a receipt to auto-fill\ntransaction details';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get processingReceipt => 'Processing receipt...';

  @override
  String confidencePercent(String confidence) {
    return 'Confidence: $confidence%';
  }

  @override
  String get merchant => 'Merchant';

  @override
  String get pleaseFillRequiredFields => 'Please fill in all required fields';

  @override
  String get createTransaction => 'Create Transaction';

  @override
  String get scanAnotherReceipt => 'Scan Another Receipt';

  @override
  String get transactionCreatedFromReceipt =>
      'Transaction created from receipt';

  @override
  String get offlineMode => 'Offline mode';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get spendingByCategory => 'Spending by Category';

  @override
  String get noSpendingDataYet => 'No spending data yet';

  @override
  String get pleaseSelectAccount => 'Please select an account';

  @override
  String get editScheduledPayment => 'Edit Scheduled Payment';

  @override
  String get newScheduledPayment => 'New Scheduled Payment';

  @override
  String get paymentName => 'Payment Name';

  @override
  String get pleaseEnterPaymentName => 'Please enter payment name';

  @override
  String get frequency => 'Frequency';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get updatePayment => 'Update Payment';

  @override
  String get createPayment => 'Create Payment';

  @override
  String get deleteScheduledPayment => 'Delete Scheduled Payment';

  @override
  String get executePayment => 'Execute Payment';

  @override
  String executePaymentConfirm(String name) {
    return 'Execute \"$name\" now?';
  }

  @override
  String get execute => 'Execute';

  @override
  String get receiptHistory => 'Receipt History';

  @override
  String get noReceiptScansYet => 'No receipt scans yet';

  @override
  String get scanReceiptToGetStarted => 'Scan a receipt to get started';

  @override
  String get addAccount => 'Add Account';

  @override
  String get noCategory => 'No category';

  @override
  String get category => 'Category';

  @override
  String get vsLastMonth => 'vs last month';

  @override
  String get receiptDetails => 'Receipt Details';

  @override
  String get scanInfo => 'Scan Info';

  @override
  String get filename => 'Filename';

  @override
  String get scannedOn => 'Scanned On';

  @override
  String get receiptData => 'Receipt Data';

  @override
  String get totalAmount => 'Total Amount';

  @override
  String get receiptDate => 'Receipt Date';

  @override
  String get confidence => 'Confidence';

  @override
  String get completed => 'Completed';

  @override
  String get failed => 'Failed';

  @override
  String get processing => 'Processing';

  @override
  String get items => 'Items';
}
