export interface AccountSummary {
  id: string;
  name: string;
  type: string;
  currency: string;
  balance: number;
}

export interface MonthlyStats {
  income: number;
  expense: number;
}

export interface CategorySpending {
  categoryId: string | null;
  categoryName: string;
  categoryIcon: string | null;
  categoryColor: string | null;
  total: number;
}

export interface RecentTransaction {
  id: string;
  amount: number;
  type: string;
  description: string | null;
  date: string;
  categoryName: string | null;
  accountName: string | null;
}

export interface DashboardResponse {
  totalBalance: number;
  convertedTotalBalance: number;
  baseCurrency: string;
  currentMonth: MonthlyStats;
  previousMonth: MonthlyStats;
  recentTransactions: RecentTransaction[];
  accounts: AccountSummary[];
  spendingByCategory: CategorySpending[];
}
