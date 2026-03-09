// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'AnticiFi';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get transactions => 'Transactions';

  @override
  String get oracle => 'Oracle';

  @override
  String get settings => 'Paramètres';

  @override
  String get welcomeBack => 'Bon retour';

  @override
  String get signInToContinue => 'Connectez-vous pour continuer';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get signIn => 'Se connecter';

  @override
  String get dontHaveAccount => 'Pas de compte ? ';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get enableBiometricTitle => 'Activer la connexion biométrique ?';

  @override
  String get enableBiometricContent =>
      'Utilisez Face ID ou Touch ID pour un accès plus rapide.';

  @override
  String get notNow => 'Pas maintenant';

  @override
  String get enable => 'Activer';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get signUpToGetStarted => 'Inscrivez-vous pour commencer';

  @override
  String get fullName => 'Nom complet';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte ? ';

  @override
  String get onboardingTitle1 => 'Bienvenue sur AnticiFi';

  @override
  String get onboardingDesc1 =>
      'Votre assistant financier IA qui vous aide à gérer votre argent plus intelligemment et à planifier l\'avenir.';

  @override
  String get onboardingTitle2 => 'Prédictions intelligentes';

  @override
  String get onboardingDesc2 =>
      'Notre IA analyse vos habitudes de dépenses et prédit les dépenses à venir.';

  @override
  String get onboardingTitle3 => 'Restez sur la bonne voie';

  @override
  String get onboardingDesc3 =>
      'Définissez des budgets, gérez vos dettes et recevez des notifications pour maintenir vos finances en bonne santé.';

  @override
  String get skip => 'Passer';

  @override
  String get next => 'Suivant';

  @override
  String get getStarted => 'Commencer';

  @override
  String get failedToLoadDashboard => 'Échec du chargement du tableau de bord';

  @override
  String get retry => 'Réessayer';

  @override
  String get recentTransactions => 'Transactions récentes';

  @override
  String get noRecentTransactions => 'Aucune transaction récente';

  @override
  String get all => 'Toutes';

  @override
  String get income => 'Revenu';

  @override
  String get expense => 'Dépense';

  @override
  String get noTransactionsYet => 'Aucune transaction pour le moment';

  @override
  String get tapPlusToAddTransaction =>
      'Appuyez sur + pour ajouter votre première transaction';

  @override
  String get deleteTransaction => 'Supprimer la transaction';

  @override
  String get deleteTransactionConfirm =>
      'Êtes-vous sûr de vouloir supprimer cette transaction ?';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get editTransaction => 'Modifier la transaction';

  @override
  String get newTransaction => 'Nouvelle transaction';

  @override
  String get account => 'Compte';

  @override
  String get amount => 'Montant';

  @override
  String get pleaseEnterAmount => 'Veuillez entrer un montant';

  @override
  String get pleaseEnterValidNumber => 'Veuillez entrer un nombre valide';

  @override
  String get amountMustBeGreaterThanZero =>
      'Le montant doit être supérieur à 0';

  @override
  String get description => 'Description';

  @override
  String get voiceLimitReached =>
      'Limite de saisie vocale atteinte. Passez à Pro pour un accès illimité';

  @override
  String get upgrade => 'Mettre à niveau';

  @override
  String get speechNotAvailable =>
      'La reconnaissance vocale n\'est pas disponible';

  @override
  String get pleaseEnterAccountFirst =>
      'Veuillez d\'abord sélectionner un compte';

  @override
  String get pleaseCreateAccountFirst => 'Veuillez d\'abord créer un compte';

  @override
  String get updateTransaction => 'Mettre à jour la transaction';

  @override
  String get addTransaction => 'Ajouter une transaction';

  @override
  String get accounts => 'Comptes';

  @override
  String get connectBank => 'Connecter la banque';

  @override
  String get noAccountsYet => 'Aucun compte pour le moment';

  @override
  String get tapPlusToAddAccount =>
      'Appuyez sur + pour ajouter votre premier compte';

  @override
  String get editAccount => 'Modifier le compte';

  @override
  String get newAccount => 'Nouveau compte';

  @override
  String get accountName => 'Nom du compte';

  @override
  String get pleaseEnterAccountName => 'Veuillez entrer le nom du compte';

  @override
  String get accountType => 'Type de compte';

  @override
  String get checking => 'Courant';

  @override
  String get savings => 'Épargne';

  @override
  String get creditCard => 'Carte de crédit';

  @override
  String get cash => 'Espèces';

  @override
  String get bankOptional => 'Banque (optionnel)';

  @override
  String get currency => 'Devise';

  @override
  String get initialBalance => 'Solde initial';

  @override
  String get updateAccount => 'Mettre à jour le compte';

  @override
  String get connectYourBank => 'Connectez votre compte bancaire';

  @override
  String get connectBankDescription =>
      'Liez votre banque en toute sécurité pour importer automatiquement les transactions et maintenir vos soldes à jour.';

  @override
  String get bankLevelEncryption => 'Chiffrement de niveau bancaire par Plaid';

  @override
  String failedToStartBankConnection(String error) {
    return 'Échec de la connexion bancaire : $error';
  }

  @override
  String connectionCancelled(String message) {
    return 'Connexion annulée : $message';
  }

  @override
  String successfullyLinkedAccounts(int count) {
    return '$count compte(s) connecté(s) avec succès';
  }

  @override
  String get subscription => 'Abonnement';

  @override
  String get manageSubscription => 'Gérer l\'abonnement';

  @override
  String get upgradeToPremium => 'Passer à Premium';

  @override
  String get active => 'Actif';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get manageAccounts => 'Gérer les comptes';

  @override
  String get preferences => 'Préférences';

  @override
  String get theme => 'Thème';

  @override
  String get dark => 'Sombre';

  @override
  String get light => 'Clair';

  @override
  String get system => 'Système';

  @override
  String get biometricLogin => 'Connexion biométrique';

  @override
  String get language => 'Langue';

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
  String get pushNotifications => 'Notifications push';

  @override
  String get data => 'Données';

  @override
  String get scanReceipt => 'Scanner un reçu';

  @override
  String get importTransactions => 'Importer des transactions';

  @override
  String get exportData => 'Exporter les données';

  @override
  String get scheduledPayments => 'Paiements programmés';

  @override
  String get budgets => 'Budgets';

  @override
  String get debts => 'Dettes';

  @override
  String get about => 'À propos';

  @override
  String get appVersion => 'Version de l\'app';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get termsOfService => 'Conditions d\'utilisation';

  @override
  String get dangerZone => 'Zone de danger';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get logout => 'Déconnexion';

  @override
  String get premium => 'PREMIUM';

  @override
  String get free => 'GRATUIT';

  @override
  String get selectCurrency => 'Sélectionner la devise';

  @override
  String get selectTheme => 'Sélectionner le thème';

  @override
  String get deleteAccountConfirm =>
      'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible. Toutes vos données seront définitivement supprimées.';

  @override
  String get logoutConfirm => 'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get profileUpdated => 'Profil mis à jour';

  @override
  String get name => 'Nom';

  @override
  String get enterYourName => 'Entrez votre nom';

  @override
  String get nameIsRequired => 'Le nom est obligatoire';

  @override
  String get saveChanges => 'Enregistrer';

  @override
  String get profileUpdatedSuccessfully => 'Profil mis à jour avec succès';

  @override
  String get inactive => 'Inactif';

  @override
  String get noActiveBudgets => 'Aucun budget actif';

  @override
  String get noInactiveBudgets => 'Aucun budget inactif';

  @override
  String get tapPlusToCreateBudget =>
      'Appuyez sur + pour créer votre premier budget';

  @override
  String get deleteBudget => 'Supprimer le budget';

  @override
  String deleteBudgetConfirm(String name) {
    return 'Êtes-vous sûr de vouloir supprimer \"$name\" ?';
  }

  @override
  String get editBudget => 'Modifier le budget';

  @override
  String get newBudget => 'Nouveau budget';

  @override
  String get budgetName => 'Nom du budget';

  @override
  String get pleaseEnterBudgetName => 'Veuillez entrer le nom du budget';

  @override
  String get budgetLimit => 'Limite du budget';

  @override
  String get pleaseEnterBudgetLimit => 'Veuillez entrer la limite du budget';

  @override
  String get pleaseEnterValidPositiveNumber =>
      'Veuillez entrer un nombre positif valide';

  @override
  String get period => 'Période';

  @override
  String get weekly => 'Hebdomadaire';

  @override
  String get monthly => 'Mensuel';

  @override
  String get yearly => 'Annuel';

  @override
  String get startDate => 'Date de début';

  @override
  String get endDateOptional => 'Date de fin (optionnel)';

  @override
  String get noEndDate => 'Pas de date de fin';

  @override
  String get updateBudget => 'Mettre à jour le budget';

  @override
  String get createBudget => 'Créer un budget';

  @override
  String get paidOff => 'Remboursé';

  @override
  String get noActiveDebts => 'Aucune dette active';

  @override
  String get noPaidOffDebts => 'Aucune dette remboursée';

  @override
  String get noDebts => 'Aucune dette';

  @override
  String get tapPlusToAddDebt =>
      'Appuyez sur + pour ajouter votre première dette';

  @override
  String get editDebt => 'Modifier la dette';

  @override
  String get newDebt => 'Nouvelle dette';

  @override
  String get debtName => 'Nom de la dette';

  @override
  String get pleaseEnterDebtName => 'Veuillez entrer le nom de la dette';

  @override
  String get debtType => 'Type de dette';

  @override
  String get personalLoan => 'Prêt personnel';

  @override
  String get mortgage => 'Hypothèque';

  @override
  String get autoLoan => 'Prêt auto';

  @override
  String get studentLoan => 'Prêt étudiant';

  @override
  String get personal => 'Personnel';

  @override
  String get other => 'Autre';

  @override
  String get originalAmount => 'Montant original';

  @override
  String get pleaseEnterOriginalAmount => 'Veuillez entrer le montant original';

  @override
  String get currentBalance => 'Solde actuel';

  @override
  String get pleaseEnterCurrentBalance => 'Veuillez entrer le solde actuel';

  @override
  String get interestRate => 'Taux d\'intérêt (%)';

  @override
  String get minimumPayment => 'Paiement minimum';

  @override
  String get dueDay => 'Jour d\'échéance (1-31)';

  @override
  String get pleaseEnterValidDay => 'Veuillez entrer un jour entre 1 et 31';

  @override
  String get creditorNameOptional => 'Nom du créancier (optionnel)';

  @override
  String get expectedPayoffDateOptional =>
      'Date de remboursement prévue (optionnel)';

  @override
  String get noDateSet => 'Aucune date définie';

  @override
  String get notesOptional => 'Notes (optionnel)';

  @override
  String get updateDebt => 'Mettre à jour la dette';

  @override
  String get addDebt => 'Ajouter une dette';

  @override
  String get debtDetails => 'Détails de la dette';

  @override
  String get original => 'Original';

  @override
  String get remaining => 'Restant';

  @override
  String get interest => 'Intérêt';

  @override
  String get minPayment => 'Paiement min.';

  @override
  String get start => 'Début';

  @override
  String get expectedPayoff => 'Remboursement prévu';

  @override
  String get notes => 'Notes';

  @override
  String get recordPayment => 'Enregistrer un paiement';

  @override
  String get paymentAmount => 'Montant du paiement';

  @override
  String get pleaseEnterPaymentAmount =>
      'Veuillez entrer le montant du paiement';

  @override
  String get paymentDate => 'Date du paiement';

  @override
  String get aiFinancialAdvisor => 'Conseiller financier IA';

  @override
  String get oracleWelcome =>
      'Bonjour ! Je suis Oracle, votre conseiller financier IA.';

  @override
  String get oracleAsk =>
      'Posez-moi n\'importe quelle question sur vos finances.';

  @override
  String get oracleHint => 'Interrogez Oracle sur vos finances...';

  @override
  String get markAllAsRead => 'Tout marquer comme lu';

  @override
  String get failedToLoadNotifications =>
      'Échec du chargement des notifications';

  @override
  String get noNotificationsYet => 'Aucune notification pour le moment';

  @override
  String get notificationsHint =>
      'Vos alertes et mises à jour apparaîtront ici';

  @override
  String get unlockFullPower => 'Débloquez toute la puissance';

  @override
  String get unlockSubtitle =>
      'Accès illimité à toutes les fonctionnalités premium';

  @override
  String get premiumIncludes => 'Premium inclut :';

  @override
  String get featureUnlimitedAccounts => 'Comptes bancaires illimités';

  @override
  String get featureBankSync => 'Synchronisation automatique avec Plaid';

  @override
  String get featureReceiptScanning => 'Numérisation de reçus (OCR)';

  @override
  String get featureAiPredictions => 'Prédictions IA et Oracle';

  @override
  String get featureSmartCategorization => 'Catégorisation intelligente';

  @override
  String get featureBudgetsDebts => 'Budgets et suivi des dettes';

  @override
  String get featureExport => 'Export de données (CSV/PDF)';

  @override
  String get featureMultiCurrency => 'Support multi-devises';

  @override
  String get yearlyPrice => '34,99 \$/an';

  @override
  String get monthlyPrice => '4,99 \$/mois';

  @override
  String get lifetimePrice => '99,99 \$';

  @override
  String get yearlySaving => 'Économisez 42% — seulement 2,92 \$/mois';

  @override
  String get cancelAnytime => 'Annulez à tout moment';

  @override
  String get lifetimeSubtitle => 'Un seul paiement, pour toujours';

  @override
  String get bestValue => 'MEILLEURE OFFRE';

  @override
  String get restorePurchases => 'Restaurer les achats';

  @override
  String get processingPurchase => 'Traitement de l\'achat...';

  @override
  String get welcomeToPremium => 'Bienvenue dans Premium !';

  @override
  String get noActiveScheduledPayments => 'Aucun paiement programmé actif';

  @override
  String get noInactiveScheduledPayments => 'Aucun paiement programmé inactif';

  @override
  String get tapPlusToAddScheduledPayment =>
      'Appuyez sur + pour ajouter votre premier paiement programmé';

  @override
  String get importCsv => 'Importer CSV';

  @override
  String get importTransactionsTitle => 'Importer des transactions';

  @override
  String get importDescription =>
      'Téléchargez un fichier CSV pour importer des transactions dans votre compte';

  @override
  String get selectAccount => 'Sélectionner le compte';

  @override
  String get chooseAnAccount => 'Choisir un compte';

  @override
  String get pickCsvFile => 'Choisir un fichier CSV';

  @override
  String percentUploaded(int progress) {
    return '$progress% téléchargé';
  }

  @override
  String get importComplete => 'Import terminé !';

  @override
  String get imported => 'Importées';

  @override
  String get skipped => 'Ignorées';

  @override
  String get errors => 'Erreurs';

  @override
  String get importAnotherFile => 'Importer un autre fichier';

  @override
  String get uploadAndImport => 'Télécharger et importer';

  @override
  String get exportFormat => 'Format d\'export';

  @override
  String get csv => 'CSV';

  @override
  String get pdf => 'PDF';

  @override
  String get dateRangeOptional => 'Plage de dates (optionnel)';

  @override
  String get endDate => 'Date de fin';

  @override
  String get clearDates => 'Effacer les dates';

  @override
  String get csvDescription =>
      'Fichier CSV avec colonnes : Date, Description, Montant, Type, Catégorie, Compte';

  @override
  String get pdfDescription =>
      'Rapport PDF avec résumé et tableau des transactions';

  @override
  String exportFormat2(String format) {
    return 'Exporter $format';
  }

  @override
  String get scanReceiptAutoFill =>
      'Scannez un reçu pour remplir\nautomatiquement les détails';

  @override
  String get takePhoto => 'Prendre une photo';

  @override
  String get chooseFromGallery => 'Choisir dans la galerie';

  @override
  String get processingReceipt => 'Traitement du reçu...';

  @override
  String confidencePercent(String confidence) {
    return 'Confiance : $confidence%';
  }

  @override
  String get merchant => 'Commerçant';

  @override
  String get pleaseFillRequiredFields =>
      'Veuillez remplir tous les champs obligatoires';

  @override
  String get createTransaction => 'Créer une transaction';

  @override
  String get scanAnotherReceipt => 'Scanner un autre reçu';

  @override
  String get transactionCreatedFromReceipt =>
      'Transaction créée depuis le reçu';

  @override
  String get offlineMode => 'Mode hors ligne';

  @override
  String get selectLanguage => 'Sélectionner la langue';
}
