import { useCallback, useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Table,
  Input,
  Select,
  Space,
  Tag,
  Button,
  Typography,
  Popconfirm,
  message,
  Card,
} from 'antd';
import {
  SearchOutlined,
  EyeOutlined,
  DeleteOutlined,
} from '@ant-design/icons';
import type { ColumnsType, TablePaginationConfig } from 'antd/es/table';
import dayjs from 'dayjs';
import { getUsers, deleteUser, type User } from '../api/users';

const { Title } = Typography;

export default function Users() {
  const navigate = useNavigate();
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(false);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(20);
  const [search, setSearch] = useState('');
  const [roleFilter, setRoleFilter] = useState<string | undefined>();
  const [tierFilter, setTierFilter] = useState<string | undefined>();

  const fetchUsers = useCallback(async () => {
    setLoading(true);
    try {
      const result = await getUsers({
        page,
        pageSize,
        search: search || undefined,
        role: roleFilter,
        tier: tierFilter,
      });
      setUsers(result.data);
      setTotal(result.total);
    } catch {
      /* handled by interceptor */
    } finally {
      setLoading(false);
    }
  }, [page, pageSize, search, roleFilter, tierFilter]);

  useEffect(() => {
    fetchUsers();
  }, [fetchUsers]);

  const handleDelete = async (id: string) => {
    try {
      await deleteUser(id);
      message.success('User deleted');
      fetchUsers();
    } catch {
      message.error('Failed to delete user');
    }
  };

  const handleTableChange = (pagination: TablePaginationConfig) => {
    setPage(pagination.current ?? 1);
    setPageSize(pagination.pageSize ?? 20);
  };

  const columns: ColumnsType<User> = [
    {
      title: '#',
      width: 60,
      render: (_: unknown, __: User, index: number) => (page - 1) * pageSize + index + 1,
    },
    {
      title: 'Email',
      dataIndex: 'email',
      ellipsis: true,
    },
    {
      title: 'Name',
      render: (_: unknown, record: User) =>
        [record.firstName, record.lastName].filter(Boolean).join(' ') || '-',
    },
    {
      title: 'Role',
      dataIndex: 'role',
      width: 100,
      render: (role: string) => (
        <Tag color={role === 'ADMIN' ? 'red' : 'blue'}>{role}</Tag>
      ),
    },
    {
      title: 'Tier',
      dataIndex: 'tier',
      width: 100,
      render: (tier: string) => (
        <Tag color={tier === 'PREMIUM' ? 'gold' : 'default'}>{tier}</Tag>
      ),
    },
    {
      title: 'Created',
      dataIndex: 'createdAt',
      width: 120,
      render: (date: string) => (date ? dayjs(date).format('DD MMM YYYY') : '-'),
    },
    {
      title: 'Last Login',
      dataIndex: 'lastLoginAt',
      width: 120,
      render: (date: string | null) => (date ? dayjs(date).format('DD MMM YYYY') : 'Never'),
    },
    {
      title: 'Actions',
      width: 120,
      render: (_: unknown, record: User) => (
        <Space>
          <Button
            type="link"
            size="small"
            icon={<EyeOutlined />}
            onClick={() => navigate(`/users/${record.id}`)}
          />
          <Popconfirm
            title="Delete this user?"
            description="This action cannot be undone."
            onConfirm={() => handleDelete(record.id)}
            okText="Delete"
            okButtonProps={{ danger: true }}
          >
            <Button type="link" size="small" danger icon={<DeleteOutlined />} />
          </Popconfirm>
        </Space>
      ),
    },
  ];

  return (
    <>
      <Title level={3} style={{ marginBottom: 24 }}>
        Users
      </Title>
      <Card style={{ borderRadius: 12 }}>
        <Space style={{ marginBottom: 16 }} wrap>
          <Input
            placeholder="Search by email or name..."
            prefix={<SearchOutlined />}
            allowClear
            style={{ width: 280 }}
            value={search}
            onChange={(e) => {
              setSearch(e.target.value);
              setPage(1);
            }}
          />
          <Select
            placeholder="Role"
            allowClear
            style={{ width: 130 }}
            value={roleFilter}
            onChange={(val) => {
              setRoleFilter(val);
              setPage(1);
            }}
            options={[
              { label: 'User', value: 'USER' },
              { label: 'Admin', value: 'ADMIN' },
            ]}
          />
          <Select
            placeholder="Tier"
            allowClear
            style={{ width: 130 }}
            value={tierFilter}
            onChange={(val) => {
              setTierFilter(val);
              setPage(1);
            }}
            options={[
              { label: 'Free', value: 'FREE' },
              { label: 'Premium', value: 'PREMIUM' },
            ]}
          />
        </Space>

        <Table<User>
          rowKey="id"
          columns={columns}
          dataSource={users}
          loading={loading}
          pagination={{
            current: page,
            pageSize,
            total,
            showSizeChanger: true,
            showTotal: (t) => `Total ${t} users`,
          }}
          onChange={handleTableChange}
          onRow={(record) => ({
            onClick: () => navigate(`/users/${record.id}`),
            style: { cursor: 'pointer' },
          })}
          scroll={{ x: 800 }}
        />
      </Card>
    </>
  );
}
