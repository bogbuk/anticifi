import { useEffect, useState } from 'react';
import { Row, Col, Card, Statistic, Spin, Typography } from 'antd';
import {
  UserOutlined,
  CrownOutlined,
  ThunderboltOutlined,
  TransactionOutlined,
} from '@ant-design/icons';
import { getStats, type AdminStats } from '../api/stats';

const { Title } = Typography;

export default function Dashboard() {
  const [stats, setStats] = useState<AdminStats | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    getStats()
      .then(setStats)
      .catch(() => {
        /* handled by interceptor */
      })
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
    {
      title: 'Total Users',
      value: stats?.totalUsers ?? 0,
      icon: <UserOutlined style={{ fontSize: 24, color: '#6366F1' }} />,
      color: '#EEF2FF',
    },
    {
      title: 'Premium Users',
      value: stats?.premiumUsers ?? 0,
      icon: <CrownOutlined style={{ fontSize: 24, color: '#F59E0B' }} />,
      color: '#FFFBEB',
    },
    {
      title: 'Active (30 days)',
      value: stats?.activeUsers30d ?? 0,
      icon: <ThunderboltOutlined style={{ fontSize: 24, color: '#10B981' }} />,
      color: '#ECFDF5',
    },
    {
      title: 'Total Transactions',
      value: stats?.totalTransactions ?? 0,
      icon: <TransactionOutlined style={{ fontSize: 24, color: '#3B82F6' }} />,
      color: '#EFF6FF',
    },
  ];

  return (
    <>
      <Title level={3} style={{ marginBottom: 24 }}>
        Dashboard
      </Title>
      <Row gutter={[24, 24]}>
        {cards.map((card) => (
          <Col xs={24} sm={12} lg={6} key={card.title}>
            <Card hoverable style={{ borderRadius: 12 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
                <div
                  style={{
                    width: 56,
                    height: 56,
                    borderRadius: 12,
                    background: card.color,
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                  }}
                >
                  {card.icon}
                </div>
                <Statistic title={card.title} value={card.value} />
              </div>
            </Card>
          </Col>
        ))}
      </Row>
    </>
  );
}
