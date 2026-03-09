// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'AnticiFi';

  @override
  String get dashboard => 'Pannello';

  @override
  String get transactions => 'Transazioni';

  @override
  String get oracle => 'Oracolo';

  @override
  String get settings => 'Impostazioni';

  @override
  String get welcomeBack => 'Bentornato';

  @override
  String get signInToContinue => 'Accedi per continuare';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Accedi';

  @override
  String get dontHaveAccount => 'Non hai un account? ';

  @override
  String get signUp => 'Registrati';

  @override
  String get enableBiometricTitle => 'Attivare il login biometrico?';

  @override
  String get enableBiometricContent =>
      'Usa Face ID o Touch ID per un accesso più rapido.';

  @override
  String get notNow => 'Non ora';

  @override
  String get enable => 'Attiva';

  @override
  String get createAccount => 'Crea account';

  @override
  String get signUpToGetStarted => 'Registrati per iniziare';

  @override
  String get fullName => 'Nome completo';

  @override
  String get confirmPassword => 'Conferma password';

  @override
  String get passwordsDoNotMatch => 'Le password non corrispondono';

  @override
  String get alreadyHaveAccount => 'Hai già un account? ';

  @override
  String get onboardingTitle1 => 'Benvenuto su AnticiFi';

  @override
  String get onboardingDesc1 =>
      'Il tuo assistente finanziario IA che ti aiuta a gestire il denaro in modo più intelligente e a pianificare il futuro.';

  @override
  String get onboardingTitle2 => 'Previsioni intelligenti';

  @override
  String get onboardingDesc2 =>
      'La nostra IA analizza i tuoi modelli di spesa e prevede le spese future.';

  @override
  String get onboardingTitle3 => 'Resta in carreggiata';

  @override
  String get onboardingDesc3 =>
      'Imposta budget, gestisci debiti e ricevi notifiche per mantenere le tue finanze in salute.';

  @override
  String get skip => 'Salta';

  @override
  String get next => 'Avanti';

  @override
  String get getStarted => 'Inizia';

  @override
  String get failedToLoadDashboard => 'Impossibile caricare il pannello';

  @override
  String get retry => 'Riprova';

  @override
  String get recentTransactions => 'Transazioni recenti';

  @override
  String get noRecentTransactions => 'Nessuna transazione recente';

  @override
  String get all => 'Tutte';

  @override
  String get income => 'Entrata';

  @override
  String get expense => 'Spesa';

  @override
  String get noTransactionsYet => 'Nessuna transazione ancora';

  @override
  String get tapPlusToAddTransaction =>
      'Tocca + per aggiungere la tua prima transazione';

  @override
  String get deleteTransaction => 'Elimina transazione';

  @override
  String get deleteTransactionConfirm =>
      'Sei sicuro di voler eliminare questa transazione?';

  @override
  String get cancel => 'Annulla';

  @override
  String get delete => 'Elimina';

  @override
  String get editTransaction => 'Modifica transazione';

  @override
  String get newTransaction => 'Nuova transazione';

  @override
  String get account => 'Conto';

  @override
  String get amount => 'Importo';

  @override
  String get pleaseEnterAmount => 'Inserisci l\'importo';

  @override
  String get pleaseEnterValidNumber => 'Inserisci un numero valido';

  @override
  String get amountMustBeGreaterThanZero =>
      'L\'importo deve essere maggiore di 0';

  @override
  String get description => 'Descrizione';

  @override
  String get voiceLimitReached =>
      'Limite input vocale raggiunto. Passa a Pro per accesso illimitato';

  @override
  String get upgrade => 'Aggiorna';

  @override
  String get speechNotAvailable => 'Riconoscimento vocale non disponibile';

  @override
  String get pleaseEnterAccountFirst => 'Prima seleziona un conto';

  @override
  String get pleaseCreateAccountFirst => 'Prima crea un conto';

  @override
  String get updateTransaction => 'Aggiorna transazione';

  @override
  String get addTransaction => 'Aggiungi transazione';

  @override
  String get accounts => 'Conti';

  @override
  String get connectBank => 'Collega banca';

  @override
  String get noAccountsYet => 'Nessun conto ancora';

  @override
  String get tapPlusToAddAccount => 'Tocca + per aggiungere il tuo primo conto';

  @override
  String get editAccount => 'Modifica conto';

  @override
  String get newAccount => 'Nuovo conto';

  @override
  String get accountName => 'Nome del conto';

  @override
  String get pleaseEnterAccountName => 'Inserisci il nome del conto';

  @override
  String get accountType => 'Tipo di conto';

  @override
  String get checking => 'Corrente';

  @override
  String get savings => 'Risparmio';

  @override
  String get creditCard => 'Carta di credito';

  @override
  String get cash => 'Contanti';

  @override
  String get bankOptional => 'Banca (opzionale)';

  @override
  String get currency => 'Valuta';

  @override
  String get initialBalance => 'Saldo iniziale';

  @override
  String get updateAccount => 'Aggiorna conto';

  @override
  String get connectYourBank => 'Collega il tuo conto bancario';

  @override
  String get connectBankDescription =>
      'Collega la tua banca in sicurezza per importare automaticamente le transazioni e mantenere i saldi aggiornati.';

  @override
  String get bankLevelEncryption =>
      'Crittografia di livello bancario tramite Plaid';

  @override
  String failedToStartBankConnection(String error) {
    return 'Errore di connessione bancaria: $error';
  }

  @override
  String connectionCancelled(String message) {
    return 'Connessione annullata: $message';
  }

  @override
  String successfullyLinkedAccounts(int count) {
    return '$count conto/i collegato/i con successo';
  }

  @override
  String get subscription => 'Abbonamento';

  @override
  String get manageSubscription => 'Gestisci abbonamento';

  @override
  String get upgradeToPremium => 'Passa a Premium';

  @override
  String get active => 'Attivo';

  @override
  String get editProfile => 'Modifica profilo';

  @override
  String get manageAccounts => 'Gestisci conti';

  @override
  String get preferences => 'Preferenze';

  @override
  String get theme => 'Tema';

  @override
  String get dark => 'Scuro';

  @override
  String get light => 'Chiaro';

  @override
  String get system => 'Sistema';

  @override
  String get biometricLogin => 'Login biometrico';

  @override
  String get language => 'Lingua';

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
  String get notifications => 'Notifiche';

  @override
  String get pushNotifications => 'Notifiche push';

  @override
  String get data => 'Dati';

  @override
  String get scanReceipt => 'Scansiona scontrino';

  @override
  String get importTransactions => 'Importa transazioni';

  @override
  String get exportData => 'Esporta dati';

  @override
  String get scheduledPayments => 'Pagamenti programmati';

  @override
  String get budgets => 'Budget';

  @override
  String get debts => 'Debiti';

  @override
  String get about => 'Info';

  @override
  String get appVersion => 'Versione app';

  @override
  String get privacyPolicy => 'Informativa sulla privacy';

  @override
  String get termsOfService => 'Termini di servizio';

  @override
  String get dangerZone => 'Zona pericolosa';

  @override
  String get deleteAccount => 'Elimina account';

  @override
  String get logout => 'Esci';

  @override
  String get premium => 'PREMIUM';

  @override
  String get free => 'GRATIS';

  @override
  String get selectCurrency => 'Seleziona valuta';

  @override
  String get selectTheme => 'Seleziona tema';

  @override
  String get deleteAccountConfirm =>
      'Sei sicuro di voler eliminare il tuo account? Questa azione non può essere annullata. Tutti i tuoi dati saranno eliminati definitivamente.';

  @override
  String get logoutConfirm => 'Sei sicuro di voler uscire?';

  @override
  String get profileUpdated => 'Profilo aggiornato';

  @override
  String get name => 'Nome';

  @override
  String get enterYourName => 'Inserisci il tuo nome';

  @override
  String get nameIsRequired => 'Il nome è obbligatorio';

  @override
  String get saveChanges => 'Salva modifiche';

  @override
  String get profileUpdatedSuccessfully => 'Profilo aggiornato con successo';

  @override
  String get inactive => 'Inattivo';

  @override
  String get noActiveBudgets => 'Nessun budget attivo';

  @override
  String get noInactiveBudgets => 'Nessun budget inattivo';

  @override
  String get tapPlusToCreateBudget => 'Tocca + per creare il tuo primo budget';

  @override
  String get deleteBudget => 'Elimina budget';

  @override
  String deleteBudgetConfirm(String name) {
    return 'Sei sicuro di voler eliminare \"$name\"?';
  }

  @override
  String get editBudget => 'Modifica budget';

  @override
  String get newBudget => 'Nuovo budget';

  @override
  String get budgetName => 'Nome del budget';

  @override
  String get pleaseEnterBudgetName => 'Inserisci il nome del budget';

  @override
  String get budgetLimit => 'Limite del budget';

  @override
  String get pleaseEnterBudgetLimit => 'Inserisci il limite del budget';

  @override
  String get pleaseEnterValidPositiveNumber =>
      'Inserisci un numero positivo valido';

  @override
  String get period => 'Periodo';

  @override
  String get weekly => 'Settimanale';

  @override
  String get monthly => 'Mensile';

  @override
  String get yearly => 'Annuale';

  @override
  String get startDate => 'Data di inizio';

  @override
  String get endDateOptional => 'Data di fine (opzionale)';

  @override
  String get noEndDate => 'Nessuna data di fine';

  @override
  String get updateBudget => 'Aggiorna budget';

  @override
  String get createBudget => 'Crea budget';

  @override
  String get paidOff => 'Saldato';

  @override
  String get noActiveDebts => 'Nessun debito attivo';

  @override
  String get noPaidOffDebts => 'Nessun debito saldato';

  @override
  String get noDebts => 'Nessun debito';

  @override
  String get tapPlusToAddDebt => 'Tocca + per aggiungere il tuo primo debito';

  @override
  String get editDebt => 'Modifica debito';

  @override
  String get newDebt => 'Nuovo debito';

  @override
  String get debtName => 'Nome del debito';

  @override
  String get pleaseEnterDebtName => 'Inserisci il nome del debito';

  @override
  String get debtType => 'Tipo di debito';

  @override
  String get personalLoan => 'Prestito personale';

  @override
  String get mortgage => 'Mutuo';

  @override
  String get autoLoan => 'Prestito auto';

  @override
  String get studentLoan => 'Prestito studentesco';

  @override
  String get personal => 'Personale';

  @override
  String get other => 'Altro';

  @override
  String get originalAmount => 'Importo originale';

  @override
  String get pleaseEnterOriginalAmount => 'Inserisci l\'importo originale';

  @override
  String get currentBalance => 'Saldo attuale';

  @override
  String get pleaseEnterCurrentBalance => 'Inserisci il saldo attuale';

  @override
  String get interestRate => 'Tasso d\'interesse (%)';

  @override
  String get minimumPayment => 'Pagamento minimo';

  @override
  String get dueDay => 'Giorno di scadenza (1-31)';

  @override
  String get pleaseEnterValidDay => 'Inserisci un giorno tra 1 e 31';

  @override
  String get creditorNameOptional => 'Nome del creditore (opzionale)';

  @override
  String get expectedPayoffDateOptional =>
      'Data prevista di estinzione (opzionale)';

  @override
  String get noDateSet => 'Nessuna data impostata';

  @override
  String get notesOptional => 'Note (opzionale)';

  @override
  String get updateDebt => 'Aggiorna debito';

  @override
  String get addDebt => 'Aggiungi debito';

  @override
  String get debtDetails => 'Dettagli debito';

  @override
  String get original => 'Originale';

  @override
  String get remaining => 'Rimanente';

  @override
  String get interest => 'Interessi';

  @override
  String get minPayment => 'Pag. min.';

  @override
  String get start => 'Inizio';

  @override
  String get expectedPayoff => 'Estinzione prevista';

  @override
  String get notes => 'Note';

  @override
  String get recordPayment => 'Registra pagamento';

  @override
  String get paymentAmount => 'Importo del pagamento';

  @override
  String get pleaseEnterPaymentAmount => 'Inserisci l\'importo del pagamento';

  @override
  String get paymentDate => 'Data del pagamento';

  @override
  String get aiFinancialAdvisor => 'Consulente finanziario IA';

  @override
  String get oracleWelcome =>
      'Ciao! Sono l\'Oracolo, il tuo consulente finanziario IA.';

  @override
  String get oracleAsk => 'Chiedimi qualsiasi cosa sulle tue finanze.';

  @override
  String get oracleHint => 'Chiedi all\'Oracolo delle tue finanze...';

  @override
  String get markAllAsRead => 'Segna tutto come letto';

  @override
  String get failedToLoadNotifications => 'Impossibile caricare le notifiche';

  @override
  String get noNotificationsYet => 'Nessuna notifica ancora';

  @override
  String get notificationsHint => 'Qui vedrai i tuoi avvisi e aggiornamenti';

  @override
  String get unlockFullPower => 'Sblocca tutta la potenza';

  @override
  String get unlockSubtitle =>
      'Accesso illimitato a tutte le funzionalità premium';

  @override
  String get premiumIncludes => 'Premium include:';

  @override
  String get featureUnlimitedAccounts => 'Conti bancari illimitati';

  @override
  String get featureBankSync => 'Sincronizzazione automatica con Plaid';

  @override
  String get featureReceiptScanning => 'Scansione scontrini (OCR)';

  @override
  String get featureAiPredictions => 'Previsioni IA e Oracolo';

  @override
  String get featureSmartCategorization => 'Categorizzazione intelligente';

  @override
  String get featureBudgetsDebts => 'Budget e monitoraggio debiti';

  @override
  String get featureExport => 'Esportazione dati (CSV/PDF)';

  @override
  String get featureMultiCurrency => 'Supporto multi-valuta';

  @override
  String get yearlyPrice => '34,99 \$/anno';

  @override
  String get monthlyPrice => '4,99 \$/mese';

  @override
  String get lifetimePrice => '99,99 \$';

  @override
  String get yearlySaving => 'Risparmia il 42% — solo 2,92 \$/mese';

  @override
  String get cancelAnytime => 'Annulla in qualsiasi momento';

  @override
  String get lifetimeSubtitle => 'Un solo pagamento, per sempre';

  @override
  String get bestValue => 'MIGLIOR OFFERTA';

  @override
  String get restorePurchases => 'Ripristina acquisti';

  @override
  String get processingPurchase => 'Elaborazione acquisto...';

  @override
  String get welcomeToPremium => 'Benvenuto in Premium!';

  @override
  String get noActiveScheduledPayments => 'Nessun pagamento programmato attivo';

  @override
  String get noInactiveScheduledPayments =>
      'Nessun pagamento programmato inattivo';

  @override
  String get tapPlusToAddScheduledPayment =>
      'Tocca + per aggiungere il primo pagamento programmato';

  @override
  String get importCsv => 'Importa CSV';

  @override
  String get importTransactionsTitle => 'Importa transazioni';

  @override
  String get importDescription =>
      'Carica un file CSV per importare transazioni nel tuo conto';

  @override
  String get selectAccount => 'Seleziona conto';

  @override
  String get chooseAnAccount => 'Scegli un conto';

  @override
  String get pickCsvFile => 'Scegli file CSV';

  @override
  String percentUploaded(int progress) {
    return '$progress% caricato';
  }

  @override
  String get importComplete => 'Importazione completa!';

  @override
  String get imported => 'Importate';

  @override
  String get skipped => 'Saltate';

  @override
  String get errors => 'Errori';

  @override
  String get importAnotherFile => 'Importa un altro file';

  @override
  String get uploadAndImport => 'Carica e importa';

  @override
  String get exportFormat => 'Formato di esportazione';

  @override
  String get csv => 'CSV';

  @override
  String get pdf => 'PDF';

  @override
  String get dateRangeOptional => 'Intervallo di date (opzionale)';

  @override
  String get endDate => 'Data di fine';

  @override
  String get clearDates => 'Cancella date';

  @override
  String get csvDescription =>
      'File CSV con colonne: Data, Descrizione, Importo, Tipo, Categoria, Conto';

  @override
  String get pdfDescription => 'Report PDF con riepilogo e tabella transazioni';

  @override
  String exportFormat2(String format) {
    return 'Esporta $format';
  }

  @override
  String get scanReceiptAutoFill =>
      'Scansiona uno scontrino per compilare\nautomaticamente i dettagli';

  @override
  String get takePhoto => 'Scatta foto';

  @override
  String get chooseFromGallery => 'Scegli dalla galleria';

  @override
  String get processingReceipt => 'Elaborazione scontrino...';

  @override
  String confidencePercent(String confidence) {
    return 'Affidabilità: $confidence%';
  }

  @override
  String get merchant => 'Esercente';

  @override
  String get pleaseFillRequiredFields => 'Compila tutti i campi obbligatori';

  @override
  String get createTransaction => 'Crea transazione';

  @override
  String get scanAnotherReceipt => 'Scansiona un altro scontrino';

  @override
  String get transactionCreatedFromReceipt =>
      'Transazione creata dallo scontrino';

  @override
  String get offlineMode => 'Modalità offline';

  @override
  String get selectLanguage => 'Seleziona lingua';
}
