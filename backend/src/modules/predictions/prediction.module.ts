import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { PredictionController } from './prediction.controller.js';
import { PredictionService } from './prediction.service.js';
import { TransactionsModule } from '../transactions/transactions.module.js';
import { AccountsModule } from '../accounts/accounts.module.js';
import { ScheduledPaymentsModule } from '../scheduled-payments/scheduled-payments.module.js';

@Module({
  imports: [
    HttpModule.register({
      timeout: 30000,
      maxRedirects: 3,
    }),
    TransactionsModule,
    AccountsModule,
    ScheduledPaymentsModule,
  ],
  controllers: [PredictionController],
  providers: [PredictionService],
  exports: [PredictionService],
})
export class PredictionModule {}
