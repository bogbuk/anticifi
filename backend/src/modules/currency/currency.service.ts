import { Injectable, Logger } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { Op } from 'sequelize';
import axios from 'axios';
import { CurrencyRate } from './currency-rate.model.js';

@Injectable()
export class CurrencyService {
  private readonly logger = new Logger(CurrencyService.name);

  constructor(
    @InjectModel(CurrencyRate)
    private readonly currencyRateModel: typeof CurrencyRate,
  ) {}

  async fetchAndStoreRates(base = 'USD'): Promise<void> {
    try {
      const response = await axios.get(
        `https://api.frankfurter.app/latest?from=${base}`,
      );
      const { rates, date } = response.data;

      const upserts = Object.entries(rates).map(([currency, rate]) =>
        this.currencyRateModel.upsert(
          {
            baseCurrency: base,
            targetCurrency: currency,
            rate: rate as number,
            date,
          } as any,
        ),
      );

      await Promise.all(upserts);
      this.logger.log(`Currency rates updated for ${base} on ${date}`);
    } catch (error) {
      this.logger.error('Failed to fetch currency rates', error);
    }
  }

  async getLatestRates(
    base: string,
    targets?: string[],
  ): Promise<CurrencyRate[]> {
    const where: any = { baseCurrency: base };

    if (targets && targets.length > 0) {
      where.targetCurrency = { [Op.in]: targets };
    }

    const latestDate = await this.currencyRateModel.max('date', {
      where: { baseCurrency: base },
    });

    if (!latestDate) {
      await this.fetchAndStoreRates(base);
      return this.getLatestRates(base, targets);
    }

    where.date = latestDate;

    return this.currencyRateModel.findAll({ where });
  }

  async convert(amount: number, from: string, to: string): Promise<number> {
    if (from === to) return amount;

    const rates = await this.getLatestRates(from, [to]);
    if (rates.length === 0) {
      return amount;
    }

    return Number(amount) * Number(rates[0].rate);
  }

  async convertAllToBase(
    accounts: Array<{ balance: number; currency: string }>,
    baseCurrency: string,
  ): Promise<number> {
    let total = 0;

    for (const account of accounts) {
      if (account.currency === baseCurrency) {
        total += Number(account.balance);
      } else {
        const converted = await this.convert(
          Number(account.balance),
          account.currency,
          baseCurrency,
        );
        total += converted;
      }
    }

    return total;
  }
}
