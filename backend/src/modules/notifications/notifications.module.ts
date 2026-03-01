import { Global, Module } from '@nestjs/common';
import { SequelizeModule } from '@nestjs/sequelize';
import { Notification } from './notification.model.js';
import { NotificationsService } from './notifications.service.js';
import { NotificationsController } from './notifications.controller.js';
import { NotificationsCron } from './notifications.cron.js';
import { PredictionModule } from '../predictions/prediction.module.js';
import { AccountsModule } from '../accounts/accounts.module.js';
import { User } from '../users/user.model.js';

@Global()
@Module({
  imports: [
    SequelizeModule.forFeature([Notification, User]),
    PredictionModule,
    AccountsModule,
  ],
  controllers: [NotificationsController],
  providers: [NotificationsService, NotificationsCron],
  exports: [NotificationsService],
})
export class NotificationsModule {}
