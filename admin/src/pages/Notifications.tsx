import { useState } from 'react';
import { Card, Typography, Input, Button, Select, message, Alert, Form } from 'antd';
import { SendOutlined } from '@ant-design/icons';
import { broadcastNotification } from '../api/admin';

const { Title } = Typography;
const { TextArea } = Input;

export default function Notifications() {
  const [form] = Form.useForm();
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<{ sent: number } | null>(null);

  const handleSend = async (values: { title: string; body: string; target: string; userIds?: string }) => {
    setLoading(true);
    setResult(null);
    try {
      const payload: { title: string; body: string; userIds?: string[] } = {
        title: values.title,
        body: values.body,
      };
      if (values.target === 'specific' && values.userIds) {
        payload.userIds = values.userIds.split(',').map(s => s.trim()).filter(Boolean);
      }
      const res = await broadcastNotification(payload);
      setResult(res);
      message.success(`Notification sent to ${res.sent} users`);
      form.resetFields();
    } catch {
      message.error('Failed to send notification');
    } finally {
      setLoading(false);
    }
  };

  return (
    <>
      <Title level={3} style={{ marginBottom: 24 }}>Broadcast Notifications</Title>

      <Card style={{ borderRadius: 12, maxWidth: 600 }}>
        <Form form={form} layout="vertical" onFinish={handleSend} initialValues={{ target: 'all' }}>
          <Form.Item name="title" label="Title" rules={[{ required: true }]}>
            <Input placeholder="Notification title" />
          </Form.Item>

          <Form.Item name="body" label="Message" rules={[{ required: true }]}>
            <TextArea rows={4} placeholder="Notification message body" />
          </Form.Item>

          <Form.Item name="target" label="Target">
            <Select
              options={[
                { label: 'All Users', value: 'all' },
                { label: 'Specific Users', value: 'specific' },
              ]}
            />
          </Form.Item>

          <Form.Item noStyle shouldUpdate={(prev, cur) => prev.target !== cur.target}>
            {({ getFieldValue }) =>
              getFieldValue('target') === 'specific' ? (
                <Form.Item name="userIds" label="User IDs (comma-separated)" rules={[{ required: true }]}>
                  <TextArea rows={2} placeholder="uuid1, uuid2, uuid3" />
                </Form.Item>
              ) : null
            }
          </Form.Item>

          <Form.Item>
            <Button type="primary" htmlType="submit" loading={loading} icon={<SendOutlined />}>
              Send Notification
            </Button>
          </Form.Item>
        </Form>

        {result && (
          <Alert
            type="success"
            message={`Successfully sent to ${result.sent} users`}
            style={{ marginTop: 16 }}
          />
        )}
      </Card>
    </>
  );
}
