import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { Op, literal } from 'sequelize';
import { User } from '../users/user.model.js';
import { Subscription } from '../subscriptions/subscription.model.js';
import { Account } from '../accounts/account.model.js';
import { Transaction } from '../transactions/transaction.model.js';
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
  ) {}

  async promoteToAdmin(email: string) {
    const user = await this.userModel.findOne({ where: { email } });
    if (!user) {
      throw new NotFoundException(`User with email "${email}" not found`);
    }

    await user.update({ role: 'ADMIN' });
    this.logger.log(`User ${email} promoted to ADMIN`);

    return {
      message: `User ${email} promoted to ADMIN`,
      userId: user.id,
      email: user.email,
      role: 'ADMIN',
    };
  }

  async getStats() {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const [totalUsers, premiumUsers, activeUsers, totalTransactions, totalAccounts] =
      await Promise.all([
        this.userModel.count(),
        this.subscriptionModel.count({
          where: { tier: 'premium', status: 'active' },
        }),
        this.userModel.count({
          where: { lastLoginAt: { [Op.gte]: thirtyDaysAgo } },
        }),
        this.transactionModel.count(),
        this.accountModel.count(),
      ]);

    return {
      totalUsers,
      premiumUsers,
      activeUsers,
      totalTransactions,
      totalAccounts,
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

    return {
      data: rows,
      total: count,
      page,
      limit,
      totalPages: Math.ceil(count / limit),
    };
  }

  async getUserById(id: string) {
    const user = await this.userModel.findByPk(id, {
      attributes: { exclude: ['passwordHash'] },
      include: [{ model: Subscription, required: false }],
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    const [accountsCount, transactionsCount] = await Promise.all([
      this.accountModel.count({ where: { userId: id } }),
      this.transactionModel.count({ where: { userId: id } }),
    ]);

    return {
      ...user.toJSON(),
      accountsCount,
      transactionsCount,
    };
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

    let subscription = await this.subscriptionModel.findOne({
      where: { userId },
    });

    if (!subscription) {
      subscription = await this.subscriptionModel.create({
        userId,
        ...dto,
      } as any);
    } else {
      await subscription.update(dto as any);
    }

    return subscription;
  }
}
