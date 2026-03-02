import {
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { WhereOptions } from 'sequelize';
import { Budget, BudgetPeriod } from './budget.model.js';
import { Category } from '../categories/category.model.js';
import { TransactionsService } from '../transactions/transactions.service.js';
import { EventsGateway } from '../events/events.gateway.js';
import { CreateBudgetDto } from './dto/create-budget.dto.js';
import { UpdateBudgetDto } from './dto/update-budget.dto.js';
import { QueryBudgetDto } from './dto/query-budget.dto.js';

export interface PaginatedResult<T> {
  data: T[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

export interface BudgetWithProgress {
  id: string;
  name: string;
  amount: number;
  period: BudgetPeriod;
  categoryId: string | null;
  categoryName: string | null;
  categoryIcon: string | null;
  categoryColor: string | null;
  startDate: string;
  endDate: string | null;
  isActive: boolean;
  spent: number;
  remaining: number;
  percentage: number;
}

@Injectable()
export class BudgetsService {
  private readonly logger = new Logger(BudgetsService.name);

  constructor(
    @InjectModel(Budget)
    private readonly budgetModel: typeof Budget,
    private readonly transactionsService: TransactionsService,
    private readonly eventsGateway: EventsGateway,
  ) {}

  async findAll(
    userId: string,
    query: QueryBudgetDto,
  ): Promise<PaginatedResult<BudgetWithProgress>> {
    const page = parseInt(query.page || '1', 10);
    const limit = parseInt(query.limit || '20', 10);
    const offset = (page - 1) * limit;

    const where: WhereOptions = { userId };

    if (query.isActive !== undefined) {
      (where as any).isActive = query.isActive === 'true';
    }

    const { count, rows } = await this.budgetModel.findAndCountAll({
      where,
      include: [
        { model: Category, attributes: ['id', 'name', 'icon', 'color'] },
      ],
      order: [['createdAt', 'DESC']],
      limit,
      offset,
    });

    const budgetsWithProgress = await Promise.all(
      rows.map((budget) => this.attachProgress(budget)),
    );

    return {
      data: budgetsWithProgress,
      total: count,
      page,
      limit,
      totalPages: Math.ceil(count / limit),
    };
  }

  async findOne(id: string, userId: string): Promise<BudgetWithProgress> {
    const budget = await this.budgetModel.findOne({
      where: { id, userId },
      include: [
        { model: Category, attributes: ['id', 'name', 'icon', 'color'] },
      ],
    });
    if (!budget) {
      throw new NotFoundException('Budget not found');
    }
    return this.attachProgress(budget);
  }

  async create(
    userId: string,
    dto: CreateBudgetDto,
  ): Promise<Budget> {
    const today = new Date().toISOString().split('T')[0]!;

    const budget = await this.budgetModel.create({
      userId,
      name: dto.name,
      amount: dto.amount,
      period: dto.period,
      categoryId: dto.categoryId || null,
      startDate: dto.startDate || today,
      endDate: dto.endDate || null,
      isActive: true,
    } as any);

    this.eventsGateway.emitToUser(userId, 'budget:created', budget.toJSON());

    return budget;
  }

  async update(
    id: string,
    userId: string,
    dto: UpdateBudgetDto,
  ): Promise<Budget> {
    const budget = await this.budgetModel.findOne({
      where: { id, userId },
    });
    if (!budget) {
      throw new NotFoundException('Budget not found');
    }

    await budget.update(dto);

    this.eventsGateway.emitToUser(userId, 'budget:updated', budget.toJSON());

    return budget;
  }

  async remove(id: string, userId: string): Promise<void> {
    const budget = await this.budgetModel.findOne({
      where: { id, userId },
    });
    if (!budget) {
      throw new NotFoundException('Budget not found');
    }

    const budgetData = budget.toJSON();
    await budget.destroy();

    this.eventsGateway.emitToUser(userId, 'budget:deleted', { id: budgetData.id });
  }

  async getActiveBudgetsWithProgress(
    userId: string,
  ): Promise<BudgetWithProgress[]> {
    const budgets = await this.budgetModel.findAll({
      where: { userId, isActive: true },
      include: [
        { model: Category, attributes: ['id', 'name', 'icon', 'color'] },
      ],
      order: [['createdAt', 'DESC']],
    });

    return Promise.all(budgets.map((budget) => this.attachProgress(budget)));
  }

  async checkBudgetAlerts(userId: string): Promise<Array<{
    budgetId: string;
    budgetName: string;
    percentage: number;
    type: 'warning' | 'exceeded';
  }>> {
    const budgets = await this.getActiveBudgetsWithProgress(userId);
    const alerts: Array<{
      budgetId: string;
      budgetName: string;
      percentage: number;
      type: 'warning' | 'exceeded';
    }> = [];

    for (const budget of budgets) {
      if (budget.percentage > 100) {
        alerts.push({
          budgetId: budget.id,
          budgetName: budget.name,
          percentage: budget.percentage,
          type: 'exceeded',
        });
      } else if (budget.percentage > 90) {
        alerts.push({
          budgetId: budget.id,
          budgetName: budget.name,
          percentage: budget.percentage,
          type: 'warning',
        });
      }
    }

    return alerts;
  }

  private async attachProgress(budget: Budget): Promise<BudgetWithProgress> {
    const { year, month } = this.getCurrentPeriod(budget.period);
    const spending = await this.transactionsService.getSpendingByCategory(
      budget.userId,
      year,
      month,
    );

    let spent = 0;

    if (budget.categoryId) {
      const match = spending.find((s) => s.categoryId === budget.categoryId);
      spent = match ? match.total : 0;
    } else {
      spent = spending.reduce((sum, s) => sum + s.total, 0);
    }

    const budgetAmount = Number(budget.amount);
    const remaining = Math.max(0, budgetAmount - spent);
    const percentage = budgetAmount > 0
      ? Math.round((spent / budgetAmount) * 100)
      : 0;

    return {
      id: budget.id,
      name: budget.name,
      amount: budgetAmount,
      period: budget.period,
      categoryId: budget.categoryId,
      categoryName: (budget as any).category?.name || null,
      categoryIcon: (budget as any).category?.icon || null,
      categoryColor: (budget as any).category?.color || null,
      startDate: budget.startDate,
      endDate: budget.endDate,
      isActive: budget.isActive,
      spent,
      remaining,
      percentage,
    };
  }

  private getCurrentPeriod(period: BudgetPeriod): { year: number; month: number } {
    const now = new Date();
    const year = now.getFullYear();
    const month = now.getMonth() + 1;

    switch (period) {
      case BudgetPeriod.WEEKLY:
      case BudgetPeriod.MONTHLY:
        return { year, month };
      case BudgetPeriod.YEARLY:
        return { year, month: 1 };
      default:
        return { year, month };
    }
  }
}
