import { Module } from '@nestjs/common';
import { AccountsModule } from '../accounts/accounts.module.js';
import { TransactionsModule } from '../transactions/transactions.module.js';
import { CategoriesModule } from '../categories/categories.module.js';
import { CurrencyModule } from '../currency/currency.module.js';
import { DashboardController } from './dashboard.controller.js';
import { DashboardService } from './dashboard.service.js';

@Module({
  imports: [AccountsModule, TransactionsModule, CategoriesModule, CurrencyModule],
  controllers: [DashboardController],
  providers: [DashboardService],
})
export class DashboardModule {}
