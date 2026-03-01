import { createHash } from 'node:crypto';
import {
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { Op, WhereOptions } from 'sequelize';
import { Transaction, TransactionType } from './transaction.model.js';
import { Account } from '../accounts/account.model.js';
import { Category } from '../categories/category.model.js';
import { CreateTransactionDto } from './dto/create-transaction.dto.js';
import { UpdateTransactionDto } from './dto/update-transaction.dto.js';
import { QueryTransactionDto } from './dto/query-transaction.dto.js';

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

    return transaction;
  }

  async remove(id: string, userId: string): Promise<void> {
    const transaction = await this.findOne(id, userId);
    const { accountId } = transaction;
    await transaction.destroy();
    await this.recalculateBalance(accountId);
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
