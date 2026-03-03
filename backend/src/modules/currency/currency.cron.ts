import { Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { CurrencyService } from './currency.service.js';

@Injectable()
export class CurrencyCron {
  private readonly logger = new Logger(CurrencyCron.name);

  constructor(private readonly currencyService: CurrencyService) {}

  @Cron('0 6 * * *')
  async handleDailyRateUpdate(): Promise<void> {
    this.logger.log('Starting daily currency rate update');
    await this.currencyService.fetchAndStoreRates('USD');
    await this.currencyService.fetchAndStoreRates('EUR');
    await this.currencyService.fetchAndStoreRates('GBP');
    this.logger.log('Daily currency rate update completed');
  }
}
