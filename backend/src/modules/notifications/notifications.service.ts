import { Inject, Injectable, Logger, NotFoundException, Optional } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { Op, WhereOptions } from 'sequelize';
import * as admin from 'firebase-admin';
import { Notification, NotificationType } from './notification.model.js';
import { User } from '../users/user.model.js';
import { EventsGateway } from '../events/events.gateway.js';
import { QueryNotificationDto } from './dto/query-notification.dto.js';

export interface PaginatedResult<T> {
  data: T[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);

  constructor(
    @InjectModel(Notification)
    private readonly notificationModel: typeof Notification,
    @InjectModel(User)
    private readonly userModel: typeof User,
    private readonly eventsGateway: EventsGateway,
    @Inject('FIREBASE_ADMIN') @Optional()
    private readonly firebaseApp: admin.app.App | null,
  ) {}

  async getNotifications(
    userId: string,
    query: QueryNotificationDto,
  ): Promise<PaginatedResult<Notification>> {
    const page = parseInt(query.page || '1', 10);
    const limit = parseInt(query.limit || '20', 10);
    const offset = (page - 1) * limit;

    const where: WhereOptions = { userId };

    if (query.type) {
      (where as any).type = query.type;
    }
    if (query.isRead !== undefined) {
      (where as any).isRead = query.isRead === 'true';
    }

    const { count, rows } = await this.notificationModel.findAndCountAll({
      where,
      order: [
        ['isRead', 'ASC'],
        ['createdAt', 'DESC'],
      ],
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

  async markAsRead(id: string, userId: string): Promise<Notification> {
    const notification = await this.notificationModel.findOne({
      where: { id, userId },
    });
    if (!notification) {
      throw new NotFoundException('Notification not found');
    }
    await notification.update({ isRead: true });

    this.eventsGateway.emitToUser(userId, 'notification:read', { id });

    return notification;
  }

  async markAllAsRead(userId: string): Promise<{ updated: number }> {
    const [updated] = await this.notificationModel.update(
      { isRead: true },
      { where: { userId, isRead: false } },
    );

    this.eventsGateway.emitToUser(userId, 'notification:all-read', {
      updated,
    });

    return { updated };
  }

  async createNotification(
    userId: string,
    title: string,
    body: string,
    type: NotificationType,
    metadata?: Record<string, unknown>,
  ): Promise<Notification> {
    const notification = await this.notificationModel.create({
      userId,
      title,
      body,
      type,
      metadata: metadata || null,
    } as any);

    this.eventsGateway.emitToUser(
      userId,
      'notification:new',
      notification.toJSON(),
    );

    this.sendPushNotification(userId, title, body, metadata).catch((err) => {
      this.logger.warn(`Failed to send push notification: ${err.message}`);
    });

    return notification;
  }

  async getUnreadCount(userId: string): Promise<{ count: number }> {
    const count = await this.notificationModel.count({
      where: { userId, isRead: false },
    });
    return { count };
  }

  async deleteOld(daysOld: number): Promise<number> {
    const cutoff = new Date();
    cutoff.setDate(cutoff.getDate() - daysOld);

    const deleted = await this.notificationModel.destroy({
      where: {
        createdAt: { [Op.lt]: cutoff },
        isRead: true,
      },
    });

    this.logger.log(`Deleted ${deleted} old notifications (older than ${daysOld} days)`);
    return deleted;
  }

  async registerFcmToken(userId: string, token: string): Promise<{ success: boolean }> {
    await this.userModel.update({ fcmToken: token }, { where: { id: userId } });
    this.logger.log(`FCM token registered for user ${userId}`);
    return { success: true };
  }

  async removeFcmToken(userId: string): Promise<{ success: boolean }> {
    await this.userModel.update({ fcmToken: null }, { where: { id: userId } });
    this.logger.log(`FCM token removed for user ${userId}`);
    return { success: true };
  }

  private async sendPushNotification(
    userId: string,
    title: string,
    body: string,
    metadata?: Record<string, unknown>,
  ): Promise<void> {
    if (!this.firebaseApp) {
      return;
    }

    const user = await this.userModel.findByPk(userId);
    if (!user?.fcmToken || !user.notificationsEnabled) {
      return;
    }

    const { count: unreadCount } = await this.getUnreadCount(userId);

    const message: admin.messaging.Message = {
      token: user.fcmToken,
      notification: { title, body },
      data: metadata
        ? Object.fromEntries(
            Object.entries(metadata).map(([k, v]) => [k, String(v)]),
          )
        : undefined,
      android: {
        priority: 'high',
        notification: { channelId: 'anticifi_notifications' },
      },
      apns: {
        payload: { aps: { sound: 'default', badge: unreadCount } },
      },
    };

    try {
      await admin.messaging(this.firebaseApp).send(message);
      this.logger.debug(`Push notification sent to user ${userId}`);
    } catch (err: any) {
      if (
        err.code === 'messaging/registration-token-not-registered' ||
        err.code === 'messaging/invalid-registration-token'
      ) {
        await this.userModel.update({ fcmToken: null }, { where: { id: userId } });
        this.logger.warn(`Removed invalid FCM token for user ${userId}`);
      }
      throw err;
    }
  }
}
