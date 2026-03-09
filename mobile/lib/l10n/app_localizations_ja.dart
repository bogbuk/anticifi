// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'AnticiFi';

  @override
  String get dashboard => 'ダッシュボード';

  @override
  String get transactions => '取引';

  @override
  String get oracle => 'オラクル';

  @override
  String get settings => '設定';

  @override
  String get welcomeBack => 'おかえりなさい';

  @override
  String get signInToContinue => 'ログインして続行';

  @override
  String get email => 'メールアドレス';

  @override
  String get password => 'パスワード';

  @override
  String get signIn => 'ログイン';

  @override
  String get dontHaveAccount => 'アカウントをお持ちでない方 ';

  @override
  String get signUp => '新規登録';

  @override
  String get enableBiometricTitle => '生体認証を有効にしますか？';

  @override
  String get enableBiometricContent => 'Face IDまたはTouch IDでより速くアクセスできます。';

  @override
  String get notNow => '後で';

  @override
  String get enable => '有効にする';

  @override
  String get createAccount => 'アカウント作成';

  @override
  String get signUpToGetStarted => '登録して始めましょう';

  @override
  String get fullName => '氏名';

  @override
  String get confirmPassword => 'パスワード確認';

  @override
  String get passwordsDoNotMatch => 'パスワードが一致しません';

  @override
  String get alreadyHaveAccount => '既にアカウントをお持ちの方 ';

  @override
  String get onboardingTitle1 => 'AnticiFiへようこそ';

  @override
  String get onboardingDesc1 => 'AIを活用した財務アシスタントが、より賢くお金を管理し、将来を計画するお手伝いをします。';

  @override
  String get onboardingTitle2 => 'スマート予測';

  @override
  String get onboardingDesc2 => 'AIが支出パターンを分析し、今後の出費を予測します。';

  @override
  String get onboardingTitle3 => '軌道を維持';

  @override
  String get onboardingDesc3 => '予算を設定し、負債を管理し、タイムリーな通知で財務の健全性を保ちましょう。';

  @override
  String get skip => 'スキップ';

  @override
  String get next => '次へ';

  @override
  String get getStarted => '始める';

  @override
  String get failedToLoadDashboard => 'ダッシュボードの読み込みに失敗しました';

  @override
  String get retry => '再試行';

  @override
  String get recentTransactions => '最近の取引';

  @override
  String get noRecentTransactions => '最近の取引はありません';

  @override
  String get all => 'すべて';

  @override
  String get income => '収入';

  @override
  String get expense => '支出';

  @override
  String get noTransactionsYet => '取引がありません';

  @override
  String get tapPlusToAddTransaction => '+ をタップして最初の取引を追加';

  @override
  String get deleteTransaction => '取引を削除';

  @override
  String get deleteTransactionConfirm => 'この取引を削除してよろしいですか？';

  @override
  String get cancel => 'キャンセル';

  @override
  String get delete => '削除';

  @override
  String get editTransaction => '取引を編集';

  @override
  String get newTransaction => '新しい取引';

  @override
  String get account => '口座';

  @override
  String get amount => '金額';

  @override
  String get pleaseEnterAmount => '金額を入力してください';

  @override
  String get pleaseEnterValidNumber => '有効な数値を入力してください';

  @override
  String get amountMustBeGreaterThanZero => '金額は0より大きくなければなりません';

  @override
  String get description => '説明';

  @override
  String get voiceLimitReached => '音声入力の制限に達しました。Proにアップグレードで無制限に';

  @override
  String get upgrade => 'アップグレード';

  @override
  String get speechNotAvailable => '音声認識が利用できません';

  @override
  String get pleaseEnterAccountFirst => '先に口座を選択してください';

  @override
  String get pleaseCreateAccountFirst => '先に口座を作成してください';

  @override
  String get updateTransaction => '取引を更新';

  @override
  String get addTransaction => '取引を追加';

  @override
  String get accounts => '口座';

  @override
  String get connectBank => '銀行を接続';

  @override
  String get noAccountsYet => '口座がありません';

  @override
  String get tapPlusToAddAccount => '+ をタップして最初の口座を追加';

  @override
  String get editAccount => '口座を編集';

  @override
  String get newAccount => '新しい口座';

  @override
  String get accountName => '口座名';

  @override
  String get pleaseEnterAccountName => '口座名を入力してください';

  @override
  String get accountType => '口座タイプ';

  @override
  String get checking => '普通預金';

  @override
  String get savings => '定期預金';

  @override
  String get creditCard => 'クレジットカード';

  @override
  String get cash => '現金';

  @override
  String get bankOptional => '銀行（任意）';

  @override
  String get currency => '通貨';

  @override
  String get initialBalance => '初期残高';

  @override
  String get updateAccount => '口座を更新';

  @override
  String get connectYourBank => '銀行口座を接続';

  @override
  String get connectBankDescription => '銀行を安全に接続して、取引を自動的にインポートし、残高を最新に保ちます。';

  @override
  String get bankLevelEncryption => 'Plaidによる銀行レベルの暗号化';

  @override
  String failedToStartBankConnection(String error) {
    return '銀行接続に失敗：$error';
  }

  @override
  String connectionCancelled(String message) {
    return '接続がキャンセルされました：$message';
  }

  @override
  String successfullyLinkedAccounts(int count) {
    return '$count件の口座を正常に接続しました';
  }

  @override
  String get subscription => 'サブスクリプション';

  @override
  String get manageSubscription => 'サブスクリプション管理';

  @override
  String get upgradeToPremium => 'プレミアムにアップグレード';

  @override
  String get active => 'アクティブ';

  @override
  String get editProfile => 'プロフィール編集';

  @override
  String get manageAccounts => '口座管理';

  @override
  String get preferences => '設定';

  @override
  String get theme => 'テーマ';

  @override
  String get dark => 'ダーク';

  @override
  String get light => 'ライト';

  @override
  String get system => 'システム';

  @override
  String get biometricLogin => '生体認証ログイン';

  @override
  String get language => '言語';

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
  String get notifications => '通知';

  @override
  String get pushNotifications => 'プッシュ通知';

  @override
  String get data => 'データ';

  @override
  String get scanReceipt => 'レシートをスキャン';

  @override
  String get importTransactions => '取引をインポート';

  @override
  String get exportData => 'データをエクスポート';

  @override
  String get scheduledPayments => '定期支払い';

  @override
  String get budgets => '予算';

  @override
  String get debts => '負債';

  @override
  String get about => 'アプリについて';

  @override
  String get appVersion => 'アプリバージョン';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get termsOfService => '利用規約';

  @override
  String get dangerZone => '危険ゾーン';

  @override
  String get deleteAccount => 'アカウント削除';

  @override
  String get logout => 'ログアウト';

  @override
  String get premium => 'プレミアム';

  @override
  String get free => '無料';

  @override
  String get selectCurrency => '通貨を選択';

  @override
  String get selectTheme => 'テーマを選択';

  @override
  String get deleteAccountConfirm =>
      'アカウントを削除してよろしいですか？この操作は元に戻せません。すべてのデータが完全に削除されます。';

  @override
  String get logoutConfirm => 'ログアウトしてよろしいですか？';

  @override
  String get profileUpdated => 'プロフィールが更新されました';

  @override
  String get name => '名前';

  @override
  String get enterYourName => '名前を入力';

  @override
  String get nameIsRequired => '名前は必須です';

  @override
  String get saveChanges => '変更を保存';

  @override
  String get profileUpdatedSuccessfully => 'プロフィールが正常に更新されました';

  @override
  String get inactive => '非アクティブ';

  @override
  String get noActiveBudgets => 'アクティブな予算はありません';

  @override
  String get noInactiveBudgets => '非アクティブな予算はありません';

  @override
  String get tapPlusToCreateBudget => '+ をタップして最初の予算を作成';

  @override
  String get deleteBudget => '予算を削除';

  @override
  String deleteBudgetConfirm(String name) {
    return '「$name」を削除してよろしいですか？';
  }

  @override
  String get editBudget => '予算を編集';

  @override
  String get newBudget => '新しい予算';

  @override
  String get budgetName => '予算名';

  @override
  String get pleaseEnterBudgetName => '予算名を入力してください';

  @override
  String get budgetLimit => '予算上限';

  @override
  String get pleaseEnterBudgetLimit => '予算上限を入力してください';

  @override
  String get pleaseEnterValidPositiveNumber => '有効な正の数を入力してください';

  @override
  String get period => '期間';

  @override
  String get weekly => '毎週';

  @override
  String get monthly => '毎月';

  @override
  String get yearly => '毎年';

  @override
  String get startDate => '開始日';

  @override
  String get endDateOptional => '終了日（任意）';

  @override
  String get noEndDate => '終了日なし';

  @override
  String get updateBudget => '予算を更新';

  @override
  String get createBudget => '予算を作成';

  @override
  String get paidOff => '完済';

  @override
  String get noActiveDebts => 'アクティブな負債はありません';

  @override
  String get noPaidOffDebts => '完済した負債はありません';

  @override
  String get noDebts => '負債はありません';

  @override
  String get tapPlusToAddDebt => '+ をタップして最初の負債を追加';

  @override
  String get editDebt => '負債を編集';

  @override
  String get newDebt => '新しい負債';

  @override
  String get debtName => '負債名';

  @override
  String get pleaseEnterDebtName => '負債名を入力してください';

  @override
  String get debtType => '負債タイプ';

  @override
  String get personalLoan => '個人ローン';

  @override
  String get mortgage => '住宅ローン';

  @override
  String get autoLoan => '自動車ローン';

  @override
  String get studentLoan => '学生ローン';

  @override
  String get personal => '個人';

  @override
  String get other => 'その他';

  @override
  String get originalAmount => '元の金額';

  @override
  String get pleaseEnterOriginalAmount => '元の金額を入力してください';

  @override
  String get currentBalance => '現在の残高';

  @override
  String get pleaseEnterCurrentBalance => '現在の残高を入力してください';

  @override
  String get interestRate => '金利（%）';

  @override
  String get minimumPayment => '最低返済額';

  @override
  String get dueDay => '返済日（1-31）';

  @override
  String get pleaseEnterValidDay => '1から31の間の日付を入力してください';

  @override
  String get creditorNameOptional => '債権者名（任意）';

  @override
  String get expectedPayoffDateOptional => '完済予定日（任意）';

  @override
  String get noDateSet => '日付未設定';

  @override
  String get notesOptional => 'メモ（任意）';

  @override
  String get updateDebt => '負債を更新';

  @override
  String get addDebt => '負債を追加';

  @override
  String get debtDetails => '負債の詳細';

  @override
  String get original => '元の額';

  @override
  String get remaining => '残額';

  @override
  String get interest => '利息';

  @override
  String get minPayment => '最低返済';

  @override
  String get start => '開始';

  @override
  String get expectedPayoff => '完済予定';

  @override
  String get notes => 'メモ';

  @override
  String get recordPayment => '返済を記録';

  @override
  String get paymentAmount => '返済額';

  @override
  String get pleaseEnterPaymentAmount => '返済額を入力してください';

  @override
  String get paymentDate => '返済日';

  @override
  String get aiFinancialAdvisor => 'AIファイナンシャルアドバイザー';

  @override
  String get oracleWelcome => 'こんにちは！AIファイナンシャルアドバイザーのオラクルです。';

  @override
  String get oracleAsk => '財務に関することは何でもお聞きください。';

  @override
  String get oracleHint => 'オラクルに財務について質問...';

  @override
  String get markAllAsRead => 'すべて既読にする';

  @override
  String get failedToLoadNotifications => '通知の読み込みに失敗しました';

  @override
  String get noNotificationsYet => '通知はまだありません';

  @override
  String get notificationsHint => 'アラートや更新がここに表示されます';

  @override
  String get unlockFullPower => 'フルパワーを解放';

  @override
  String get unlockSubtitle => 'すべてのプレミアム機能に無制限アクセス';

  @override
  String get premiumIncludes => 'プレミアムに含まれるもの：';

  @override
  String get featureUnlimitedAccounts => '無制限の銀行口座';

  @override
  String get featureBankSync => 'Plaidによる自動銀行同期';

  @override
  String get featureReceiptScanning => 'レシートスキャン（OCR）';

  @override
  String get featureAiPredictions => 'AI予測とオラクル';

  @override
  String get featureSmartCategorization => 'スマート分類';

  @override
  String get featureBudgetsDebts => '予算と負債追跡';

  @override
  String get featureExport => 'データエクスポート（CSV/PDF）';

  @override
  String get featureMultiCurrency => 'マルチ通貨対応';

  @override
  String get yearlyPrice => '\$34.99/年';

  @override
  String get monthlyPrice => '\$4.99/月';

  @override
  String get lifetimePrice => '\$99.99';

  @override
  String get yearlySaving => '42%節約 — 月額わずか\$2.92';

  @override
  String get cancelAnytime => 'いつでもキャンセル可能';

  @override
  String get lifetimeSubtitle => '一回の支払い、永久に';

  @override
  String get bestValue => 'ベストバリュー';

  @override
  String get restorePurchases => '購入を復元';

  @override
  String get processingPurchase => '購入処理中...';

  @override
  String get welcomeToPremium => 'プレミアムへようこそ！';

  @override
  String get noActiveScheduledPayments => 'アクティブな定期支払いはありません';

  @override
  String get noInactiveScheduledPayments => '非アクティブな定期支払いはありません';

  @override
  String get tapPlusToAddScheduledPayment => '+ をタップして最初の定期支払いを追加';

  @override
  String get importCsv => 'CSVインポート';

  @override
  String get importTransactionsTitle => '取引をインポート';

  @override
  String get importDescription => 'CSVファイルをアップロードして口座に取引をインポート';

  @override
  String get selectAccount => '口座を選択';

  @override
  String get chooseAnAccount => '口座を選んでください';

  @override
  String get pickCsvFile => 'CSVファイルを選択';

  @override
  String percentUploaded(int progress) {
    return '$progress%アップロード済み';
  }

  @override
  String get importComplete => 'インポート完了！';

  @override
  String get imported => 'インポート済み';

  @override
  String get skipped => 'スキップ';

  @override
  String get errors => 'エラー';

  @override
  String get importAnotherFile => '別のファイルをインポート';

  @override
  String get uploadAndImport => 'アップロードしてインポート';

  @override
  String get exportFormat => 'エクスポート形式';

  @override
  String get csv => 'CSV';

  @override
  String get pdf => 'PDF';

  @override
  String get dateRangeOptional => '日付範囲（任意）';

  @override
  String get endDate => '終了日';

  @override
  String get clearDates => '日付をクリア';

  @override
  String get csvDescription => 'CSV：日付、説明、金額、タイプ、カテゴリー、口座';

  @override
  String get pdfDescription => '概要と取引テーブル付きPDFレポート';

  @override
  String exportFormat2(String format) {
    return '$formatエクスポート';
  }

  @override
  String get scanReceiptAutoFill => 'レシートをスキャンして\n取引詳細を自動入力';

  @override
  String get takePhoto => '写真を撮る';

  @override
  String get chooseFromGallery => 'ギャラリーから選択';

  @override
  String get processingReceipt => 'レシート処理中...';

  @override
  String confidencePercent(String confidence) {
    return '信頼度：$confidence%';
  }

  @override
  String get merchant => '店舗';

  @override
  String get pleaseFillRequiredFields => '必須項目をすべて入力してください';

  @override
  String get createTransaction => '取引を作成';

  @override
  String get scanAnotherReceipt => '別のレシートをスキャン';

  @override
  String get transactionCreatedFromReceipt => 'レシートから取引を作成しました';

  @override
  String get offlineMode => 'オフラインモード';

  @override
  String get selectLanguage => '言語を選択';

  @override
  String get totalBalance => '合計残高';

  @override
  String get spendingByCategory => 'カテゴリー別支出';

  @override
  String get noSpendingDataYet => '支出データはまだありません';

  @override
  String get pleaseSelectAccount => '口座を選択してください';

  @override
  String get editScheduledPayment => '定期支払いを編集';

  @override
  String get newScheduledPayment => '新しい定期支払い';

  @override
  String get paymentName => '支払い名';

  @override
  String get pleaseEnterPaymentName => '支払い名を入力してください';

  @override
  String get frequency => '頻度';

  @override
  String get descriptionOptional => '説明（任意）';

  @override
  String get updatePayment => '支払いを更新';

  @override
  String get createPayment => '支払いを作成';

  @override
  String get deleteScheduledPayment => '定期支払いを削除';

  @override
  String get executePayment => '支払いを実行';

  @override
  String executePaymentConfirm(String name) {
    return '「$name」を今すぐ実行しますか？';
  }

  @override
  String get execute => '実行';

  @override
  String get receiptHistory => 'レシート履歴';

  @override
  String get noReceiptScansYet => 'スキャンしたレシートはまだありません';

  @override
  String get scanReceiptToGetStarted => 'レシートをスキャンして始めましょう';

  @override
  String get addAccount => '口座を追加';

  @override
  String get noCategory => 'カテゴリーなし';

  @override
  String get category => 'カテゴリー';

  @override
  String get vsLastMonth => '先月比';
}
