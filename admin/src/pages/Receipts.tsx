import { useEffect, useState } from 'react';
import { Card, Table, Typography, Select, Space, Tag, Progress, Modal } from 'antd';
import { useNavigate } from 'react-router-dom';
import dayjs from 'dayjs';
import { getAllReceipts, type ReceiptItem, type PaginatedResult } from '../api/admin';

const { Title, Text } = Typography;

export default function Receipts() {
  const navigate = useNavigate();
  const [data, setData] = useState<PaginatedResult<ReceiptItem> | null>(null);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [status, setStatus] = useState<string | undefined>();
  const [detail, setDetail] = useState<ReceiptItem | null>(null);

  const load = () => {
    setLoading(true);
    const params: Record<string, any> = { page, limit: 20 };
    if (status) params.status = status;
    getAllReceipts(params)
      .then(setData)
      .catch(() => {})
      .finally(() => setLoading(false));
  };

  useEffect(load, [page, status]);

  const statusColors: Record<string, string> = {
    pending: 'blue',
    processing: 'orange',
    completed: 'green',
    failed: 'red',
  };

  const columns = [
    {
      title: 'Date',
      dataIndex: 'createdAt',
      render: (v: string) => dayjs(v).format('DD MMM YYYY HH:mm'),
    },
    {
      title: 'User',
      dataIndex: 'user',
      render: (u: ReceiptItem['user']) =>
        u ? <a onClick={() => navigate(`/users/${u.id}`)}>{u.email}</a> : '-',
    },
    {
      title: 'File',
      dataIndex: 'originalFilename',
      ellipsis: true,
    },
    {
      title: 'Status',
      dataIndex: 'status',
      render: (v: string) => <Tag color={statusColors[v] ?? 'default'}>{v.toUpperCase()}</Tag>,
    },
    {
      title: 'Confidence',
      dataIndex: 'confidence',
      render: (v: number) => <Progress percent={Math.round(Number(v))} size="small" status={Number(v) >= 70 ? 'success' : 'exception'} />,
    },
    {
      title: 'Merchant',
      render: (_: unknown, r: ReceiptItem) => r.parsedData?.merchant ?? '-',
    },
    {
      title: 'Amount',
      render: (_: unknown, r: ReceiptItem) =>
        r.parsedData?.amount ? `$${Number(r.parsedData.amount).toFixed(2)}` : '-',
      align: 'right' as const,
    },
    {
      title: '',
      render: (_: unknown, r: ReceiptItem) => (
        <a onClick={() => setDetail(r)}>Details</a>
      ),
    },
  ];

  return (
    <>
      <Title level={3} style={{ marginBottom: 24 }}>Receipt Scans (OCR)</Title>

      <Card style={{ borderRadius: 12 }}>
        <Space style={{ marginBottom: 16 }}>
          <Select
            placeholder="Status"
            allowClear
            style={{ width: 140 }}
            value={status}
            onChange={setStatus}
            options={[
              { label: 'Pending', value: 'pending' },
              { label: 'Processing', value: 'processing' },
              { label: 'Completed', value: 'completed' },
              { label: 'Failed', value: 'failed' },
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

      <Modal
        title="Receipt Details"
        open={!!detail}
        onCancel={() => setDetail(null)}
        footer={null}
        width={600}
      >
        {detail && (
          <div>
            <Text strong>File:</Text> {detail.originalFilename}<br />
            <Text strong>Status:</Text> <Tag color={statusColors[detail.status]}>{detail.status.toUpperCase()}</Tag><br />
            <Text strong>Confidence:</Text> {Math.round(Number(detail.confidence))}%<br />
            <Text strong>Created:</Text> {dayjs(detail.createdAt).format('DD MMM YYYY HH:mm')}<br />
            {detail.parsedData && (
              <>
                <br />
                <Text strong>Parsed Data:</Text>
                <pre style={{ background: '#f5f5f5', padding: 12, borderRadius: 8, marginTop: 8 }}>
                  {JSON.stringify(detail.parsedData, null, 2)}
                </pre>
              </>
            )}
          </div>
        )}
      </Modal>
    </>
  );
}
