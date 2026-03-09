import axios from 'axios';
import { clearAuth, getToken } from '../store/auth';

const client = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'https://api.anticifi.com',
  headers: {
    'Content-Type': 'application/json',
  },
});

client.interceptors.request.use((config) => {
  const token = getToken();
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

client.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      clearAuth();
      window.location.href = '/login';
    }
    return Promise.reject(error);
  },
);

export default client;
