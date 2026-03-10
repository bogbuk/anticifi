import { useEffect, useState } from 'react';
import { Row, Col, Card, Statistic, Spin, Typography, Select, Space, Table, Tag } from 'antd';
import {
  LineChart, Line, BarChart, Bar, PieChart, Pie, Cell,
  XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend,
} from 'recharts';
import {
  getAnalyticsUserGrowth, getAnalyticsTransactions, getAnalyticsRevenue,
  getAnalyticsRetention, getAnalyticsCategories, getAnalyticsSubscriptions,
  type TimeSeriesPoint, type RetentionData, type CategoryBreakdown, type SubscriptionBreakdown,
} from '../api/admin';

const { Title } = Typography;

const COLORS = ['#6366F1', '#3B82F6', '#10B981', '#F59E0B', '#EF4444', '#EC4899', '#8B5CF6', '#14B8A6'];

export default function Analytics() {
  const [days, setDays] = useState(90);
  const [loading, setLoading] = useState(true);
  const [userGrowth, setUserGrowth] = useState<TimeSeriesPoint[]>([]);
  const [txVolume, setTxVolume] = useState<TimeSeriesPoint[]>([]);
  const [revenue, setRevenue] = useState<TimeSeriesPoint[]>([]);
  const [retention, setRetention] = useState<RetentionData | null>(null);
  const [categories, setCategories] = useState<CategoryBreakdown[]>([]);
  const [subs, setSubs] = useState<SubscriptionBreakdown[]>([]);

  useEffect(() => {
    setLoading(true);
    Promise.all([
      getAnalyticsUserGrowth(days).then(setUserGrowth),
      getAnalyticsTransactions(days).then(setTxVolume),
      getAnalyticsRevenue(days).then(setRevenue),
      getAnalyticsRetention().then(setRetention),
      getAnalyticsCategories().then(setCategories),
      getAnalyticsSubscriptions().then(setSubs),
    ])
      .catch(() => {})
      .finally(() => setLoading(false));
  }, [days]);

  if (loading) {
    return <div style={{ textAlign: 'center', padding: 100 }}><Spin size="large" /></div>;
  }

  return (
    <>
      <Space style={{ marginBottom: 24, display: 'flex', justifyContent: 'space-between' }}>
        <Title level={3} style={{ margin: 0 }}>Analytics</Title>
        <Select
          value={days}
          onChange={setDays}
          options={[
            { label: '7 days', value: 7 },
            { label: '30 days', value: 30 },
            { label: '90 days', value: 90 },
            { label: '1 year', value: 365 },
          ]}
          style={{ width: 120 }}
        />
      </Space>

      {/* Retention cards */}
      <Row gutter={[16, 16]} style={{ marginBottom: 24 }}>
        <Col xs={12} sm={6}>
          <Card style={{ borderRadius: 12 }}>
            <Statistic title="DAU" value={retention?.dau ?? 0} />
          </Card>
        </Col>
        <Col xs={12} sm={6}>
          <Card style={{ borderRadius: 12 }}>
            <Statistic title="WAU" value={retention?.wau ?? 0} />
          </Card>
        </Col>
        <Col xs={12} sm={6}>
          <Card style={{ borderRadius: 12 }}>
            <Statistic title="MAU" value={retention?.mau ?? 0} />
          </Card>
        </Col>
        <Col xs={12} sm={6}>
          <Card style={{ borderRadius: 12 }}>
            <Statistic title="Total Users" value={retention?.total ?? 0} />
          </Card>
        </Col>
      </Row>

      {/* Charts */}
      <Row gutter={[24, 24]}>
        <Col xs={24} lg={12}>
          <Card title="User Growth" style={{ borderRadius: 12 }}>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={userGrowth}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="date" tick={{ fontSize: 10 }} />
                <YAxis allowDecimals={false} />
                <Tooltip />
                <Bar dataKey="count" fill="#6366F1" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </Card>
        </Col>

        <Col xs={24} lg={12}>
          <Card title="Transaction Volume" style={{ borderRadius: 12 }}>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={txVolume}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="date" tick={{ fontSize: 10 }} />
                <YAxis yAxisId="count" allowDecimals={false} />
                <YAxis yAxisId="total" orientation="right" />
                <Tooltip />
                <Legend />
                <Line yAxisId="count" type="monotone" dataKey="count" stroke="#3B82F6" strokeWidth={2} dot={false} name="Count" />
                <Line yAxisId="total" type="monotone" dataKey="total" stroke="#10B981" strokeWidth={2} dot={false} name="Total $" />
              </LineChart>
            </ResponsiveContainer>
          </Card>
        </Col>

        <Col xs={24} lg={12}>
          <Card title="Premium Subscriptions" style={{ borderRadius: 12 }}>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={revenue}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="date" tick={{ fontSize: 10 }} />
                <YAxis allowDecimals={false} />
                <Tooltip />
                <Bar dataKey="count" fill="#F59E0B" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </Card>
        </Col>

        <Col xs={24} lg={12}>
          <Card title="Top Categories by Spend" style={{ borderRadius: 12 }}>
            <ResponsiveContainer width="100%" height={300}>
              <PieChart>
                <Pie
                  data={categories.slice(0, 8)}
                  dataKey="total"
                  nameKey="name"
                  cx="50%"
                  cy="50%"
                  outerRadius={100}
                  label={({ name, percent }) => `${name} ${((percent ?? 0) * 100).toFixed(0)}%`}
                >
                  {categories.slice(0, 8).map((_, i) => (
                    <Cell key={i} fill={COLORS[i % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          </Card>
        </Col>
      </Row>

      {/* Subscription breakdown */}
      <Card title="Subscription Breakdown" style={{ borderRadius: 12, marginTop: 24 }}>
        <Table
          dataSource={subs}
          rowKey={(r) => `${r.tier}-${r.status}`}
          pagination={false}
          size="small"
          columns={[
            { title: 'Tier', dataIndex: 'tier', render: (v: string) => <Tag color={v === 'premium' ? 'gold' : 'default'}>{v.toUpperCase()}</Tag> },
            { title: 'Status', dataIndex: 'status', render: (v: string) => <Tag>{v.toUpperCase()}</Tag> },
            { title: 'Count', dataIndex: 'count', align: 'right' as const },
          ]}
        />
      </Card>
    </>
  );
}
