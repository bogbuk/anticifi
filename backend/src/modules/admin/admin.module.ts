import { Module } from '@nestjs/common';
import { SequelizeModule } from '@nestjs/sequelize';
import { AdminController } from './admin.controller.js';
import { AdminService } from './admin.service.js';
import { User } from '../users/user.model.js';
import { Subscription } from '../subscriptions/subscription.model.js';
import { Account } from '../accounts/account.model.js';
import { Transaction } from '../transactions/transaction.model.js';

@Module({
  imports: [
    SequelizeModule.forFeature([User, Subscription, Account, Transaction]),
  ],
  controllers: [AdminController],
  providers: [AdminService],
})
export class AdminModule {}
