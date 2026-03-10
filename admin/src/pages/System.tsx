import { useEffect, useState } from 'react';
import { Card, Typography, Tag, Descriptions, Spin, Button, Row, Col } from 'antd';
import { ReloadOutlined, CheckCircleOutlined, CloseCircleOutlined } from '@ant-design/icons';
import client from '../api/client';

const { Title } = Typography;

interface HealthData {
  status: string;
  uptime?: number;
  timestamp?: string;
  [key: string]: any;
}

export default function System() {
  const [health, setHealth] = useState<HealthData | null>(null);
  const [loading, setLoading] = useState(true);

  const loadHealth = () => {
    setLoading(true);
    client.get('/health')
      .then(r => setHealth(r.data))
      .catch(() => setHealth({ status: 'error' }))
      .finally(() => setLoading(false));
  };

  useEffect(loadHealth, []);

  const isHealthy = health?.status === 'ok' || health?.status === 'healthy';

  return (
    <>
      <Title level={3} style={{ marginBottom: 24 }}>System Health</Title>

      <Row gutter={[24, 24]}>
        <Col xs={24} lg={12}>
          <Card
            title="API Status"
            style={{ borderRadius: 12 }}
            extra={
              <Button icon={<ReloadOutlined />} onClick={loadHealth} loading={loading} size="small">
                Refresh
              </Button>
            }
          >
            {loading ? (
              <div style={{ textAlign: 'center', padding: 40 }}><Spin /></div>
            ) : (
              <>
                <div style={{ textAlign: 'center', marginBottom: 24 }}>
                  {isHealthy ? (
                    <CheckCircleOutlined style={{ fontSize: 64, color: '#10B981' }} />
                  ) : (
                    <CloseCircleOutlined style={{ fontSize: 64, color: '#EF4444' }} />
                  )}
                  <div style={{ marginTop: 12 }}>
                    <Tag color={isHealthy ? 'green' : 'red'} style={{ fontSize: 16, padding: '4px 16px' }}>
                      {isHealthy ? 'HEALTHY' : 'UNHEALTHY'}
                    </Tag>
                  </div>
                </div>

                <Descriptions column={1} bordered size="small">
                  <Descriptions.Item label="Status">{health?.status}</Descriptions.Item>
                  {health?.uptime != null && (
                    <Descriptions.Item label="Uptime">
                      {Math.floor(health.uptime / 3600)}h {Math.floor((health.uptime % 3600) / 60)}m
                    </Descriptions.Item>
                  )}
                  {health?.timestamp && (
                    <Descriptions.Item label="Server Time">{health.timestamp}</Descriptions.Item>
                  )}
                </Descriptions>
              </>
            )}
          </Card>
        </Col>

        <Col xs={24} lg={12}>
          <Card title="Environment" style={{ borderRadius: 12 }}>
            <Descriptions column={1} bordered size="small">
              <Descriptions.Item label="API URL">
                {import.meta.env.VITE_API_URL || 'https://api.anticifi.com'}
              </Descriptions.Item>
              <Descriptions.Item label="Admin Version">1.0.0</Descriptions.Item>
              <Descriptions.Item label="Build">Production</Descriptions.Item>
            </Descriptions>
          </Card>
        </Col>
      </Row>
    </>
  );
}
