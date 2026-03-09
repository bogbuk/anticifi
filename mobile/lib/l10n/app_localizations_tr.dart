// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'AnticiFi';

  @override
  String get dashboard => 'Panel';

  @override
  String get transactions => 'İşlemler';

  @override
  String get oracle => 'Kahin';

  @override
  String get settings => 'Ayarlar';

  @override
  String get welcomeBack => 'Tekrar hoş geldiniz';

  @override
  String get signInToContinue => 'Devam etmek için giriş yapın';

  @override
  String get email => 'E-posta';

  @override
  String get password => 'Şifre';

  @override
  String get signIn => 'Giriş Yap';

  @override
  String get dontHaveAccount => 'Hesabınız yok mu? ';

  @override
  String get signUp => 'Kayıt Ol';

  @override
  String get enableBiometricTitle => 'Biyometrik giriş etkinleştirilsin mi?';

  @override
  String get enableBiometricContent =>
      'Daha hızlı erişim için Face ID veya Touch ID kullanın.';

  @override
  String get notNow => 'Şimdi değil';

  @override
  String get enable => 'Etkinleştir';

  @override
  String get createAccount => 'Hesap oluştur';

  @override
  String get signUpToGetStarted => 'Başlamak için kayıt olun';

  @override
  String get fullName => 'Ad soyad';

  @override
  String get confirmPassword => 'Şifreyi onayla';

  @override
  String get passwordsDoNotMatch => 'Şifreler eşleşmiyor';

  @override
  String get alreadyHaveAccount => 'Zaten hesabınız var mı? ';

  @override
  String get onboardingTitle1 => 'AnticiFi\'ye hoş geldiniz';

  @override
  String get onboardingDesc1 =>
      'Paranızı daha akıllı yönetmenize ve geleceği planlamanıza yardımcı olan AI destekli finans asistanınız.';

  @override
  String get onboardingTitle2 => 'Akıllı tahminler';

  @override
  String get onboardingDesc2 =>
      'AI\'mız harcama kalıplarınızı analiz eder ve gelecek harcamaları öngörür.';

  @override
  String get onboardingTitle3 => 'Yolda kalın';

  @override
  String get onboardingDesc3 =>
      'Bütçe belirleyin, borçları yönetin ve finanslarınızı sağlıklı tutmak için bildirimler alın.';

  @override
  String get skip => 'Atla';

  @override
  String get next => 'İleri';

  @override
  String get getStarted => 'Başla';

  @override
  String get failedToLoadDashboard => 'Panel yüklenemedi';

  @override
  String get failedToLoadAccounts => 'Hesaplar yüklenemedi';

  @override
  String get retry => 'Tekrar dene';

  @override
  String get recentTransactions => 'Son işlemler';

  @override
  String get noRecentTransactions => 'Son işlem yok';

  @override
  String get all => 'Tümü';

  @override
  String get income => 'Gelir';

  @override
  String get expense => 'Gider';

  @override
  String get noTransactionsYet => 'Henüz işlem yok';

  @override
  String get tapPlusToAddTransaction =>
      'İlk işleminizi eklemek için + öğesine dokunun';

  @override
  String get deleteTransaction => 'İşlemi sil';

  @override
  String get deleteTransactionConfirm =>
      'Bu işlemi silmek istediğinizden emin misiniz?';

  @override
  String get cancel => 'İptal';

  @override
  String get delete => 'Sil';

  @override
  String get editTransaction => 'İşlemi düzenle';

  @override
  String get newTransaction => 'Yeni işlem';

  @override
  String get account => 'Hesap';

  @override
  String get amount => 'Tutar';

  @override
  String get pleaseEnterAmount => 'Tutar girin';

  @override
  String get pleaseEnterValidNumber => 'Geçerli bir sayı girin';

  @override
  String get amountMustBeGreaterThanZero => 'Tutar 0\'dan büyük olmalıdır';

  @override
  String get description => 'Açıklama';

  @override
  String get voiceLimitReached =>
      'Sesli giriş limiti doldu. Sınırsız erişim için Pro\'ya yükseltin';

  @override
  String get upgrade => 'Yükselt';

  @override
  String get speechNotAvailable => 'Ses tanıma kullanılamıyor';

  @override
  String get pleaseEnterAccountFirst => 'Önce bir hesap seçin';

  @override
  String get pleaseCreateAccountFirst => 'Önce bir hesap oluşturun';

  @override
  String get updateTransaction => 'İşlemi güncelle';

  @override
  String get addTransaction => 'İşlem ekle';

  @override
  String get accounts => 'Hesaplar';

  @override
  String get connectBank => 'Banka bağla';

  @override
  String get noAccountsYet => 'Henüz hesap yok';

  @override
  String get tapPlusToAddAccount =>
      'İlk hesabınızı eklemek için + öğesine dokunun';

  @override
  String get editAccount => 'Hesabı düzenle';

  @override
  String get newAccount => 'Yeni hesap';

  @override
  String get accountName => 'Hesap adı';

  @override
  String get pleaseEnterAccountName => 'Hesap adını girin';

  @override
  String get accountType => 'Hesap türü';

  @override
  String get checking => 'Vadesiz';

  @override
  String get savings => 'Tasarruf';

  @override
  String get creditCard => 'Kredi kartı';

  @override
  String get cash => 'Nakit';

  @override
  String get bankOptional => 'Banka (isteğe bağlı)';

  @override
  String get currency => 'Para birimi';

  @override
  String get initialBalance => 'Başlangıç bakiyesi';

  @override
  String get updateAccount => 'Hesabı güncelle';

  @override
  String get connectYourBank => 'Banka hesabınızı bağlayın';

  @override
  String get connectBankDescription =>
      'İşlemleri otomatik olarak içe aktarmak ve bakiyelerinizi güncel tutmak için bankanızı güvenli bir şekilde bağlayın.';

  @override
  String get bankLevelEncryption =>
      'Plaid tarafından banka düzeyinde şifreleme';

  @override
  String failedToStartBankConnection(String error) {
    return 'Banka bağlantısı başarısız: $error';
  }

  @override
  String connectionCancelled(String message) {
    return 'Bağlantı iptal edildi: $message';
  }

  @override
  String successfullyLinkedAccounts(int count) {
    return '$count hesap başarıyla bağlandı';
  }

  @override
  String get subscription => 'Abonelik';

  @override
  String get manageSubscription => 'Aboneliği yönet';

  @override
  String get upgradeToPremium => 'Premium\'a yükselt';

  @override
  String get active => 'Aktif';

  @override
  String get editProfile => 'Profili düzenle';

  @override
  String get manageAccounts => 'Hesapları yönet';

  @override
  String get preferences => 'Tercihler';

  @override
  String get theme => 'Tema';

  @override
  String get dark => 'Koyu';

  @override
  String get light => 'Açık';

  @override
  String get system => 'Sistem';

  @override
  String get biometricLogin => 'Biyometrik giriş';

  @override
  String get language => 'Dil';

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
  String get notifications => 'Bildirimler';

  @override
  String get pushNotifications => 'Anlık bildirimler';

  @override
  String get data => 'Veriler';

  @override
  String get scanReceipt => 'Fiş tara';

  @override
  String get importTransactions => 'İşlemleri içe aktar';

  @override
  String get exportData => 'Verileri dışa aktar';

  @override
  String get scheduledPayments => 'Zamanlanmış ödemeler';

  @override
  String get budgets => 'Bütçeler';

  @override
  String get debts => 'Borçlar';

  @override
  String get about => 'Hakkında';

  @override
  String get appVersion => 'Uygulama sürümü';

  @override
  String get privacyPolicy => 'Gizlilik politikası';

  @override
  String get termsOfService => 'Kullanım koşulları';

  @override
  String get dangerZone => 'Tehlikeli bölge';

  @override
  String get deleteAccount => 'Hesabı sil';

  @override
  String get logout => 'Çıkış yap';

  @override
  String get premium => 'PREMIUM';

  @override
  String get free => 'ÜCRETSİZ';

  @override
  String get selectCurrency => 'Para birimi seç';

  @override
  String get selectTheme => 'Tema seç';

  @override
  String get deleteAccountConfirm =>
      'Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz. Tüm verileriniz kalıcı olarak silinecektir.';

  @override
  String get logoutConfirm => 'Çıkış yapmak istediğinizden emin misiniz?';

  @override
  String get profileUpdated => 'Profil güncellendi';

  @override
  String get name => 'Ad';

  @override
  String get enterYourName => 'Adınızı girin';

  @override
  String get nameIsRequired => 'Ad zorunludur';

  @override
  String get saveChanges => 'Değişiklikleri kaydet';

  @override
  String get profileUpdatedSuccessfully => 'Profil başarıyla güncellendi';

  @override
  String get inactive => 'Pasif';

  @override
  String get noActiveBudgets => 'Aktif bütçe yok';

  @override
  String get noInactiveBudgets => 'Pasif bütçe yok';

  @override
  String get tapPlusToCreateBudget =>
      'İlk bütçenizi oluşturmak için + öğesine dokunun';

  @override
  String get deleteBudget => 'Bütçeyi sil';

  @override
  String deleteBudgetConfirm(String name) {
    return '\"$name\" silmek istediğinizden emin misiniz?';
  }

  @override
  String get editBudget => 'Bütçeyi düzenle';

  @override
  String get newBudget => 'Yeni bütçe';

  @override
  String get budgetName => 'Bütçe adı';

  @override
  String get pleaseEnterBudgetName => 'Bütçe adını girin';

  @override
  String get budgetLimit => 'Bütçe limiti';

  @override
  String get pleaseEnterBudgetLimit => 'Bütçe limitini girin';

  @override
  String get pleaseEnterValidPositiveNumber => 'Geçerli bir pozitif sayı girin';

  @override
  String get period => 'Dönem';

  @override
  String get weekly => 'Haftalık';

  @override
  String get monthly => 'Aylık';

  @override
  String get yearly => 'Yıllık';

  @override
  String get startDate => 'Başlangıç tarihi';

  @override
  String get endDateOptional => 'Bitiş tarihi (isteğe bağlı)';

  @override
  String get noEndDate => 'Bitiş tarihi yok';

  @override
  String get updateBudget => 'Bütçeyi güncelle';

  @override
  String get createBudget => 'Bütçe oluştur';

  @override
  String get paidOff => 'Ödendi';

  @override
  String get noActiveDebts => 'Aktif borç yok';

  @override
  String get noPaidOffDebts => 'Ödenmiş borç yok';

  @override
  String get noDebts => 'Borç yok';

  @override
  String get tapPlusToAddDebt => 'İlk borcunuzu eklemek için + öğesine dokunun';

  @override
  String get editDebt => 'Borcu düzenle';

  @override
  String get newDebt => 'Yeni borç';

  @override
  String get debtName => 'Borç adı';

  @override
  String get pleaseEnterDebtName => 'Borç adını girin';

  @override
  String get debtType => 'Borç türü';

  @override
  String get personalLoan => 'Bireysel kredi';

  @override
  String get mortgage => 'Konut kredisi';

  @override
  String get autoLoan => 'Taşıt kredisi';

  @override
  String get studentLoan => 'Öğrenim kredisi';

  @override
  String get personal => 'Kişisel';

  @override
  String get other => 'Diğer';

  @override
  String get originalAmount => 'Orijinal tutar';

  @override
  String get pleaseEnterOriginalAmount => 'Orijinal tutarı girin';

  @override
  String get currentBalance => 'Mevcut bakiye';

  @override
  String get pleaseEnterCurrentBalance => 'Mevcut bakiyeyi girin';

  @override
  String get interestRate => 'Faiz oranı (%)';

  @override
  String get minimumPayment => 'Minimum ödeme';

  @override
  String get dueDay => 'Ödeme günü (1-31)';

  @override
  String get pleaseEnterValidDay => '1 ile 31 arasında bir gün girin';

  @override
  String get creditorNameOptional => 'Alacaklı adı (isteğe bağlı)';

  @override
  String get expectedPayoffDateOptional =>
      'Beklenen ödeme tarihi (isteğe bağlı)';

  @override
  String get noDateSet => 'Tarih belirlenmedi';

  @override
  String get notesOptional => 'Notlar (isteğe bağlı)';

  @override
  String get updateDebt => 'Borcu güncelle';

  @override
  String get addDebt => 'Borç ekle';

  @override
  String get debtDetails => 'Borç detayları';

  @override
  String get original => 'Orijinal';

  @override
  String get remaining => 'Kalan';

  @override
  String get interest => 'Faiz';

  @override
  String get minPayment => 'Min. ödeme';

  @override
  String get start => 'Başlangıç';

  @override
  String get expectedPayoff => 'Beklenen ödeme';

  @override
  String get notes => 'Notlar';

  @override
  String get recordPayment => 'Ödeme kaydet';

  @override
  String get paymentAmount => 'Ödeme tutarı';

  @override
  String get pleaseEnterPaymentAmount => 'Ödeme tutarını girin';

  @override
  String get paymentDate => 'Ödeme tarihi';

  @override
  String get aiFinancialAdvisor => 'AI finans danışmanı';

  @override
  String get oracleWelcome => 'Merhaba! Ben Kahin, AI finans danışmanınız.';

  @override
  String get oracleAsk => 'Finanslarınız hakkında bana her şeyi sorun.';

  @override
  String get oracleHint => 'Kahin\'e finanslarınızı sorun...';

  @override
  String get markAllAsRead => 'Tümünü okundu olarak işaretle';

  @override
  String get failedToLoadNotifications => 'Bildirimler yüklenemedi';

  @override
  String get noNotificationsYet => 'Henüz bildirim yok';

  @override
  String get notificationsHint =>
      'Uyarılarınız ve güncellemeleriniz burada görünecek';

  @override
  String get unlockFullPower => 'Tam gücü açın';

  @override
  String get unlockSubtitle => 'Tüm premium özelliklere sınırsız erişim';

  @override
  String get premiumIncludes => 'Premium şunları içerir:';

  @override
  String get featureUnlimitedAccounts => 'Sınırsız banka hesabı';

  @override
  String get featureBankSync => 'Plaid ile otomatik banka senkronizasyonu';

  @override
  String get featureReceiptScanning => 'Fiş tarama (OCR)';

  @override
  String get featureAiPredictions => 'AI tahminleri ve Kahin';

  @override
  String get featureSmartCategorization => 'Akıllı kategorilendirme';

  @override
  String get featureBudgetsDebts => 'Bütçeler ve borç takibi';

  @override
  String get featureExport => 'Veri dışa aktarma (CSV/PDF)';

  @override
  String get featureMultiCurrency => 'Çoklu para birimi desteği';

  @override
  String get yearlyPrice => '34,99 \$/yıl';

  @override
  String get monthlyPrice => '4,99 \$/ay';

  @override
  String get lifetimePrice => '99,99 \$';

  @override
  String get yearlySaving => '%42 tasarruf — sadece 2,92 \$/ay';

  @override
  String get cancelAnytime => 'İstediğiniz zaman iptal edin';

  @override
  String get lifetimeSubtitle => 'Tek ödeme, sonsuza kadar';

  @override
  String get bestValue => 'EN İYİ DEĞER';

  @override
  String get restorePurchases => 'Satın almaları geri yükle';

  @override
  String get processingPurchase => 'Satın alma işleniyor...';

  @override
  String get welcomeToPremium => 'Premium\'a hoş geldiniz!';

  @override
  String get noActiveScheduledPayments => 'Aktif zamanlanmış ödeme yok';

  @override
  String get noInactiveScheduledPayments => 'Pasif zamanlanmış ödeme yok';

  @override
  String get tapPlusToAddScheduledPayment =>
      'İlk zamanlanmış ödemenizi eklemek için + öğesine dokunun';

  @override
  String get importCsv => 'CSV içe aktar';

  @override
  String get importTransactionsTitle => 'İşlemleri içe aktar';

  @override
  String get importDescription =>
      'Hesabınıza işlem aktarmak için bir CSV dosyası yükleyin';

  @override
  String get selectAccount => 'Hesap seç';

  @override
  String get chooseAnAccount => 'Bir hesap seçin';

  @override
  String get pickCsvFile => 'CSV dosyası seç';

  @override
  String percentUploaded(int progress) {
    return '%$progress yüklendi';
  }

  @override
  String get importComplete => 'İçe aktarma tamamlandı!';

  @override
  String get imported => 'İçe aktarıldı';

  @override
  String get skipped => 'Atlandı';

  @override
  String get errors => 'Hatalar';

  @override
  String get importAnotherFile => 'Başka dosya içe aktar';

  @override
  String get uploadAndImport => 'Yükle ve içe aktar';

  @override
  String get exportFormat => 'Dışa aktarma formatı';

  @override
  String get csv => 'CSV';

  @override
  String get pdf => 'PDF';

  @override
  String get dateRangeOptional => 'Tarih aralığı (isteğe bağlı)';

  @override
  String get endDate => 'Bitiş tarihi';

  @override
  String get clearDates => 'Tarihleri temizle';

  @override
  String get csvDescription =>
      'Sütunlu CSV dosyası: Tarih, Açıklama, Tutar, Tür, Kategori, Hesap';

  @override
  String get pdfDescription => 'Özet ve işlem tablosu içeren PDF rapor';

  @override
  String exportFormat2(String format) {
    return '$format dışa aktar';
  }

  @override
  String get scanReceiptAutoFill =>
      'İşlem detaylarını otomatik\ndoldurmak için bir fiş tarayın';

  @override
  String get takePhoto => 'Fotoğraf çek';

  @override
  String get chooseFromGallery => 'Galeriden seç';

  @override
  String get processingReceipt => 'Fiş işleniyor...';

  @override
  String confidencePercent(String confidence) {
    return 'Güven: %$confidence';
  }

  @override
  String get merchant => 'Satıcı';

  @override
  String get pleaseFillRequiredFields => 'Tüm zorunlu alanları doldurun';

  @override
  String get createTransaction => 'İşlem oluştur';

  @override
  String get scanAnotherReceipt => 'Başka fiş tara';

  @override
  String get transactionCreatedFromReceipt => 'Fişten işlem oluşturuldu';

  @override
  String get offlineMode => 'Çevrimdışı mod';

  @override
  String get selectLanguage => 'Dil seç';

  @override
  String get totalBalance => 'Toplam bakiye';

  @override
  String get spendingByCategory => 'Kategoriye göre harcamalar';

  @override
  String get noSpendingDataYet => 'Henüz harcama verisi yok';

  @override
  String get pleaseSelectAccount => 'Lütfen bir hesap seçin';

  @override
  String get editScheduledPayment => 'Zamanlanmış ödemeyi düzenle';

  @override
  String get newScheduledPayment => 'Yeni zamanlanmış ödeme';

  @override
  String get paymentName => 'Ödeme adı';

  @override
  String get pleaseEnterPaymentName => 'Ödeme adını girin';

  @override
  String get frequency => 'Sıklık';

  @override
  String get descriptionOptional => 'Açıklama (isteğe bağlı)';

  @override
  String get updatePayment => 'Ödemeyi güncelle';

  @override
  String get createPayment => 'Ödeme oluştur';

  @override
  String get deleteScheduledPayment => 'Zamanlanmış ödemeyi sil';

  @override
  String get executePayment => 'Ödemeyi gerçekleştir';

  @override
  String executePaymentConfirm(String name) {
    return '\"$name\" şimdi gerçekleştirilsin mi?';
  }

  @override
  String get execute => 'Gerçekleştir';

  @override
  String get receiptHistory => 'Fiş geçmişi';

  @override
  String get noReceiptScansYet => 'Henüz taranan fiş yok';

  @override
  String get scanReceiptToGetStarted => 'Başlamak için bir fiş tarayın';

  @override
  String get addAccount => 'Hesap ekle';

  @override
  String get noCategory => 'Kategorisiz';

  @override
  String get category => 'Kategori';

  @override
  String get vsLastMonth => 'geçen aya göre';

  @override
  String get receiptDetails => 'Fiş detayları';

  @override
  String get scanInfo => 'Tarama bilgisi';

  @override
  String get filename => 'Dosya adı';

  @override
  String get scannedOn => 'Taranma tarihi';

  @override
  String get receiptData => 'Fiş verileri';

  @override
  String get totalAmount => 'Toplam tutar';

  @override
  String get receiptDate => 'Fiş tarihi';

  @override
  String get confidence => 'Güvenilirlik';

  @override
  String get completed => 'Tamamlandı';

  @override
  String get failed => 'Başarısız';

  @override
  String get processing => 'İşleniyor';

  @override
  String get items => 'Kalemler';
}
