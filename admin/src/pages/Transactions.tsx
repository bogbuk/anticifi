import { useEffect, useState } from 'react';
import { Card, Table, Typography, Select, DatePicker, Space, Tag } from 'antd';
import { useNavigate } from 'react-router-dom';
import dayjs from 'dayjs';
import { getAllTransactions, type TransactionItem, type PaginatedResult } from '../api/admin';

const { Title } = Typography;
const { RangePicker } = DatePicker;

export default function Transactions() {
  const navigate = useNavigate();
  const [data, setData] = useState<PaginatedResult<TransactionItem> | null>(null);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [type, setType] = useState<string | undefined>();
  const [dateRange, setDateRange] = useState<[dayjs.Dayjs, dayjs.Dayjs] | null>(null);

  const load = () => {
    setLoading(true);
    const params: Record<string, any> = { page, limit: 20 };
    if (type) params.type = type;
    if (dateRange) {
      params.startDate = dateRange[0].format('YYYY-MM-DD');
      params.endDate = dateRange[1].format('YYYY-MM-DD');
    }
    getAllTransactions(params)
      .then(setData)
      .catch(() => {})
      .finally(() => setLoading(false));
  };

  useEffect(load, [page, type, dateRange]);

  const columns = [
    {
      title: 'Date',
      dataIndex: 'date',
      render: (v: string) => dayjs(v).format('DD MMM YYYY'),
    },
    {
      title: 'User',
      dataIndex: 'user',
      render: (u: TransactionItem['user']) =>
        u ? (
          <a onClick={() => navigate(`/users/${u.id}`)}>
            {u.email}
          </a>
        ) : '-',
    },
    {
      title: 'Type',
      dataIndex: 'type',
      render: (v: string) => (
        <Tag color={v === 'income' ? 'green' : 'red'}>{v.toUpperCase()}</Tag>
      ),
    },
    {
      title: 'Amount',
      dataIndex: 'amount',
      render: (v: number) => `$${Number(v).toFixed(2)}`,
      align: 'right' as const,
    },
    {
      title: 'Description',
      dataIndex: 'description',
      ellipsis: true,
    },
  ];

  return (
    <>
      <Title level={3} style={{ marginBottom: 24 }}>Transactions</Title>

      <Card style={{ borderRadius: 12 }}>
        <Space style={{ marginBottom: 16 }} wrap>
          <Select
            placeholder="Type"
            allowClear
            style={{ width: 120 }}
            value={type}
            onChange={setType}
            options={[
              { label: 'Income', value: 'income' },
              { label: 'Expense', value: 'expense' },
            ]}
          />
          <RangePicker
            onChange={(dates) => setDateRange(dates as [dayjs.Dayjs, dayjs.Dayjs] | null)}
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
