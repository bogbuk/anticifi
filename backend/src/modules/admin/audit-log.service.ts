import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { AuditLog } from './audit-log.model.js';
import { User } from '../users/user.model.js';

@Injectable()
export class AuditLogService {
  constructor(@InjectModel(AuditLog) private readonly auditLogModel: typeof AuditLog) {}

  async log(params: {
    adminId: string;
    action: string;
    targetType?: string;
    targetId?: string;
    details?: Record<string, any>;
    ipAddress?: string;
  }) {
    return this.auditLogModel.create(params as any);
  }

  async getLogs(query: { page?: number; limit?: number; action?: string; adminId?: string }) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 50;
    const offset = (page - 1) * limit;
    const where: any = {};
    if (query.action) where.action = query.action;
    if (query.adminId) where.adminId = query.adminId;

    const { rows, count } = await this.auditLogModel.findAndCountAll({
      where,
      include: [{ model: User, attributes: ['id', 'email', 'firstName', 'lastName'] }],
      order: [['createdAt', 'DESC']],
      limit,
      offset,
    });

    return { data: rows, total: count, page, limit, totalPages: Math.ceil(count / limit) };
  }
}