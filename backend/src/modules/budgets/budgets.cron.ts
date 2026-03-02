import { Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { InjectModel } from '@nestjs/sequelize';
import { BudgetsService } from './budgets.service.js';
import { NotificationsService } from '../notifications/notifications.service.js';
import { NotificationType } from '../notifications/notification.model.js';
import { User } from '../users/user.model.js';

@Injectable()
export class BudgetsCron {
  private readonly logger = new Logger(BudgetsCron.name);

  constructor(
    private readonly budgetsService: BudgetsService,
    private readonly notificationsService: NotificationsService,
    @InjectModel(User)
    private readonly userModel: typeof User,
  ) {}

  @Cron('0 9 * * *')
  async handleBudgetAlerts(): Promise<void> {
    this.logger.log('Starting daily budget alerts check...');

    try {
      const users = await this.userModel.findAll({
        attributes: ['id'],
      });

      let totalAlerts = 0;

      for (const user of users) {
        const alerts = await this.budgetsService.checkBudgetAlerts(user.id);

        for (const alert of alerts) {
          const title =
            alert.type === 'exceeded'
              ? 'Budget Exceeded'
              : 'Budget Almost Exceeded';
          const body =
            alert.type === 'exceeded'
              ? `Your budget "${alert.budgetName}" has been exceeded (${alert.percentage}% spent)`
              : `Your budget "${alert.budgetName}" is almost exceeded (${alert.percentage}% spent)`;

          await this.notificationsService.createNotification(
            user.id,
            title,
            body,
            NotificationType.BUDGET_ALERT,
            {
              budgetId: alert.budgetId,
              budgetName: alert.budgetName,
              percentage: alert.percentage,
              alertType: alert.type,
            },
          );

          totalAlerts++;
        }
      }

      this.logger.log(`Budget alerts check completed: ${totalAlerts} alerts sent`);
    } catch (error) {
      this.logger.error(`Budget alerts cron failed: ${error}`);
    }
  }
}
