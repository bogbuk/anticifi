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
    const bases = ['USD', 'EUR', 'GBP', 'MDL', 'RON', 'UAH', 'TRY', 'JPY', 'CNY', 'PLN', 'CZK', 'CHF'];
    for (const base of bases) {
      await this.currencyService.fetchAndStoreRates(base);
    }
    this.logger.log('Daily currency rate update completed');
  }
}
