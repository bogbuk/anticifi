import { Module } from '@nestjs/common';
import { TransactionsModule } from '../transactions/transactions.module.js';
import { AccountsModule } from '../accounts/accounts.module.js';
import { ExportController } from './export.controller.js';
import { ExportService } from './export.service.js';

@Module({
  imports: [TransactionsModule, AccountsModule],
  controllers: [ExportController],
  providers: [ExportService],
})
export class ExportModule {}
