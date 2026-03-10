import { Module } from '@nestjs/common';
import { SequelizeModule } from '@nestjs/sequelize';
import { AdminController } from './admin.controller.js';
import { AdminService } from './admin.service.js';
import { AdminAnalyticsService } from './admin-analytics.service.js';
import { AuditLogService } from './audit-log.service.js';
import { AuditLog } from './audit-log.model.js';
import { User } from '../users/user.model.js';
import { Subscription } from '../subscriptions/subscription.model.js';
import { Account } from '../accounts/account.model.js';
import { Transaction } from '../transactions/transaction.model.js';
import { Budget } from '../budgets/budget.model.js';
import { Debt } from '../debts/debt.model.js';
import { ReceiptScan } from '../receipts/receipt.model.js';
import { Notification } from '../notifications/notification.model.js';

@Module({
  imports: [
    SequelizeModule.forFeature([
      User, Subscription, Account, Transaction,
      Budget, Debt, ReceiptScan, Notification, AuditLog,
    ]),
  ],
  controllers: [AdminController],
  providers: [AdminService, AdminAnalyticsService, AuditLogService],
})
export class AdminModule {}
