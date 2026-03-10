import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { Op, QueryTypes } from 'sequelize';
import * as bcrypt from 'bcrypt';
import { User } from '../users/user.model.js';
import { Subscription } from '../subscriptions/subscription.model.js';
import { Account } from '../accounts/account.model.js';
import { Transaction } from '../transactions/transaction.model.js';
import { Budget } from '../budgets/budget.model.js';
import { Debt } from '../debts/debt.model.js';
import { ReceiptScan } from '../receipts/receipt.model.js';
import { Notification } from '../notifications/notification.model.js';
import { QueryUsersDto } from './dto/query-users.dto.js';
import { UpdateUserAdminDto } from './dto/update-user-admin.dto.js';
import { UpdateSubscriptionAdminDto } from './dto/update-subscription-admin.dto.js';

@Injectable()
export class AdminService {
  private readonly logger = new Logger(AdminService.name);

  constructor(
    @InjectModel(User) private readonly userModel: typeof User,
    @InjectModel(Subscription) private readonly subscriptionModel: typeof Subscription,
    @InjectModel(Account) private readonly accountModel: typeof Account,
    @InjectModel(Transaction) private readonly transactionModel: typeof Transaction,
    @InjectModel(Budget) private readonly budgetModel: typeof Budget,
    @InjectModel(Debt) private readonly debtModel: typeof Debt,
    @InjectModel(ReceiptScan) private readonly receiptModel: typeof ReceiptScan,
    @InjectModel(Notification) private readonly notificationModel: typeof Notification,
  ) {}

  async promoteToAdmin(email: string) {
    const sequelize = this.userModel.sequelize!;
    try {
      await sequelize.query(`
        DO $$
        BEGIN
          IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_users_role') THEN
            CREATE TYPE "enum_users_role" AS ENUM ('USER', 'ADMIN');
          END IF;
          IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns
            WHERE table_name = 'users' AND column_name = 'role'
          ) THEN
            ALTER TABLE users ADD COLUMN role "enum_users_role" NOT NULL DEFAULT 'USER';
          END IF;
        END $$;
      `);
    } catch (e) {
      this.logger.warn(`Migration warning: ${(e as Error).message}`);
    }

    const user = await this.userModel.findOne({ where: { email } });
    if (!user) {
      throw new NotFoundException(`User with email "${email}" not found`);
    }

    await user.update({ role: 'ADMIN' });
    this.logger.log(`User ${email} promoted to ADMIN`);

    return { message: `User ${email} promoted to ADMIN`, userId: user.id, email: user.email, role: 'ADMIN' };
  }

  async resetPassword(email: string, newPassword: string) {
    const user = await this.userModel.findOne({ where: { email } });
    if (!user) {
      throw new NotFoundException(`User with email "${email}" not found`);
    }

    const passwordHash = await bcrypt.hash(newPassword, 12);
    await user.update({ passwordHash });
    this.logger.log(`Password reset for ${email}`);

    return { message: `Password reset for ${email}` };
  }

  async getStats() {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const [totalUsers, premiumUsers, activeUsers, totalTransactions, totalAccounts, totalBudgets, totalDebts, totalReceipts] =
      await Promise.all([
        this.userModel.count(),
        this.subscriptionModel.count({ where: { tier: 'premium', status: 'active' } }),
        this.userModel.count({ where: { lastLoginAt: { [Op.gte]: thirtyDaysAgo } } }),
        this.transactionModel.count(),
        this.accountModel.count(),
        this.budgetModel.count(),
        this.debtModel.count(),
        this.receiptModel.count(),
      ]);

    const sequelize = this.userModel.sequelize!;
    const userGrowth = await sequelize.query<{ date: string; count: string }>(
      `SELECT DATE(created_at) as date, COUNT(*) as count FROM users WHERE created_at >= NOW() - INTERVAL '30 days' GROUP BY DATE(created_at) ORDER BY date`,
      { type: QueryTypes.SELECT },
    );

    const transactionVolume = await sequelize.query<{ date: string; count: string }>(
      `SELECT DATE(date) as date, COUNT(*) as count FROM transactions WHERE date >= NOW() - INTERVAL '30 days' AND deleted_at IS NULL GROUP BY DATE(date) ORDER BY date`,
      { type: QueryTypes.SELECT },
    );

    return {
      totalUsers,
      premiumUsers,
      activeUsers,
      totalTransactions,
      totalAccounts,
      totalBudgets,
      totalDebts,
      totalReceipts,
      userGrowth: userGrowth.map(r => ({ date: r.date, count: Number(r.count) })),
      transactionVolume: transactionVolume.map(r => ({ date: r.date, count: Number(r.count) })),
    };
  }

  async getUsers(query: QueryUsersDto) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const offset = (page - 1) * limit;

    const where: any = {};

    if (query.search) {
      where[Op.or] = [
        { email: { [Op.iLike]: `%${query.search}%` } },
        { firstName: { [Op.iLike]: `%${query.search}%` } },
        { lastName: { [Op.iLike]: `%${query.search}%` } },
      ];
    }

    if (query.role) {
      where.role = query.role;
    }

    const includeOptions: any[] = [
      {
        model: Subscription,
        required: false,
        where: query.tier ? { tier: query.tier } : undefined,
      },
    ];

    const sortBy = query.sortBy || 'createdAt';
    const sortOrder = query.sortOrder || 'DESC';

