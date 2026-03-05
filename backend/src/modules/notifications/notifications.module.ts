import { Global, Module } from '@nestjs/common';
import { SequelizeModule } from '@nestjs/sequelize';
import { ConfigService } from '@nestjs/config';
import * as admin from 'firebase-admin';
import { Notification } from './notification.model.js';
import { NotificationsService } from './notifications.service.js';
import { NotificationsController } from './notifications.controller.js';
import { NotificationsCron } from './notifications.cron.js';
import { PredictionModule } from '../predictions/prediction.module.js';
import { AccountsModule } from '../accounts/accounts.module.js';
import { User } from '../users/user.model.js';

const FIREBASE_ADMIN = 'FIREBASE_ADMIN';

@Global()
@Module({
  imports: [
    SequelizeModule.forFeature([Notification, User]),
    PredictionModule,
    AccountsModule,
  ],
  controllers: [NotificationsController],
  providers: [
    NotificationsService,
    NotificationsCron,
    {
      provide: FIREBASE_ADMIN,
      useFactory: (configService: ConfigService) => {
        const projectId = configService.get<string>('FIREBASE_PROJECT_ID');
        if (!projectId) {
          return null;
        }

        if (admin.apps.length > 0) {
          return admin.apps[0]!;
        }

        const privateKey = configService.get<string>('FIREBASE_PRIVATE_KEY');
        if (privateKey) {
          return admin.initializeApp({
            credential: admin.credential.cert({
              projectId,
              clientEmail: configService.get<string>('FIREBASE_CLIENT_EMAIL'),
              privateKey: privateKey.replace(/\\n/g, '\n'),
            }),
          });
        }

        return admin.initializeApp({ projectId });
      },
      inject: [ConfigService],
    },
  ],
  exports: [NotificationsService],
})
export class NotificationsModule {}
