// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'AnticiFi';

  @override
  String get dashboard => 'Panel';

  @override
  String get transactions => 'Transacciones';

  @override
  String get oracle => 'Oráculo';

  @override
  String get settings => 'Ajustes';

  @override
  String get welcomeBack => 'Bienvenido de nuevo';

  @override
  String get signInToContinue => 'Inicia sesión para continuar';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get dontHaveAccount => '¿No tienes cuenta? ';

  @override
  String get signUp => 'Registrarse';

  @override
  String get enableBiometricTitle => '¿Activar inicio biométrico?';

  @override
  String get enableBiometricContent =>
      'Usa Face ID o Touch ID para un acceso más rápido.';

  @override
  String get notNow => 'Ahora no';

  @override
  String get enable => 'Activar';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get signUpToGetStarted => 'Regístrate para comenzar';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get alreadyHaveAccount => '¿Ya tienes cuenta? ';

  @override
  String get onboardingTitle1 => 'Bienvenido a AnticiFi';

  @override
  String get onboardingDesc1 =>
      'Tu asistente financiero con IA que te ayuda a gestionar el dinero de forma más inteligente y planificar el futuro.';

  @override
  String get onboardingTitle2 => 'Predicciones inteligentes';

  @override
  String get onboardingDesc2 =>
      'Nuestra IA analiza tus patrones de gasto y pronostica los próximos gastos para que nunca te pillen desprevenido.';

  @override
  String get onboardingTitle3 => 'Mantente en el camino';

  @override
  String get onboardingDesc3 =>
      'Establece presupuestos, gestiona deudas y recibe notificaciones oportunas para mantener tus finanzas saludables.';

  @override
  String get skip => 'Saltar';

  @override
  String get next => 'Siguiente';

  @override
  String get getStarted => 'Comenzar';

  @override
  String get failedToLoadDashboard => 'Error al cargar el panel';

  @override
  String get retry => 'Reintentar';

  @override
  String get recentTransactions => 'Transacciones recientes';

  @override
  String get noRecentTransactions => 'Sin transacciones recientes';

  @override
  String get all => 'Todas';

  @override
  String get income => 'Ingreso';

  @override
  String get expense => 'Gasto';

  @override
  String get noTransactionsYet => 'Aún no hay transacciones';

  @override
  String get tapPlusToAddTransaction =>
      'Toca + para añadir tu primera transacción';

  @override
  String get deleteTransaction => 'Eliminar transacción';

  @override
  String get deleteTransactionConfirm =>
      '¿Estás seguro de que quieres eliminar esta transacción?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get editTransaction => 'Editar transacción';

  @override
  String get newTransaction => 'Nueva transacción';

  @override
  String get account => 'Cuenta';

  @override
  String get amount => 'Monto';

  @override
  String get pleaseEnterAmount => 'Ingresa el monto';

  @override
  String get pleaseEnterValidNumber => 'Ingresa un número válido';

  @override
  String get amountMustBeGreaterThanZero => 'El monto debe ser mayor que 0';

  @override
  String get description => 'Descripción';

  @override
  String get voiceLimitReached =>
      'Límite de entrada de voz alcanzado. Actualiza a Pro para acceso ilimitado';

  @override
  String get upgrade => 'Actualizar';

  @override
  String get speechNotAvailable =>
      'El reconocimiento de voz no está disponible';

  @override
  String get pleaseEnterAccountFirst => 'Primero selecciona una cuenta';

  @override
  String get pleaseCreateAccountFirst => 'Primero crea una cuenta';

  @override
  String get updateTransaction => 'Actualizar transacción';

  @override
  String get addTransaction => 'Añadir transacción';

  @override
  String get accounts => 'Cuentas';

  @override
  String get connectBank => 'Conectar banco';

  @override
  String get noAccountsYet => 'Aún no hay cuentas';

  @override
  String get tapPlusToAddAccount => 'Toca + para añadir tu primera cuenta';

  @override
  String get editAccount => 'Editar cuenta';

  @override
  String get newAccount => 'Nueva cuenta';

  @override
  String get accountName => 'Nombre de la cuenta';

  @override
  String get pleaseEnterAccountName => 'Ingresa el nombre de la cuenta';

  @override
  String get accountType => 'Tipo de cuenta';

  @override
  String get checking => 'Corriente';

  @override
  String get savings => 'Ahorros';

  @override
  String get creditCard => 'Tarjeta de crédito';

  @override
  String get cash => 'Efectivo';

  @override
  String get bankOptional => 'Banco (opcional)';

  @override
  String get currency => 'Moneda';

  @override
  String get initialBalance => 'Saldo inicial';

  @override
  String get updateAccount => 'Actualizar cuenta';

  @override
  String get connectYourBank => 'Conecta tu cuenta bancaria';

  @override
  String get connectBankDescription =>
      'Vincula tu banco de forma segura para importar transacciones automáticamente y mantener tus saldos actualizados.';

  @override
  String get bankLevelEncryption => 'Cifrado de nivel bancario con Plaid';

  @override
  String failedToStartBankConnection(String error) {
    return 'Error al conectar el banco: $error';
  }

  @override
  String connectionCancelled(String message) {
    return 'Conexión cancelada: $message';
  }

  @override
  String successfullyLinkedAccounts(int count) {
    return 'Se vincularon exitosamente $count cuenta(s)';
  }

  @override
  String get subscription => 'Suscripción';

  @override
  String get manageSubscription => 'Gestionar suscripción';

  @override
  String get upgradeToPremium => 'Actualizar a Premium';

  @override
  String get active => 'Activo';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get manageAccounts => 'Gestionar cuentas';

  @override
  String get preferences => 'Preferencias';

  @override
  String get theme => 'Tema';

  @override
  String get dark => 'Oscuro';

  @override
  String get light => 'Claro';

  @override
  String get system => 'Sistema';

  @override
  String get biometricLogin => 'Inicio biométrico';

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
  String get notifications => 'Notificaciones';

  @override
  String get pushNotifications => 'Notificaciones push';

  @override
  String get data => 'Datos';

  @override
  String get scanReceipt => 'Escanear recibo';

  @override
  String get importTransactions => 'Importar transacciones';

  @override
  String get exportData => 'Exportar datos';

  @override
  String get scheduledPayments => 'Pagos programados';

  @override
  String get budgets => 'Presupuestos';

  @override
  String get debts => 'Deudas';

  @override
  String get about => 'Acerca de';

  @override
  String get appVersion => 'Versión de la app';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get termsOfService => 'Términos de servicio';

  @override
  String get dangerZone => 'Zona de peligro';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get premium => 'PREMIUM';

  @override
  String get free => 'GRATIS';

  @override
  String get selectCurrency => 'Seleccionar moneda';

  @override
  String get selectTheme => 'Seleccionar tema';

  @override
  String get deleteAccountConfirm =>
      '¿Estás seguro de que quieres eliminar tu cuenta? Esta acción no se puede deshacer. Todos tus datos se eliminarán permanentemente.';

  @override
  String get logoutConfirm => '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get profileUpdated => 'Perfil actualizado';

  @override
  String get name => 'Nombre';

  @override
  String get enterYourName => 'Ingresa tu nombre';

  @override
  String get nameIsRequired => 'El nombre es obligatorio';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get profileUpdatedSuccessfully => 'Perfil actualizado exitosamente';

  @override
  String get inactive => 'Inactivo';

  @override
  String get noActiveBudgets => 'Sin presupuestos activos';

  @override
  String get noInactiveBudgets => 'Sin presupuestos inactivos';

  @override
  String get tapPlusToCreateBudget => 'Toca + para crear tu primer presupuesto';

  @override
  String get deleteBudget => 'Eliminar presupuesto';

  @override
  String deleteBudgetConfirm(String name) {
    return '¿Estás seguro de que quieres eliminar \"$name\"?';
  }

  @override
  String get editBudget => 'Editar presupuesto';

  @override
  String get newBudget => 'Nuevo presupuesto';

  @override
  String get budgetName => 'Nombre del presupuesto';

  @override
  String get pleaseEnterBudgetName => 'Ingresa el nombre del presupuesto';

  @override
  String get budgetLimit => 'Límite del presupuesto';

  @override
  String get pleaseEnterBudgetLimit => 'Ingresa el límite del presupuesto';

  @override
  String get pleaseEnterValidPositiveNumber =>
      'Ingresa un número positivo válido';

  @override
  String get period => 'Período';

  @override
  String get weekly => 'Semanal';

  @override
  String get monthly => 'Mensual';

  @override
  String get yearly => 'Anual';

  @override
  String get startDate => 'Fecha de inicio';

  @override
  String get endDateOptional => 'Fecha de fin (opcional)';

  @override
  String get noEndDate => 'Sin fecha de fin';

  @override
  String get updateBudget => 'Actualizar presupuesto';

  @override
  String get createBudget => 'Crear presupuesto';

  @override
  String get paidOff => 'Pagado';

  @override
  String get noActiveDebts => 'Sin deudas activas';

  @override
  String get noPaidOffDebts => 'Sin deudas pagadas';

  @override
  String get noDebts => 'Sin deudas';

  @override
  String get tapPlusToAddDebt => 'Toca + para añadir tu primera deuda';

  @override
  String get editDebt => 'Editar deuda';

  @override
  String get newDebt => 'Nueva deuda';

  @override
  String get debtName => 'Nombre de la deuda';

  @override
  String get pleaseEnterDebtName => 'Ingresa el nombre de la deuda';

  @override
  String get debtType => 'Tipo de deuda';

  @override
  String get personalLoan => 'Préstamo personal';

  @override
  String get mortgage => 'Hipoteca';

  @override
  String get autoLoan => 'Préstamo de auto';

  @override
  String get studentLoan => 'Préstamo estudiantil';

  @override
  String get personal => 'Personal';

  @override
  String get other => 'Otro';

  @override
  String get originalAmount => 'Monto original';

  @override
  String get pleaseEnterOriginalAmount => 'Ingresa el monto original';

  @override
  String get currentBalance => 'Saldo actual';

  @override
  String get pleaseEnterCurrentBalance => 'Ingresa el saldo actual';

  @override
  String get interestRate => 'Tasa de interés (%)';

  @override
  String get minimumPayment => 'Pago mínimo';

  @override
  String get dueDay => 'Día de pago (1-31)';

  @override
  String get pleaseEnterValidDay => 'Ingresa un día entre 1 y 31';

  @override
  String get creditorNameOptional => 'Nombre del acreedor (opcional)';

  @override
  String get expectedPayoffDateOptional => 'Fecha estimada de pago (opcional)';

  @override
  String get noDateSet => 'Sin fecha establecida';

  @override
  String get notesOptional => 'Notas (opcional)';

  @override
  String get updateDebt => 'Actualizar deuda';

  @override
  String get addDebt => 'Añadir deuda';

  @override
  String get debtDetails => 'Detalles de la deuda';

  @override
  String get original => 'Original';

  @override
  String get remaining => 'Restante';

  @override
  String get interest => 'Interés';

  @override
  String get minPayment => 'Pago mín.';

  @override
  String get start => 'Inicio';

  @override
  String get expectedPayoff => 'Pago estimado';

  @override
  String get notes => 'Notas';

  @override
  String get recordPayment => 'Registrar pago';

  @override
  String get paymentAmount => 'Monto del pago';

  @override
  String get pleaseEnterPaymentAmount => 'Ingresa el monto del pago';

  @override
  String get paymentDate => 'Fecha de pago';

  @override
  String get aiFinancialAdvisor => 'Asesor financiero IA';

  @override
  String get oracleWelcome => '¡Hola! Soy Oráculo, tu asesor financiero IA.';

  @override
  String get oracleAsk => 'Pregúntame cualquier cosa sobre tus finanzas.';

  @override
  String get oracleHint => 'Pregunta al Oráculo sobre tus finanzas...';

  @override
  String get markAllAsRead => 'Marcar todo como leído';

  @override
  String get failedToLoadNotifications => 'Error al cargar las notificaciones';

  @override
  String get noNotificationsYet => 'Aún no hay notificaciones';

  @override
  String get notificationsHint => 'Aquí verás tus alertas y actualizaciones';

  @override
  String get unlockFullPower => 'Desbloquea todo el poder';

  @override
  String get unlockSubtitle => 'Acceso ilimitado a todas las funciones premium';

  @override
  String get premiumIncludes => 'Premium incluye:';

  @override
  String get featureUnlimitedAccounts => 'Cuentas bancarias ilimitadas';

  @override
  String get featureBankSync => 'Sincronización automática con Plaid';

  @override
  String get featureReceiptScanning => 'Escaneo de recibos (OCR)';

  @override
  String get featureAiPredictions => 'Predicciones IA y Oráculo';

  @override
  String get featureSmartCategorization => 'Categorización inteligente';

  @override
  String get featureBudgetsDebts => 'Presupuestos y seguimiento de deudas';

  @override
  String get featureExport => 'Exportación de datos (CSV/PDF)';

  @override
  String get featureMultiCurrency => 'Soporte multi-moneda';

  @override
  String get yearlyPrice => '\$34.99/año';

  @override
  String get monthlyPrice => '\$4.99/mes';

  @override
  String get lifetimePrice => '\$99.99';

  @override
  String get yearlySaving => 'Ahorra 42% — solo \$2.92/mes';

  @override
  String get cancelAnytime => 'Cancela en cualquier momento';

  @override
  String get lifetimeSubtitle => 'Un solo pago, para siempre';

  @override
  String get bestValue => 'MEJOR VALOR';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get processingPurchase => 'Procesando compra...';

  @override
  String get welcomeToPremium => '¡Bienvenido a Premium!';

  @override
  String get noActiveScheduledPayments => 'Sin pagos programados activos';

  @override
  String get noInactiveScheduledPayments => 'Sin pagos programados inactivos';

  @override
  String get tapPlusToAddScheduledPayment =>
      'Toca + para añadir tu primer pago programado';

  @override
  String get importCsv => 'Importar CSV';

  @override
  String get importTransactionsTitle => 'Importar transacciones';

  @override
  String get importDescription =>
      'Sube un archivo CSV para importar transacciones a tu cuenta';

  @override
  String get selectAccount => 'Seleccionar cuenta';

  @override
  String get chooseAnAccount => 'Elige una cuenta';

  @override
  String get pickCsvFile => 'Elegir archivo CSV';

  @override
  String percentUploaded(int progress) {
    return '$progress% subido';
  }

  @override
  String get importComplete => '¡Importación completa!';

  @override
  String get imported => 'Importadas';

  @override
  String get skipped => 'Omitidas';

  @override
  String get errors => 'Errores';

  @override
  String get importAnotherFile => 'Importar otro archivo';

  @override
  String get uploadAndImport => 'Subir e importar';

  @override
  String get exportFormat => 'Formato de exportación';

  @override
  String get csv => 'CSV';

  @override
  String get pdf => 'PDF';

  @override
  String get dateRangeOptional => 'Rango de fechas (opcional)';

  @override
  String get endDate => 'Fecha de fin';

  @override
  String get clearDates => 'Limpiar fechas';

  @override
  String get csvDescription =>
      'Archivo CSV con columnas: Fecha, Descripción, Monto, Tipo, Categoría, Cuenta';

  @override
  String get pdfDescription =>
      'Informe PDF con resumen y tabla de transacciones';

  @override
  String exportFormat2(String format) {
    return 'Exportar $format';
  }

  @override
  String get scanReceiptAutoFill =>
      'Escanea un recibo para completar\nautomáticamente los detalles';

  @override
  String get takePhoto => 'Tomar foto';

  @override
  String get chooseFromGallery => 'Elegir de la galería';

  @override
  String get processingReceipt => 'Procesando recibo...';

  @override
  String confidencePercent(String confidence) {
    return 'Confianza: $confidence%';
  }

  @override
  String get merchant => 'Comerciante';

  @override
  String get pleaseFillRequiredFields =>
      'Completa todos los campos obligatorios';

  @override
  String get createTransaction => 'Crear transacción';

  @override
  String get scanAnotherReceipt => 'Escanear otro recibo';

  @override
  String get transactionCreatedFromReceipt => 'Transacción creada desde recibo';

  @override
  String get offlineMode => 'Modo sin conexión';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get totalBalance => 'Saldo total';

  @override
  String get spendingByCategory => 'Gastos por categoría';

  @override
  String get noSpendingDataYet => 'Aún no hay datos de gastos';

  @override
  String get pleaseSelectAccount => 'Por favor, selecciona una cuenta';

  @override
  String get editScheduledPayment => 'Editar pago programado';

  @override
  String get newScheduledPayment => 'Nuevo pago programado';

  @override
  String get paymentName => 'Nombre del pago';

  @override
  String get pleaseEnterPaymentName => 'Ingresa el nombre del pago';

  @override
  String get frequency => 'Frecuencia';

  @override
  String get descriptionOptional => 'Descripción (opcional)';

  @override
  String get updatePayment => 'Actualizar pago';

  @override
  String get createPayment => 'Crear pago';

  @override
  String get deleteScheduledPayment => 'Eliminar pago programado';

  @override
  String get executePayment => 'Ejecutar pago';

  @override
  String executePaymentConfirm(String name) {
    return '¿Ejecutar \"$name\" ahora?';
  }

  @override
  String get execute => 'Ejecutar';

  @override
  String get receiptHistory => 'Historial de recibos';

  @override
  String get noReceiptScansYet => 'Aún no hay escaneos de recibos';

  @override
  String get scanReceiptToGetStarted => 'Escanea un recibo para comenzar';

  @override
  String get addAccount => 'Añadir cuenta';

  @override
  String get noCategory => 'Sin categoría';

  @override
  String get category => 'Categoría';

  @override
  String get vsLastMonth => 'respecto al mes pasado';
}
