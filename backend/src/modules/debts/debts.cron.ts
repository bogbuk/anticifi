import { Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { InjectModel } from '@nestjs/sequelize';
import { DebtsService } from './debts.service.js';
import { NotificationsService } from '../notifications/notifications.service.js';
import { NotificationType } from '../notifications/notification.model.js';
import { User } from '../users/user.model.js';

@Injectable()
export class DebtsCron {
  private readonly logger = new Logger(DebtsCron.name);

  constructor(
    private readonly debtsService: DebtsService,
    private readonly notificationsService: NotificationsService,
    @InjectModel(User)
    private readonly userModel: typeof User,
  ) {}

  @Cron('0 8 * * *')
  async handleDebtPaymentReminders(): Promise<void> {
    this.logger.log('Starting daily debt payment reminders...');

    try {
      const users = await this.userModel.findAll({
        attributes: ['id'],
      });

      let totalReminders = 0;

      for (const user of users) {
        const debts = await this.debtsService.getDebtsWithUpcomingPayments(user.id);

        for (const debt of debts) {
          const today = new Date().getDate();
          const daysUntil = debt.dueDay! - today;
          const dayLabel = daysUntil === 0 ? 'today' : `in ${daysUntil} day${daysUntil > 1 ? 's' : ''}`;

          await this.notificationsService.createNotification(
            user.id,
            'Debt Payment Due',
            `Payment for "${debt.name}" is due ${dayLabel}. Minimum payment: $${Number(debt.minimumPayment).toFixed(2)}`,
            NotificationType.DEBT_PAYMENT_DUE,
            {
              debtId: debt.id,
              debtName: debt.name,
              dueDay: debt.dueDay,
              minimumPayment: Number(debt.minimumPayment),
            },
          );

          totalReminders++;
        }
      }

      this.logger.log(`Debt payment reminders completed: ${totalReminders} reminders sent`);
    } catch (error) {
      this.logger.error(`Debt payment reminders cron failed: ${error}`);
    }
  }
}
