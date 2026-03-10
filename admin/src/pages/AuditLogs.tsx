import { useEffect, useState } from 'react';
import { Card, Table, Typography, Tag, Space, Select } from 'antd';
import dayjs from 'dayjs';
import { getAuditLogs, type AuditLogItem, type PaginatedResult } from '../api/admin';

const { Title } = Typography;

export default function AuditLogs() {
  const [data, setData] = useState<PaginatedResult<AuditLogItem> | null>(null);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [action, setAction] = useState<string | undefined>();

  const load = () => {
    setLoading(true);
    const params: Record<string, any> = { page, limit: 50 };
    if (action) params.action = action;
    getAuditLogs(params)
      .then(setData)
      .catch(() => {})
      .finally(() => setLoading(false));
  };

  useEffect(load, [page, action]);

  const columns = [
    {
      title: 'Time',
      dataIndex: 'createdAt',
      render: (v: string) => dayjs(v).format('DD MMM YYYY HH:mm:ss'),
      width: 180,
    },
    {
      title: 'Admin',
      dataIndex: 'admin',
      render: (a: AuditLogItem['admin']) => a?.email ?? '-',
    },
    {
      title: 'Action',
      dataIndex: 'action',
      render: (v: string) => <Tag color="blue">{v}</Tag>,
    },
    {
      title: 'Target',
      render: (_: unknown, r: AuditLogItem) =>
        r.targetType ? `${r.targetType} / ${r.targetId?.slice(0, 8)}...` : '-',
    },
    {
      title: 'Details',
      dataIndex: 'details',
      render: (v: Record<string, any> | null) =>
        v ? <code style={{ fontSize: 11 }}>{JSON.stringify(v).slice(0, 80)}</code> : '-',
      ellipsis: true,
    },
    {
      title: 'IP',
      dataIndex: 'ipAddress',
    },
  ];

  return (
    <>
      <Title level={3} style={{ marginBottom: 24 }}>Audit Logs</Title>

      <Card style={{ borderRadius: 12 }}>
        <Space style={{ marginBottom: 16 }}>
          <Select
            placeholder="Filter by action"
            allowClear
            style={{ width: 200 }}
            value={action}
            onChange={setAction}
            options={[
              { label: 'User Update', value: 'user.update' },
              { label: 'User Delete', value: 'user.delete' },
              { label: 'Subscription Update', value: 'subscription.update' },
              { label: 'Notification Broadcast', value: 'notification.broadcast' },
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
            pageSize: 50,
            onChange: setPage,
            showTotal: (t) => `Total: ${t}`,
          }}
          size="small"
        />
      </Card>
    </>
  );
}
