import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { Op, WhereOptions } from 'sequelize';
import { Notification, NotificationType } from './notification.model.js';
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
    private readonly eventsGateway: EventsGateway,
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
}
