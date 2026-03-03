import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { CurrencyService } from './currency.service.js';

@Controller('currencies')
@UseGuards(AuthGuard('jwt'))
export class CurrencyController {
  constructor(private readonly currencyService: CurrencyService) {}

  @Get('rates')
  async getRates(
    @Query('base') base?: string,
    @Query('targets') targets?: string,
  ) {
    const baseCurrency = base || 'USD';
    const targetList = targets ? targets.split(',') : undefined;
    const rates = await this.currencyService.getLatestRates(
      baseCurrency,
      targetList,
    );
    return {
      base: baseCurrency,
      rates: rates.map((r) => ({
        currency: r.targetCurrency,
        rate: Number(r.rate),
        date: r.date,
      })),
    };
  }

  @Get('convert')
  async convert(
    @Query('amount') amount: string,
    @Query('from') from: string,
    @Query('to') to: string,
  ) {
    const result = await this.currencyService.convert(
      parseFloat(amount),
      from,
      to,
    );
    return {
      amount: parseFloat(amount),
      from,
      to,
      result,
    };
  }
}
