import { useEffect, useState } from 'react';
import { Row, Col, Card, Statistic, Spin, Typography } from 'antd';
import {
  UserOutlined,
  CrownOutlined,
  ThunderboltOutlined,
  TransactionOutlined,
  BankOutlined,
  WalletOutlined,
  DollarOutlined,
  ScanOutlined,
} from '@ant-design/icons';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import { getStats, type AdminStats } from '../api/admin';

const { Title } = Typography;

export default function Dashboard() {
  const [stats, setStats] = useState<AdminStats | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    getStats()
      .then(setStats)
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  if (loading) {
    return (
      <div style={{ textAlign: 'center', padding: 100 }}>
        <Spin size="large" />
      </div>
    );
  }

  const cards = [
    { title: 'Total Users', value: stats?.totalUsers ?? 0, icon: <UserOutlined style={{ fontSize: 24, color: '#6366F1' }} />, color: '#EEF2FF' },
    { title: 'Premium Users', value: stats?.premiumUsers ?? 0, icon: <CrownOutlined style={{ fontSize: 24, color: '#F59E0B' }} />, color: '#FFFBEB' },
    { title: 'Active (30d)', value: stats?.activeUsers ?? 0, icon: <ThunderboltOutlined style={{ fontSize: 24, color: '#10B981' }} />, color: '#ECFDF5' },
    { title: 'Transactions', value: stats?.totalTransactions ?? 0, icon: <TransactionOutlined style={{ fontSize: 24, color: '#3B82F6' }} />, color: '#EFF6FF' },
    { title: 'Accounts', value: stats?.totalAccounts ?? 0, icon: <BankOutlined style={{ fontSize: 24, color: '#8B5CF6' }} />, color: '#F5F3FF' },
    { title: 'Budgets', value: stats?.totalBudgets ?? 0, icon: <WalletOutlined style={{ fontSize: 24, color: '#EC4899' }} />, color: '#FDF2F8' },
    { title: 'Debts', value: stats?.totalDebts ?? 0, icon: <DollarOutlined style={{ fontSize: 24, color: '#EF4444' }} />, color: '#FEF2F2' },
    { title: 'Receipts', value: stats?.totalReceipts ?? 0, icon: <ScanOutlined style={{ fontSize: 24, color: '#14B8A6' }} />, color: '#F0FDFA' },
  ];

  return (
    <>
      <Title level={3} style={{ marginBottom: 24 }}>Dashboard</Title>

      <Row gutter={[16, 16]}>
        {cards.map((card) => (
          <Col xs={12} sm={8} lg={6} xl={3} key={card.title}>
            <Card hoverable style={{ borderRadius: 12 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                <div style={{ width: 48, height: 48, borderRadius: 10, background: card.color, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                  {card.icon}
                </div>
                <Statistic title={card.title} value={card.value} valueStyle={{ fontSize: 20 }} />
              </div>
            </Card>
          </Col>
        ))}
      </Row>

      <Row gutter={[24, 24]} style={{ marginTop: 24 }}>
        <Col xs={24} lg={12}>
          <Card title="User Growth (30 days)" style={{ borderRadius: 12 }}>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={stats?.userGrowth ?? []}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="date" tick={{ fontSize: 11 }} />
                <YAxis allowDecimals={false} />
                <Tooltip />
                <Line type="monotone" dataKey="count" stroke="#6366F1" strokeWidth={2} dot={false} />
              </LineChart>
            </ResponsiveContainer>
          </Card>
        </Col>
        <Col xs={24} lg={12}>
          <Card title="Transaction Volume (30 days)" style={{ borderRadius: 12 }}>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={stats?.transactionVolume ?? []}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="date" tick={{ fontSize: 11 }} />
                <YAxis allowDecimals={false} />
                <Tooltip />
                <Line type="monotone" dataKey="count" stroke="#3B82F6" strokeWidth={2} dot={false} />
              </LineChart>
            </ResponsiveContainer>
          </Card>
        </Col>
      </Row>
    </>
  );
}
