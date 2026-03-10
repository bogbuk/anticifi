import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { User } from '../users/user.model.js';
import { Transaction } from '../transactions/transaction.model.js';
import { Subscription } from '../subscriptions/subscription.model.js';
import { QueryTypes } from 'sequelize';

@Injectable()
export class AdminAnalyticsService {
  constructor(
    @InjectModel(User) private readonly userModel: typeof User,
    @InjectModel(Transaction) private readonly transactionModel: typeof Transaction,
    @InjectModel(Subscription) private readonly subscriptionModel: typeof Subscription,
  ) {}

  private get sequelize() {
    return this.userModel.sequelize!;
  }

  async getUserGrowth(days = 90) {
    const result = await this.sequelize.query<{ date: string; count: string }>(
      `SELECT DATE(created_at) as date, COUNT(*) as count
       FROM users WHERE created_at >= NOW() - $1::int * INTERVAL '1 day'
       GROUP BY DATE(created_at) ORDER BY date`,
      { bind: [days], type: QueryTypes.SELECT },
    );
    return result.map(r => ({ date: r.date, count: Number(r.count) }));
  }

  async getTransactionVolume(days = 90) {
    const result = await this.sequelize.query<{ date: string; count: string; total: string }>(
      `SELECT DATE(date) as date, COUNT(*) as count, COALESCE(SUM(amount), 0) as total
       FROM transactions WHERE date >= NOW() - $1::int * INTERVAL '1 day' AND deleted_at IS NULL
       GROUP BY DATE(date) ORDER BY date`,
      { bind: [days], type: QueryTypes.SELECT },
    );
    return result.map(r => ({ date: r.date, count: Number(r.count), total: Number(r.total) }));
  }

  async getRevenue(days = 90) {
    const result = await this.sequelize.query<{ date: string; count: string }>(
      `SELECT DATE(created_at) as date, COUNT(*) as count
       FROM subscriptions WHERE tier = 'premium' AND created_at >= NOW() - $1::int * INTERVAL '1 day'
       GROUP BY DATE(created_at) ORDER BY date`,
      { bind: [days], type: QueryTypes.SELECT },
    );
    return result.map(r => ({ date: r.date, count: Number(r.count) }));
  }

  async getRetention() {
    const [dau] = await this.sequelize.query<{ count: string }>(
      `SELECT COUNT(DISTINCT id) as count FROM users WHERE last_login_at >= NOW() - INTERVAL '1 day'`,
      { type: QueryTypes.SELECT },
    );
    const [wau] = await this.sequelize.query<{ count: string }>(
      `SELECT COUNT(DISTINCT id) as count FROM users WHERE last_login_at >= NOW() - INTERVAL '7 days'`,
      { type: QueryTypes.SELECT },
    );
    const [mau] = await this.sequelize.query<{ count: string }>(
      `SELECT COUNT(DISTINCT id) as count FROM users WHERE last_login_at >= NOW() - INTERVAL '30 days'`,
      { type: QueryTypes.SELECT },
    );
    const total = await this.userModel.count();
    return {
      dau: Number(dau?.count ?? 0),
      wau: Number(wau?.count ?? 0),
      mau: Number(mau?.count ?? 0),
      total,
    };
  }

  async getCategoryBreakdown() {
    const result = await this.sequelize.query<{ name: string; count: string; total: string }>(
      `SELECT c.name, COUNT(t.id) as count, COALESCE(SUM(t.amount), 0) as total
       FROM transactions t
       JOIN categories c ON t.category_id = c.id
       WHERE t.deleted_at IS NULL
       GROUP BY c.name ORDER BY total DESC LIMIT 20`,
      { type: QueryTypes.SELECT },
    );
    return result.map(r => ({ name: r.name, count: Number(r.count), total: Number(r.total) }));
  }

  async getSubscriptionBreakdown() {
    const result = await this.sequelize.query<{ tier: string; status: string; count: string }>(
      `SELECT tier, status, COUNT(*) as count FROM subscriptions GROUP BY tier, status`,
      { type: QueryTypes.SELECT },
    );
    return result.map(r => ({ tier: r.tier, status: r.status, count: Number(r.count) }));
  }
}