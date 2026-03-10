import { useEffect, useState } from 'react';
import { Card, Table, Typography, Select, Space, Tag } from 'antd';
import { useNavigate } from 'react-router-dom';
import dayjs from 'dayjs';
import { getAllSubscriptions, type SubscriptionItem, type PaginatedResult } from '../api/admin';

const { Title } = Typography;

export default function Subscriptions() {
  const navigate = useNavigate();
  const [data, setData] = useState<PaginatedResult<SubscriptionItem> | null>(null);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [tier, setTier] = useState<string | undefined>();
  const [status, setStatus] = useState<string | undefined>();

  const load = () => {
    setLoading(true);
    const params: Record<string, any> = { page, limit: 20 };
    if (tier) params.tier = tier;
    if (status) params.status = status;
    getAllSubscriptions(params)
      .then(setData)
      .catch(() => {})
      .finally(() => setLoading(false));
  };

  useEffect(load, [page, tier, status]);

  const columns = [
    {
      title: 'User',
      dataIndex: 'user',
      render: (u: SubscriptionItem['user']) =>
        u ? <a onClick={() => navigate(`/users/${u.id}`)}>{u.email}</a> : '-',
    },
    {
      title: 'Tier',
      dataIndex: 'tier',
      render: (v: string) => (
        <Tag color={v === 'premium' ? 'gold' : 'default'}>{v.toUpperCase()}</Tag>
      ),
    },
    {
      title: 'Status',
      dataIndex: 'status',
      render: (v: string) => {
        const colors: Record<string, string> = { active: 'green', expired: 'red', cancelled: 'orange', grace_period: 'blue' };
        return <Tag color={colors[v] ?? 'default'}>{v.toUpperCase()}</Tag>;
      },
    },
    {
      title: 'Period',
      dataIndex: 'period',
    },
    {
      title: 'Expires',
      dataIndex: 'expiresAt',
      render: (v: string | null) => v ? dayjs(v).format('DD MMM YYYY') : '-',
    },
    {
      title: 'Created',
      dataIndex: 'createdAt',
      render: (v: string) => dayjs(v).format('DD MMM YYYY'),
    },
  ];

  return (
    <>
      <Title level={3} style={{ marginBottom: 24 }}>Subscriptions</Title>

      <Card style={{ borderRadius: 12 }}>
        <Space style={{ marginBottom: 16 }} wrap>
          <Select
            placeholder="Tier"
            allowClear
            style={{ width: 120 }}
            value={tier}
            onChange={setTier}
            options={[
              { label: 'Free', value: 'free' },
              { label: 'Premium', value: 'premium' },
            ]}
          />
          <Select
            placeholder="Status"
            allowClear
            style={{ width: 140 }}
            value={status}
            onChange={setStatus}
            options={[
              { label: 'Active', value: 'active' },
              { label: 'Expired', value: 'expired' },
              { label: 'Cancelled', value: 'cancelled' },
            ]}
          />
        </Space>

        <Table
          dataSource={data?.data ?? []}
          columns={columns}
          rowKey="id"
          loading={loading}
          pagination={{
            current: data?.page ?? 1,
            total: data?.total ?? 0,
            pageSize: 20,
            onChange: setPage,
            showTotal: (t) => `Total: ${t}`,
          }}
          size="small"
        />
      </Card>
    </>
  );
}
