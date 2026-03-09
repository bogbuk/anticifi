import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ro.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('pt'),
    Locale('ro'),
    Locale('ru'),
    Locale('tr'),
    Locale('uk'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'AnticiFi'**
  String get appTitle;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @oracle.
  ///
  /// In en, this message translates to:
  /// **'Oracle'**
  String get oracle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @enableBiometricTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable Biometric Login?'**
  String get enableBiometricTitle;

  /// No description provided for @enableBiometricContent.
  ///
  /// In en, this message translates to:
  /// **'Use Face ID or Touch ID for faster access next time.'**
  String get enableBiometricContent;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get notNow;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @signUpToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Sign up to get started'**
  String get signUpToGetStarted;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Welcome to AnticiFi'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Your AI-powered financial assistant that helps you manage money smarter and plan for the future.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Smart Predictions'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Our AI analyzes your spending patterns and forecasts upcoming expenses so you\'re never caught off guard.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Stay on Track'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'Set budgets, manage debts, and get timely notifications to keep your finances healthy and on target.'**
  String get onboardingDesc3;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @failedToLoadDashboard.
  ///
  /// In en, this message translates to:
  /// **'Failed to load dashboard'**
  String get failedToLoadDashboard;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @noRecentTransactions.
  ///
  /// In en, this message translates to:
  /// **'No recent transactions'**
  String get noRecentTransactions;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// No description provided for @tapPlusToAddTransaction.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first transaction'**
  String get tapPlusToAddTransaction;

  /// No description provided for @deleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction'**
  String get deleteTransaction;

  /// No description provided for @deleteTransactionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this transaction?'**
  String get deleteTransactionConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @editTransaction.
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get editTransaction;

  /// No description provided for @newTransaction.
  ///
  /// In en, this message translates to:
  /// **'New Transaction'**
  String get newTransaction;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @pleaseEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get pleaseEnterAmount;

  /// No description provided for @pleaseEnterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get pleaseEnterValidNumber;

  /// No description provided for @amountMustBeGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than 0'**
  String get amountMustBeGreaterThanZero;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @voiceLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Voice input limit reached. Upgrade to Pro for unlimited access'**
  String get voiceLimitReached;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @speechNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition is not available'**
  String get speechNotAvailable;

  /// No description provided for @pleaseEnterAccountFirst.
  ///
  /// In en, this message translates to:
  /// **'Please enter account first'**
  String get pleaseEnterAccountFirst;

  /// No description provided for @pleaseCreateAccountFirst.
  ///
  /// In en, this message translates to:
  /// **'Please create an account first'**
  String get pleaseCreateAccountFirst;

  /// No description provided for @updateTransaction.
  ///
  /// In en, this message translates to:
  /// **'Update Transaction'**
  String get updateTransaction;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// No description provided for @accounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accounts;

  /// No description provided for @connectBank.
  ///
  /// In en, this message translates to:
  /// **'Connect Bank'**
  String get connectBank;

  /// No description provided for @noAccountsYet.
  ///
  /// In en, this message translates to:
  /// **'No accounts yet'**
  String get noAccountsYet;

  /// No description provided for @tapPlusToAddAccount.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first account'**
  String get tapPlusToAddAccount;

  /// No description provided for @editAccount.
  ///
  /// In en, this message translates to:
  /// **'Edit Account'**
  String get editAccount;

  /// No description provided for @newAccount.
  ///
  /// In en, this message translates to:
  /// **'New Account'**
  String get newAccount;

  /// No description provided for @accountName.
  ///
  /// In en, this message translates to:
  /// **'Account Name'**
  String get accountName;

  /// No description provided for @pleaseEnterAccountName.
  ///
  /// In en, this message translates to:
  /// **'Please enter account name'**
  String get pleaseEnterAccountName;

  /// No description provided for @accountType.
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get accountType;

  /// No description provided for @checking.
  ///
  /// In en, this message translates to:
  /// **'Checking'**
  String get checking;

  /// No description provided for @savings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get savings;

  /// No description provided for @creditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get creditCard;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @bankOptional.
  ///
  /// In en, this message translates to:
  /// **'Bank (optional)'**
  String get bankOptional;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @initialBalance.
  ///
  /// In en, this message translates to:
  /// **'Initial Balance'**
  String get initialBalance;

  /// No description provided for @updateAccount.
  ///
  /// In en, this message translates to:
  /// **'Update Account'**
  String get updateAccount;

  /// No description provided for @connectYourBank.
  ///
  /// In en, this message translates to:
  /// **'Connect your bank account'**
  String get connectYourBank;

  /// No description provided for @connectBankDescription.
  ///
  /// In en, this message translates to:
  /// **'Securely link your bank to automatically import transactions and keep your balances up to date.'**
  String get connectBankDescription;

  /// No description provided for @bankLevelEncryption.
  ///
  /// In en, this message translates to:
  /// **'Bank-level encryption powered by Plaid'**
  String get bankLevelEncryption;

  /// No description provided for @failedToStartBankConnection.
  ///
  /// In en, this message translates to:
  /// **'Failed to start bank connection: {error}'**
  String failedToStartBankConnection(String error);

  /// No description provided for @connectionCancelled.
  ///
  /// In en, this message translates to:
  /// **'Connection cancelled: {message}'**
  String connectionCancelled(String message);

  /// No description provided for @successfullyLinkedAccounts.
  ///
  /// In en, this message translates to:
  /// **'Successfully linked {count} account(s)'**
  String successfullyLinkedAccounts(int count);

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @manageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get manageSubscription;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @manageAccounts.
  ///
  /// In en, this message translates to:
  /// **'Manage Accounts'**
  String get manageAccounts;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @biometricLogin.
  ///
  /// In en, this message translates to:
  /// **'Biometric Login'**
  String get biometricLogin;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @russian.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get russian;

  /// No description provided for @romanian.
  ///
  /// In en, this message translates to:
  /// **'Română'**
  String get romanian;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get german;

  /// No description provided for @ukrainian.
  ///
  /// In en, this message translates to:
  /// **'Українська'**
  String get ukrainian;

  /// No description provided for @portuguese.
  ///
  /// In en, this message translates to:
  /// **'Português'**
  String get portuguese;

  /// No description provided for @italian.
  ///
  /// In en, this message translates to:
  /// **'Italiano'**
  String get italian;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Türkçe'**
  String get turkish;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get chinese;

  /// No description provided for @japanese.
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get japanese;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @scanReceipt.
  ///
  /// In en, this message translates to:
  /// **'Scan Receipt'**
  String get scanReceipt;

  /// No description provided for @importTransactions.
  ///
  /// In en, this message translates to:
  /// **'Import Transactions'**
  String get importTransactions;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @scheduledPayments.
  ///
  /// In en, this message translates to:
  /// **'Scheduled Payments'**
  String get scheduledPayments;

  /// No description provided for @budgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgets;

  /// No description provided for @debts.
  ///
  /// In en, this message translates to:
  /// **'Debts'**
  String get debts;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM'**
  String get premium;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get free;

  /// No description provided for @selectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get selectCurrency;

  /// No description provided for @selectTheme.
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get selectTheme;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone. All your data will be permanently removed.'**
  String get deleteAccountConfirm;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// No description provided for @nameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameIsRequired;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @noActiveBudgets.
  ///
  /// In en, this message translates to:
  /// **'No active budgets'**
  String get noActiveBudgets;

  /// No description provided for @noInactiveBudgets.
  ///
  /// In en, this message translates to:
  /// **'No inactive budgets'**
  String get noInactiveBudgets;

  /// No description provided for @tapPlusToCreateBudget.
  ///
  /// In en, this message translates to:
  /// **'Tap + to create your first budget'**
  String get tapPlusToCreateBudget;

  /// No description provided for @deleteBudget.
  ///
  /// In en, this message translates to:
  /// **'Delete Budget'**
  String get deleteBudget;

  /// No description provided for @deleteBudgetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String deleteBudgetConfirm(String name);

  /// No description provided for @editBudget.
  ///
  /// In en, this message translates to:
  /// **'Edit Budget'**
  String get editBudget;

  /// No description provided for @newBudget.
  ///
  /// In en, this message translates to:
  /// **'New Budget'**
  String get newBudget;

  /// No description provided for @budgetName.
  ///
  /// In en, this message translates to:
  /// **'Budget Name'**
  String get budgetName;

  /// No description provided for @pleaseEnterBudgetName.
  ///
  /// In en, this message translates to:
  /// **'Please enter budget name'**
  String get pleaseEnterBudgetName;

  /// No description provided for @budgetLimit.
  ///
  /// In en, this message translates to:
  /// **'Budget Limit'**
  String get budgetLimit;

  /// No description provided for @pleaseEnterBudgetLimit.
  ///
  /// In en, this message translates to:
  /// **'Please enter budget limit'**
  String get pleaseEnterBudgetLimit;

  /// No description provided for @pleaseEnterValidPositiveNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid positive number'**
  String get pleaseEnterValidPositiveNumber;

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get period;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDateOptional.
  ///
  /// In en, this message translates to:
  /// **'End Date (optional)'**
  String get endDateOptional;

  /// No description provided for @noEndDate.
  ///
  /// In en, this message translates to:
  /// **'No end date'**
  String get noEndDate;

  /// No description provided for @updateBudget.
  ///
  /// In en, this message translates to:
  /// **'Update Budget'**
  String get updateBudget;

  /// No description provided for @createBudget.
  ///
  /// In en, this message translates to:
  /// **'Create Budget'**
  String get createBudget;

  /// No description provided for @paidOff.
  ///
  /// In en, this message translates to:
  /// **'Paid Off'**
  String get paidOff;

  /// No description provided for @noActiveDebts.
  ///
  /// In en, this message translates to:
  /// **'No active debts'**
  String get noActiveDebts;

  /// No description provided for @noPaidOffDebts.
  ///
  /// In en, this message translates to:
  /// **'No paid off debts'**
  String get noPaidOffDebts;

  /// No description provided for @noDebts.
  ///
  /// In en, this message translates to:
  /// **'No debts'**
  String get noDebts;

  /// No description provided for @tapPlusToAddDebt.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first debt'**
  String get tapPlusToAddDebt;

  /// No description provided for @editDebt.
  ///
  /// In en, this message translates to:
  /// **'Edit Debt'**
  String get editDebt;

  /// No description provided for @newDebt.
  ///
  /// In en, this message translates to:
  /// **'New Debt'**
  String get newDebt;

  /// No description provided for @debtName.
  ///
  /// In en, this message translates to:
  /// **'Debt Name'**
  String get debtName;

  /// No description provided for @pleaseEnterDebtName.
  ///
  /// In en, this message translates to:
  /// **'Please enter debt name'**
  String get pleaseEnterDebtName;

  /// No description provided for @debtType.
  ///
  /// In en, this message translates to:
  /// **'Debt Type'**
  String get debtType;

  /// No description provided for @personalLoan.
  ///
  /// In en, this message translates to:
  /// **'Personal Loan'**
  String get personalLoan;

  /// No description provided for @mortgage.
  ///
  /// In en, this message translates to:
  /// **'Mortgage'**
  String get mortgage;

  /// No description provided for @autoLoan.
  ///
  /// In en, this message translates to:
  /// **'Auto Loan'**
  String get autoLoan;

  /// No description provided for @studentLoan.
  ///
  /// In en, this message translates to:
  /// **'Student Loan'**
  String get studentLoan;

  /// No description provided for @personal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get personal;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @originalAmount.
  ///
  /// In en, this message translates to:
  /// **'Original Amount'**
  String get originalAmount;

  /// No description provided for @pleaseEnterOriginalAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter original amount'**
  String get pleaseEnterOriginalAmount;

  /// No description provided for @currentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current Balance'**
  String get currentBalance;

  /// No description provided for @pleaseEnterCurrentBalance.
  ///
  /// In en, this message translates to:
  /// **'Please enter current balance'**
  String get pleaseEnterCurrentBalance;

  /// No description provided for @interestRate.
  ///
  /// In en, this message translates to:
  /// **'Interest Rate (%)'**
  String get interestRate;

  /// No description provided for @minimumPayment.
  ///
  /// In en, this message translates to:
  /// **'Minimum Payment'**
  String get minimumPayment;

  /// No description provided for @dueDay.
  ///
  /// In en, this message translates to:
  /// **'Due Day (1-31)'**
  String get dueDay;

  /// No description provided for @pleaseEnterValidDay.
  ///
  /// In en, this message translates to:
  /// **'Please enter a day between 1 and 31'**
  String get pleaseEnterValidDay;

  /// No description provided for @creditorNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Creditor Name (optional)'**
  String get creditorNameOptional;

  /// No description provided for @expectedPayoffDateOptional.
  ///
  /// In en, this message translates to:
  /// **'Expected Payoff Date (optional)'**
  String get expectedPayoffDateOptional;

  /// No description provided for @noDateSet.
  ///
  /// In en, this message translates to:
  /// **'No date set'**
  String get noDateSet;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptional;

  /// No description provided for @updateDebt.
  ///
  /// In en, this message translates to:
  /// **'Update Debt'**
  String get updateDebt;

  /// No description provided for @addDebt.
  ///
  /// In en, this message translates to:
  /// **'Add Debt'**
  String get addDebt;

  /// No description provided for @debtDetails.
  ///
  /// In en, this message translates to:
  /// **'Debt Details'**
  String get debtDetails;

  /// No description provided for @original.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get original;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @interest.
  ///
  /// In en, this message translates to:
  /// **'Interest'**
  String get interest;

  /// No description provided for @minPayment.
  ///
  /// In en, this message translates to:
  /// **'Min Payment'**
  String get minPayment;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @expectedPayoff.
  ///
  /// In en, this message translates to:
  /// **'Expected Payoff'**
  String get expectedPayoff;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @recordPayment.
  ///
  /// In en, this message translates to:
  /// **'Record Payment'**
  String get recordPayment;

  /// No description provided for @paymentAmount.
  ///
  /// In en, this message translates to:
  /// **'Payment Amount'**
  String get paymentAmount;

  /// No description provided for @pleaseEnterPaymentAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter payment amount'**
  String get pleaseEnterPaymentAmount;

  /// No description provided for @paymentDate.
  ///
  /// In en, this message translates to:
  /// **'Payment Date'**
  String get paymentDate;

  /// No description provided for @aiFinancialAdvisor.
  ///
  /// In en, this message translates to:
  /// **'AI Financial Advisor'**
  String get aiFinancialAdvisor;

  /// No description provided for @oracleWelcome.
  ///
  /// In en, this message translates to:
  /// **'Hi! I\'m Oracle, your AI financial advisor.'**
  String get oracleWelcome;

  /// No description provided for @oracleAsk.
  ///
  /// In en, this message translates to:
  /// **'Ask me anything about your future finances.'**
  String get oracleAsk;

  /// No description provided for @oracleHint.
  ///
  /// In en, this message translates to:
  /// **'Ask Oracle about your finances...'**
  String get oracleHint;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @failedToLoadNotifications.
  ///
  /// In en, this message translates to:
  /// **'Failed to load notifications'**
  String get failedToLoadNotifications;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @notificationsHint.
  ///
  /// In en, this message translates to:
  /// **'You\'ll see your alerts and updates here'**
  String get notificationsHint;

  /// No description provided for @unlockFullPower.
  ///
  /// In en, this message translates to:
  /// **'Unlock Full Power'**
  String get unlockFullPower;

  /// No description provided for @unlockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get unlimited access to all premium features'**
  String get unlockSubtitle;

  /// No description provided for @premiumIncludes.
  ///
  /// In en, this message translates to:
  /// **'Premium includes:'**
  String get premiumIncludes;

  /// No description provided for @featureUnlimitedAccounts.
  ///
  /// In en, this message translates to:
  /// **'Unlimited bank accounts'**
  String get featureUnlimitedAccounts;

  /// No description provided for @featureBankSync.
  ///
  /// In en, this message translates to:
  /// **'Auto bank sync with Plaid'**
  String get featureBankSync;

  /// No description provided for @featureReceiptScanning.
  ///
  /// In en, this message translates to:
  /// **'Receipt scanning (OCR)'**
  String get featureReceiptScanning;

  /// No description provided for @featureAiPredictions.
  ///
  /// In en, this message translates to:
  /// **'AI predictions & Oracle'**
  String get featureAiPredictions;

  /// No description provided for @featureSmartCategorization.
  ///
  /// In en, this message translates to:
  /// **'Smart categorization'**
  String get featureSmartCategorization;

  /// No description provided for @featureBudgetsDebts.
  ///
  /// In en, this message translates to:
  /// **'Budgets & debt tracking'**
  String get featureBudgetsDebts;

  /// No description provided for @featureExport.
  ///
  /// In en, this message translates to:
  /// **'Data export (CSV/PDF)'**
  String get featureExport;

  /// No description provided for @featureMultiCurrency.
  ///
  /// In en, this message translates to:
  /// **'Multi-currency support'**
  String get featureMultiCurrency;

  /// No description provided for @yearlyPrice.
  ///
  /// In en, this message translates to:
  /// **'\$34.99/year'**
  String get yearlyPrice;

  /// No description provided for @monthlyPrice.
  ///
  /// In en, this message translates to:
  /// **'\$4.99/month'**
  String get monthlyPrice;

  /// No description provided for @lifetimePrice.
  ///
  /// In en, this message translates to:
  /// **'\$99.99'**
  String get lifetimePrice;

  /// No description provided for @yearlySaving.
  ///
  /// In en, this message translates to:
  /// **'Save 42% - just \$2.92/month'**
  String get yearlySaving;

  /// No description provided for @cancelAnytime.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime'**
  String get cancelAnytime;

  /// No description provided for @lifetimeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One-time payment, forever yours'**
  String get lifetimeSubtitle;

  /// No description provided for @bestValue.
  ///
  /// In en, this message translates to:
  /// **'BEST VALUE'**
  String get bestValue;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// No description provided for @processingPurchase.
  ///
  /// In en, this message translates to:
  /// **'Processing purchase...'**
  String get processingPurchase;

  /// No description provided for @welcomeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Premium!'**
  String get welcomeToPremium;

  /// No description provided for @noActiveScheduledPayments.
  ///
  /// In en, this message translates to:
  /// **'No active scheduled payments'**
  String get noActiveScheduledPayments;

  /// No description provided for @noInactiveScheduledPayments.
  ///
  /// In en, this message translates to:
  /// **'No inactive scheduled payments'**
  String get noInactiveScheduledPayments;

  /// No description provided for @tapPlusToAddScheduledPayment.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first scheduled payment'**
  String get tapPlusToAddScheduledPayment;

  /// No description provided for @importCsv.
  ///
  /// In en, this message translates to:
  /// **'Import CSV'**
  String get importCsv;

  /// No description provided for @importTransactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Transactions'**
  String get importTransactionsTitle;

  /// No description provided for @importDescription.
  ///
  /// In en, this message translates to:
  /// **'Upload a CSV file to import transactions into your account'**
  String get importDescription;

  /// No description provided for @selectAccount.
  ///
  /// In en, this message translates to:
  /// **'Select Account'**
  String get selectAccount;

  /// No description provided for @chooseAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Choose an account'**
  String get chooseAnAccount;

  /// No description provided for @pickCsvFile.
  ///
  /// In en, this message translates to:
  /// **'Pick CSV File'**
  String get pickCsvFile;

  /// No description provided for @percentUploaded.
  ///
  /// In en, this message translates to:
  /// **'{progress}% uploaded'**
  String percentUploaded(int progress);

  /// No description provided for @importComplete.
  ///
  /// In en, this message translates to:
  /// **'Import Complete!'**
  String get importComplete;

  /// No description provided for @imported.
  ///
  /// In en, this message translates to:
  /// **'Imported'**
  String get imported;

  /// No description provided for @skipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get skipped;

  /// No description provided for @errors.
  ///
  /// In en, this message translates to:
  /// **'Errors'**
  String get errors;

  /// No description provided for @importAnotherFile.
  ///
  /// In en, this message translates to:
  /// **'Import Another File'**
  String get importAnotherFile;

  /// No description provided for @uploadAndImport.
  ///
  /// In en, this message translates to:
  /// **'Upload & Import'**
  String get uploadAndImport;

  /// No description provided for @exportFormat.
  ///
  /// In en, this message translates to:
  /// **'Export Format'**
  String get exportFormat;

  /// No description provided for @csv.
  ///
  /// In en, this message translates to:
  /// **'CSV'**
  String get csv;

  /// No description provided for @pdf.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get pdf;

  /// No description provided for @dateRangeOptional.
  ///
  /// In en, this message translates to:
  /// **'Date Range (Optional)'**
  String get dateRangeOptional;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @clearDates.
  ///
  /// In en, this message translates to:
  /// **'Clear dates'**
  String get clearDates;

  /// No description provided for @csvDescription.
  ///
  /// In en, this message translates to:
  /// **'CSV file with columns: Date, Description, Amount, Type, Category, Account'**
  String get csvDescription;

  /// No description provided for @pdfDescription.
  ///
  /// In en, this message translates to:
  /// **'PDF report with summary and transaction table'**
  String get pdfDescription;

  /// No description provided for @exportFormat2.
  ///
  /// In en, this message translates to:
  /// **'Export {format}'**
  String exportFormat2(String format);

  /// No description provided for @scanReceiptAutoFill.
  ///
  /// In en, this message translates to:
  /// **'Scan a receipt to auto-fill\ntransaction details'**
  String get scanReceiptAutoFill;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @processingReceipt.
  ///
  /// In en, this message translates to:
  /// **'Processing receipt...'**
  String get processingReceipt;

  /// No description provided for @confidencePercent.
  ///
  /// In en, this message translates to:
  /// **'Confidence: {confidence}%'**
  String confidencePercent(String confidence);

  /// No description provided for @merchant.
  ///
  /// In en, this message translates to:
  /// **'Merchant'**
  String get merchant;

  /// No description provided for @pleaseFillRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields'**
  String get pleaseFillRequiredFields;

  /// No description provided for @createTransaction.
  ///
  /// In en, this message translates to:
  /// **'Create Transaction'**
  String get createTransaction;

  /// No description provided for @scanAnotherReceipt.
  ///
  /// In en, this message translates to:
  /// **'Scan Another Receipt'**
  String get scanAnotherReceipt;

  /// No description provided for @transactionCreatedFromReceipt.
  ///
  /// In en, this message translates to:
  /// **'Transaction created from receipt'**
  String get transactionCreatedFromReceipt;

  /// No description provided for @offlineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline mode'**
  String get offlineMode;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'de',
        'en',
        'es',
        'fr',
        'it',
        'ja',
        'pt',
        'ro',
        'ru',
        'tr',
        'uk',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'pt':
      return AppLocalizationsPt();
    case 'ro':
      return AppLocalizationsRo();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
    case 'uk':
      return AppLocalizationsUk();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
