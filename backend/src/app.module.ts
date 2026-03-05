import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { SequelizeModule } from '@nestjs/sequelize';
import { APP_FILTER } from '@nestjs/core';
import { databaseConfig } from './config/database.config.js';
import { AuthModule } from './modules/auth/auth.module.js';
import { UsersModule } from './modules/users/users.module.js';
import { AccountsModule } from './modules/accounts/accounts.module.js';
import { TransactionsModule } from './modules/transactions/transactions.module.js';
import { CategoriesModule } from './modules/categories/categories.module.js';
import { ImportModule } from './modules/import/import.module.js';
import { DashboardModule } from './modules/dashboard/dashboard.module.js';
import { EventsModule } from './modules/events/events.module.js';
import { ScheduledPaymentsModule } from './modules/scheduled-payments/scheduled-payments.module.js';
import { PredictionModule } from './modules/predictions/prediction.module.js';
import { NotificationsModule } from './modules/notifications/notifications.module.js';
import { HealthModule } from './modules/health/health.module.js';
import { PlaidModule } from './modules/plaid/plaid.module.js';
import { BudgetsModule } from './modules/budgets/budgets.module.js';
import { DebtsModule } from './modules/debts/debts.module.js';
import { CurrencyModule } from './modules/currency/currency.module.js';
import { ReceiptsModule } from './modules/receipts/receipt.module.js';
import { ExportModule } from './modules/export/export.module.js';
import { CategorizationModule } from './modules/categorization/categorization.module.js';
import { SubscriptionsModule } from './modules/subscriptions/subscriptions.module.js';
import { HttpExceptionFilter } from './common/filters/http-exception.filter.js';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    SequelizeModule.forRootAsync(databaseConfig),
    EventsModule,
    SubscriptionsModule,
    CategorizationModule,
    AuthModule,
    UsersModule,
    AccountsModule,
    TransactionsModule,
    CategoriesModule,
    ImportModule,
    DashboardModule,
    ScheduledPaymentsModule,
    PredictionModule,
    NotificationsModule,
    PlaidModule,
    BudgetsModule,
    DebtsModule,
    CurrencyModule,
    ReceiptsModule,
    ExportModule,
    HealthModule,
  ],
  providers: [
    {
      provide: APP_FILTER,
      useClass: HttpExceptionFilter,
    },
  ],
})
export class AppModule {}
