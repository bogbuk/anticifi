// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'AnticiFi';

  @override
  String get dashboard => 'Painel';

  @override
  String get transactions => 'Transações';

  @override
  String get oracle => 'Oráculo';

  @override
  String get settings => 'Configurações';

  @override
  String get welcomeBack => 'Bem-vindo de volta';

  @override
  String get signInToContinue => 'Entre para continuar';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Senha';

  @override
  String get signIn => 'Entrar';

  @override
  String get dontHaveAccount => 'Não tem conta? ';

  @override
  String get signUp => 'Cadastrar';

  @override
  String get enableBiometricTitle => 'Ativar login biométrico?';

  @override
  String get enableBiometricContent =>
      'Use Face ID ou Touch ID para acesso mais rápido.';

  @override
  String get notNow => 'Agora não';

  @override
  String get enable => 'Ativar';

  @override
  String get createAccount => 'Criar conta';

  @override
  String get signUpToGetStarted => 'Cadastre-se para começar';

  @override
  String get fullName => 'Nome completo';

  @override
  String get confirmPassword => 'Confirmar senha';

  @override
  String get passwordsDoNotMatch => 'As senhas não coincidem';

  @override
  String get alreadyHaveAccount => 'Já tem uma conta? ';

  @override
  String get onboardingTitle1 => 'Bem-vindo ao AnticiFi';

  @override
  String get onboardingDesc1 =>
      'Seu assistente financeiro com IA que ajuda a gerenciar dinheiro de forma mais inteligente e planejar o futuro.';

  @override
  String get onboardingTitle2 => 'Previsões inteligentes';

  @override
  String get onboardingDesc2 =>
      'Nossa IA analisa seus padrões de gastos e prevê despesas futuras para que você nunca seja pego de surpresa.';

  @override
  String get onboardingTitle3 => 'Mantenha o controle';

  @override
  String get onboardingDesc3 =>
      'Defina orçamentos, gerencie dívidas e receba notificações para manter suas finanças saudáveis.';

  @override
  String get skip => 'Pular';

  @override
  String get next => 'Próximo';

  @override
  String get getStarted => 'Começar';

  @override
  String get failedToLoadDashboard => 'Falha ao carregar o painel';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get recentTransactions => 'Transações recentes';

  @override
  String get noRecentTransactions => 'Sem transações recentes';

  @override
  String get all => 'Todas';

  @override
  String get income => 'Receita';

  @override
  String get expense => 'Despesa';

  @override
  String get noTransactionsYet => 'Nenhuma transação ainda';

  @override
  String get tapPlusToAddTransaction =>
      'Toque em + para adicionar sua primeira transação';

  @override
  String get deleteTransaction => 'Excluir transação';

  @override
  String get deleteTransactionConfirm =>
      'Tem certeza de que deseja excluir esta transação?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Excluir';

  @override
  String get editTransaction => 'Editar transação';

  @override
  String get newTransaction => 'Nova transação';

  @override
  String get account => 'Conta';

  @override
  String get amount => 'Valor';

  @override
  String get pleaseEnterAmount => 'Insira o valor';

  @override
  String get pleaseEnterValidNumber => 'Insira um número válido';

  @override
  String get amountMustBeGreaterThanZero => 'O valor deve ser maior que 0';

  @override
  String get description => 'Descrição';

  @override
  String get voiceLimitReached =>
      'Limite de entrada de voz atingido. Atualize para Pro para acesso ilimitado';

  @override
  String get upgrade => 'Atualizar';

  @override
  String get speechNotAvailable => 'Reconhecimento de voz não disponível';

  @override
  String get pleaseEnterAccountFirst => 'Primeiro selecione uma conta';

  @override
  String get pleaseCreateAccountFirst => 'Primeiro crie uma conta';

  @override
  String get updateTransaction => 'Atualizar transação';

  @override
  String get addTransaction => 'Adicionar transação';

  @override
  String get accounts => 'Contas';

  @override
  String get connectBank => 'Conectar banco';

  @override
  String get noAccountsYet => 'Nenhuma conta ainda';

  @override
  String get tapPlusToAddAccount =>
      'Toque em + para adicionar sua primeira conta';

  @override
  String get editAccount => 'Editar conta';

  @override
  String get newAccount => 'Nova conta';

  @override
  String get accountName => 'Nome da conta';

  @override
  String get pleaseEnterAccountName => 'Insira o nome da conta';

  @override
  String get accountType => 'Tipo de conta';

  @override
  String get checking => 'Corrente';

  @override
  String get savings => 'Poupança';

  @override
  String get creditCard => 'Cartão de crédito';

  @override
  String get cash => 'Dinheiro';

  @override
  String get bankOptional => 'Banco (opcional)';

  @override
  String get currency => 'Moeda';

  @override
  String get initialBalance => 'Saldo inicial';

  @override
  String get updateAccount => 'Atualizar conta';

  @override
  String get connectYourBank => 'Conecte sua conta bancária';

  @override
  String get connectBankDescription =>
      'Vincule seu banco com segurança para importar transações automaticamente e manter seus saldos atualizados.';

  @override
  String get bankLevelEncryption => 'Criptografia de nível bancário pelo Plaid';

  @override
  String failedToStartBankConnection(String error) {
    return 'Falha na conexão bancária: $error';
  }

  @override
  String connectionCancelled(String message) {
    return 'Conexão cancelada: $message';
  }

  @override
  String successfullyLinkedAccounts(int count) {
    return '$count conta(s) vinculada(s) com sucesso';
  }

  @override
  String get subscription => 'Assinatura';

  @override
  String get manageSubscription => 'Gerenciar assinatura';

  @override
  String get upgradeToPremium => 'Atualizar para Premium';

  @override
  String get active => 'Ativo';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get manageAccounts => 'Gerenciar contas';

  @override
  String get preferences => 'Preferências';

  @override
  String get theme => 'Tema';

  @override
  String get dark => 'Escuro';

  @override
  String get light => 'Claro';

  @override
  String get system => 'Sistema';

  @override
  String get biometricLogin => 'Login biométrico';

  @override
  String get language => 'Idioma';

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
  String get notifications => 'Notificações';

  @override
  String get pushNotifications => 'Notificações push';

  @override
  String get data => 'Dados';

  @override
  String get scanReceipt => 'Escanear recibo';

  @override
  String get importTransactions => 'Importar transações';

  @override
  String get exportData => 'Exportar dados';

  @override
  String get scheduledPayments => 'Pagamentos agendados';

  @override
  String get budgets => 'Orçamentos';

  @override
  String get debts => 'Dívidas';

  @override
  String get about => 'Sobre';

  @override
  String get appVersion => 'Versão do app';

  @override
  String get privacyPolicy => 'Política de privacidade';

  @override
  String get termsOfService => 'Termos de serviço';

  @override
  String get dangerZone => 'Zona de perigo';

  @override
  String get deleteAccount => 'Excluir conta';

  @override
  String get logout => 'Sair';

  @override
  String get premium => 'PREMIUM';

  @override
  String get free => 'GRÁTIS';

  @override
  String get selectCurrency => 'Selecionar moeda';

  @override
  String get selectTheme => 'Selecionar tema';

  @override
  String get deleteAccountConfirm =>
      'Tem certeza de que deseja excluir sua conta? Esta ação não pode ser desfeita. Todos os seus dados serão permanentemente removidos.';

  @override
  String get logoutConfirm => 'Tem certeza de que deseja sair?';

  @override
  String get profileUpdated => 'Perfil atualizado';

  @override
  String get name => 'Nome';

  @override
  String get enterYourName => 'Insira seu nome';

  @override
  String get nameIsRequired => 'Nome é obrigatório';

  @override
  String get saveChanges => 'Salvar alterações';

  @override
  String get profileUpdatedSuccessfully => 'Perfil atualizado com sucesso';

  @override
  String get inactive => 'Inativo';

  @override
  String get noActiveBudgets => 'Sem orçamentos ativos';

  @override
  String get noInactiveBudgets => 'Sem orçamentos inativos';

  @override
  String get tapPlusToCreateBudget =>
      'Toque em + para criar seu primeiro orçamento';

  @override
  String get deleteBudget => 'Excluir orçamento';

  @override
  String deleteBudgetConfirm(String name) {
    return 'Tem certeza de que deseja excluir \"$name\"?';
  }

  @override
  String get editBudget => 'Editar orçamento';

  @override
  String get newBudget => 'Novo orçamento';

  @override
  String get budgetName => 'Nome do orçamento';

  @override
  String get pleaseEnterBudgetName => 'Insira o nome do orçamento';

  @override
  String get budgetLimit => 'Limite do orçamento';

  @override
  String get pleaseEnterBudgetLimit => 'Insira o limite do orçamento';

  @override
  String get pleaseEnterValidPositiveNumber =>
      'Insira um número positivo válido';

  @override
  String get period => 'Período';

  @override
  String get weekly => 'Semanal';

  @override
  String get monthly => 'Mensal';

  @override
  String get yearly => 'Anual';

  @override
  String get startDate => 'Data de início';

  @override
  String get endDateOptional => 'Data de fim (opcional)';

  @override
  String get noEndDate => 'Sem data de fim';

  @override
  String get updateBudget => 'Atualizar orçamento';

  @override
  String get createBudget => 'Criar orçamento';

  @override
  String get paidOff => 'Quitado';

  @override
  String get noActiveDebts => 'Sem dívidas ativas';

  @override
  String get noPaidOffDebts => 'Sem dívidas quitadas';

  @override
  String get noDebts => 'Sem dívidas';

  @override
  String get tapPlusToAddDebt =>
      'Toque em + para adicionar sua primeira dívida';

  @override
  String get editDebt => 'Editar dívida';

  @override
  String get newDebt => 'Nova dívida';

  @override
  String get debtName => 'Nome da dívida';

  @override
  String get pleaseEnterDebtName => 'Insira o nome da dívida';

  @override
  String get debtType => 'Tipo de dívida';

  @override
  String get personalLoan => 'Empréstimo pessoal';

  @override
  String get mortgage => 'Hipoteca';

  @override
  String get autoLoan => 'Financiamento de veículo';

  @override
  String get studentLoan => 'Empréstimo estudantil';

  @override
  String get personal => 'Pessoal';

  @override
  String get other => 'Outro';

  @override
  String get originalAmount => 'Valor original';

  @override
  String get pleaseEnterOriginalAmount => 'Insira o valor original';

  @override
  String get currentBalance => 'Saldo atual';

  @override
  String get pleaseEnterCurrentBalance => 'Insira o saldo atual';

  @override
  String get interestRate => 'Taxa de juros (%)';

  @override
  String get minimumPayment => 'Pagamento mínimo';

  @override
  String get dueDay => 'Dia de vencimento (1-31)';

  @override
  String get pleaseEnterValidDay => 'Insira um dia entre 1 e 31';

  @override
  String get creditorNameOptional => 'Nome do credor (opcional)';

  @override
  String get expectedPayoffDateOptional =>
      'Data prevista de quitação (opcional)';

  @override
  String get noDateSet => 'Nenhuma data definida';

  @override
  String get notesOptional => 'Notas (opcional)';

  @override
  String get updateDebt => 'Atualizar dívida';

  @override
  String get addDebt => 'Adicionar dívida';

  @override
  String get debtDetails => 'Detalhes da dívida';

  @override
  String get original => 'Original';

  @override
  String get remaining => 'Restante';

  @override
  String get interest => 'Juros';

  @override
  String get minPayment => 'Pag. mín.';

  @override
  String get start => 'Início';

  @override
  String get expectedPayoff => 'Quitação prevista';

  @override
  String get notes => 'Notas';

  @override
  String get recordPayment => 'Registrar pagamento';

  @override
  String get paymentAmount => 'Valor do pagamento';

  @override
  String get pleaseEnterPaymentAmount => 'Insira o valor do pagamento';

  @override
  String get paymentDate => 'Data do pagamento';

  @override
  String get aiFinancialAdvisor => 'Consultor financeiro IA';

  @override
  String get oracleWelcome =>
      'Olá! Sou o Oráculo, seu consultor financeiro IA.';

  @override
  String get oracleAsk => 'Pergunte-me qualquer coisa sobre suas finanças.';

  @override
  String get oracleHint => 'Pergunte ao Oráculo sobre finanças...';

  @override
  String get markAllAsRead => 'Marcar tudo como lido';

  @override
  String get failedToLoadNotifications => 'Falha ao carregar notificações';

  @override
  String get noNotificationsYet => 'Nenhuma notificação ainda';

  @override
  String get notificationsHint => 'Seus alertas e atualizações aparecerão aqui';

  @override
  String get unlockFullPower => 'Desbloqueie todo o poder';

  @override
  String get unlockSubtitle => 'Acesso ilimitado a todos os recursos premium';

  @override
  String get premiumIncludes => 'Premium inclui:';

  @override
  String get featureUnlimitedAccounts => 'Contas bancárias ilimitadas';

  @override
  String get featureBankSync => 'Sincronização automática com Plaid';

  @override
  String get featureReceiptScanning => 'Escaneamento de recibos (OCR)';

  @override
  String get featureAiPredictions => 'Previsões IA e Oráculo';

  @override
  String get featureSmartCategorization => 'Categorização inteligente';

  @override
  String get featureBudgetsDebts => 'Orçamentos e rastreamento de dívidas';

  @override
  String get featureExport => 'Exportação de dados (CSV/PDF)';

  @override
  String get featureMultiCurrency => 'Suporte multi-moeda';

  @override
  String get yearlyPrice => 'R\$ 34,99/ano';

  @override
  String get monthlyPrice => 'R\$ 4,99/mês';

  @override
  String get lifetimePrice => 'R\$ 99,99';

  @override
  String get yearlySaving => 'Economize 42% — apenas R\$ 2,92/mês';

  @override
  String get cancelAnytime => 'Cancele a qualquer momento';

  @override
  String get lifetimeSubtitle => 'Um pagamento, para sempre';

  @override
  String get bestValue => 'MELHOR VALOR';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get processingPurchase => 'Processando compra...';

  @override
  String get welcomeToPremium => 'Bem-vindo ao Premium!';

  @override
  String get noActiveScheduledPayments => 'Sem pagamentos agendados ativos';

  @override
  String get noInactiveScheduledPayments => 'Sem pagamentos agendados inativos';

  @override
  String get tapPlusToAddScheduledPayment =>
      'Toque em + para agendar seu primeiro pagamento';

  @override
  String get importCsv => 'Importar CSV';

  @override
  String get importTransactionsTitle => 'Importar transações';

  @override
  String get importDescription =>
      'Envie um arquivo CSV para importar transações para sua conta';

  @override
  String get selectAccount => 'Selecionar conta';

  @override
  String get chooseAnAccount => 'Escolha uma conta';

  @override
  String get pickCsvFile => 'Escolher arquivo CSV';

  @override
  String percentUploaded(int progress) {
    return '$progress% enviado';
  }

  @override
  String get importComplete => 'Importação completa!';

  @override
  String get imported => 'Importadas';

  @override
  String get skipped => 'Ignoradas';

  @override
  String get errors => 'Erros';

  @override
  String get importAnotherFile => 'Importar outro arquivo';

  @override
  String get uploadAndImport => 'Enviar e importar';

  @override
  String get exportFormat => 'Formato de exportação';

  @override
  String get csv => 'CSV';

  @override
  String get pdf => 'PDF';

  @override
  String get dateRangeOptional => 'Período (opcional)';

  @override
  String get endDate => 'Data de fim';

  @override
  String get clearDates => 'Limpar datas';

  @override
  String get csvDescription =>
      'Arquivo CSV com colunas: Data, Descrição, Valor, Tipo, Categoria, Conta';

  @override
  String get pdfDescription =>
      'Relatório PDF com resumo e tabela de transações';

  @override
  String exportFormat2(String format) {
    return 'Exportar $format';
  }

  @override
  String get scanReceiptAutoFill =>
      'Escaneie um recibo para preencher\nautomaticamente os detalhes';

  @override
  String get takePhoto => 'Tirar foto';

  @override
  String get chooseFromGallery => 'Escolher da galeria';

  @override
  String get processingReceipt => 'Processando recibo...';

  @override
  String confidencePercent(String confidence) {
    return 'Confiança: $confidence%';
  }

  @override
  String get merchant => 'Comerciante';

  @override
  String get pleaseFillRequiredFields =>
      'Preencha todos os campos obrigatórios';

  @override
  String get createTransaction => 'Criar transação';

  @override
  String get scanAnotherReceipt => 'Escanear outro recibo';

  @override
  String get transactionCreatedFromReceipt => 'Transação criada do recibo';

  @override
  String get offlineMode => 'Modo offline';

  @override
  String get selectLanguage => 'Selecionar idioma';
}
