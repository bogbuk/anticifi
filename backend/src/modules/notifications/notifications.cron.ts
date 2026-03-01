import { Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { NotificationsService } from './notifications.service.js';
import { NotificationType } from './notification.model.js';
import { PredictionService } from '../predictions/prediction.service.js';
import { AccountsService } from '../accounts/accounts.service.js';
import { InjectModel } from '@nestjs/sequelize';
import { User } from '../users/user.model.js';

@Injectable()
export class NotificationsCron {
  private readonly logger = new Logger(NotificationsCron.name);

  constructor(
    @InjectModel(User)
    private readonly userModel: typeof User,
    private readonly notificationsService: NotificationsService,
    private readonly predictionService: PredictionService,
    private readonly accountsService: AccountsService,
  ) {}

  /** Daily check for low balance predictions — runs at 8:00 AM */
  @Cron('0 8 * * *')
  async handleLowBalanceAlerts(): Promise<void> {
    this.logger.log('Starting low balance prediction check...');

    try {
      const users = await this.userModel.findAll({
        attributes: ['id'],
      });

      let alertsSent = 0;

      for (const user of users) {
        try {
          const accounts = await this.accountsService.findAllByUserId(user.id);

          for (const account of accounts) {
            const forecast = await this.predictionService.getForecast(
              user.id,
              account.id,
              7,
            );

            const lowPrediction = forecast.predictions.find(
              (p) => p.predictedBalance < 100,
            );

            if (lowPrediction) {
              await this.notificationsService.createNotification(
                user.id,
                'Low Balance Alert',
                `Your account "${account.name}" is predicted to drop below $100 within the next 7 days. Predicted balance: $${lowPrediction.predictedBalance.toFixed(2)}.`,
                NotificationType.BALANCE_ALERT,
                {
                  accountId: account.id,
                  accountName: account.name,
                  predictedBalance: lowPrediction.predictedBalance,
                },
              );
              alertsSent++;
            }
          }
        } catch (error) {
          this.logger.error(
            `Failed to check predictions for user ${user.id}: ${error}`,
          );
        }
      }

      this.logger.log(
        `Low balance prediction check completed: ${alertsSent} alerts sent`,
      );
    } catch (error) {
      this.logger.error(`Low balance prediction cron failed: ${error}`);
    }
  }

  /** Cleanup old read notifications — runs daily at midnight */
  @Cron('0 0 * * *')
  async handleCleanup(): Promise<void> {
    this.logger.log('Starting notification cleanup...');
    try {
      const deleted = await this.notificationsService.deleteOld(90);
      this.logger.log(`Notification cleanup completed: ${deleted} deleted`);
    } catch (error) {
      this.logger.error(`Notification cleanup cron failed: ${error}`);
    }
  }
}
