import {
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { Op, WhereOptions } from 'sequelize';
import {
  ScheduledPayment,
  PaymentFrequency,
} from './scheduled-payment.model.js';
import { Account } from '../accounts/account.model.js';
import { Category } from '../categories/category.model.js';
import { TransactionsService } from '../transactions/transactions.service.js';
import { TransactionType } from '../transactions/transaction.model.js';
import { EventsGateway } from '../events/events.gateway.js';
import { CreateScheduledPaymentDto } from './dto/create-scheduled-payment.dto.js';
import { UpdateScheduledPaymentDto } from './dto/update-scheduled-payment.dto.js';
import { QueryScheduledPaymentDto } from './dto/query-scheduled-payment.dto.js';

export interface PaginatedResult<T> {
  data: T[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

@Injectable()
export class ScheduledPaymentsService {
  private readonly logger = new Logger(ScheduledPaymentsService.name);

  constructor(
    @InjectModel(ScheduledPayment)
    private readonly scheduledPaymentModel: typeof ScheduledPayment,
    private readonly transactionsService: TransactionsService,
    private readonly eventsGateway: EventsGateway,
  ) {}

  async findAll(
    userId: string,
    query: QueryScheduledPaymentDto,
  ): Promise<PaginatedResult<ScheduledPayment>> {
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
    if (query.isActive !== undefined) {
      (where as any).isActive = query.isActive === 'true';
    }

    const { count, rows } = await this.scheduledPaymentModel.findAndCountAll({
      where,
      include: [
        { model: Account, attributes: ['id', 'name', 'type', 'currency'] },
        { model: Category, attributes: ['id', 'name', 'icon', 'color'] },
      ],
      order: [['nextExecutionDate', 'ASC']],
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

  async findOne(id: string, userId: string): Promise<ScheduledPayment> {
    const payment = await this.scheduledPaymentModel.findOne({
      where: { id, userId },
      include: [
        { model: Account, attributes: ['id', 'name', 'type', 'currency'] },
        { model: Category, attributes: ['id', 'name', 'icon', 'color'] },
      ],
    });
    if (!payment) {
      throw new NotFoundException('Scheduled payment not found');
    }
    return payment;
  }

  async create(
    userId: string,
    dto: CreateScheduledPaymentDto,
  ): Promise<ScheduledPayment> {
    const payment = await this.scheduledPaymentModel.create({
      userId,
      accountId: dto.accountId,
      categoryId: dto.categoryId || null,
      name: dto.name,
      amount: dto.amount,
      type: dto.type,
      frequency: dto.frequency,
      startDate: dto.startDate,
      endDate: dto.endDate || null,
      nextExecutionDate: dto.nextExecutionDate || dto.startDate,
      isActive: dto.isActive !== undefined ? dto.isActive : true,
      description: dto.description || null,
    } as any);

    this.eventsGateway.emitToUser(userId, 'scheduled-payment:created', payment.toJSON());

    return payment;
  }

  async update(
    id: string,
    userId: string,
    dto: UpdateScheduledPaymentDto,
  ): Promise<ScheduledPayment> {
    const payment = await this.findOne(id, userId);
    await payment.update(dto);

    this.eventsGateway.emitToUser(userId, 'scheduled-payment:updated', payment.toJSON());

    return payment;
  }

  async remove(id: string, userId: string): Promise<void> {
    const payment = await this.findOne(id, userId);
    const paymentData = payment.toJSON();
    await payment.destroy();

    this.eventsGateway.emitToUser(userId, 'scheduled-payment:deleted', { id: paymentData.id });
  }

  async executeSingle(id: string, userId: string): Promise<ScheduledPayment> {
    const payment = await this.findOne(id, userId);

    const today = new Date().toISOString().split('T')[0]!;

    await this.transactionsService.create(userId, {
      accountId: payment.accountId,
      amount: payment.amount,
      type: payment.type as unknown as TransactionType,
      description: payment.description || payment.name,
      categoryId: payment.categoryId || undefined,
      date: today,
    });

    const nextDate = this.calculateNextDate(
      payment.nextExecutionDate,
      payment.frequency,
    );

    const updateData: any = {
      lastExecutedAt: new Date(),
      nextExecutionDate: nextDate,
    };

    if (payment.endDate && nextDate > payment.endDate) {
      updateData.isActive = false;
    }

    await payment.update(updateData);

    this.eventsGateway.emitToUser(userId, 'scheduled-payment:executed', payment.toJSON());

    return payment;
  }

  async executeScheduledPayments(): Promise<{ executed: number; errors: number }> {
    const today = new Date().toISOString().split('T')[0]!;

    const duePayments = await this.scheduledPaymentModel.findAll({
      where: {
        isActive: true,
        nextExecutionDate: { [Op.lte]: today },
      },
    });

    let executed = 0;
    let errors = 0;

    for (const payment of duePayments) {
      try {
        await this.transactionsService.create(payment.userId, {
          accountId: payment.accountId,
          amount: payment.amount,
          type: payment.type as unknown as TransactionType,
          description: payment.description || payment.name,
          categoryId: payment.categoryId || undefined,
          date: today,
        });

        const nextDate = this.calculateNextDate(
          payment.nextExecutionDate,
          payment.frequency,
        );

        const updateData: any = {
          lastExecutedAt: new Date(),
          nextExecutionDate: nextDate,
        };

        if (payment.endDate && nextDate > payment.endDate) {
          updateData.isActive = false;
        }

        await payment.update(updateData);

        this.eventsGateway.emitToUser(
          payment.userId,
          'scheduled-payment:executed',
          payment.toJSON(),
        );

        executed++;
      } catch (error) {
        this.logger.error(
          `Failed to execute scheduled payment ${payment.id}: ${error}`,
        );
        errors++;
      }
    }

    return { executed, errors };
  }

  calculateNextDate(currentDate: string, frequency: PaymentFrequency): string {
    const date = new Date(currentDate + 'T00:00:00');

    switch (frequency) {
      case PaymentFrequency.DAILY:
        date.setDate(date.getDate() + 1);
        break;
      case PaymentFrequency.WEEKLY:
        date.setDate(date.getDate() + 7);
        break;
      case PaymentFrequency.BIWEEKLY:
        date.setDate(date.getDate() + 14);
        break;
      case PaymentFrequency.MONTHLY:
        date.setMonth(date.getMonth() + 1);
        break;
      case PaymentFrequency.QUARTERLY:
        date.setMonth(date.getMonth() + 3);
        break;
      case PaymentFrequency.YEARLY:
        date.setFullYear(date.getFullYear() + 1);
        break;
    }

    return date.toISOString().split('T')[0]!;
  }
}
