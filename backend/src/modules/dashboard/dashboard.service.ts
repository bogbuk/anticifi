import { Injectable } from '@nestjs/common';
import { AccountsService } from '../accounts/accounts.service.js';
import { TransactionsService } from '../transactions/transactions.service.js';
import { CurrencyService } from '../currency/currency.service.js';
import {
  DashboardResponse,
  RecentTransaction,
} from './dto/dashboard-response.dto.js';

@Injectable()
export class DashboardService {
  constructor(
    private readonly accountsService: AccountsService,
    private readonly transactionsService: TransactionsService,
    private readonly currencyService: CurrencyService,
  ) {}

  async getDashboard(userId: string): Promise<DashboardResponse> {
    const now = new Date();
    const currentYear = now.getFullYear();
    const currentMonth = now.getMonth() + 1;
    const prevMonth = currentMonth === 1 ? 12 : currentMonth - 1;
    const prevYear = currentMonth === 1 ? currentYear - 1 : currentYear;

    const [
      accounts,
      currentMonthStats,
      previousMonthStats,
      recentRaw,
      spendingByCategory,
    ] = await Promise.all([
      this.accountsService.findAllByUserId(userId),
      this.transactionsService.getMonthlyStats(userId, currentYear, currentMonth),
      this.transactionsService.getMonthlyStats(userId, prevYear, prevMonth),
      this.transactionsService.getRecentTransactions(userId, 10),
      this.transactionsService.getSpendingByCategory(userId, currentYear, currentMonth),
    ]);

    const baseCurrency = 'USD';
    const convertedTotalBalance = await this.currencyService.convertAllToBase(
      accounts.map((acc) => ({
        balance: Number(acc.balance),
        currency: acc.currency,
      })),
      baseCurrency,
    );

    const totalBalance = accounts.reduce(
      (sum, acc) => sum + Number(acc.balance),
      0,
    );

    const accountsSummary = accounts.map((acc) => ({
      id: acc.id,
      name: acc.name,
      type: acc.type,
      currency: acc.currency,
      balance: Number(acc.balance),
    }));

    const recentTransactions: RecentTransaction[] = recentRaw.map((tx: any) => ({
      id: tx.id,
      amount: Number(tx.amount),
      type: tx.type,
      description: tx.description,
      date: tx.date,
      categoryName: tx.category?.name || null,
      accountName: tx.account?.name || null,
    }));

    return {
      totalBalance,
      convertedTotalBalance,
      baseCurrency,
      currentMonth: currentMonthStats,
      previousMonth: previousMonthStats,
      recentTransactions,
      accounts: accountsSummary,
      spendingByCategory,
    };
  }
}
