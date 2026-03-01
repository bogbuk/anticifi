import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from './../src/app.module';

jest.setTimeout(60000);

describe('API E2E Tests', () => {
  let app: INestApplication<App>;

  const testEmail = `test-${Date.now()}@test.com`;
  const testPassword = 'TestPassword123!';
  const testFirstName = 'TestUser';
  const testLastName = 'E2E';

  let accessToken: string;
  let refreshToken: string;
  let userId: string;

  let categoryId: string;
  let accountId: string;
  let transactionId: string;
  let scheduledPaymentId: string;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.setGlobalPrefix('api');
    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        transform: true,
      }),
    );
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  // ---------------------------------------------------------------------------
  // Health
  // ---------------------------------------------------------------------------
  describe('Health', () => {
    it('GET /api/health - should return health status', async () => {
      const { body } = await request(app.getHttpServer())
        .get('/api/health')
        .expect(200);

      expect(body).toHaveProperty('status', 'ok');
      expect(body).toHaveProperty('version');
      expect(body).toHaveProperty('uptime');
      expect(body).toHaveProperty('database', 'ok');
      expect(body).toHaveProperty('timestamp');
    });
  });

  // ---------------------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------------------
  describe('Auth', () => {
    it('POST /api/auth/register - should register a new user', async () => {
      const { body } = await request(app.getHttpServer())
        .post('/api/auth/register')
        .send({
          email: testEmail,
          password: testPassword,
          firstName: testFirstName,
          lastName: testLastName,
        })
        .expect(201);

      expect(body).toHaveProperty('accessToken');
      expect(body).toHaveProperty('refreshToken');
      expect(body).toHaveProperty('user');
      expect(body.user).toHaveProperty('id');
      expect(body.user).toHaveProperty('email', testEmail);
      expect(body.user).toHaveProperty('firstName', testFirstName);
      expect(body.user).toHaveProperty('lastName', testLastName);
      expect(body.user).toHaveProperty('isEmailVerified', false);
      expect(body.user).toHaveProperty('currency', 'USD');
      expect(body.user).toHaveProperty('createdAt');

      accessToken = body.accessToken;
      refreshToken = body.refreshToken;
      userId = body.user.id;
    });

    it('POST /api/auth/register - should fail with duplicate email', async () => {
      await request(app.getHttpServer())
        .post('/api/auth/register')
        .send({
          email: testEmail,
          password: testPassword,
          firstName: testFirstName,
        })
        .expect(409);
    });

    it('POST /api/auth/register - should fail with invalid data', async () => {
      await request(app.getHttpServer())
        .post('/api/auth/register')
        .send({
          email: 'not-an-email',
          password: '123',
        })
        .expect(400);
    });

    it('POST /api/auth/login - should login with valid credentials', async () => {
      const { body } = await request(app.getHttpServer())
        .post('/api/auth/login')
        .send({
          email: testEmail,
          password: testPassword,
        })
        .expect(200);

      expect(body).toHaveProperty('accessToken');
      expect(body).toHaveProperty('refreshToken');
      expect(body).toHaveProperty('user');
      expect(body.user).toHaveProperty('email', testEmail);

      accessToken = body.accessToken;
      refreshToken = body.refreshToken;
    });

    it('POST /api/auth/login - should fail with wrong password', async () => {
      await request(app.getHttpServer())
        .post('/api/auth/login')
        .send({
          email: testEmail,
          password: 'WrongPassword123!',
        })
        .expect(401);
    });

    it('GET /api/auth/profile - should return current user profile from JWT', async () => {
      const { body } = await request(app.getHttpServer())
        .get('/api/auth/profile')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(body).toHaveProperty('userId', userId);
      expect(body).toHaveProperty('email', testEmail);
    });

    it('GET /api/auth/profile - should fail without token', async () => {
      await request(app.getHttpServer())
        .get('/api/auth/profile')
        .expect(401);
    });

    it('POST /api/auth/refresh - should refresh tokens', async () => {
      const { body } = await request(app.getHttpServer())
        .post('/api/auth/refresh')
        .send({ refreshToken })
        .expect(200);

      expect(body).toHaveProperty('accessToken');
      expect(body).toHaveProperty('refreshToken');

      accessToken = body.accessToken;
      refreshToken = body.refreshToken;
    });

    it('POST /api/auth/refresh - should fail with invalid refresh token', async () => {
      await request(app.getHttpServer())
        .post('/api/auth/refresh')
        .send({ refreshToken: 'invalid-token' })
        .expect(401);
    });

    it('POST /api/auth/logout - should logout', async () => {
      const { body } = await request(app.getHttpServer())
        .post('/api/auth/logout')
        .expect(200);

      expect(body).toHaveProperty('message', 'Logged out');
    });
  });

  // ---------------------------------------------------------------------------
  // Categories
  // ---------------------------------------------------------------------------
  describe('Categories', () => {
    it('GET /api/categories - should return default categories', async () => {
      const { body } = await request(app.getHttpServer())
        .get('/api/categories')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(Array.isArray(body)).toBe(true);
      expect(body.length).toBeGreaterThanOrEqual(9);

      const categoryNames = body.map((c: { name: string }) => c.name);
      expect(categoryNames).toContain('Food');
      expect(categoryNames).toContain('Transport');
      expect(categoryNames).toContain('Housing');
      expect(categoryNames).toContain('Entertainment');
      expect(categoryNames).toContain('Shopping');
      expect(categoryNames).toContain('Health');
      expect(categoryNames).toContain('Salary');
      expect(categoryNames).toContain('Freelance');
      expect(categoryNames).toContain('Other');

      // Save a default category id for later use
      const foodCategory = body.find((c: { name: string }) => c.name === 'Food');
      categoryId = foodCategory.id;
    });

    it('GET /api/categories - should fail without auth', async () => {
      await request(app.getHttpServer())
        .get('/api/categories')
        .expect(401);
    });

    it('POST /api/categories - should create a custom category', async () => {
      const { body } = await request(app.getHttpServer())
        .post('/api/categories')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          name: 'Custom E2E Category',
          icon: 'test-icon',
          color: '#FF5733',
        })
        .expect(201);

      expect(body).toHaveProperty('id');
      expect(body).toHaveProperty('name', 'Custom E2E Category');
      expect(body).toHaveProperty('icon', 'test-icon');
      expect(body).toHaveProperty('color', '#FF5733');
      expect(body).toHaveProperty('isDefault', false);
    });

    it('PATCH /api/categories/:id - should not update a default category', async () => {
      await request(app.getHttpServer())
        .patch(`/api/categories/${categoryId}`)
        .set('Authorization', `Bearer ${accessToken}`)
        .send({ name: 'Renamed Food' })
        .expect(403);
    });

    it('DELETE /api/categories/:id - should not delete a default category', async () => {
      await request(app.getHttpServer())
        .delete(`/api/categories/${categoryId}`)
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(403);
    });
  });

  // ---------------------------------------------------------------------------
  // Accounts
  // ---------------------------------------------------------------------------
  describe('Accounts', () => {
    it('POST /api/accounts - should create an account', async () => {
      const { body } = await request(app.getHttpServer())
        .post('/api/accounts')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          name: 'Test Checking',
          type: 'checking',
          bank: 'Test Bank',
          currency: 'USD',
          initialBalance: 1000,
        })
        .expect(201);

      expect(body).toHaveProperty('id');
      expect(body).toHaveProperty('userId');
      expect(body).toHaveProperty('name', 'Test Checking');
      expect(body).toHaveProperty('type', 'checking');
      expect(body).toHaveProperty('bank', 'Test Bank');
      expect(body).toHaveProperty('currency', 'USD');
      expect(body).toHaveProperty('initialBalance');
      expect(body).toHaveProperty('isActive', true);
      expect(body).toHaveProperty('createdAt');
      expect(body).toHaveProperty('updatedAt');

      accountId = body.id;
    });

    it('POST /api/accounts - should fail without auth', async () => {
      await request(app.getHttpServer())
        .post('/api/accounts')
        .send({
          name: 'No Auth Account',
          type: 'checking',
        })
        .expect(401);
    });

    it('POST /api/accounts - should fail with invalid type', async () => {
      await request(app.getHttpServer())
        .post('/api/accounts')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          name: 'Bad Account',
          type: 'invalid-type',
        })
        .expect(400);
    });

    it('GET /api/accounts - should return all accounts as array', async () => {
      const { body } = await request(app.getHttpServer())
        .get('/api/accounts')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(Array.isArray(body)).toBe(true);
      expect(body.length).toBeGreaterThanOrEqual(1);

      const account = body.find((a: { id: string }) => a.id === accountId);
      expect(account).toBeDefined();
      expect(account.name).toBe('Test Checking');
    });

    it('GET /api/accounts/:id - should return a single account', async () => {
      const { body } = await request(app.getHttpServer())
        .get(`/api/accounts/${accountId}`)
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(body).toHaveProperty('id', accountId);
      expect(body).toHaveProperty('name', 'Test Checking');
      expect(body).toHaveProperty('type', 'checking');
    });

    it('PATCH /api/accounts/:id - should update the account', async () => {
      const { body } = await request(app.getHttpServer())
        .patch(`/api/accounts/${accountId}`)
        .set('Authorization', `Bearer ${accessToken}`)
        .send({ name: 'Updated Checking' })
        .expect(200);

      expect(body).toHaveProperty('id', accountId);
      expect(body).toHaveProperty('name', 'Updated Checking');
    });
  });

  // ---------------------------------------------------------------------------
  // Transactions
  // ---------------------------------------------------------------------------
  describe('Transactions', () => {
    it('POST /api/transactions - should create a transaction', async () => {
      const { body } = await request(app.getHttpServer())
        .post('/api/transactions')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          accountId,
          amount: 50.75,
          type: 'expense',
          description: 'Grocery shopping',
          categoryId,
          date: '2026-03-01',
        })
        .expect(201);

      expect(body).toHaveProperty('id');
      expect(body).toHaveProperty('accountId', accountId);
      expect(body).toHaveProperty('userId');
      expect(body).toHaveProperty('amount');
      expect(body).toHaveProperty('type', 'expense');
      expect(body).toHaveProperty('description', 'Grocery shopping');
      expect(body).toHaveProperty('categoryId', categoryId);
      expect(body).toHaveProperty('date');
      expect(body).toHaveProperty('createdAt');
      expect(body).toHaveProperty('updatedAt');

      transactionId = body.id;
    });

    it('POST /api/transactions - should create a second transaction with different data', async () => {
      const { body } = await request(app.getHttpServer())
        .post('/api/transactions')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          accountId,
          amount: 3000,
          type: 'income',
          description: 'Monthly salary',
          categoryId,
          date: '2026-02-28',
        })
        .expect(201);

      expect(body).toHaveProperty('id');
      expect(body).toHaveProperty('type', 'income');
    });

    it('POST /api/transactions - should fail without auth', async () => {
      await request(app.getHttpServer())
        .post('/api/transactions')
        .send({
          accountId,
          amount: 10,
          type: 'expense',
          date: '2026-03-01',
        })
        .expect(401);
    });

    it('POST /api/transactions - should fail with invalid data', async () => {
      await request(app.getHttpServer())
        .post('/api/transactions')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          accountId,
          amount: 'not-a-number',
          type: 'invalid',
          date: '2026-03-01',
        })
        .expect(400);
    });

    it('GET /api/transactions - should return paginated transactions', async () => {
      const { body } = await request(app.getHttpServer())
        .get('/api/transactions')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(body).toHaveProperty('data');
      expect(body).toHaveProperty('total');
      expect(body).toHaveProperty('page');
      expect(body).toHaveProperty('limit');
      expect(body).toHaveProperty('totalPages');
      expect(Array.isArray(body.data)).toBe(true);
      expect(body.data.length).toBeGreaterThanOrEqual(2);
    });

    it('GET /api/transactions/:id - should return a single transaction with includes', async () => {
      const { body } = await request(app.getHttpServer())
        .get(`/api/transactions/${transactionId}`)
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(body).toHaveProperty('id', transactionId);
      expect(body).toHaveProperty('accountId', accountId);
      expect(body).toHaveProperty('description', 'Grocery shopping');
    });

    it('PATCH /api/transactions/:id - should update the transaction', async () => {
      const { body } = await request(app.getHttpServer())
        .patch(`/api/transactions/${transactionId}`)
        .set('Authorization', `Bearer ${accessToken}`)
        .send({ description: 'Updated grocery shopping' })
        .expect(200);

      expect(body).toHaveProperty('id', transactionId);
      expect(body).toHaveProperty('description', 'Updated grocery shopping');
    });

    it('DELETE /api/transactions/:id - should delete the transaction', async () => {
      await request(app.getHttpServer())
        .delete(`/api/transactions/${transactionId}`)
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(204);
    });

    it('GET /api/transactions/:id - should not find deleted transaction', async () => {
      await request(app.getHttpServer())
        .get(`/api/transactions/${transactionId}`)
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(404);
    });
  });

  // ---------------------------------------------------------------------------
  // Dashboard
  // ---------------------------------------------------------------------------
  describe('Dashboard', () => {
    it('GET /api/dashboard - should return dashboard data', async () => {
      const { body } = await request(app.getHttpServer())
        .get('/api/dashboard')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(body).toHaveProperty('totalBalance');
      expect(body).toHaveProperty('currentMonth');
      expect(body.currentMonth).toHaveProperty('income');
      expect(body.currentMonth).toHaveProperty('expense');
      expect(body).toHaveProperty('previousMonth');
      expect(body.previousMonth).toHaveProperty('income');
      expect(body.previousMonth).toHaveProperty('expense');
      expect(body).toHaveProperty('recentTransactions');
      expect(Array.isArray(body.recentTransactions)).toBe(true);
      expect(body).toHaveProperty('accounts');
      expect(Array.isArray(body.accounts)).toBe(true);
      expect(body).toHaveProperty('spendingByCategory');
      expect(Array.isArray(body.spendingByCategory)).toBe(true);
    });

    it('GET /api/dashboard - should fail without auth', async () => {
      await request(app.getHttpServer())
        .get('/api/dashboard')
        .expect(401);
    });
  });

  // ---------------------------------------------------------------------------
  // Scheduled Payments
  // ---------------------------------------------------------------------------
  describe('Scheduled Payments', () => {
    it('POST /api/scheduled-payments - should create a scheduled payment', async () => {
      const { body } = await request(app.getHttpServer())
        .post('/api/scheduled-payments')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          accountId,
          categoryId,
          name: 'Monthly Rent',
          amount: 1200,
          type: 'expense',
          frequency: 'monthly',
          startDate: '2026-03-01',
          nextExecutionDate: '2026-03-01',
          isActive: true,
          description: 'Monthly apartment rent',
        })
        .expect(201);

      expect(body).toHaveProperty('id');
      expect(body).toHaveProperty('userId');
      expect(body).toHaveProperty('accountId', accountId);
      expect(body).toHaveProperty('name', 'Monthly Rent');
      expect(body).toHaveProperty('amount');
      expect(body).toHaveProperty('type', 'expense');
      expect(body).toHaveProperty('frequency', 'monthly');
      expect(body).toHaveProperty('startDate');
      expect(body).toHaveProperty('isActive', true);
      expect(body).toHaveProperty('description', 'Monthly apartment rent');
      expect(body).toHaveProperty('createdAt');
      expect(body).toHaveProperty('updatedAt');

      scheduledPaymentId = body.id;
    });

    it('POST /api/scheduled-payments - should fail without auth', async () => {
      await request(app.getHttpServer())
        .post('/api/scheduled-payments')
        .send({
          accountId,
          name: 'Unauthorized Payment',
          amount: 100,
          type: 'expense',
          frequency: 'monthly',
          startDate: '2026-03-01',
        })
        .expect(401);
    });

    it('GET /api/scheduled-payments - should return paginated scheduled payments', async () => {
      const { body } = await request(app.getHttpServer())
        .get('/api/scheduled-payments')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(body).toHaveProperty('data');
      expect(body).toHaveProperty('total');
      expect(body).toHaveProperty('page');
      expect(body).toHaveProperty('limit');
      expect(body).toHaveProperty('totalPages');
      expect(Array.isArray(body.data)).toBe(true);
      expect(body.data.length).toBeGreaterThanOrEqual(1);
    });

    it('GET /api/scheduled-payments/:id - should return a single scheduled payment', async () => {
      const { body } = await request(app.getHttpServer())
        .get(`/api/scheduled-payments/${scheduledPaymentId}`)
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(body).toHaveProperty('id', scheduledPaymentId);
      expect(body).toHaveProperty('name', 'Monthly Rent');
    });

    it('PATCH /api/scheduled-payments/:id - should update a scheduled payment', async () => {
      const { body } = await request(app.getHttpServer())
        .patch(`/api/scheduled-payments/${scheduledPaymentId}`)
        .set('Authorization', `Bearer ${accessToken}`)
        .send({ name: 'Updated Rent' })
        .expect(200);

      expect(body).toHaveProperty('id', scheduledPaymentId);
      expect(body).toHaveProperty('name', 'Updated Rent');
    });

    it('POST /api/scheduled-payments/:id/execute - should execute the scheduled payment', async () => {
      const { body } = await request(app.getHttpServer())
        .post(`/api/scheduled-payments/${scheduledPaymentId}/execute`)
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(201);

      expect(body).toHaveProperty('id', scheduledPaymentId);
      expect(body).toHaveProperty('lastExecutedAt');
      expect(body.lastExecutedAt).not.toBeNull();
    });

    it('DELETE /api/scheduled-payments/:id - should delete the scheduled payment', async () => {
      await request(app.getHttpServer())
        .delete(`/api/scheduled-payments/${scheduledPaymentId}`)
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(204);
    });

    it('GET /api/scheduled-payments/:id - should not find deleted scheduled payment', async () => {
      await request(app.getHttpServer())
        .get(`/api/scheduled-payments/${scheduledPaymentId}`)
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(404);
    });
  });

  // ---------------------------------------------------------------------------
  // Notifications
  // ---------------------------------------------------------------------------
  describe('Notifications', () => {
    it('GET /api/notifications - should return paginated notifications', async () => {
      const { body } = await request(app.getHttpServer())
        .get('/api/notifications')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(body).toHaveProperty('data');
      expect(body).toHaveProperty('total');
      expect(body).toHaveProperty('page');
      expect(body).toHaveProperty('limit');
      expect(body).toHaveProperty('totalPages');
      expect(Array.isArray(body.data)).toBe(true);
    });

    it('GET /api/notifications/unread-count - should return unread count', async () => {
      const { body } = await request(app.getHttpServer())
        .get('/api/notifications/unread-count')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(body).toHaveProperty('count');
      expect(typeof body.count).toBe('number');
    });

    it('PATCH /api/notifications/read-all - should mark all notifications as read', async () => {
      const { body } = await request(app.getHttpServer())
        .patch('/api/notifications/read-all')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(body).toHaveProperty('updated');
      expect(typeof body.updated).toBe('number');
    });

    it('GET /api/notifications - should fail without auth', async () => {
      await request(app.getHttpServer())
        .get('/api/notifications')
        .expect(401);
    });
  });

  // ---------------------------------------------------------------------------
  // Users
  // ---------------------------------------------------------------------------
  describe('Users', () => {
    it('GET /api/users/profile - should return the full user profile', async () => {
      const { body } = await request(app.getHttpServer())
        .get('/api/users/profile')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(body).toHaveProperty('id', userId);
      expect(body).toHaveProperty('email', testEmail);
      expect(body).toHaveProperty('firstName', testFirstName);
      expect(body).toHaveProperty('lastName', testLastName);
      expect(body).toHaveProperty('isEmailVerified');
      expect(body).toHaveProperty('currency');
      expect(body).toHaveProperty('locale');
      expect(body).toHaveProperty('notificationsEnabled');
      expect(body).toHaveProperty('theme');
      expect(body).toHaveProperty('createdAt');
      expect(body).toHaveProperty('updatedAt');
      expect(body).not.toHaveProperty('passwordHash');
    });

    it('GET /api/users/profile - should fail without auth', async () => {
      await request(app.getHttpServer())
        .get('/api/users/profile')
        .expect(401);
    });

    it('PATCH /api/users/profile - should update the user profile', async () => {
      const { body } = await request(app.getHttpServer())
        .patch('/api/users/profile')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          firstName: 'UpdatedFirst',
          lastName: 'UpdatedLast',
          currency: 'EUR',
          locale: 'de',
          notificationsEnabled: false,
          theme: 'dark',
        })
        .expect(200);

      expect(body).toHaveProperty('firstName', 'UpdatedFirst');
      expect(body).toHaveProperty('lastName', 'UpdatedLast');
      expect(body).toHaveProperty('currency', 'EUR');
      expect(body).toHaveProperty('locale', 'de');
      expect(body).toHaveProperty('notificationsEnabled', false);
      expect(body).toHaveProperty('theme', 'dark');
      expect(body).not.toHaveProperty('passwordHash');
    });

    it('PATCH /api/users/profile - should fail with invalid theme', async () => {
      await request(app.getHttpServer())
        .patch('/api/users/profile')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({ theme: 'neon' })
        .expect(400);
    });
  });
});
