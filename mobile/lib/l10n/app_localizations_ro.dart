// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get appTitle => 'AnticiFi';

  @override
  String get dashboard => 'Panou';

  @override
  String get transactions => 'Tranzacții';

  @override
  String get oracle => 'Oracol';

  @override
  String get settings => 'Setări';

  @override
  String get welcomeBack => 'Bine ai revenit';

  @override
  String get signInToContinue => 'Conectează-te pentru a continua';

  @override
  String get email => 'Email';

  @override
  String get password => 'Parolă';

  @override
  String get signIn => 'Conectare';

  @override
  String get dontHaveAccount => 'Nu ai cont? ';

  @override
  String get signUp => 'Înregistrare';

  @override
  String get enableBiometricTitle => 'Activezi autentificarea biometrică?';

  @override
  String get enableBiometricContent =>
      'Folosește Face ID sau Touch ID pentru acces mai rapid.';

  @override
  String get notNow => 'Nu acum';

  @override
  String get enable => 'Activează';

  @override
  String get createAccount => 'Creează cont';

  @override
  String get signUpToGetStarted => 'Înregistrează-te pentru a începe';

  @override
  String get fullName => 'Nume complet';

  @override
  String get confirmPassword => 'Confirmă parola';

  @override
  String get passwordsDoNotMatch => 'Parolele nu se potrivesc';

  @override
  String get alreadyHaveAccount => 'Ai deja un cont? ';

  @override
  String get onboardingTitle1 => 'Bine ai venit la AnticiFi';

  @override
  String get onboardingDesc1 =>
      'Asistentul tău financiar bazat pe AI care te ajută să gestionezi banii mai inteligent și să planifici viitorul.';

  @override
  String get onboardingTitle2 => 'Predicții inteligente';

  @override
  String get onboardingDesc2 =>
      'AI-ul nostru analizează tiparele de cheltuieli și prognozează cheltuielile viitoare.';

  @override
  String get onboardingTitle3 => 'Rămâi pe drumul cel bun';

  @override
  String get onboardingDesc3 =>
      'Setează bugete, gestionează datorii și primește notificări pentru a-ți menține finanțele sănătoase.';

  @override
  String get skip => 'Sari';

  @override
  String get next => 'Următorul';

  @override
  String get getStarted => 'Începe';

  @override
  String get failedToLoadDashboard => 'Nu s-a putut încărca panoul';

  @override
  String get retry => 'Reîncearcă';

  @override
  String get recentTransactions => 'Tranzacții recente';

  @override
  String get noRecentTransactions => 'Nicio tranzacție recentă';

  @override
  String get all => 'Toate';

  @override
  String get income => 'Venit';

  @override
  String get expense => 'Cheltuială';

  @override
  String get noTransactionsYet => 'Nicio tranzacție încă';

  @override
  String get tapPlusToAddTransaction =>
      'Apasă + pentru a adăuga prima tranzacție';

  @override
  String get deleteTransaction => 'Șterge tranzacția';

  @override
  String get deleteTransactionConfirm =>
      'Ești sigur că vrei să ștergi această tranzacție?';

  @override
  String get cancel => 'Anulează';

  @override
  String get delete => 'Șterge';

  @override
  String get editTransaction => 'Editează tranzacția';

  @override
  String get newTransaction => 'Tranzacție nouă';

  @override
  String get account => 'Cont';

  @override
  String get amount => 'Sumă';

  @override
  String get pleaseEnterAmount => 'Introdu suma';

  @override
  String get pleaseEnterValidNumber => 'Introdu un număr valid';

  @override
  String get amountMustBeGreaterThanZero =>
      'Suma trebuie să fie mai mare decât 0';

  @override
  String get description => 'Descriere';

  @override
  String get voiceLimitReached =>
      'Limita de input vocal atinsă. Treci la Pro pentru acces nelimitat';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get speechNotAvailable => 'Recunoașterea vocală nu este disponibilă';

  @override
  String get pleaseEnterAccountFirst => 'Selectează mai întâi contul';

  @override
  String get pleaseCreateAccountFirst => 'Creează mai întâi un cont';

  @override
  String get updateTransaction => 'Actualizează tranzacția';

  @override
  String get addTransaction => 'Adaugă tranzacție';

  @override
  String get accounts => 'Conturi';

  @override
  String get connectBank => 'Conectează banca';

  @override
  String get noAccountsYet => 'Niciun cont încă';

  @override
  String get tapPlusToAddAccount => 'Apasă + pentru a adăuga primul cont';

  @override
  String get editAccount => 'Editează contul';

  @override
  String get newAccount => 'Cont nou';

  @override
  String get accountName => 'Numele contului';

  @override
  String get pleaseEnterAccountName => 'Introdu numele contului';

  @override
  String get accountType => 'Tipul contului';

  @override
  String get checking => 'Cont curent';

  @override
  String get savings => 'Economii';

  @override
  String get creditCard => 'Card de credit';

  @override
  String get cash => 'Numerar';

  @override
  String get bankOptional => 'Bancă (opțional)';

  @override
  String get currency => 'Monedă';

  @override
  String get initialBalance => 'Sold inițial';

  @override
  String get updateAccount => 'Actualizează contul';

  @override
  String get connectYourBank => 'Conectează contul bancar';

  @override
  String get connectBankDescription =>
      'Leagă banca în siguranță pentru a importa automat tranzacțiile și a menține soldurile actualizate.';

  @override
  String get bankLevelEncryption => 'Criptare de nivel bancar prin Plaid';

  @override
  String failedToStartBankConnection(String error) {
    return 'Eroare la conectarea băncii: $error';
  }

  @override
  String connectionCancelled(String message) {
    return 'Conectare anulată: $message';
  }

  @override
  String successfullyLinkedAccounts(int count) {
    return 'S-au conectat cu succes $count cont(uri)';
  }

  @override
  String get subscription => 'Abonament';

  @override
  String get manageSubscription => 'Gestionează abonamentul';

  @override
  String get upgradeToPremium => 'Treci la Premium';

  @override
  String get active => 'Activ';

  @override
  String get editProfile => 'Editează profilul';

  @override
  String get manageAccounts => 'Gestionează conturile';

  @override
  String get preferences => 'Preferințe';

  @override
  String get theme => 'Temă';

  @override
  String get dark => 'Întunecată';

  @override
  String get light => 'Luminoasă';

  @override
  String get system => 'Sistem';

  @override
  String get biometricLogin => 'Autentificare biometrică';

  @override
  String get language => 'Limbă';

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
  String get notifications => 'Notificări';

  @override
  String get pushNotifications => 'Notificări push';

  @override
  String get data => 'Date';

  @override
  String get scanReceipt => 'Scanează chitanța';

  @override
  String get importTransactions => 'Importă tranzacții';

  @override
  String get exportData => 'Exportă date';

  @override
  String get scheduledPayments => 'Plăți programate';

  @override
  String get budgets => 'Bugete';

  @override
  String get debts => 'Datorii';

  @override
  String get about => 'Despre';

  @override
  String get appVersion => 'Versiunea aplicației';

  @override
  String get privacyPolicy => 'Politica de confidențialitate';

  @override
  String get termsOfService => 'Termeni și condiții';

  @override
  String get dangerZone => 'Zonă periculoasă';

  @override
  String get deleteAccount => 'Șterge contul';

  @override
  String get logout => 'Deconectare';

  @override
  String get premium => 'PREMIUM';

  @override
  String get free => 'GRATUIT';

  @override
  String get selectCurrency => 'Selectează moneda';

  @override
  String get selectTheme => 'Selectează tema';

  @override
  String get deleteAccountConfirm =>
      'Ești sigur că vrei să ștergi contul? Această acțiune nu poate fi anulată. Toate datele vor fi șterse permanent.';

  @override
  String get logoutConfirm => 'Ești sigur că vrei să te deconectezi?';

  @override
  String get profileUpdated => 'Profil actualizat';

  @override
  String get name => 'Nume';

  @override
  String get enterYourName => 'Introdu numele tău';

  @override
  String get nameIsRequired => 'Numele este obligatoriu';

  @override
  String get saveChanges => 'Salvează modificările';

  @override
  String get profileUpdatedSuccessfully => 'Profil actualizat cu succes';

  @override
  String get inactive => 'Inactiv';

  @override
  String get noActiveBudgets => 'Niciun buget activ';

  @override
  String get noInactiveBudgets => 'Niciun buget inactiv';

  @override
  String get tapPlusToCreateBudget => 'Apasă + pentru a crea primul buget';

  @override
  String get deleteBudget => 'Șterge bugetul';

  @override
  String deleteBudgetConfirm(String name) {
    return 'Ești sigur că vrei să ștergi \"$name\"?';
  }

  @override
  String get editBudget => 'Editează bugetul';

  @override
  String get newBudget => 'Buget nou';

  @override
  String get budgetName => 'Numele bugetului';

  @override
  String get pleaseEnterBudgetName => 'Introdu numele bugetului';

  @override
  String get budgetLimit => 'Limita bugetului';

  @override
  String get pleaseEnterBudgetLimit => 'Introdu limita bugetului';

  @override
  String get pleaseEnterValidPositiveNumber => 'Introdu un număr pozitiv valid';

  @override
  String get period => 'Perioadă';

  @override
  String get weekly => 'Săptămânal';

  @override
  String get monthly => 'Lunar';

  @override
  String get yearly => 'Anual';

  @override
  String get startDate => 'Data de început';

  @override
  String get endDateOptional => 'Data de sfârșit (opțional)';

  @override
  String get noEndDate => 'Fără dată de sfârșit';

  @override
  String get updateBudget => 'Actualizează bugetul';

  @override
  String get createBudget => 'Creează buget';

  @override
  String get paidOff => 'Achitat';

  @override
  String get noActiveDebts => 'Nicio datorie activă';

  @override
  String get noPaidOffDebts => 'Nicio datorie achitată';

  @override
  String get noDebts => 'Nicio datorie';

  @override
  String get tapPlusToAddDebt => 'Apasă + pentru a adăuga prima datorie';

  @override
  String get editDebt => 'Editează datoria';

  @override
  String get newDebt => 'Datorie nouă';

  @override
  String get debtName => 'Numele datoriei';

  @override
  String get pleaseEnterDebtName => 'Introdu numele datoriei';

  @override
  String get debtType => 'Tipul datoriei';

  @override
  String get personalLoan => 'Împrumut personal';

  @override
  String get mortgage => 'Ipotecă';

  @override
  String get autoLoan => 'Credit auto';

  @override
  String get studentLoan => 'Credit studențesc';

  @override
  String get personal => 'Personal';

  @override
  String get other => 'Altele';

  @override
  String get originalAmount => 'Suma inițială';

  @override
  String get pleaseEnterOriginalAmount => 'Introdu suma inițială';

  @override
  String get currentBalance => 'Sold curent';

  @override
  String get pleaseEnterCurrentBalance => 'Introdu soldul curent';

  @override
  String get interestRate => 'Rata dobânzii (%)';

  @override
  String get minimumPayment => 'Plata minimă';

  @override
  String get dueDay => 'Ziua scadentă (1-31)';

  @override
  String get pleaseEnterValidDay => 'Introdu o zi între 1 și 31';

  @override
  String get creditorNameOptional => 'Numele creditorului (opțional)';

  @override
  String get expectedPayoffDateOptional =>
      'Data estimată de achitare (opțional)';

  @override
  String get noDateSet => 'Nicio dată setată';

  @override
  String get notesOptional => 'Note (opțional)';

  @override
  String get updateDebt => 'Actualizează datoria';

  @override
  String get addDebt => 'Adaugă datorie';

  @override
  String get debtDetails => 'Detalii datorie';

  @override
  String get original => 'Inițială';

  @override
  String get remaining => 'Rămas';

  @override
  String get interest => 'Dobândă';

  @override
  String get minPayment => 'Plata min.';

  @override
  String get start => 'Început';

  @override
  String get expectedPayoff => 'Achitare estimată';

  @override
  String get notes => 'Note';

  @override
  String get recordPayment => 'Înregistrează plata';

  @override
  String get paymentAmount => 'Suma plății';

  @override
  String get pleaseEnterPaymentAmount => 'Introdu suma plății';

  @override
  String get paymentDate => 'Data plății';

  @override
  String get aiFinancialAdvisor => 'Consilier financiar AI';

  @override
  String get oracleWelcome =>
      'Salut! Sunt Oracolul, consilierul tău financiar AI.';

  @override
  String get oracleAsk => 'Întreabă-mă orice despre finanțele tale.';

  @override
  String get oracleHint => 'Întreabă Oracolul despre finanțe...';

  @override
  String get markAllAsRead => 'Marchează toate ca citite';

  @override
  String get failedToLoadNotifications => 'Nu s-au putut încărca notificările';

  @override
  String get noNotificationsYet => 'Nicio notificare încă';

  @override
  String get notificationsHint => 'Aici vei vedea alertele și actualizările';

  @override
  String get unlockFullPower => 'Deblochează puterea completă';

  @override
  String get unlockSubtitle => 'Acces nelimitat la toate funcțiile premium';

  @override
  String get premiumIncludes => 'Premium include:';

  @override
  String get featureUnlimitedAccounts => 'Conturi bancare nelimitate';

  @override
  String get featureBankSync => 'Sincronizare automată cu banca prin Plaid';

  @override
  String get featureReceiptScanning => 'Scanare chitanțe (OCR)';

  @override
  String get featureAiPredictions => 'Predicții AI și Oracol';

  @override
  String get featureSmartCategorization => 'Categorizare inteligentă';

  @override
  String get featureBudgetsDebts => 'Bugete și urmărirea datoriilor';

  @override
  String get featureExport => 'Export date (CSV/PDF)';

  @override
  String get featureMultiCurrency => 'Suport multi-monedă';

  @override
  String get yearlyPrice => '\$34.99/an';

  @override
  String get monthlyPrice => '\$4.99/lună';

  @override
  String get lifetimePrice => '\$99.99';

  @override
  String get yearlySaving => 'Economisești 42% — doar \$2.92/lună';

  @override
  String get cancelAnytime => 'Anulează oricând';

  @override
  String get lifetimeSubtitle => 'O singură plată, pentru totdeauna';

  @override
  String get bestValue => 'CEA MAI BUNĂ VALOARE';

  @override
  String get restorePurchases => 'Restaurează achizițiile';

  @override
  String get processingPurchase => 'Se procesează achiziția...';

  @override
  String get welcomeToPremium => 'Bine ai venit la Premium!';

  @override
  String get noActiveScheduledPayments => 'Nicio plată programată activă';

  @override
  String get noInactiveScheduledPayments => 'Nicio plată programată inactivă';

  @override
  String get tapPlusToAddScheduledPayment =>
      'Apasă + pentru a adăuga prima plată programată';

  @override
  String get importCsv => 'Import CSV';

  @override
  String get importTransactionsTitle => 'Importă tranzacții';

  @override
  String get importDescription =>
      'Încarcă un fișier CSV pentru a importa tranzacții în contul tău';

  @override
  String get selectAccount => 'Selectează contul';

  @override
  String get chooseAnAccount => 'Alege un cont';

  @override
  String get pickCsvFile => 'Alege fișier CSV';

  @override
  String percentUploaded(int progress) {
    return '$progress% încărcat';
  }

  @override
  String get importComplete => 'Import complet!';

  @override
  String get imported => 'Importate';

  @override
  String get skipped => 'Sărite';

  @override
  String get errors => 'Erori';

  @override
  String get importAnotherFile => 'Importă alt fișier';

  @override
  String get uploadAndImport => 'Încarcă și importă';

  @override
  String get exportFormat => 'Format export';

  @override
  String get csv => 'CSV';

  @override
  String get pdf => 'PDF';

  @override
  String get dateRangeOptional => 'Interval de date (opțional)';

  @override
  String get endDate => 'Data de sfârșit';

  @override
  String get clearDates => 'Șterge datele';

  @override
  String get csvDescription =>
      'Fișier CSV cu coloane: Dată, Descriere, Sumă, Tip, Categorie, Cont';

  @override
  String get pdfDescription => 'Raport PDF cu rezumat și tabel de tranzacții';

  @override
  String exportFormat2(String format) {
    return 'Exportă $format';
  }

  @override
  String get scanReceiptAutoFill =>
      'Scanează o chitanță pentru a completa\nautomat detaliile tranzacției';

  @override
  String get takePhoto => 'Fă o poză';

  @override
  String get chooseFromGallery => 'Alege din galerie';

  @override
  String get processingReceipt => 'Se procesează chitanța...';

  @override
  String confidencePercent(String confidence) {
    return 'Încredere: $confidence%';
  }

  @override
  String get merchant => 'Comerciant';

  @override
  String get pleaseFillRequiredFields =>
      'Completează toate câmpurile obligatorii';

  @override
  String get createTransaction => 'Creează tranzacție';

  @override
  String get scanAnotherReceipt => 'Scanează altă chitanță';

  @override
  String get transactionCreatedFromReceipt => 'Tranzacție creată din chitanță';

  @override
  String get offlineMode => 'Mod offline';

  @override
  String get selectLanguage => 'Selectează limba';

  @override
  String get totalBalance => 'Sold total';

  @override
  String get spendingByCategory => 'Cheltuieli pe categorii';

  @override
  String get noSpendingDataYet => 'Nu există date despre cheltuieli încă';

  @override
  String get pleaseSelectAccount => 'Te rugăm să selectezi un cont';

  @override
  String get editScheduledPayment => 'Editează plata programată';

  @override
  String get newScheduledPayment => 'Plată programată nouă';

  @override
  String get paymentName => 'Numele plății';

  @override
  String get pleaseEnterPaymentName => 'Introdu numele plății';

  @override
  String get frequency => 'Frecvență';

  @override
  String get descriptionOptional => 'Descriere (opțional)';

  @override
  String get updatePayment => 'Actualizează plata';

  @override
  String get createPayment => 'Creează plată';

  @override
  String get deleteScheduledPayment => 'Șterge plata programată';

  @override
  String get executePayment => 'Execută plata';

  @override
  String executePaymentConfirm(String name) {
    return 'Executați \"$name\" acum?';
  }

  @override
  String get execute => 'Execută';

  @override
  String get receiptHistory => 'Istoric chitanțe';

  @override
  String get noReceiptScansYet => 'Nu există scanări de chitanțe încă';

  @override
  String get scanReceiptToGetStarted => 'Scanează o chitanță pentru a începe';

  @override
  String get addAccount => 'Adaugă cont';

  @override
  String get noCategory => 'Fără categorie';

  @override
  String get category => 'Categorie';

  @override
  String get vsLastMonth => 'față de luna trecută';
}
