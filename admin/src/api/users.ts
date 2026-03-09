import client from './client';

export interface User {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  role: 'USER' | 'ADMIN';
  tier: 'FREE' | 'PREMIUM';
  createdAt: string;
  lastLoginAt: string | null;
  subscription?: Subscription;
  accountsCount?: number;
  transactionsCount?: number;
}

export interface Subscription {
  tier: 'FREE' | 'PREMIUM';
  status: 'ACTIVE' | 'CANCELLED' | 'EXPIRED';
  expiresAt: string | null;
}

export interface UsersParams {
  page?: number;
  pageSize?: number;
  search?: string;
  role?: string;
  tier?: string;
  sortField?: string;
  sortOrder?: string;
}

export interface PaginatedUsers {
  data: User[];
  total: number;
  page: number;
  pageSize: number;
}

export async function getUsers(params: UsersParams = {}): Promise<PaginatedUsers> {
  const { data } = await client.get<PaginatedUsers>('/admin/users', { params });
  return data;
}

export async function getUser(id: string): Promise<User> {
  const { data } = await client.get<User>(`/admin/users/${id}`);
  return data;
}

export async function updateUser(
  id: string,
  updates: Partial<Pick<User, 'role' | 'firstName' | 'lastName'>>,
): Promise<User> {
  const { data } = await client.patch<User>(`/admin/users/${id}`, updates);
  return data;
}

export async function deleteUser(id: string): Promise<void> {
  await client.delete(`/admin/users/${id}`);
}

export async function updateSubscription(
  userId: string,
  updates: Partial<Pick<Subscription, 'tier' | 'status'>>,
): Promise<Subscription> {
  const { data } = await client.patch<Subscription>(
    `/admin/users/${userId}/subscription`,
    updates,
  );
  return data;
}