    const { rows, count } = await this.userModel.findAndCountAll({
      where,
      include: includeOptions,
      order: [[sortBy, sortOrder]],
      limit,
      offset,
      attributes: { exclude: ['passwordHash'] },
    });

    return { data: rows, total: count, page, limit, totalPages: Math.ceil(count / limit) };
  }

  async getUserById(id: string) {
    const user = await this.userModel.findByPk(id, {
      attributes: { exclude: ['passwordHash'] },
      include: [{ model: Subscription, required: false }],
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    const [accountsCount, transactionsCount, budgetsCount, debtsCount] = await Promise.all([
      this.accountModel.count({ where: { userId: id } }),
      this.transactionModel.count({ where: { userId: id } }),
      this.budgetModel.count({ where: { userId: id } }),
      this.debtModel.count({ where: { userId: id } }),
    ]);

    return { ...user.toJSON(), accountsCount, transactionsCount, budgetsCount, debtsCount };
  }

  async updateUser(id: string, dto: UpdateUserAdminDto) {
    const user = await this.userModel.findByPk(id);
    if (!user) {
      throw new NotFoundException('User not found');
    }
    await user.update(dto as any);
    return this.getUserById(id);
  }

  async deleteUser(id: string) {
    const user = await this.userModel.findByPk(id);
    if (!user) {
      throw new NotFoundException('User not found');
    }
    await user.destroy();
    return { message: 'User deleted successfully' };
  }

  async updateSubscription(userId: string, dto: UpdateSubscriptionAdminDto) {
    const user = await this.userModel.findByPk(userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }

    let subscription = await this.subscriptionModel.findOne({ where: { userId } });

    if (!subscription) {
      subscription = await this.subscriptionModel.create({ userId, ...dto } as any);
    } else {
      await subscription.update(dto as any);
    }

    return subscription;
  }

  // --- User data access ---

  async getUserTransactions(userId: string, query: { page?: number; limit?: number; type?: string; startDate?: string; endDate?: string }) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const offset = (page - 1) * limit;
    const where: any = { userId };
    if (query.type) where.type = query.type;
    if (query.startDate || query.endDate) {
      where.date = {};
      if (query.startDate) where.date[Op.gte] = query.startDate;
      if (query.endDate) where.date[Op.lte] = query.endDate;
    }

    const { rows, count } = await this.transactionModel.findAndCountAll({
      where,
      order: [['date', 'DESC']],
      limit,
      offset,
    });

    return { data: rows, total: count, page, limit, totalPages: Math.ceil(count / limit) };
  }

  async getUserAccounts(userId: string) {
    return this.accountModel.findAll({ where: { userId }, order: [['createdAt', 'DESC']] });
  }

  async getUserBudgets(userId: string) {
    return this.budgetModel.findAll({ where: { userId }, order: [['createdAt', 'DESC']] });
  }

  async getUserDebts(userId: string) {
    return this.debtModel.findAll({ where: { userId }, order: [['createdAt', 'DESC']] });
  }

  // --- Global views ---

  async getAllTransactions(query: { page?: number; limit?: number; type?: string; startDate?: string; endDate?: string; userId?: string }) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const offset = (page - 1) * limit;
    const where: any = {};
    if (query.userId) where.userId = query.userId;
    if (query.type) where.type = query.type;
    if (query.startDate || query.endDate) {
      where.date = {};
      if (query.startDate) where.date[Op.gte] = query.startDate;
      if (query.endDate) where.date[Op.lte] = query.endDate;
    }

    const { rows, count } = await this.transactionModel.findAndCountAll({
      where,
      include: [{ model: User, attributes: ['id', 'email', 'firstName', 'lastName'] }],
      order: [['date', 'DESC']],
      limit,
      offset,
    });

    return { data: rows, total: count, page, limit, totalPages: Math.ceil(count / limit) };
  }

  async getAllSubscriptions(query: { page?: number; limit?: number; tier?: string; status?: string }) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const offset = (page - 1) * limit;
    const where: any = {};
    if (query.tier) where.tier = query.tier;
    if (query.status) where.status = query.status;

    const { rows, count } = await this.subscriptionModel.findAndCountAll({
      where,
      include: [{ model: User, attributes: ['id', 'email', 'firstName', 'lastName'] }],
      order: [['createdAt', 'DESC']],
      limit,
      offset,
    });

    return { data: rows, total: count, page, limit, totalPages: Math.ceil(count / limit) };
  }

  async getReceipts(query: { page?: number; limit?: number; status?: string }) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const offset = (page - 1) * limit;
    const where: any = {};
    if (query.status) where.status = query.status;

    const { rows, count } = await this.receiptModel.findAndCountAll({
      where,
      include: [{ model: User, attributes: ['id', 'email', 'firstName', 'lastName'] }],
      order: [['createdAt', 'DESC']],
      limit,
      offset,
    });

    return { data: rows, total: count, page, limit, totalPages: Math.ceil(count / limit) };
  }

  async broadcastNotification(params: { title: string; body: string; userIds?: string[] }) {
    const users = params.userIds?.length
      ? await this.userModel.findAll({ where: { id: { [Op.in]: params.userIds } } })
      : await this.userModel.findAll();

    const notifications = users.map(u => ({
      userId: u.id,
      title: params.title,
      body: params.body,
      type: 'system',
      isRead: false,
    }));

    if (notifications.length > 0) {
      await this.notificationModel.bulkCreate(notifications as any[]);
    }

    return { sent: notifications.length };
  }
}
