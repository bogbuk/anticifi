import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import AdminLayout from './layouts/AdminLayout';
import ProtectedRoute from './components/ProtectedRoute';
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';
import Users from './pages/Users';
import UserDetail from './pages/UserDetail';
import Transactions from './pages/Transactions';
import Subscriptions from './pages/Subscriptions';
import Analytics from './pages/Analytics';
import Notifications from './pages/Notifications';
import Receipts from './pages/Receipts';
import AuditLogs from './pages/AuditLogs';
import System from './pages/System';

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route
          path="/"
          element={
            <ProtectedRoute>
              <AdminLayout />
            </ProtectedRoute>
          }
        >
          <Route index element={<Navigate to="/dashboard" replace />} />
          <Route path="dashboard" element={<Dashboard />} />
          <Route path="users" element={<Users />} />
          <Route path="users/:id" element={<UserDetail />} />
          <Route path="transactions" element={<Transactions />} />
          <Route path="subscriptions" element={<Subscriptions />} />
          <Route path="analytics" element={<Analytics />} />
          <Route path="notifications" element={<Notifications />} />
          <Route path="receipts" element={<Receipts />} />
          <Route path="audit-logs" element={<AuditLogs />} />
          <Route path="system" element={<System />} />
        </Route>
        <Route path="*" element={<Navigate to="/dashboard" replace />} />
      </Routes>
    </BrowserRouter>
  );
}
