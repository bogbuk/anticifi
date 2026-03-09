// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'AnticiFi';

  @override
  String get dashboard => 'Главная';

  @override
  String get transactions => 'Транзакции';

  @override
  String get oracle => 'Оракул';

  @override
  String get settings => 'Настройки';

  @override
  String get welcomeBack => 'С возвращением';

  @override
  String get signInToContinue => 'Войдите, чтобы продолжить';

  @override
  String get email => 'Эл. почта';

  @override
  String get password => 'Пароль';

  @override
  String get signIn => 'Войти';

  @override
  String get dontHaveAccount => 'Нет аккаунта? ';

  @override
  String get signUp => 'Регистрация';

  @override
  String get enableBiometricTitle => 'Включить биометрию?';

  @override
  String get enableBiometricContent =>
      'Используйте Face ID или Touch ID для быстрого входа.';

  @override
  String get notNow => 'Не сейчас';

  @override
  String get enable => 'Включить';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get signUpToGetStarted => 'Зарегистрируйтесь для начала';

  @override
  String get fullName => 'Полное имя';

  @override
  String get confirmPassword => 'Подтвердите пароль';

  @override
  String get passwordsDoNotMatch => 'Пароли не совпадают';

  @override
  String get alreadyHaveAccount => 'Уже есть аккаунт? ';

  @override
  String get onboardingTitle1 => 'Добро пожаловать в AnticiFi';

  @override
  String get onboardingDesc1 =>
      'Ваш AI-финансовый помощник, который помогает управлять деньгами умнее и планировать будущее.';

  @override
  String get onboardingTitle2 => 'Умные прогнозы';

  @override
  String get onboardingDesc2 =>
      'Наш AI анализирует ваши траты и прогнозирует предстоящие расходы, чтобы вы были всегда готовы.';

  @override
  String get onboardingTitle3 => 'Держите всё под контролем';

  @override
  String get onboardingDesc3 =>
      'Устанавливайте бюджеты, управляйте долгами и получайте уведомления для поддержания финансового здоровья.';

  @override
  String get skip => 'Пропустить';

  @override
  String get next => 'Далее';

  @override
  String get getStarted => 'Начать';

  @override
  String get failedToLoadDashboard => 'Не удалось загрузить данные';

  @override
  String get retry => 'Повторить';

  @override
  String get recentTransactions => 'Последние транзакции';

  @override
  String get noRecentTransactions => 'Нет недавних транзакций';

  @override
  String get all => 'Все';

  @override
  String get income => 'Доход';

  @override
  String get expense => 'Расход';

  @override
  String get noTransactionsYet => 'Пока нет транзакций';

  @override
  String get tapPlusToAddTransaction =>
      'Нажмите +, чтобы добавить первую транзакцию';

  @override
  String get deleteTransaction => 'Удалить транзакцию';

  @override
  String get deleteTransactionConfirm =>
      'Вы уверены, что хотите удалить эту транзакцию?';

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get editTransaction => 'Редактировать транзакцию';

  @override
  String get newTransaction => 'Новая транзакция';

  @override
  String get account => 'Счёт';

  @override
  String get amount => 'Сумма';

  @override
  String get pleaseEnterAmount => 'Введите сумму';

  @override
  String get pleaseEnterValidNumber => 'Введите корректное число';

  @override
  String get amountMustBeGreaterThanZero => 'Сумма должна быть больше 0';

  @override
  String get description => 'Описание';

  @override
  String get voiceLimitReached =>
      'Лимит голосового ввода исчерпан. Перейдите на Pro для безлимитного доступа';

  @override
  String get upgrade => 'Обновить';

  @override
  String get speechNotAvailable => 'Распознавание речи недоступно';

  @override
  String get pleaseEnterAccountFirst => 'Сначала выберите счёт';

  @override
  String get pleaseCreateAccountFirst => 'Сначала создайте счёт';

  @override
  String get updateTransaction => 'Обновить транзакцию';

  @override
  String get addTransaction => 'Добавить транзакцию';

  @override
  String get accounts => 'Счета';

  @override
  String get connectBank => 'Подключить банк';

  @override
  String get noAccountsYet => 'Пока нет счетов';

  @override
  String get tapPlusToAddAccount => 'Нажмите +, чтобы добавить первый счёт';

  @override
  String get editAccount => 'Редактировать счёт';

  @override
  String get newAccount => 'Новый счёт';

  @override
  String get accountName => 'Название счёта';

  @override
  String get pleaseEnterAccountName => 'Введите название счёта';

  @override
  String get accountType => 'Тип счёта';

  @override
  String get checking => 'Текущий';

  @override
  String get savings => 'Накопительный';

  @override
  String get creditCard => 'Кредитная карта';

  @override
  String get cash => 'Наличные';

  @override
  String get bankOptional => 'Банк (необязательно)';

  @override
  String get currency => 'Валюта';

  @override
  String get initialBalance => 'Начальный баланс';

  @override
  String get updateAccount => 'Обновить счёт';

  @override
  String get connectYourBank => 'Подключите ваш банковский счёт';

  @override
  String get connectBankDescription =>
      'Безопасно свяжите банк для автоматического импорта транзакций и обновления балансов.';

  @override
  String get bankLevelEncryption => 'Банковский уровень шифрования от Plaid';

  @override
  String failedToStartBankConnection(String error) {
    return 'Ошибка подключения банка: $error';
  }

  @override
  String connectionCancelled(String message) {
    return 'Подключение отменено: $message';
  }

  @override
  String successfullyLinkedAccounts(int count) {
    return 'Успешно подключено счетов: $count';
  }

  @override
  String get subscription => 'Подписка';

  @override
  String get manageSubscription => 'Управление подпиской';

  @override
  String get upgradeToPremium => 'Перейти на Premium';

  @override
  String get active => 'Активный';

  @override
  String get editProfile => 'Редактировать профиль';

  @override
  String get manageAccounts => 'Управление счетами';

  @override
  String get preferences => 'Настройки';

  @override
  String get theme => 'Тема';

  @override
  String get dark => 'Тёмная';

  @override
  String get light => 'Светлая';

  @override
  String get system => 'Системная';

  @override
  String get biometricLogin => 'Биометрический вход';

  @override
  String get language => 'Язык';

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
  String get notifications => 'Уведомления';

  @override
  String get pushNotifications => 'Push-уведомления';

  @override
  String get data => 'Данные';

  @override
  String get scanReceipt => 'Сканировать чек';

  @override
  String get importTransactions => 'Импорт транзакций';

  @override
  String get exportData => 'Экспорт данных';

  @override
  String get scheduledPayments => 'Запланированные платежи';

  @override
  String get budgets => 'Бюджеты';

  @override
  String get debts => 'Долги';

  @override
  String get about => 'О приложении';

  @override
  String get appVersion => 'Версия приложения';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get termsOfService => 'Условия использования';

  @override
  String get dangerZone => 'Опасная зона';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get logout => 'Выйти';

  @override
  String get premium => 'PREMIUM';

  @override
  String get free => 'БЕСПЛАТНО';

  @override
  String get selectCurrency => 'Выберите валюту';

  @override
  String get selectTheme => 'Выберите тему';

  @override
  String get deleteAccountConfirm =>
      'Вы уверены, что хотите удалить аккаунт? Это действие нельзя отменить. Все ваши данные будут удалены безвозвратно.';

  @override
  String get logoutConfirm => 'Вы уверены, что хотите выйти?';

  @override
  String get profileUpdated => 'Профиль обновлён';

  @override
  String get name => 'Имя';

  @override
  String get enterYourName => 'Введите ваше имя';

  @override
  String get nameIsRequired => 'Имя обязательно';

  @override
  String get saveChanges => 'Сохранить изменения';

  @override
  String get profileUpdatedSuccessfully => 'Профиль успешно обновлён';

  @override
  String get inactive => 'Неактивный';

  @override
  String get noActiveBudgets => 'Нет активных бюджетов';

  @override
  String get noInactiveBudgets => 'Нет неактивных бюджетов';

  @override
  String get tapPlusToCreateBudget => 'Нажмите +, чтобы создать первый бюджет';

  @override
  String get deleteBudget => 'Удалить бюджет';

  @override
  String deleteBudgetConfirm(String name) {
    return 'Вы уверены, что хотите удалить \"$name\"?';
  }

  @override
  String get editBudget => 'Редактировать бюджет';

  @override
  String get newBudget => 'Новый бюджет';

  @override
  String get budgetName => 'Название бюджета';

  @override
  String get pleaseEnterBudgetName => 'Введите название бюджета';

  @override
  String get budgetLimit => 'Лимит бюджета';

  @override
  String get pleaseEnterBudgetLimit => 'Введите лимит бюджета';

  @override
  String get pleaseEnterValidPositiveNumber =>
      'Введите корректное положительное число';

  @override
  String get period => 'Период';

  @override
  String get weekly => 'Еженедельно';

  @override
  String get monthly => 'Ежемесячно';

  @override
  String get yearly => 'Ежегодно';

  @override
  String get startDate => 'Дата начала';

  @override
  String get endDateOptional => 'Дата окончания (необязательно)';

  @override
  String get noEndDate => 'Без даты окончания';

  @override
  String get updateBudget => 'Обновить бюджет';

  @override
  String get createBudget => 'Создать бюджет';

  @override
  String get paidOff => 'Погашен';

  @override
  String get noActiveDebts => 'Нет активных долгов';

  @override
  String get noPaidOffDebts => 'Нет погашенных долгов';

  @override
  String get noDebts => 'Нет долгов';

  @override
  String get tapPlusToAddDebt => 'Нажмите +, чтобы добавить первый долг';

  @override
  String get editDebt => 'Редактировать долг';

  @override
  String get newDebt => 'Новый долг';

  @override
  String get debtName => 'Название долга';

  @override
  String get pleaseEnterDebtName => 'Введите название долга';

  @override
  String get debtType => 'Тип долга';

  @override
  String get personalLoan => 'Личный займ';

  @override
  String get mortgage => 'Ипотека';

  @override
  String get autoLoan => 'Автокредит';

  @override
  String get studentLoan => 'Студенческий кредит';

  @override
  String get personal => 'Личный';

  @override
  String get other => 'Другое';

  @override
  String get originalAmount => 'Первоначальная сумма';

  @override
  String get pleaseEnterOriginalAmount => 'Введите первоначальную сумму';

  @override
  String get currentBalance => 'Текущий баланс';

  @override
  String get pleaseEnterCurrentBalance => 'Введите текущий баланс';

  @override
  String get interestRate => 'Процентная ставка (%)';

  @override
  String get minimumPayment => 'Минимальный платёж';

  @override
  String get dueDay => 'День платежа (1-31)';

  @override
  String get pleaseEnterValidDay => 'Введите день от 1 до 31';

  @override
  String get creditorNameOptional => 'Кредитор (необязательно)';

  @override
  String get expectedPayoffDateOptional =>
      'Ожидаемая дата погашения (необязательно)';

  @override
  String get noDateSet => 'Дата не указана';

  @override
  String get notesOptional => 'Заметки (необязательно)';

  @override
  String get updateDebt => 'Обновить долг';

  @override
  String get addDebt => 'Добавить долг';

  @override
  String get debtDetails => 'Детали долга';

  @override
  String get original => 'Исходная';

  @override
  String get remaining => 'Остаток';

  @override
  String get interest => 'Процент';

  @override
  String get minPayment => 'Мин. платёж';

  @override
  String get start => 'Начало';

  @override
  String get expectedPayoff => 'Дата погашения';

  @override
  String get notes => 'Заметки';

  @override
  String get recordPayment => 'Записать платёж';

  @override
  String get paymentAmount => 'Сумма платежа';

  @override
  String get pleaseEnterPaymentAmount => 'Введите сумму платежа';

  @override
  String get paymentDate => 'Дата платежа';

  @override
  String get aiFinancialAdvisor => 'AI финансовый советник';

  @override
  String get oracleWelcome => 'Привет! Я Оракул, ваш AI финансовый советник.';

  @override
  String get oracleAsk => 'Спросите меня о ваших финансах.';

  @override
  String get oracleHint => 'Спросите Оракула о финансах...';

  @override
  String get markAllAsRead => 'Отметить все как прочитанные';

  @override
  String get failedToLoadNotifications => 'Не удалось загрузить уведомления';

  @override
  String get noNotificationsYet => 'Пока нет уведомлений';

  @override
  String get notificationsHint => 'Здесь будут ваши оповещения и обновления';

  @override
  String get unlockFullPower => 'Откройте полный доступ';

  @override
  String get unlockSubtitle => 'Безлимитный доступ ко всем премиум функциям';

  @override
  String get premiumIncludes => 'Premium включает:';

  @override
  String get featureUnlimitedAccounts => 'Безлимитные банковские счета';

  @override
  String get featureBankSync => 'Автосинхронизация банков через Plaid';

  @override
  String get featureReceiptScanning => 'Сканирование чеков (OCR)';

  @override
  String get featureAiPredictions => 'AI прогнозы и Оракул';

  @override
  String get featureSmartCategorization => 'Умная категоризация';

  @override
  String get featureBudgetsDebts => 'Бюджеты и учёт долгов';

  @override
  String get featureExport => 'Экспорт данных (CSV/PDF)';

  @override
  String get featureMultiCurrency => 'Мультивалютность';

  @override
  String get yearlyPrice => '34,99 \$/год';

  @override
  String get monthlyPrice => '4,99 \$/мес';

  @override
  String get lifetimePrice => '99,99 \$';

  @override
  String get yearlySaving => 'Экономия 42% — всего 2,92 \$/мес';

  @override
  String get cancelAnytime => 'Отмена в любое время';

  @override
  String get lifetimeSubtitle => 'Один платёж — навсегда';

  @override
  String get bestValue => 'ЛУЧШАЯ ЦЕНА';

  @override
  String get restorePurchases => 'Восстановить покупки';

  @override
  String get processingPurchase => 'Обработка покупки...';

  @override
  String get welcomeToPremium => 'Добро пожаловать в Premium!';

  @override
  String get noActiveScheduledPayments =>
      'Нет активных запланированных платежей';

  @override
  String get noInactiveScheduledPayments =>
      'Нет неактивных запланированных платежей';

  @override
  String get tapPlusToAddScheduledPayment =>
      'Нажмите +, чтобы добавить первый платёж';

  @override
  String get importCsv => 'Импорт CSV';

  @override
  String get importTransactionsTitle => 'Импорт транзакций';

  @override
  String get importDescription =>
      'Загрузите CSV файл для импорта транзакций на ваш счёт';

  @override
  String get selectAccount => 'Выберите счёт';

  @override
  String get chooseAnAccount => 'Выберите счёт';

  @override
  String get pickCsvFile => 'Выбрать CSV файл';

  @override
  String percentUploaded(int progress) {
    return '$progress% загружено';
  }

  @override
  String get importComplete => 'Импорт завершён!';

  @override
  String get imported => 'Импортировано';

  @override
  String get skipped => 'Пропущено';

  @override
  String get errors => 'Ошибки';

  @override
  String get importAnotherFile => 'Импортировать другой файл';

  @override
  String get uploadAndImport => 'Загрузить и импортировать';

  @override
  String get exportFormat => 'Формат экспорта';

  @override
  String get csv => 'CSV';

  @override
  String get pdf => 'PDF';

  @override
  String get dateRangeOptional => 'Период (необязательно)';

  @override
  String get endDate => 'Дата окончания';

  @override
  String get clearDates => 'Сбросить даты';

  @override
  String get csvDescription =>
      'CSV файл с колонками: Дата, Описание, Сумма, Тип, Категория, Счёт';

  @override
  String get pdfDescription => 'PDF отчёт со сводкой и таблицей транзакций';

  @override
  String exportFormat2(String format) {
    return 'Экспорт $format';
  }

  @override
  String get scanReceiptAutoFill =>
      'Сканируйте чек для\nавтозаполнения транзакции';

  @override
  String get takePhoto => 'Сделать фото';

  @override
  String get chooseFromGallery => 'Выбрать из галереи';

  @override
  String get processingReceipt => 'Обработка чека...';

  @override
  String confidencePercent(String confidence) {
    return 'Точность: $confidence%';
  }

  @override
  String get merchant => 'Продавец';

  @override
  String get pleaseFillRequiredFields => 'Заполните все обязательные поля';

  @override
  String get createTransaction => 'Создать транзакцию';

  @override
  String get scanAnotherReceipt => 'Сканировать другой чек';

  @override
  String get transactionCreatedFromReceipt => 'Транзакция создана из чека';

  @override
  String get offlineMode => 'Офлайн режим';

  @override
  String get selectLanguage => 'Выберите язык';
}
