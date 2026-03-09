import client from './client';

export interface AdminStats {
  totalUsers: number;
  premiumUsers: number;
  activeUsers30d: number;
  totalTransactions: number;
}

export async function getStats(): Promise<AdminStats> {
  const { data } = await client.get<AdminStats>('/admin/stats');
  return data;
}
