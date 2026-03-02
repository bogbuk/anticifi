import {
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { WhereOptions } from 'sequelize';
import { Debt, DebtType } from './debt.model.js';
import { DebtPayment } from './debt-payment.model.js';
import { EventsGateway } from '../events/events.gateway.js';
import { CreateDebtDto } from './dto/create-debt.dto.js';
import { UpdateDebtDto } from './dto/update-debt.dto.js';
import { QueryDebtDto } from './dto/query-debt.dto.js';
import { CreateDebtPaymentDto } from './dto/create-debt-payment.dto.js';
import { QueryDebtPaymentDto } from './dto/query-debt-payment.dto.js';

export interface PaginatedResult<T> {
  data: T[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

export interface DebtWithProgress {
  id: string;
  name: string;
  type: DebtType;
  originalAmount: number;
  currentBalance: number;
  interestRate: number;
  minimumPayment: number;
  dueDay: number | null;
  startDate: string;
  expectedPayoffDate: string | null;
  creditorName: string | null;
  notes: string | null;
  isActive: boolean;
  isPaidOff: boolean;
  totalPaid: number;
  progressPercent: number;
  createdAt: Date;
}

export interface DebtSummary {
  totalDebts: number;
  activeDebts: number;
  paidOffDebts: number;
  totalOriginalAmount: number;
  totalCurrentBalance: number;
  totalPaid: number;
  overallProgress: number;
}

@Injectable()
export class DebtsService {
  private readonly logger = new Logger(DebtsService.name);

  constructor(
    @InjectModel(Debt)
    private readonly debtModel: typeof Debt,
    @InjectModel(DebtPayment)
    private readonly debtPaymentModel: typeof DebtPayment,
    private readonly eventsGateway: EventsGateway,
  ) {}

  async findAll(
    userId: string,
    query: QueryDebtDto,
  ): Promise<PaginatedResult<DebtWithProgress>> {
    const page = parseInt(query.page || '1', 10);
    const limit = parseInt(query.limit || '20', 10);
    const offset = (page - 1) * limit;

    const where: WhereOptions = { userId };

    if (query.isActive !== undefined) {
      (where as any).isActive = query.isActive === 'true';
    }
    if (query.isPaidOff !== undefined) {
      (where as any).isPaidOff = query.isPaidOff === 'true';
    }
    if (query.type) {
      (where as any).type = query.type;
    }

    const { count, rows } = await this.debtModel.findAndCountAll({
      where,
      order: [['createdAt', 'DESC']],
      limit,
      offset,
    });

    const debtsWithProgress = await Promise.all(
      rows.map((debt) => this.attachProgress(debt)),
    );

    return {
      data: debtsWithProgress,
      total: count,
      page,
      limit,
      totalPages: Math.ceil(count / limit),
    };
  }

  async findOne(id: string, userId: string): Promise<DebtWithProgress> {
    const debt = await this.debtModel.findOne({
      where: { id, userId },
    });
    if (!debt) {
      throw new NotFoundException('Debt not found');
    }
    return this.attachProgress(debt);
  }

  async create(userId: string, dto: CreateDebtDto): Promise<Debt> {
    const today = new Date().toISOString().split('T')[0]!;

    const debt = await this.debtModel.create({
      userId,
      name: dto.name,
      type: dto.type,
      originalAmount: dto.originalAmount,
      currentBalance: dto.currentBalance,
      interestRate: dto.interestRate ?? 0,
      minimumPayment: dto.minimumPayment ?? 0,
      dueDay: dto.dueDay || null,
      startDate: dto.startDate || today,
      expectedPayoffDate: dto.expectedPayoffDate || null,
      creditorName: dto.creditorName || null,
      notes: dto.notes || null,
      isActive: true,
      isPaidOff: false,
    } as any);

    this.eventsGateway.emitToUser(userId, 'debt:created', debt.toJSON());

    return debt;
  }

  async update(id: string, userId: string, dto: UpdateDebtDto): Promise<Debt> {
    const debt = await this.debtModel.findOne({
      where: { id, userId },
    });
    if (!debt) {
      throw new NotFoundException('Debt not found');
    }

    await debt.update(dto);

    this.eventsGateway.emitToUser(userId, 'debt:updated', debt.toJSON());

    return debt;
  }

  async remove(id: string, userId: string): Promise<void> {
    const debt = await this.debtModel.findOne({
      where: { id, userId },
    });
    if (!debt) {
      throw new NotFoundException('Debt not found');
    }

    const debtData = debt.toJSON();
    await debt.destroy();

    this.eventsGateway.emitToUser(userId, 'debt:deleted', { id: debtData.id });
  }

  async recordPayment(
    debtId: string,
    userId: string,
    dto: CreateDebtPaymentDto,
  ): Promise<DebtPayment> {
    const debt = await this.debtModel.findOne({
      where: { id: debtId, userId },
    });
    if (!debt) {
      throw new NotFoundException('Debt not found');
    }

    const today = new Date().toISOString().split('T')[0]!;

    const payment = await this.debtPaymentModel.create({
      debtId,
      userId,
      amount: dto.amount,
      paymentDate: dto.paymentDate || today,
      notes: dto.notes || null,
    } as any);

    // Update current balance
    const newBalance = Math.max(0, Number(debt.currentBalance) - dto.amount);
    await debt.update({
      currentBalance: newBalance,
      isPaidOff: newBalance === 0,
    });

    this.eventsGateway.emitToUser(userId, 'debt:payment_recorded', {
      debtId,
      payment: payment.toJSON(),
      newBalance,
    });

    return payment;
  }

  async getPayments(
    debtId: string,
    userId: string,
    query: QueryDebtPaymentDto,
  ): Promise<PaginatedResult<DebtPayment>> {
    // Verify debt belongs to user
    const debt = await this.debtModel.findOne({
      where: { id: debtId, userId },
    });
    if (!debt) {
      throw new NotFoundException('Debt not found');
    }

    const page = parseInt(query.page || '1', 10);
    const limit = parseInt(query.limit || '20', 10);
    const offset = (page - 1) * limit;

    const { count, rows } = await this.debtPaymentModel.findAndCountAll({
      where: { debtId, userId },
      order: [['paymentDate', 'DESC']],
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

  async getSummary(userId: string): Promise<DebtSummary> {
    const debts = await this.debtModel.findAll({
      where: { userId },
    });

    const totalDebts = debts.length;
    const activeDebts = debts.filter((d) => d.isActive && !d.isPaidOff).length;
    const paidOffDebts = debts.filter((d) => d.isPaidOff).length;

    const totalOriginalAmount = debts.reduce(
      (sum, d) => sum + Number(d.originalAmount),
      0,
    );
    const totalCurrentBalance = debts.reduce(
      (sum, d) => sum + Number(d.currentBalance),
      0,
    );
    const totalPaid = totalOriginalAmount - totalCurrentBalance;
    const overallProgress =
      totalOriginalAmount > 0
        ? Math.round((totalPaid / totalOriginalAmount) * 100)
        : 0;

    return {
      totalDebts,
      activeDebts,
      paidOffDebts,
      totalOriginalAmount,
      totalCurrentBalance,
      totalPaid,
      overallProgress,
    };
  }

  async getDebtsWithUpcomingPayments(userId: string): Promise<Debt[]> {
    const today = new Date();
    const currentDay = today.getDate();

    const debts = await this.debtModel.findAll({
      where: { userId, isActive: true, isPaidOff: false },
    });

    // Return debts where dueDay is within next 3 days
    return debts.filter((debt) => {
      if (!debt.dueDay) return false;
      const daysUntilDue = this.getDaysUntilDue(currentDay, debt.dueDay);
      return daysUntilDue >= 0 && daysUntilDue <= 3;
    });
  }

  private getDaysUntilDue(currentDay: number, dueDay: number): number {
    if (dueDay >= currentDay) {
      return dueDay - currentDay;
    }
    // Due day is in next month
    return -1;
  }

  private async attachProgress(debt: Debt): Promise<DebtWithProgress> {
    const originalAmount = Number(debt.originalAmount);
    const currentBalance = Number(debt.currentBalance);
    const totalPaid = Math.max(0, originalAmount - currentBalance);
    const progressPercent =
      originalAmount > 0
        ? Math.round((totalPaid / originalAmount) * 100)
        : 0;

    return {
      id: debt.id,
      name: debt.name,
      type: debt.type,
      originalAmount,
      currentBalance,
      interestRate: Number(debt.interestRate),
      minimumPayment: Number(debt.minimumPayment),
      dueDay: debt.dueDay,
      startDate: debt.startDate,
      expectedPayoffDate: debt.expectedPayoffDate,
      creditorName: debt.creditorName,
      notes: debt.notes,
      isActive: debt.isActive,
      isPaidOff: debt.isPaidOff,
      totalPaid,
      progressPercent,
      createdAt: debt.createdAt,
    };
  }
}
