import { Module } from '@nestjs/common';
import { SequelizeModule } from '@nestjs/sequelize';
import { TransactionsModule } from '../transactions/transactions.module.js';
import { Category } from '../categories/category.model.js';
import { CategorizationController } from './categorization.controller.js';
import { CategorizationService } from './categorization.service.js';

@Module({
  imports: [
    SequelizeModule.forFeature([Category]),
    TransactionsModule,
  ],
  controllers: [CategorizationController],
  providers: [CategorizationService],
})
export class CategorizationModule {}
