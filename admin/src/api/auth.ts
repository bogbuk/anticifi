import client from './client';
import { setToken, setUser, clearAuth } from '../store/auth';

interface LoginResponse {
  accessToken: string;
  refreshToken: string;
}

interface UserProfile {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  role: string;
}

export async function login(email: string, password: string): Promise<void> {
  const { data } = await client.post<LoginResponse>('/auth/login', {
    email,
    password,
  });
  setToken(data.accessToken, data.refreshToken);

  const profile = await getProfile();
  setUser(profile);
}

export async function getProfile(): Promise<UserProfile> {
  const { data } = await client.get<UserProfile>('/auth/profile');
  return data;
}

export function logout(): void {
  clearAuth();
  window.location.href = '/login';
}
