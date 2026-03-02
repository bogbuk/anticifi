import { Module } from '@nestjs/common';
import { SequelizeModule } from '@nestjs/sequelize';
import { PlaidItem } from './plaid-item.model.js';
import { Account } from '../accounts/account.model.js';
import { Transaction } from '../transactions/transaction.model.js';
import { PlaidService } from './plaid.service.js';
import { PlaidSyncService } from './plaid-sync.service.js';
import { PlaidEncryptionService } from './plaid-encryption.service.js';
import { PlaidController } from './plaid.controller.js';

@Module({
  imports: [SequelizeModule.forFeature([PlaidItem, Account, Transaction])],
  controllers: [PlaidController],
  providers: [PlaidService, PlaidSyncService, PlaidEncryptionService],
  exports: [PlaidService, PlaidSyncService],
})
export class PlaidModule {}
