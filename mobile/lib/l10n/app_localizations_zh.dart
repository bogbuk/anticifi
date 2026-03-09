// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'AnticiFi';

  @override
  String get dashboard => '仪表盘';

  @override
  String get transactions => '交易';

  @override
  String get oracle => '预言师';

  @override
  String get settings => '设置';

  @override
  String get welcomeBack => '欢迎回来';

  @override
  String get signInToContinue => '登录以继续';

  @override
  String get email => '电子邮箱';

  @override
  String get password => '密码';

  @override
  String get signIn => '登录';

  @override
  String get dontHaveAccount => '没有账户？';

  @override
  String get signUp => '注册';

  @override
  String get enableBiometricTitle => '启用生物识别登录？';

  @override
  String get enableBiometricContent => '使用 Face ID 或 Touch ID 快速访问。';

  @override
  String get notNow => '暂不';

  @override
  String get enable => '启用';

  @override
  String get createAccount => '创建账户';

  @override
  String get signUpToGetStarted => '注册开始使用';

  @override
  String get fullName => '全名';

  @override
  String get confirmPassword => '确认密码';

  @override
  String get passwordsDoNotMatch => '密码不匹配';

  @override
  String get alreadyHaveAccount => '已有账户？';

  @override
  String get onboardingTitle1 => '欢迎使用 AnticiFi';

  @override
  String get onboardingDesc1 => '您的 AI 财务助手，帮助您更智能地管理资金并规划未来。';

  @override
  String get onboardingTitle2 => '智能预测';

  @override
  String get onboardingDesc2 => '我们的 AI 分析您的消费模式并预测即将到来的支出。';

  @override
  String get onboardingTitle3 => '保持正轨';

  @override
  String get onboardingDesc3 => '设定预算、管理债务并获取及时通知，保持财务健康。';

  @override
  String get skip => '跳过';

  @override
  String get next => '下一步';

  @override
  String get getStarted => '开始使用';

  @override
  String get failedToLoadDashboard => '无法加载仪表盘';

  @override
  String get failedToLoadAccounts => '无法加载账户';

  @override
  String get retry => '重试';

  @override
  String get recentTransactions => '最近交易';

  @override
  String get noRecentTransactions => '没有最近的交易';

  @override
  String get all => '全部';

  @override
  String get income => '收入';

  @override
  String get expense => '支出';

  @override
  String get noTransactionsYet => '暂无交易';

  @override
  String get tapPlusToAddTransaction => '点击 + 添加您的第一笔交易';

  @override
  String get deleteTransaction => '删除交易';

  @override
  String get deleteTransactionConfirm => '确定要删除此交易吗？';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get editTransaction => '编辑交易';

  @override
  String get newTransaction => '新交易';

  @override
  String get account => '账户';

  @override
  String get amount => '金额';

  @override
  String get pleaseEnterAmount => '请输入金额';

  @override
  String get pleaseEnterValidNumber => '请输入有效数字';

  @override
  String get amountMustBeGreaterThanZero => '金额必须大于 0';

  @override
  String get description => '描述';

  @override
  String get voiceLimitReached => '语音输入已达上限。升级到 Pro 获取无限访问';

  @override
  String get upgrade => '升级';

  @override
  String get speechNotAvailable => '语音识别不可用';

  @override
  String get pleaseEnterAccountFirst => '请先选择账户';

  @override
  String get pleaseCreateAccountFirst => '请先创建账户';

  @override
  String get updateTransaction => '更新交易';

  @override
  String get addTransaction => '添加交易';

  @override
  String get accounts => '账户';

  @override
  String get connectBank => '连接银行';

  @override
  String get noAccountsYet => '暂无账户';

  @override
  String get tapPlusToAddAccount => '点击 + 添加您的第一个账户';

  @override
  String get editAccount => '编辑账户';

  @override
  String get newAccount => '新账户';

  @override
  String get accountName => '账户名称';

  @override
  String get pleaseEnterAccountName => '请输入账户名称';

  @override
  String get accountType => '账户类型';

  @override
  String get checking => '活期';

  @override
  String get savings => '储蓄';

  @override
  String get creditCard => '信用卡';

  @override
  String get cash => '现金';

  @override
  String get bankOptional => '银行（可选）';

  @override
  String get currency => '货币';

  @override
  String get initialBalance => '初始余额';

  @override
  String get updateAccount => '更新账户';

  @override
  String get connectYourBank => '连接您的银行账户';

  @override
  String get connectBankDescription => '安全地关联您的银行，自动导入交易并保持余额更新。';

  @override
  String get bankLevelEncryption => '由 Plaid 提供银行级加密';

  @override
  String failedToStartBankConnection(String error) {
    return '银行连接失败：$error';
  }

  @override
  String connectionCancelled(String message) {
    return '连接已取消：$message';
  }

  @override
  String successfullyLinkedAccounts(int count) {
    return '成功连接 $count 个账户';
  }

  @override
  String get subscription => '订阅';

  @override
  String get manageSubscription => '管理订阅';

  @override
  String get upgradeToPremium => '升级到高级版';

  @override
  String get active => '活跃';

  @override
  String get editProfile => '编辑个人资料';

  @override
  String get manageAccounts => '管理账户';

  @override
  String get preferences => '偏好设置';

  @override
  String get theme => '主题';

  @override
  String get dark => '深色';

  @override
  String get light => '浅色';

  @override
  String get system => '系统';

  @override
  String get biometricLogin => '生物识别登录';

  @override
  String get language => '语言';

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
  String get pushNotifications => '推送通知';

  @override
  String get data => '数据';

  @override
  String get scanReceipt => '扫描收据';

  @override
  String get importTransactions => '导入交易';

  @override
  String get exportData => '导出数据';

  @override
  String get scheduledPayments => '定期付款';

  @override
  String get budgets => '预算';

  @override
  String get debts => '债务';

  @override
  String get about => '关于';

  @override
  String get appVersion => '应用版本';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get termsOfService => '服务条款';

  @override
  String get dangerZone => '危险区域';

  @override
  String get deleteAccount => '删除账户';

  @override
  String get logout => '退出登录';

  @override
  String get premium => '高级版';

  @override
  String get free => '免费';

  @override
  String get selectCurrency => '选择货币';

  @override
  String get selectTheme => '选择主题';

  @override
  String get deleteAccountConfirm => '确定要删除您的账户吗？此操作无法撤销。您的所有数据将被永久删除。';

  @override
  String get logoutConfirm => '确定要退出登录吗？';

  @override
  String get profileUpdated => '个人资料已更新';

  @override
  String get name => '姓名';

  @override
  String get enterYourName => '输入您的姓名';

  @override
  String get nameIsRequired => '姓名为必填项';

  @override
  String get saveChanges => '保存更改';

  @override
  String get profileUpdatedSuccessfully => '个人资料更新成功';

  @override
  String get inactive => '非活跃';

  @override
  String get noActiveBudgets => '没有活跃预算';

  @override
  String get noInactiveBudgets => '没有非活跃预算';

  @override
  String get tapPlusToCreateBudget => '点击 + 创建您的第一个预算';

  @override
  String get deleteBudget => '删除预算';

  @override
  String deleteBudgetConfirm(String name) {
    return '确定要删除「$name」吗？';
  }

  @override
  String get editBudget => '编辑预算';

  @override
  String get newBudget => '新预算';

  @override
  String get budgetName => '预算名称';

  @override
  String get pleaseEnterBudgetName => '请输入预算名称';

  @override
  String get budgetLimit => '预算限额';

  @override
  String get pleaseEnterBudgetLimit => '请输入预算限额';

  @override
  String get pleaseEnterValidPositiveNumber => '请输入有效的正数';

  @override
  String get period => '周期';

  @override
  String get weekly => '每周';

  @override
  String get monthly => '每月';

  @override
  String get yearly => '每年';

  @override
  String get startDate => '开始日期';

  @override
  String get endDateOptional => '结束日期（可选）';

  @override
  String get noEndDate => '无结束日期';

  @override
  String get updateBudget => '更新预算';

  @override
  String get createBudget => '创建预算';

  @override
  String get paidOff => '已还清';

  @override
  String get noActiveDebts => '没有活跃债务';

  @override
  String get noPaidOffDebts => '没有已还清债务';

  @override
  String get noDebts => '没有债务';

  @override
  String get tapPlusToAddDebt => '点击 + 添加您的第一笔债务';

  @override
  String get editDebt => '编辑债务';

  @override
  String get newDebt => '新债务';

  @override
  String get debtName => '债务名称';

  @override
  String get pleaseEnterDebtName => '请输入债务名称';

  @override
  String get debtType => '债务类型';

  @override
  String get personalLoan => '个人贷款';

  @override
  String get mortgage => '按揭贷款';

  @override
  String get autoLoan => '汽车贷款';

  @override
  String get studentLoan => '助学贷款';

  @override
  String get personal => '个人';

  @override
  String get other => '其他';

  @override
  String get originalAmount => '原始金额';

  @override
  String get pleaseEnterOriginalAmount => '请输入原始金额';

  @override
  String get currentBalance => '当前余额';

  @override
  String get pleaseEnterCurrentBalance => '请输入当前余额';

  @override
  String get interestRate => '利率（%）';

  @override
  String get minimumPayment => '最低还款';

  @override
  String get dueDay => '还款日（1-31）';

  @override
  String get pleaseEnterValidDay => '请输入 1 到 31 之间的日期';

  @override
  String get creditorNameOptional => '债权人名称（可选）';

  @override
  String get expectedPayoffDateOptional => '预计还清日期（可选）';

  @override
  String get noDateSet => '未设置日期';

  @override
  String get notesOptional => '备注（可选）';

  @override
  String get updateDebt => '更新债务';

  @override
  String get addDebt => '添加债务';

  @override
  String get debtDetails => '债务详情';

  @override
  String get original => '原始';

  @override
  String get remaining => '剩余';

  @override
  String get interest => '利息';

  @override
  String get minPayment => '最低还款';

  @override
  String get start => '开始';

  @override
  String get expectedPayoff => '预计还清';

  @override
  String get notes => '备注';

  @override
  String get recordPayment => '记录还款';

  @override
  String get paymentAmount => '还款金额';

  @override
  String get pleaseEnterPaymentAmount => '请输入还款金额';

  @override
  String get paymentDate => '还款日期';

  @override
  String get aiFinancialAdvisor => 'AI 财务顾问';

  @override
  String get oracleWelcome => '你好！我是预言师，您的 AI 财务顾问。';

  @override
  String get oracleAsk => '关于财务问题随时问我。';

  @override
  String get oracleHint => '向预言师咨询财务问题...';

  @override
  String get markAllAsRead => '全部标记为已读';

  @override
  String get failedToLoadNotifications => '无法加载通知';

  @override
  String get noNotificationsYet => '暂无通知';

  @override
  String get notificationsHint => '您的提醒和更新将显示在这里';

  @override
  String get unlockFullPower => '解锁全部功能';

  @override
  String get unlockSubtitle => '无限访问所有高级功能';

  @override
  String get premiumIncludes => '高级版包括：';

  @override
  String get featureUnlimitedAccounts => '无限银行账户';

  @override
  String get featureBankSync => '通过 Plaid 自动银行同步';

  @override
  String get featureReceiptScanning => '收据扫描（OCR）';

  @override
  String get featureAiPredictions => 'AI 预测和预言师';

  @override
  String get featureSmartCategorization => '智能分类';

  @override
  String get featureBudgetsDebts => '预算和债务跟踪';

  @override
  String get featureExport => '数据导出（CSV/PDF）';

  @override
  String get featureMultiCurrency => '多币种支持';

  @override
  String get yearlyPrice => '\$34.99/年';

  @override
  String get monthlyPrice => '\$4.99/月';

  @override
  String get lifetimePrice => '\$99.99';

  @override
  String get yearlySaving => '节省 42% — 仅 \$2.92/月';

  @override
  String get cancelAnytime => '随时取消';

  @override
  String get lifetimeSubtitle => '一次付款，永久拥有';

  @override
  String get bestValue => '最佳价值';

  @override
  String get restorePurchases => '恢复购买';

  @override
  String get processingPurchase => '正在处理购买...';

  @override
  String get welcomeToPremium => '欢迎加入高级版！';

  @override
  String get noActiveScheduledPayments => '没有活跃的定期付款';

  @override
  String get noInactiveScheduledPayments => '没有非活跃的定期付款';

  @override
  String get tapPlusToAddScheduledPayment => '点击 + 添加您的第一个定期付款';

  @override
  String get importCsv => '导入 CSV';

  @override
  String get importTransactionsTitle => '导入交易';

  @override
  String get importDescription => '上传 CSV 文件将交易导入您的账户';

  @override
  String get selectAccount => '选择账户';

  @override
  String get chooseAnAccount => '选择一个账户';

  @override
  String get pickCsvFile => '选择 CSV 文件';

  @override
  String percentUploaded(int progress) {
    return '已上传 $progress%';
  }

  @override
  String get importComplete => '导入完成！';

  @override
  String get imported => '已导入';

  @override
  String get skipped => '已跳过';

  @override
  String get errors => '错误';

  @override
  String get importAnotherFile => '导入另一个文件';

  @override
  String get uploadAndImport => '上传并导入';

  @override
  String get exportFormat => '导出格式';

  @override
  String get csv => 'CSV';

  @override
  String get pdf => 'PDF';

  @override
  String get dateRangeOptional => '日期范围（可选）';

  @override
  String get endDate => '结束日期';

  @override
  String get clearDates => '清除日期';

  @override
  String get csvDescription => 'CSV 文件包含列：日期、描述、金额、类型、类别、账户';

  @override
  String get pdfDescription => 'PDF 报告包含摘要和交易表';

  @override
  String exportFormat2(String format) {
    return '导出 $format';
  }

  @override
  String get scanReceiptAutoFill => '扫描收据以自动填充\n交易详情';

  @override
  String get takePhoto => '拍照';

  @override
  String get chooseFromGallery => '从相册选择';

  @override
  String get processingReceipt => '正在处理收据...';

  @override
  String confidencePercent(String confidence) {
    return '置信度：$confidence%';
  }

  @override
  String get merchant => '商户';

  @override
  String get pleaseFillRequiredFields => '请填写所有必填字段';

  @override
  String get createTransaction => '创建交易';

  @override
  String get scanAnotherReceipt => '扫描另一张收据';

  @override
  String get transactionCreatedFromReceipt => '从收据创建了交易';

  @override
  String get offlineMode => '离线模式';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get totalBalance => '总余额';

  @override
  String get spendingByCategory => '按类别支出';

  @override
  String get noSpendingDataYet => '暂无支出数据';

  @override
  String get pleaseSelectAccount => '请选择一个账户';

  @override
  String get editScheduledPayment => '编辑定期付款';

  @override
  String get newScheduledPayment => '新定期付款';

  @override
  String get paymentName => '付款名称';

  @override
  String get pleaseEnterPaymentName => '请输入付款名称';

  @override
  String get frequency => '频率';

  @override
  String get descriptionOptional => '描述（可选）';

  @override
  String get updatePayment => '更新付款';

  @override
  String get createPayment => '创建付款';

  @override
  String get deleteScheduledPayment => '删除定期付款';

  @override
  String get executePayment => '执行付款';

  @override
  String executePaymentConfirm(String name) {
    return '立即执行「$name」？';
  }

  @override
  String get execute => '执行';

  @override
  String get receiptHistory => '收据历史';

  @override
  String get noReceiptScansYet => '暂无收据扫描';

  @override
  String get scanReceiptToGetStarted => '扫描收据以开始';

  @override
  String get addAccount => '添加账户';

  @override
  String get noCategory => '无类别';

  @override
  String get category => '类别';

  @override
  String get vsLastMonth => '与上月相比';

  @override
  String get receiptDetails => '收据详情';

  @override
  String get scanInfo => '扫描信息';

  @override
  String get filename => '文件名';

  @override
  String get scannedOn => '扫描日期';

  @override
  String get receiptData => '收据数据';

  @override
  String get totalAmount => '总金额';

  @override
  String get receiptDate => '收据日期';

  @override
  String get confidence => '置信度';

  @override
  String get completed => '已完成';

  @override
  String get failed => '失败';

  @override
  String get processing => '处理中';

  @override
  String get items => '项目';
}
