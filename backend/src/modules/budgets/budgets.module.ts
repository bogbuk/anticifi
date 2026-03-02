import { Module } from '@nestjs/common';
import { SequelizeModule } from '@nestjs/sequelize';
import { ScheduleModule } from '@nestjs/schedule';
import { Budget } from './budget.model.js';
import { BudgetsController } from './budgets.controller.js';
import { BudgetsService } from './budgets.service.js';
import { BudgetsCron } from './budgets.cron.js';
import { TransactionsModule } from '../transactions/transactions.module.js';
import { User } from '../users/user.model.js';

@Module({
  imports: [
    SequelizeModule.forFeature([Budget, User]),
    ScheduleModule.forRoot(),
    TransactionsModule,
  ],
  controllers: [BudgetsController],
  providers: [BudgetsService, BudgetsCron],
  exports: [BudgetsService],
})
export class BudgetsModule {}
