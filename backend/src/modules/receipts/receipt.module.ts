import { Module } from '@nestjs/common';
import { SequelizeModule } from '@nestjs/sequelize';
import { ReceiptScan } from './receipt.model.js';
import { ReceiptService } from './receipt.service.js';
import { ReceiptController } from './receipt.controller.js';
import { TransactionsModule } from '../transactions/transactions.module.js';
import { Account } from '../accounts/account.model.js';

@Module({
  imports: [
    SequelizeModule.forFeature([ReceiptScan, Account]),
    TransactionsModule,
  ],
  controllers: [ReceiptController],
  providers: [ReceiptService],
})
export class ReceiptsModule {}
