import { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import {
  Card,
  Descriptions,
  Tag,
  Button,
  Space,
  Spin,
  Typography,
  Popconfirm,
  Select,
  message,
  Row,
  Col,
  Statistic,
  Divider,
} from 'antd';
import {
  ArrowLeftOutlined,
  DeleteOutlined,
  BankOutlined,
  TransactionOutlined,
} from '@ant-design/icons';
import dayjs from 'dayjs';
import { getUser, updateUser, deleteUser, updateSubscription, type User } from '../api/users';

const { Title } = Typography;

export default function UserDetail() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [roleLoading, setRoleLoading] = useState(false);
  const [tierLoading, setTierLoading] = useState(false);

  useEffect(() => {
    if (!id) return;
    setLoading(true);
    getUser(id)
      .then(setUser)
      .catch(() => message.error('Failed to load user'))
      .finally(() => setLoading(false));
  }, [id]);

  const handleRoleChange = async (role: 'USER' | 'ADMIN') => {
    if (!id) return;
    setRoleLoading(true);
    try {
      const updated = await updateUser(id, { role });
      setUser(updated);
      message.success('Role updated');
    } catch {
      message.error('Failed to update role');
    } finally {
      setRoleLoading(false);
    }
  };

  const handleTierChange = async (tier: 'FREE' | 'PREMIUM') => {
    if (!id) return;
    setTierLoading(true);
    try {
      await updateSubscription(id, { tier });
      const updated = await getUser(id);
      setUser(updated);
      message.success('Subscription updated');
    } catch {
      message.error('Failed to update subscription');
    } finally {
      setTierLoading(false);
    }
  };

  const handleDelete = async () => {
    if (!id) return;
    try {
      await deleteUser(id);
      message.success('User deleted');
      navigate('/users', { replace: true });
    } catch {
      message.error('Failed to delete user');
    }
  };

  if (loading) {
    return (
      <div style={{ textAlign: 'center', padding: 100 }}>
        <Spin size="large" />
      </div>
    );
  }

  if (!user) {
    return (
      <Card>
        <Title level={4}>User not found</Title>
        <Button onClick={() => navigate('/users')}>Back to Users</Button>
      </Card>
    );
  }

  return (
    <>
      <Space style={{ marginBottom: 24 }}>
        <Button icon={<ArrowLeftOutlined />} onClick={() => navigate('/users')}>
          Back
        </Button>
        <Title level={3} style={{ margin: 0 }}>
          User Detail
        </Title>
      </Space>

      <Row gutter={[24, 24]}>
        <Col xs={24} lg={16}>
          <Card title="User Information" style={{ borderRadius: 12 }}>
            <Descriptions column={{ xs: 1, sm: 2 }} bordered size="small">
              <Descriptions.Item label="ID" span={2}>
                <code>{user.id}</code>
              </Descriptions.Item>
              <Descriptions.Item label="Email">{user.email}</Descriptions.Item>
              <Descriptions.Item label="Name">
                {[user.firstName, user.lastName].filter(Boolean).join(' ') || '-'}
              </Descriptions.Item>
              <Descriptions.Item label="Role">
                <Select
                  size="small"
                  value={user.role}
                  loading={roleLoading}
                  onChange={handleRoleChange}
                  style={{ width: 100 }}
                  options={[
                    { label: 'User', value: 'USER' },
                    { label: 'Admin', value: 'ADMIN' },
                  ]}
                />
              </Descriptions.Item>
              <Descriptions.Item label="Created">
                {dayjs(user.createdAt).format('DD MMM YYYY, HH:mm')}
              </Descriptions.Item>
              <Descriptions.Item label="Last Login">
                {user.lastLoginAt
                  ? dayjs(user.lastLoginAt).format('DD MMM YYYY, HH:mm')
                  : 'Never'}
              </Descriptions.Item>
            </Descriptions>

            <Divider />

            <Popconfirm
              title="Delete this user?"
              description="This action cannot be undone. All user data will be permanently removed."
              onConfirm={handleDelete}
              okText="Delete"
              okButtonProps={{ danger: true }}
            >
              <Button danger icon={<DeleteOutlined />}>
                Delete User
              </Button>
            </Popconfirm>
          </Card>
        </Col>

        <Col xs={24} lg={8}>
          <Card title="Subscription" style={{ borderRadius: 12, marginBottom: 24 }}>
            <Space direction="vertical" size="middle" style={{ width: '100%' }}>
              <div>
                <Typography.Text type="secondary">Current Tier</Typography.Text>
                <div style={{ marginTop: 4 }}>
                  <Select
                    value={user.tier}
                    loading={tierLoading}
                    onChange={handleTierChange}
                    style={{ width: '100%' }}
                    options={[
                      { label: 'Free', value: 'FREE' },
                      { label: 'Premium', value: 'PREMIUM' },
                    ]}
                  />
                </div>
              </div>
              {user.subscription && (
                <>
                  <div>
                    <Typography.Text type="secondary">Status</Typography.Text>
                    <div style={{ marginTop: 4 }}>
                      <Tag
                        color={
                          user.subscription.status === 'ACTIVE'
                            ? 'green'
                            : user.subscription.status === 'CANCELLED'
                              ? 'orange'
                              : 'red'
                        }
                      >
                        {user.subscription.status}
                      </Tag>
                    </div>
                  </div>
                  {user.subscription.expiresAt && (
                    <div>
                      <Typography.Text type="secondary">Expires</Typography.Text>
                      <div style={{ marginTop: 4 }}>
                        {dayjs(user.subscription.expiresAt).format('DD MMM YYYY')}
                      </div>
                    </div>
                  )}
                </>
              )}
            </Space>
          </Card>

          <Card title="Activity" style={{ borderRadius: 12 }}>
            <Row gutter={16}>
              <Col span={12}>
                <Statistic
                  title="Accounts"
                  value={user.accountsCount ?? 0}
                  prefix={<BankOutlined />}
                />
              </Col>
              <Col span={12}>
                <Statistic
                  title="Transactions"
                  value={user.transactionsCount ?? 0}
                  prefix={<TransactionOutlined />}
                />
              </Col>
            </Row>
          </Card>
        </Col>
      </Row>
    </>
  );
}
