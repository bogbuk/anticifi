import { Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { ScheduledPaymentsService } from './scheduled-payments.service.js';

@Injectable()
export class ScheduledPaymentsCron {
  private readonly logger = new Logger(ScheduledPaymentsCron.name);

  constructor(
    private readonly scheduledPaymentsService: ScheduledPaymentsService,
  ) {}

  @Cron('0 0 * * *')
  async handleScheduledPayments(): Promise<void> {
    this.logger.log('Starting scheduled payments execution...');

    try {
      const result =
        await this.scheduledPaymentsService.executeScheduledPayments();

      this.logger.log(
        `Scheduled payments execution completed: ${result.executed} executed, ${result.errors} errors`,
      );
    } catch (error) {
      this.logger.error(`Scheduled payments cron failed: ${error}`);
    }
  }
}
