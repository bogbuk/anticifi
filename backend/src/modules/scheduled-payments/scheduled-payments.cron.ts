import { Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { ScheduledPaymentsService } from './scheduled-payments.service.js';
import { NotificationsService } from '../notifications/notifications.service.js';
import { NotificationType } from '../notifications/notification.model.js';

@Injectable()
export class ScheduledPaymentsCron {
  private readonly logger = new Logger(ScheduledPaymentsCron.name);

  constructor(
    private readonly scheduledPaymentsService: ScheduledPaymentsService,
    private readonly notificationsService: NotificationsService,
  ) {}

  @Cron('0 0 * * *')
  async handleScheduledPayments(): Promise<void> {
    this.logger.log('Starting scheduled payments execution...');

    try {
      const result =
        await this.scheduledPaymentsService.executeScheduledPayments();

      // Create notifications for executed and failed payments
      for (const executed of result.executedPayments) {
        await this.notificationsService.createNotification(
          executed.userId,
          'Payment executed',
          `Payment executed: ${executed.name} — $${Number(executed.amount).toFixed(2)}`,
          NotificationType.PAYMENT_REMINDER,
          {
            paymentId: executed.id,
            paymentName: executed.name,
            amount: Number(executed.amount),
          },
        );
      }

      for (const failed of result.failedPayments) {
        await this.notificationsService.createNotification(
          failed.userId,
          'Payment failed',
          `Payment failed: ${failed.name}`,
          NotificationType.PAYMENT_REMINDER,
          {
            paymentId: failed.id,
            paymentName: failed.name,
          },
        );
      }

      this.logger.log(
        `Scheduled payments execution completed: ${result.executed} executed, ${result.errors} errors`,
      );
    } catch (error) {
      this.logger.error(`Scheduled payments cron failed: ${error}`);
    }
  }
}
