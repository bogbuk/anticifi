import { Module } from '@nestjs/common';
import { SequelizeModule } from '@nestjs/sequelize';
import { ImportJob } from './import-job.model.js';
import { Transaction } from '../transactions/transaction.model.js';
import { ImportController } from './import.controller.js';
import { ImportService } from './import.service.js';
import { TransactionsModule } from '../transactions/transactions.module.js';

@Module({
  imports: [
    SequelizeModule.forFeature([ImportJob, Transaction]),
    TransactionsModule,
  ],
  controllers: [ImportController],
  providers: [ImportService],
  exports: [ImportService],
})
export class ImportModule {}
