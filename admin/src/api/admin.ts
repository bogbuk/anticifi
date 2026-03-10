import client from './client';

// --- Stats ---
export interface AdminStats {
  totalUsers: number;
  premiumUsers: number;
  activeUsers: number;
  totalTransactions: number;
  totalAccounts: number;
  totalBudgets: number;
  totalDebts: number;
  totalReceipts: number;
  userGrowth: { date: string; count: number }[];
  transactionVolume: { date: string; count: number }[];
}

export async function getStats(): Promise<AdminStats> {
  const { data } = await client.get<AdminStats>('/admin/stats');
  return data;
}

// --- Analytics ---
export interface TimeSeriesPoint {
  date: string;
  count: number;
  total?: number;
}

export interface RetentionData {
  dau: number;
  wau: number;
  mau: number;
  total: number;
}

export interface CategoryBreakdown {
  name: string;
  count: number;
  total: number;
}

export interface SubscriptionBreakdown {
  tier: string;
  status: string;
  count: number;
}

export const getAnalyticsUserGrowth = (days = 90) =>
  client.get<TimeSeriesPoint[]>('/admin/analytics/user-growth', { params: { days } }).then(r => r.data);

export const getAnalyticsTransactions = (days = 90) =>
  client.get<TimeSeriesPoint[]>('/admin/analytics/transactions', { params: { days } }).then(r => r.data);

export const getAnalyticsRevenue = (days = 90) =>
  client.get<TimeSeriesPoint[]>('/admin/analytics/revenue', { params: { days } }).then(r => r.data);

export const getAnalyticsRetention = () =>
  client.get<RetentionData>('/admin/analytics/retention').then(r => r.data);

export const getAnalyticsCategories = () =>
  client.get<CategoryBreakdown[]>('/admin/analytics/categories').then(r => r.data);

export const getAnalyticsSubscriptions = () =>
  client.get<SubscriptionBreakdown[]>('/admin/analytics/subscriptions').then(r => r.data);

// --- Transactions ---
export interface TransactionItem {
  id: string;
  amount: number;
  type: 'income' | 'expense';
  description: string;
  date: string;
  user?: { id: string; email: string; firstName: string; lastName: string };
}

export interface PaginatedResult<T> {
  data: T[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

export const getAllTransactions = (params: Record<string, any> = {}) =>
  client.get<PaginatedResult<TransactionItem>>('/admin/transactions', { params }).then(r => r.data);

export const getUserTransactions = (userId: string, params: Record<string, any> = {}) =>
  client.get<PaginatedResult<TransactionItem>>(`/admin/users/${userId}/transactions`, { params }).then(r => r.data);

// --- Accounts ---
export interface AccountItem {
  id: string;
  name: string;
  type: string;
  bank: string;
  currency: string;
  balance: number;
  connectionType: string;
  createdAt: string;
}

export const getUserAccounts = (userId: string) =>
  client.get<AccountItem[]>(`/admin/users/${userId}/accounts`).then(r => r.data);

// --- Budgets ---
export interface BudgetItem {
  id: string;
  name: string;
  amount: number;
  period: string;
  isActive: boolean;
  startDate: string;
}

export const getUserBudgets = (userId: string) =>
  client.get<BudgetItem[]>(`/admin/users/${userId}/budgets`).then(r => r.data);

// --- Debts ---
export interface DebtItem {
  id: string;
  name: string;
  originalAmount: number;
  currentBalance: number;
  interestRate: number;
  type: string;
  isActive: boolean;
  isPaidOff: boolean;
}

export const getUserDebts = (userId: string) =>
  client.get<DebtItem[]>(`/admin/users/${userId}/debts`).then(r => r.data);

// --- Subscriptions ---
export interface SubscriptionItem {
  id: string;
  tier: string;
  status: string;
  period: string;
  expiresAt: string | null;
  createdAt: string;
  user?: { id: string; email: string; firstName: string; lastName: string };
}

export const getAllSubscriptions = (params: Record<string, any> = {}) =>
  client.get<PaginatedResult<SubscriptionItem>>('/admin/subscriptions', { params }).then(r => r.data);

// --- Receipts ---
export interface ReceiptItem {
  id: string;
  status: string;
  originalFilename: string;
  confidence: number;
  parsedData: any;
  createdAt: string;
  user?: { id: string; email: string; firstName: string; lastName: string };
}

export const getAllReceipts = (params: Record<string, any> = {}) =>
  client.get<PaginatedResult<ReceiptItem>>('/admin/receipts', { params }).then(r => r.data);

// --- Notifications ---
export const broadcastNotification = (payload: { title: string; body: string; userIds?: string[] }) =>
  client.post('/admin/notifications/broadcast', payload).then(r => r.data);

// --- Audit Logs ---
export interface AuditLogItem {
  id: string;
  action: string;
  targetType: string;
  targetId: string;
  details: Record<string, any>;
  ipAddress: string;
  createdAt: string;
  admin?: { id: string; email: string; firstName: string; lastName: string };
}

export const getAuditLogs = (params: Record<string, any> = {}) =>
  client.get<PaginatedResult<AuditLogItem>>('/admin/audit-logs', { params }).then(r => r.data);
