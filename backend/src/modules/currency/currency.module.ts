import { Module } from '@nestjs/common';
import { SequelizeModule } from '@nestjs/sequelize';
import { ScheduleModule } from '@nestjs/schedule';
import { CurrencyRate } from './currency-rate.model.js';
import { CurrencyService } from './currency.service.js';
import { CurrencyCron } from './currency.cron.js';
import { CurrencyController } from './currency.controller.js';

@Module({
  imports: [
    SequelizeModule.forFeature([CurrencyRate]),
    ScheduleModule.forRoot(),
  ],
  controllers: [CurrencyController],
  providers: [CurrencyService, CurrencyCron],
  exports: [CurrencyService],
})
export class CurrencyModule {}
