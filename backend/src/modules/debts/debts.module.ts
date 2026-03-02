import { Module } from '@nestjs/common';
import { SequelizeModule } from '@nestjs/sequelize';
import { ScheduleModule } from '@nestjs/schedule';
import { Debt } from './debt.model.js';
import { DebtPayment } from './debt-payment.model.js';
import { DebtsController } from './debts.controller.js';
import { DebtsService } from './debts.service.js';
import { DebtsCron } from './debts.cron.js';
import { User } from '../users/user.model.js';

@Module({
  imports: [
    SequelizeModule.forFeature([Debt, DebtPayment, User]),
    ScheduleModule.forRoot(),
  ],
  controllers: [DebtsController],
  providers: [DebtsService, DebtsCron],
  exports: [DebtsService],
})
export class DebtsModule {}
