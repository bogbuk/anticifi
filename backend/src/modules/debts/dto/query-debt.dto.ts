import { IsOptional, IsNumberString, IsBooleanString, IsEnum } from 'class-validator';
import { DebtType } from '../debt.model.js';

export class QueryDebtDto {
  @IsNumberString()
  @IsOptional()
  declare page?: string;

  @IsNumberString()
  @IsOptional()
  declare limit?: string;

  @IsBooleanString()
  @IsOptional()
  declare isActive?: string;

  @IsBooleanString()
  @IsOptional()
  declare isPaidOff?: string;

  @IsEnum(DebtType)
  @IsOptional()
  declare type?: DebtType;
}
