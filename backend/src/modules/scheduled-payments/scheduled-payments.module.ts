import { Module } from '@nestjs/common';
import { SequelizeModule } from '@nestjs/sequelize';
import { ScheduleModule } from '@nestjs/schedule';
import { ScheduledPayment } from './scheduled-payment.model.js';
import { ScheduledPaymentsController } from './scheduled-payments.controller.js';
import { ScheduledPaymentsService } from './scheduled-payments.service.js';
import { ScheduledPaymentsCron } from './scheduled-payments.cron.js';
import { TransactionsModule } from '../transactions/transactions.module.js';

@Module({
  imports: [
    SequelizeModule.forFeature([ScheduledPayment]),
    ScheduleModule.forRoot(),
    TransactionsModule,
  ],
  controllers: [ScheduledPaymentsController],
  providers: [ScheduledPaymentsService, ScheduledPaymentsCron],
  exports: [ScheduledPaymentsService],
})
export class ScheduledPaymentsModule {}
