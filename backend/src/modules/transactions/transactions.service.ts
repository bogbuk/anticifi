import { createHash } from 'node:crypto';
import {
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { Op, WhereOptions, fn, col, literal } from 'sequelize';
import { Transaction, TransactionType } from './transaction.model.js';
import { Account } from '../accounts/account.model.js';
import { Category } from '../categories/category.model.js';
import { CreateTransactionDto } from './dto/create-transaction.dto.js';
import { UpdateTransactionDto } from './dto/update-transaction.dto.js';
import { QueryTransactionDto } from './dto/query-transaction.dto.js';
import { EventsGateway } from '../events/events.gateway.js';

export interface MonthlyStatsResult {
  income: number;
  expense: number;
}

export interface CategorySpendingResult {
  categoryId: string | null;
  categoryName: string;
  categoryIcon: string | null;
  categoryColor: string | null;
  total: number;
}

export interface PaginatedResult<T> {
  data: T[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

@Injectable()
export class TransactionsService {
  constructor(
    @InjectModel(Transaction)
    private readonly transactionModel: typeof Transaction,
    @InjectModel(Account)
    private readonly accountModel: typeof Account,
    private readonly eventsGateway: EventsGateway,
  ) {}

  async findAll(
    userId: string,
    query: QueryTransactionDto,
  ): Promise<PaginatedResult<Transaction>> {
    const page = parseInt(query.page || '1', 10);
    const limit = parseInt(query.limit || '20', 10);
    const offset = (page - 1) * limit;

    const where: WhereOptions = { userId };

    if (query.accountId) {
      (where as any).accountId = query.accountId;
    }
    if (query.type) {
      (where as any).type = query.type;
    }
    if (query.categoryId) {
      (where as any).categoryId = query.categoryId;
    }
    if (query.startDate || query.endDate) {
      const dateCondition: any = {};
      if (query.startDate) {
        dateCondition[Op.gte] = query.startDate;
      }
      if (query.endDate) {
        dateCondition[Op.lte] = query.endDate;
      }
      (where as any).date = dateCondition;
    }
    if (query.search) {
      (where as any).description = { [Op.iLike]: `%${query.search}%` };
    }

    const { count, rows } = await this.transactionModel.findAndCountAll({
      where,
      include: [{ model: Category, attributes: ['id', 'name', 'icon', 'color'] }],
      order: [['date', 'DESC'], ['createdAt', 'DESC']],
      limit,
      offset,
    });

    return {
      data: rows,
      total: count,
      page,
      limit,
      totalPages: Math.ceil(count / limit),
    };
  }

  async findOne(id: string, userId: string): Promise<Transaction> {
    const transaction = await this.transactionModel.findOne({
      where: { id, userId },
      include: [
        { model: Category, attributes: ['id', 'name', 'icon', 'color'] },
        { model: Account, attributes: ['id', 'name', 'type', 'currency'] },
      ],
    });
    if (!transaction) {
      throw new NotFoundException('Transaction not found');
    }
    return transaction;
  }

  async create(
    userId: string,
    dto: CreateTransactionDto,
  ): Promise<Transaction> {
    const transactionHash = this.generateHash(
      dto.accountId,
      dto.amount,
      dto.date,
      dto.description,
    );

    const transaction = await this.transactionModel.create({
      userId,
      accountId: dto.accountId,
      amount: dto.amount,
      type: dto.type,
      description: dto.description,
      categoryId: dto.categoryId,
      date: dto.date,
      transactionHash,
    } as any);

    await this.recalculateBalance(dto.accountId);

    this.eventsGateway.emitToUser(userId, 'transaction:created', transaction.toJSON());
    const account = await this.accountModel.findByPk(dto.accountId);
    if (account) {
      this.eventsGateway.emitToUser(userId, 'balance:updated', {
        accountId: account.id,
        balance: account.balance,
      });
    }

    return transaction;
  }

  async update(
    id: string,
    userId: string,
    dto: UpdateTransactionDto,
  ): Promise<Transaction> {
    const transaction = await this.findOne(id, userId);
    const oldAccountId = transaction.accountId;

    if (dto.accountId || dto.amount !== undefined || dto.date || dto.description !== undefined) {
      const hashAccountId = dto.accountId || transaction.accountId;
      const hashAmount = dto.amount !== undefined ? dto.amount : transaction.amount;
      const hashDate = dto.date || transaction.date;
      const hashDescription = dto.description !== undefined ? dto.description : transaction.description;

      (dto as any).transactionHash = this.generateHash(
        hashAccountId,
        hashAmount,
        hashDate,
        hashDescription,
      );
    }

    await transaction.update(dto);

    await this.recalculateBalance(transaction.accountId);
    if (dto.accountId && dto.accountId !== oldAccountId) {
      await this.recalculateBalance(oldAccountId);
    }

    this.eventsGateway.emitToUser(userId, 'transaction:updated', transaction.toJSON());
    const updatedAccount = await this.accountModel.findByPk(transaction.accountId);
    if (updatedAccount) {
      this.eventsGateway.emitToUser(userId, 'balance:updated', {
        accountId: updatedAccount.id,
        balance: updatedAccount.balance,
      });
    }
    if (dto.accountId && dto.accountId !== oldAccountId) {
      const oldAccount = await this.accountModel.findByPk(oldAccountId);
      if (oldAccount) {
        this.eventsGateway.emitToUser(userId, 'balance:updated', {
          accountId: oldAccount.id,
          balance: oldAccount.balance,
        });
      }
    }

    return transaction;
  }

  async remove(id: string, userId: string): Promise<void> {
    const transaction = await this.findOne(id, userId);
    const { accountId } = transaction;
    const transactionData = transaction.toJSON();
    await transaction.destroy();
    await this.recalculateBalance(accountId);

    this.eventsGateway.emitToUser(userId, 'transaction:deleted', { id: transactionData.id });
    const account = await this.accountModel.findByPk(accountId);
    if (account) {
      this.eventsGateway.emitToUser(userId, 'balance:updated', {
        accountId: account.id,
        balance: account.balance,
      });
    }
  }

  async recalculateBalance(accountId: string): Promise<void> {
    const account = await this.accountModel.findByPk(accountId);
    if (!account) {
      return;
    }

    const incomeSum = await this.transactionModel.sum('amount', {
      where: { accountId, type: TransactionType.INCOME },
    }) || 0;

    const expenseSum = await this.transactionModel.sum('amount', {
      where: { accountId, type: TransactionType.EXPENSE },
    }) || 0;

    const balance = Number(account.initialBalance) + Number(incomeSum) - Number(expenseSum);
    await account.update({ balance });
  }

  async getMonthlyStats(
    userId: string,
    year: number,
    month: number,
  ): Promise<MonthlyStatsResult> {
    const startDate = `${year}-${String(month).padStart(2, '0')}-01`;
    const endMonth = month === 12 ? 1 : month + 1;
    const endYear = month === 12 ? year + 1 : year;
    const endDate = `${endYear}-${String(endMonth).padStart(2, '0')}-01`;

    const income =
      (await this.transactionModel.sum('amount', {
        where: {
          userId,
          type: TransactionType.INCOME,
          date: { [Op.gte]: startDate, [Op.lt]: endDate },
        },
      })) || 0;

    const expense =
      (await this.transactionModel.sum('amount', {
        where: {
          userId,
          type: TransactionType.EXPENSE,
          date: { [Op.gte]: startDate, [Op.lt]: endDate },
        },
      })) || 0;

    return { income: Number(income), expense: Number(expense) };
  }

  async getSpendingByCategory(
    userId: string,
    year: number,
    month: number,
  ): Promise<CategorySpendingResult[]> {
    const startDate = `${year}-${String(month).padStart(2, '0')}-01`;
    const endMonth = month === 12 ? 1 : month + 1;
    const endYear = month === 12 ? year + 1 : year;
    const endDate = `${endYear}-${String(endMonth).padStart(2, '0')}-01`;

    const results = await this.transactionModel.findAll({
      attributes: [
        'categoryId',
        [fn('SUM', col('Transaction.amount')), 'total'],
      ],
      where: {
        userId,
        type: TransactionType.EXPENSE,
        date: { [Op.gte]: startDate, [Op.lt]: endDate },
      },
      include: [
        {
          model: Category,
          attributes: ['id', 'name', 'icon', 'color'],
        },
      ],
      group: ['Transaction.category_id', 'category.id', 'category.name', 'category.icon', 'category.color'],
      order: [[literal('total'), 'DESC']],
      raw: false,
    });

    return results.map((row: any) => ({
      categoryId: row.categoryId,
      categoryName: row.category?.name || 'Uncategorized',
      categoryIcon: row.category?.icon || null,
      categoryColor: row.category?.color || null,
      total: Number(row.getDataValue('total')),
    }));
  }

  async getRecentTransactions(
    userId: string,
    limit = 10,
  ): Promise<Transaction[]> {
    return this.transactionModel.findAll({
      where: { userId },
      include: [
        { model: Category, attributes: ['id', 'name', 'icon', 'color'] },
        { model: Account, attributes: ['id', 'name', 'type', 'currency'] },
      ],
      order: [['date', 'DESC'], ['createdAt', 'DESC']],
      limit,
    });
  }

  generateHash(
    accountId: string,
    amount: number,
    date: string,
    description?: string | null,
  ): string {
    const raw = [
      accountId,
      date,
      Number(amount).toFixed(2),
      (description || '').toLowerCase().trim(),
    ].join(':');

    return createHash('sha256').update(raw).digest('hex');
  }
}
