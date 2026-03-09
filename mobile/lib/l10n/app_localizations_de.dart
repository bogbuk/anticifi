// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'AnticiFi';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get transactions => 'Transaktionen';

  @override
  String get oracle => 'Orakel';

  @override
  String get settings => 'Einstellungen';

  @override
  String get welcomeBack => 'Willkommen zurück';

  @override
  String get signInToContinue => 'Melde dich an, um fortzufahren';

  @override
  String get email => 'E-Mail';

  @override
  String get password => 'Passwort';

  @override
  String get signIn => 'Anmelden';

  @override
  String get dontHaveAccount => 'Kein Konto? ';

  @override
  String get signUp => 'Registrieren';

  @override
  String get enableBiometricTitle => 'Biometrische Anmeldung aktivieren?';

  @override
  String get enableBiometricContent =>
      'Verwende Face ID oder Touch ID für schnelleren Zugang.';

  @override
  String get notNow => 'Nicht jetzt';

  @override
  String get enable => 'Aktivieren';

  @override
  String get createAccount => 'Konto erstellen';

  @override
  String get signUpToGetStarted => 'Registriere dich, um loszulegen';

  @override
  String get fullName => 'Vollständiger Name';

  @override
  String get confirmPassword => 'Passwort bestätigen';

  @override
  String get passwordsDoNotMatch => 'Passwörter stimmen nicht überein';

  @override
  String get alreadyHaveAccount => 'Bereits ein Konto? ';

  @override
  String get onboardingTitle1 => 'Willkommen bei AnticiFi';

  @override
  String get onboardingDesc1 =>
      'Dein KI-gestützter Finanzassistent, der dir hilft, Geld klüger zu verwalten und die Zukunft zu planen.';

  @override
  String get onboardingTitle2 => 'Intelligente Vorhersagen';

  @override
  String get onboardingDesc2 =>
      'Unsere KI analysiert deine Ausgabenmuster und prognostiziert kommende Ausgaben.';

  @override
  String get onboardingTitle3 => 'Bleib auf Kurs';

  @override
  String get onboardingDesc3 =>
      'Setze Budgets, verwalte Schulden und erhalte rechtzeitige Benachrichtigungen für gesunde Finanzen.';

  @override
  String get skip => 'Überspringen';

  @override
  String get next => 'Weiter';

  @override
  String get getStarted => 'Loslegen';

  @override
  String get failedToLoadDashboard => 'Dashboard konnte nicht geladen werden';

  @override
  String get failedToLoadAccounts => 'Konten konnten nicht geladen werden';

  @override
  String get retry => 'Wiederholen';

  @override
  String get recentTransactions => 'Letzte Transaktionen';

  @override
  String get noRecentTransactions => 'Keine aktuellen Transaktionen';

  @override
  String get all => 'Alle';

  @override
  String get income => 'Einnahme';

  @override
  String get expense => 'Ausgabe';

  @override
  String get noTransactionsYet => 'Noch keine Transaktionen';

  @override
  String get tapPlusToAddTransaction =>
      'Tippe auf +, um deine erste Transaktion hinzuzufügen';

  @override
  String get deleteTransaction => 'Transaktion löschen';

  @override
  String get deleteTransactionConfirm =>
      'Bist du sicher, dass du diese Transaktion löschen möchtest?';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get editTransaction => 'Transaktion bearbeiten';

  @override
  String get newTransaction => 'Neue Transaktion';

  @override
  String get account => 'Konto';

  @override
  String get amount => 'Betrag';

  @override
  String get pleaseEnterAmount => 'Bitte Betrag eingeben';

  @override
  String get pleaseEnterValidNumber => 'Bitte eine gültige Zahl eingeben';

  @override
  String get amountMustBeGreaterThanZero => 'Der Betrag muss größer als 0 sein';

  @override
  String get description => 'Beschreibung';

  @override
  String get voiceLimitReached =>
      'Spracheingabelimit erreicht. Upgrade auf Pro für unbegrenzten Zugang';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get speechNotAvailable => 'Spracherkennung ist nicht verfügbar';

  @override
  String get pleaseEnterAccountFirst => 'Bitte zuerst ein Konto auswählen';

  @override
  String get pleaseCreateAccountFirst => 'Bitte zuerst ein Konto erstellen';

  @override
  String get updateTransaction => 'Transaktion aktualisieren';

  @override
  String get addTransaction => 'Transaktion hinzufügen';

  @override
  String get accounts => 'Konten';

  @override
  String get connectBank => 'Bank verbinden';

  @override
  String get noAccountsYet => 'Noch keine Konten';

  @override
  String get tapPlusToAddAccount =>
      'Tippe auf +, um dein erstes Konto hinzuzufügen';

  @override
  String get editAccount => 'Konto bearbeiten';

  @override
  String get newAccount => 'Neues Konto';

  @override
  String get accountName => 'Kontoname';

  @override
  String get pleaseEnterAccountName => 'Bitte Kontonamen eingeben';

  @override
  String get accountType => 'Kontotyp';

  @override
  String get checking => 'Girokonto';

  @override
  String get savings => 'Sparkonto';

  @override
  String get creditCard => 'Kreditkarte';

  @override
  String get cash => 'Bargeld';

  @override
  String get bankOptional => 'Bank (optional)';

  @override
  String get currency => 'Währung';

  @override
  String get initialBalance => 'Anfangssaldo';

  @override
  String get updateAccount => 'Konto aktualisieren';

  @override
  String get connectYourBank => 'Verbinde dein Bankkonto';

  @override
  String get connectBankDescription =>
      'Verknüpfe deine Bank sicher, um Transaktionen automatisch zu importieren und Salden aktuell zu halten.';

  @override
  String get bankLevelEncryption => 'Bankverschlüsselung durch Plaid';

  @override
  String failedToStartBankConnection(String error) {
    return 'Bankverbindung fehlgeschlagen: $error';
  }

  @override
  String connectionCancelled(String message) {
    return 'Verbindung abgebrochen: $message';
  }

  @override
  String successfullyLinkedAccounts(int count) {
    return '$count Konto(en) erfolgreich verbunden';
  }

  @override
  String get subscription => 'Abonnement';

  @override
  String get manageSubscription => 'Abonnement verwalten';

  @override
  String get upgradeToPremium => 'Auf Premium upgraden';

  @override
  String get active => 'Aktiv';

  @override
  String get editProfile => 'Profil bearbeiten';

  @override
  String get manageAccounts => 'Konten verwalten';

  @override
  String get preferences => 'Einstellungen';

  @override
  String get theme => 'Design';

  @override
  String get dark => 'Dunkel';

  @override
  String get light => 'Hell';

  @override
  String get system => 'System';

  @override
  String get biometricLogin => 'Biometrische Anmeldung';

  @override
  String get language => 'Sprache';

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
  String get notifications => 'Benachrichtigungen';

  @override
  String get pushNotifications => 'Push-Benachrichtigungen';

  @override
  String get data => 'Daten';

  @override
  String get scanReceipt => 'Beleg scannen';

  @override
  String get importTransactions => 'Transaktionen importieren';

  @override
  String get exportData => 'Daten exportieren';

  @override
  String get scheduledPayments => 'Geplante Zahlungen';

  @override
  String get budgets => 'Budgets';

  @override
  String get debts => 'Schulden';

  @override
  String get about => 'Über';

  @override
  String get appVersion => 'App-Version';

  @override
  String get privacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get termsOfService => 'Nutzungsbedingungen';

  @override
  String get dangerZone => 'Gefahrenzone';

  @override
  String get deleteAccount => 'Konto löschen';

  @override
  String get logout => 'Abmelden';

  @override
  String get premium => 'PREMIUM';

  @override
  String get free => 'KOSTENLOS';

  @override
  String get selectCurrency => 'Währung auswählen';

  @override
  String get selectTheme => 'Design auswählen';

  @override
  String get deleteAccountConfirm =>
      'Bist du sicher, dass du dein Konto löschen möchtest? Diese Aktion kann nicht rückgängig gemacht werden. Alle Daten werden dauerhaft gelöscht.';

  @override
  String get logoutConfirm => 'Bist du sicher, dass du dich abmelden möchtest?';

  @override
  String get profileUpdated => 'Profil aktualisiert';

  @override
  String get name => 'Name';

  @override
  String get enterYourName => 'Gib deinen Namen ein';

  @override
  String get nameIsRequired => 'Name ist erforderlich';

  @override
  String get saveChanges => 'Änderungen speichern';

  @override
  String get profileUpdatedSuccessfully => 'Profil erfolgreich aktualisiert';

  @override
  String get inactive => 'Inaktiv';

  @override
  String get noActiveBudgets => 'Keine aktiven Budgets';

  @override
  String get noInactiveBudgets => 'Keine inaktiven Budgets';

  @override
  String get tapPlusToCreateBudget =>
      'Tippe auf +, um dein erstes Budget zu erstellen';

  @override
  String get deleteBudget => 'Budget löschen';

  @override
  String deleteBudgetConfirm(String name) {
    return 'Bist du sicher, dass du \"$name\" löschen möchtest?';
  }

  @override
  String get editBudget => 'Budget bearbeiten';

  @override
  String get newBudget => 'Neues Budget';

  @override
  String get budgetName => 'Budgetname';

  @override
  String get pleaseEnterBudgetName => 'Bitte Budgetnamen eingeben';

  @override
  String get budgetLimit => 'Budgetlimit';

  @override
  String get pleaseEnterBudgetLimit => 'Bitte Budgetlimit eingeben';

  @override
  String get pleaseEnterValidPositiveNumber =>
      'Bitte eine gültige positive Zahl eingeben';

  @override
  String get period => 'Zeitraum';

  @override
  String get weekly => 'Wöchentlich';

  @override
  String get monthly => 'Monatlich';

  @override
  String get yearly => 'Jährlich';

  @override
  String get startDate => 'Startdatum';

  @override
  String get endDateOptional => 'Enddatum (optional)';

  @override
  String get noEndDate => 'Kein Enddatum';

  @override
  String get updateBudget => 'Budget aktualisieren';

  @override
  String get createBudget => 'Budget erstellen';

  @override
  String get paidOff => 'Abbezahlt';

  @override
  String get noActiveDebts => 'Keine aktiven Schulden';

  @override
  String get noPaidOffDebts => 'Keine abbezahlten Schulden';

  @override
  String get noDebts => 'Keine Schulden';

  @override
  String get tapPlusToAddDebt =>
      'Tippe auf +, um deine erste Schuld hinzuzufügen';

  @override
  String get editDebt => 'Schuld bearbeiten';

  @override
  String get newDebt => 'Neue Schuld';

  @override
  String get debtName => 'Schuldname';

  @override
  String get pleaseEnterDebtName => 'Bitte Schuldnamen eingeben';

  @override
  String get debtType => 'Schuldtyp';

  @override
  String get personalLoan => 'Privatkredit';

  @override
  String get mortgage => 'Hypothek';

  @override
  String get autoLoan => 'Autokredit';

  @override
  String get studentLoan => 'Studienkredit';

  @override
  String get personal => 'Persönlich';

  @override
  String get other => 'Sonstiges';

  @override
  String get originalAmount => 'Ursprünglicher Betrag';

  @override
  String get pleaseEnterOriginalAmount =>
      'Bitte ursprünglichen Betrag eingeben';

  @override
  String get currentBalance => 'Aktueller Saldo';

  @override
  String get pleaseEnterCurrentBalance => 'Bitte aktuellen Saldo eingeben';

  @override
  String get interestRate => 'Zinssatz (%)';

  @override
  String get minimumPayment => 'Mindestzahlung';

  @override
  String get dueDay => 'Fälligkeitstag (1-31)';

  @override
  String get pleaseEnterValidDay =>
      'Bitte einen Tag zwischen 1 und 31 eingeben';

  @override
  String get creditorNameOptional => 'Gläubigername (optional)';

  @override
  String get expectedPayoffDateOptional =>
      'Voraussichtliches Tilgungsdatum (optional)';

  @override
  String get noDateSet => 'Kein Datum festgelegt';

  @override
  String get notesOptional => 'Notizen (optional)';

  @override
  String get updateDebt => 'Schuld aktualisieren';

  @override
  String get addDebt => 'Schuld hinzufügen';

  @override
  String get debtDetails => 'Schulddetails';

  @override
  String get original => 'Original';

  @override
  String get remaining => 'Verbleibend';

  @override
  String get interest => 'Zinsen';

  @override
  String get minPayment => 'Min. Zahlung';

  @override
  String get start => 'Start';

  @override
  String get expectedPayoff => 'Voraussichtliche Tilgung';

  @override
  String get notes => 'Notizen';

  @override
  String get recordPayment => 'Zahlung erfassen';

  @override
  String get paymentAmount => 'Zahlungsbetrag';

  @override
  String get pleaseEnterPaymentAmount => 'Bitte Zahlungsbetrag eingeben';

  @override
  String get paymentDate => 'Zahlungsdatum';

  @override
  String get aiFinancialAdvisor => 'KI-Finanzberater';

  @override
  String get oracleWelcome => 'Hallo! Ich bin Orakel, dein KI-Finanzberater.';

  @override
  String get oracleAsk => 'Frag mich alles über deine Finanzen.';

  @override
  String get oracleHint => 'Frag Orakel zu deinen Finanzen...';

  @override
  String get markAllAsRead => 'Alle als gelesen markieren';

  @override
  String get failedToLoadNotifications =>
      'Benachrichtigungen konnten nicht geladen werden';

  @override
  String get noNotificationsYet => 'Noch keine Benachrichtigungen';

  @override
  String get notificationsHint => 'Hier siehst du deine Warnungen und Updates';

  @override
  String get unlockFullPower => 'Volle Leistung freischalten';

  @override
  String get unlockSubtitle =>
      'Unbegrenzter Zugang zu allen Premium-Funktionen';

  @override
  String get premiumIncludes => 'Premium beinhaltet:';

  @override
  String get featureUnlimitedAccounts => 'Unbegrenzte Bankkonten';

  @override
  String get featureBankSync => 'Automatische Banksynchronisation mit Plaid';

  @override
  String get featureReceiptScanning => 'Belegscanning (OCR)';

  @override
  String get featureAiPredictions => 'KI-Vorhersagen & Orakel';

  @override
  String get featureSmartCategorization => 'Intelligente Kategorisierung';

  @override
  String get featureBudgetsDebts => 'Budgets & Schuldenverfolgung';

  @override
  String get featureExport => 'Datenexport (CSV/PDF)';

  @override
  String get featureMultiCurrency => 'Multi-Währungs-Unterstützung';

  @override
  String get yearlyPrice => '34,99 \$/Jahr';

  @override
  String get monthlyPrice => '4,99 \$/Monat';

  @override
  String get lifetimePrice => '99,99 \$';

  @override
  String get yearlySaving => 'Spare 42% — nur 2,92 \$/Monat';

  @override
  String get cancelAnytime => 'Jederzeit kündbar';

  @override
  String get lifetimeSubtitle => 'Einmalzahlung, für immer deins';

  @override
  String get bestValue => 'BESTES ANGEBOT';

  @override
  String get restorePurchases => 'Käufe wiederherstellen';

  @override
  String get processingPurchase => 'Kauf wird verarbeitet...';

  @override
  String get welcomeToPremium => 'Willkommen bei Premium!';

  @override
  String get noActiveScheduledPayments => 'Keine aktiven geplanten Zahlungen';

  @override
  String get noInactiveScheduledPayments =>
      'Keine inaktiven geplanten Zahlungen';

  @override
  String get tapPlusToAddScheduledPayment =>
      'Tippe auf +, um deine erste geplante Zahlung hinzuzufügen';

  @override
  String get importCsv => 'CSV importieren';

  @override
  String get importTransactionsTitle => 'Transaktionen importieren';

  @override
  String get importDescription =>
      'Lade eine CSV-Datei hoch, um Transaktionen in dein Konto zu importieren';

  @override
  String get selectAccount => 'Konto auswählen';

  @override
  String get chooseAnAccount => 'Wähle ein Konto';

  @override
  String get pickCsvFile => 'CSV-Datei auswählen';

  @override
  String percentUploaded(int progress) {
    return '$progress% hochgeladen';
  }

  @override
  String get importComplete => 'Import abgeschlossen!';

  @override
  String get imported => 'Importiert';

  @override
  String get skipped => 'Übersprungen';

  @override
  String get errors => 'Fehler';

  @override
  String get importAnotherFile => 'Weitere Datei importieren';

  @override
  String get uploadAndImport => 'Hochladen und importieren';

  @override
  String get exportFormat => 'Exportformat';

  @override
  String get csv => 'CSV';

  @override
  String get pdf => 'PDF';

  @override
  String get dateRangeOptional => 'Zeitraum (optional)';

  @override
  String get endDate => 'Enddatum';

  @override
  String get clearDates => 'Daten löschen';

  @override
  String get csvDescription =>
      'CSV-Datei mit Spalten: Datum, Beschreibung, Betrag, Typ, Kategorie, Konto';

  @override
  String get pdfDescription =>
      'PDF-Bericht mit Zusammenfassung und Transaktionstabelle';

  @override
  String exportFormat2(String format) {
    return '$format exportieren';
  }

  @override
  String get scanReceiptAutoFill =>
      'Scanne einen Beleg, um die\nTransaktionsdetails automatisch auszufüllen';

  @override
  String get takePhoto => 'Foto aufnehmen';

  @override
  String get chooseFromGallery => 'Aus Galerie wählen';

  @override
  String get processingReceipt => 'Beleg wird verarbeitet...';

  @override
  String confidencePercent(String confidence) {
    return 'Konfidenz: $confidence%';
  }

  @override
  String get merchant => 'Händler';

  @override
  String get pleaseFillRequiredFields => 'Bitte alle Pflichtfelder ausfüllen';

  @override
  String get createTransaction => 'Transaktion erstellen';

  @override
  String get scanAnotherReceipt => 'Weiteren Beleg scannen';

  @override
  String get transactionCreatedFromReceipt => 'Transaktion aus Beleg erstellt';

  @override
  String get offlineMode => 'Offlinemodus';

  @override
  String get selectLanguage => 'Sprache auswählen';

  @override
  String get totalBalance => 'Gesamtsaldo';

  @override
  String get spendingByCategory => 'Ausgaben nach Kategorie';

  @override
  String get noSpendingDataYet => 'Noch keine Ausgabendaten';

  @override
  String get pleaseSelectAccount => 'Bitte wähle ein Konto aus';

  @override
  String get editScheduledPayment => 'Geplante Zahlung bearbeiten';

  @override
  String get newScheduledPayment => 'Neue geplante Zahlung';

  @override
  String get paymentName => 'Zahlungsname';

  @override
  String get pleaseEnterPaymentName => 'Bitte Zahlungsnamen eingeben';

  @override
  String get frequency => 'Häufigkeit';

  @override
  String get descriptionOptional => 'Beschreibung (optional)';

  @override
  String get updatePayment => 'Zahlung aktualisieren';

  @override
  String get createPayment => 'Zahlung erstellen';

  @override
  String get deleteScheduledPayment => 'Geplante Zahlung löschen';

  @override
  String get executePayment => 'Zahlung ausführen';

  @override
  String executePaymentConfirm(String name) {
    return '\"$name\" jetzt ausführen?';
  }

  @override
  String get execute => 'Ausführen';

  @override
  String get receiptHistory => 'Belegverlauf';

  @override
  String get noReceiptScansYet => 'Noch keine Belege gescannt';

  @override
  String get scanReceiptToGetStarted => 'Scanne einen Beleg, um zu beginnen';

  @override
  String get addAccount => 'Konto hinzufügen';

  @override
  String get noCategory => 'Keine Kategorie';

  @override
  String get category => 'Kategorie';

  @override
  String get vsLastMonth => 'im Vergleich zum Vormonat';

  @override
  String get receiptDetails => 'Belegdetails';

  @override
  String get scanInfo => 'Scan-Informationen';

  @override
  String get filename => 'Dateiname';

  @override
  String get scannedOn => 'Gescannt am';

  @override
  String get receiptData => 'Belegdaten';

  @override
  String get totalAmount => 'Gesamtbetrag';

  @override
  String get receiptDate => 'Belegdatum';

  @override
  String get confidence => 'Zuverlässigkeit';

  @override
  String get completed => 'Abgeschlossen';

  @override
  String get failed => 'Fehlgeschlagen';

  @override
  String get processing => 'Verarbeitung';

  @override
  String get items => 'Artikel';
}
