import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';
import { TransactionsService } from '../transactions/transactions.service.js';
import { AccountsService } from '../accounts/accounts.service.js';
import { ScheduledPaymentsService } from '../scheduled-payments/scheduled-payments.service.js';
import type { PredictionResponseDto, ChatPredictionResponseDto } from './dto/prediction-response.dto.js';

@Injectable()
export class PredictionService {
  private readonly logger = new Logger(PredictionService.name);
  private readonly mlServiceUrl: string;

  constructor(
    private readonly httpService: HttpService,
    private readonly configService: ConfigService,
    private readonly transactionsService: TransactionsService,
    private readonly accountsService: AccountsService,
    private readonly scheduledPaymentsService: ScheduledPaymentsService,
  ) {
    this.mlServiceUrl =
      this.configService.get<string>('ML_SERVICE_URL') || 'http://localhost:8001';
  }

  async getForecast(
    userId: string,
    accountId?: string,
    daysAhead: number = 30,
  ): Promise<PredictionResponseDto> {
    const transactions = await this.getUserTransactions(userId, accountId);
    const currentBalance = await this.getCurrentBalance(userId, accountId);

    const payload = {
      userId,
      accountId: accountId || null,
      daysAhead,
      transactions,
      currentBalance,
    };

    try {
      const response = await firstValueFrom(
        this.httpService.post<PredictionResponseDto>(
          `${this.mlServiceUrl}/api/predict`,
          payload,
        ),
      );
      return response.data;
    } catch (error) {
      this.logger.error(`ML service prediction failed: ${error}`);
      return {
        predictions: [],
        currentBalance,
        confidence: 0,
      };
    }
  }

  async chatPredict(
    userId: string,
    question: string,
  ): Promise<ChatPredictionResponseDto> {
    const transactions = await this.getUserTransactions(userId);
    const currentBalance = await this.getCurrentBalance(userId);
    const scheduledPayments = await this.getScheduledPayments(userId);

    const payload = {
      userId,
      question,
      transactions,
      currentBalance,
      scheduledPayments,
    };

    try {
      const response = await firstValueFrom(
        this.httpService.post<ChatPredictionResponseDto>(
          `${this.mlServiceUrl}/api/predict/chat`,
          payload,
        ),
      );
      return response.data;
    } catch (error) {
      this.logger.error(`ML service chat prediction failed: ${error}`);
      return {
        answer:
          'Sorry, the prediction service is currently unavailable. Please try again later.',
        predictions: null,
      };
    }
  }

  private async getUserTransactions(
    userId: string,
    accountId?: string,
  ): Promise<Array<{ date: string; amount: number; type: string }>> {
    const result = await this.transactionsService.findAll(userId, {
      accountId,
      limit: '1000',
      page: '1',
    });

    return result.data.map((tx) => ({
      date: tx.date,
      amount: Number(tx.amount),
      type: tx.type,
    }));
  }

  private async getCurrentBalance(
    userId: string,
    accountId?: string,
  ): Promise<number> {
    if (accountId) {
      const account = await this.accountsService.findOneByIdAndUserId(
        accountId,
        userId,
      );
      return Number(account.balance);
    }

    const accounts = await this.accountsService.findAllByUserId(userId);
    return accounts.reduce((sum, acc) => sum + Number(acc.balance), 0);
  }

  private async getScheduledPayments(
    userId: string,
  ): Promise<
    Array<{
      name: string;
      amount: number;
      type: string;
      frequency: string;
      nextExecutionDate: string;
    }>
  > {
    const result = await this.scheduledPaymentsService.findAll(userId, {
      isActive: 'true',
      limit: '100',
      page: '1',
    });

    return result.data.map((sp) => ({
      name: sp.name,
      amount: Number(sp.amount),
      type: sp.type,
      frequency: sp.frequency,
      nextExecutionDate: sp.nextExecutionDate,
    }));
  }
}
